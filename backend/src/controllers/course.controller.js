import { supabaseAdmin } from "../config/supabase.js";
import multer from "multer";
import path from "path";

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 100 * 1024 * 1024 }, // 100 MB max
});

export const uploadCourseMiddleware = upload.fields([
  { name: 'thumbnail', maxCount: 1 },
  { name: 'material', maxCount: 1 },
  { name: 'video', maxCount: 1 },
]);

export async function uploadCourse(req, res) {
  try {
    const user = req.user;
    const { title, description, category } = req.body;

    if (!title || !title.trim()) {
      return res.status(400).json({ success: false, message: "Title is required." });
    }

    // Task 4: Backend Integrity - Block Double-Tap Duplicates
    const oneMinuteAgo = new Date(Date.now() - 60000).toISOString();
    const { data: recentCourses } = await supabaseAdmin
      .from('courses')
      .select('id')
      .eq('tutor_id', user.id)
      .eq('title', title.trim())
      .gte('created_at', oneMinuteAgo)
      .limit(1);

    if (recentCourses && recentCourses.length > 0) {
      return res.status(429).json({ success: false, message: "Duplicate course creation detected. Please wait." });
    }

    const files = req.files || {};
    const uploadedUrls = {};

    for (const field of ['thumbnail', 'material', 'video']) {
      if (files[field] && files[field].length > 0) {
        const file = files[field][0];
        const ext = path.extname(file.originalname);
        const fileName = `${user.id}_${Date.now()}_${field}${ext}`;
        
        const { error } = await supabaseAdmin.storage
          .from("courses")
          .upload(fileName, file.buffer, { contentType: file.mimetype });

        if (error) {
          console.error(`[uploadCourse] Storage error for ${field}:`, error.message);
          throw error;
        }
        
        const { data: publicData } = supabaseAdmin.storage
          .from("courses")
          .getPublicUrl(fileName);
        
        uploadedUrls[field] = publicData.publicUrl;
      }
    }

    // Task 1: Map category to subject_id
    let subjectId = null;
    if (category) {
      const { data: subjectData } = await supabaseAdmin
        .from('Subjects')
        .select('id')
        .ilike('name', category.trim())
        .limit(1);
      if (subjectData && subjectData.length > 0) {
        subjectId = subjectData[0].id;
        // Automatically link this tutor to this subject so they appear in Mentor searches!
        await supabaseAdmin.from('tutor_subjects').upsert({
          tutor_id: user.id,
          subject_id: subjectId
        }, { onConflict: 'tutor_id, subject_id' }).select();
      }
    }

    let payload = {
      tutor_id: user.id,
      title: title.trim(),
      description: description ? description.trim() : "",
      image_url: uploadedUrls.thumbnail || null,
      video_url: uploadedUrls.video || null,
      material_url: uploadedUrls.material || null,
      rating: 5.0,
      duration_hours: 1,
      card_color: 'blue',
      is_live: false,
      is_featured: true,
      category: category || 'General',
      level: 'Beginner',
      price: 0,
      rating_count: 0
    };

    // Try inserting with all columns
    let { data, error } = await supabaseAdmin
      .from("courses")
      .insert(payload)
      .select();

    // If it fails due to missing columns, fallback by removing them
    if (error && (error.message?.includes('video_url') || error.message?.includes('material_url') || error.message?.includes('column') || error.code === 'PGRST204' || error.code === '42703')) {
        console.warn('Columns video_url or material_url missing from courses table. Falling back to omitting them.');
        delete payload.video_url;
        delete payload.material_url;
        const fallback = await supabaseAdmin.from("courses").insert(payload).select();
        data = fallback.data;
        error = fallback.error;
    }

    if (error) {
      console.error("[uploadCourse] DB Insert error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, course: data[0] });

  } catch (err) {
    console.error("[uploadCourse] Error:", err);
    return res.status(500).json({ success: false, message: "Failed to upload course." });
  }
}
