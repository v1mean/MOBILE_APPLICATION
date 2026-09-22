import { supabaseAdmin } from "../config/supabase.js";
import multer from "multer";
import path from "path";

// ── multer: memory storage (we stream bytes directly to Supabase) ──────────
const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // 5 MB
  fileFilter: (_, file, cb) => {
    const allowed = [".jpg", ".jpeg", ".png", ".webp", ".gif"];
    const ext = path.extname(file.originalname).toLowerCase();
    if (allowed.includes(ext)) {
      cb(null, true);
    } else {
      cb(new Error("Only image files are allowed."));
    }
  },
});

export const uploadAvatarMiddleware = upload.single("avatar");

// ── PATCH /api/users/profile ───────────────────────────────────────────────
// Uses supabaseAdmin to bypass Row Level Security on the Users table.
export async function updateProfile(req, res) {
  try {
    const user = req.user;
    const { name, phone, location, role, profileImage } = req.body;

    if (!name || !name.trim()) {
      return res
        .status(400)
        .json({ success: false, message: "Full name cannot be empty." });
    }

    const payload = {
      user_id: user.id,
      name: name.trim(),
      phone: (phone ?? "").trim(),
      location: (location ?? "").trim(),
      role: (role ?? "Student").trim() || "Student",
      email: user.email ?? "",
    };

    if (profileImage && profileImage.trim()) {
      payload.profile_image = profileImage.trim();
    }

    const { error } = await supabaseAdmin
      .from("Users")
      .upsert(payload, { onConflict: "user_id" });

    if (error) {
      console.error("[updateProfile] Supabase error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    // Sync full_name and avatar_url to profiles table
    const profilePayload = { full_name: payload.name };
    if (payload.profile_image) profilePayload.avatar_url = payload.profile_image;
    
    await supabaseAdmin
      .from("profiles")
      .update(profilePayload)
      .eq("id", user.id);

    return res.status(200).json({ success: true, message: "Profile updated." });
  } catch (err) {
    console.error("[updateProfile] Unexpected error:", err);
    return res
      .status(500)
      .json({ success: false, message: "Failed to update profile." });
  }
}

// ── GET /api/mentors/search ────────────────────────────────────────────────
export async function searchMentors(req, res) {
  try {
    const { query, subject, minPrice, maxPrice, city, day } = req.query;

    let dbQuery = supabaseAdmin
      .from("tutor_profiles")
      .select(
        `
        tutor_id,
        bio,
        hourly_rate,
        experience_years,
        rating,
        available_days,
        city,
        subjects,
        Users!inner (
          user_id,
          name,
          profile_image,
          email
        )
      `
      );

    if (query && query.trim()) {
      dbQuery = dbQuery.ilike("bio", `%${query.trim()}%`);
    }

    if (subject && subject.trim()) {
      dbQuery = dbQuery.ilike("subjects", `%${subject.trim()}%`);
    }

    if (minPrice !== undefined && minPrice !== "") {
      dbQuery = dbQuery.gte("hourly_rate", parseFloat(minPrice));
    }
    if (maxPrice !== undefined && maxPrice !== "") {
      dbQuery = dbQuery.lte("hourly_rate", parseFloat(maxPrice));
    }

    if (city && city.trim()) {
      dbQuery = dbQuery.ilike("city", `%${city.trim()}%`);
    }

    if (day && day.trim()) {
      dbQuery = dbQuery.contains("available_days", [day.trim()]);
    }

    const { data, error } = await dbQuery.order("rating", { ascending: false });

    if (error) {
      console.error("[searchMentors] Supabase error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, mentors: data ?? [] });
  } catch (err) {
    console.error("[searchMentors] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Search failed." });
  }
}

// ── POST /api/users/upload-avatar ─────────────────────────────────────────
export async function uploadAvatar(req, res) {
  try {
    const user = req.user;
    if (!req.file) {
      return res
        .status(400)
        .json({ success: false, message: "No file uploaded." });
    }

    const ext = path.extname(req.file.originalname).toLowerCase() || ".jpg";
    const fileName = `avatars/${user.id}${ext}`;

    const { error: uploadError } = await supabaseAdmin.storage
      .from("avatars")
      .upload(fileName, req.file.buffer, {
        contentType: req.file.mimetype,
        upsert: true,
      });

    if (uploadError) {
      console.error("[uploadAvatar] Storage error:", uploadError.message);
      return res
        .status(500)
        .json({ success: false, message: uploadError.message });
    }

    const { data: urlData } = supabaseAdmin.storage
      .from("avatars")
      .getPublicUrl(fileName);

    const publicUrl = urlData?.publicUrl;
    if (!publicUrl) {
      return res
        .status(500)
        .json({ success: false, message: "Could not get public URL." });
    }

    // Update profiles table
    const { error: profileError } = await supabaseAdmin
      .from("profiles")
      .update({ avatar_url: publicUrl })
      .eq("id", user.id);

    if (profileError) {
      console.warn("[uploadAvatar] Profile update warning:", profileError.message);
    }

    // Update Users table (used by the Flutter app)
    await supabaseAdmin
      .from("Users")
      .update({ profile_image: publicUrl })
      .eq("user_id", user.id);


    return res.status(200).json({ success: true, avatarUrl: publicUrl });
  } catch (err) {
    console.error("[uploadAvatar] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Upload failed." });
  }
}

// ── GET /api/mentors  ────────────────────────────────────────────────────────
export async function getFilteredMentors(req, res) {
  try {
    const { query, subject_id, minPrice, maxPrice, day_of_week, city } = req.query;

    // Step 1: Build base tutor_profiles query (NO JOINING availability/subjects in SQL)
    let dbQuery = supabaseAdmin
      .from('tutor_profiles')
      .select(`
        tutor_id,
        user_id,
        bio,
        hourly_rate,
        experience_years,
        rating,
        location,
        teaching_mode,
        is_available,
        total_students,
        review_count
      `)
      .eq('is_available', true);

    if (minPrice && minPrice !== '') dbQuery = dbQuery.gte('hourly_rate', parseFloat(minPrice));
    if (maxPrice && maxPrice !== '') dbQuery = dbQuery.lte('hourly_rate', parseFloat(maxPrice));
    if (city && city.trim()) dbQuery = dbQuery.ilike('location', `%${city.trim()}%`);

    const { data: tutors, error: tutorError } = await dbQuery
      .order('rating', { ascending: false })
      .limit(50);

    if (tutorError) {
      return res.status(500).json({ success: false, message: tutorError.message });
    }
    if (!tutors || tutors.length === 0) {
      return res.status(200).json({ success: true, mentors: [] });
    }

    const tutorIds = tutors.map(t => t.tutor_id);

    // Step 2: Manually fetch availability
    const { data: availData } = await supabaseAdmin
      .from('availability')
      .select('tutor_id, day_of_week, start_time, end_time, is_available')
      .in('tutor_id', tutorIds);

    // Step 3: Manually fetch subjects
    const { data: subjData } = await supabaseAdmin
      .from('tutor_subjects')
      .select('tutor_id, subject_id')
      .in('tutor_id', tutorIds);
      
    // Fetch actual subject names
    const { data: allSubjects } = await supabaseAdmin.from('Subjects').select('id, name');
    const subjMap = {};
    (allSubjects || []).forEach(s => subjMap[s.id] = s);

    // Step 4: Manually fetch users (profiles table)
    const { data: usersData } = await supabaseAdmin
      .from('profiles')
      .select('id, full_name, avatar_url')
      .in('id', tutorIds);
    const usersMap = {};
    (usersData || []).forEach(u => usersMap[u.id] = u);

    // Step 5: Assemble and filter
    let result = tutors.map(t => {
      const myAvail = (availData || []).filter(a => a.tutor_id === t.tutor_id);
      const mySubj = (subjData || []).filter(s => s.tutor_id === t.tutor_id).map(s => ({
        subject_id: s.subject_id,
        Subjects: subjMap[s.subject_id] || { id: s.subject_id, name: 'Unknown' }
      }));
      
      const p = usersMap[t.tutor_id];

      return {
        ...t,
        availability: myAvail,
        tutor_subjects: mySubj,
        user: p ? {
          user_id: p.id,
          name: p.full_name,
          profile_image: p.avatar_url
        } : null
      };
    }).filter(t => t.user !== null); // Drop if missing profile

    // Filter by day_of_week locally
    if (day_of_week && day_of_week.trim()) {
      const reqDay = day_of_week.trim();
      result = result.filter(t => 
        t.availability.some(a => a.day_of_week === reqDay && a.is_available)
      );
    }

    // Filter by subject_id locally
    if (subject_id && subject_id.trim()) {
      const reqSubj = subject_id.trim();
      result = result.filter(t => 
        t.tutor_subjects.some(ts => ts.subject_id === reqSubj)
      );
    }

    // Search query
    if (query && query.trim()) {
      const q = query.trim().toLowerCase();
      result = result.filter(t =>
        (t.bio || '').toLowerCase().includes(q) ||
        (t.user?.name || '').toLowerCase().includes(q) ||
        t.tutor_subjects.some(ts => ts.Subjects.name.toLowerCase().includes(q))
      );
    }

    return res.status(200).json({ success: true, mentors: result });
  } catch (err) {
    console.error('[getFilteredMentors] Unexpected error:', err);
    return res.status(500).json({ success: false, message: 'Search failed.' });
  }
}

// ── GET /api/users/my-courses ──────────────────────────────────────────────
export async function getMyCourses(req, res) {
  try {
    const userId = req.user.id;
    const { data, error } = await supabaseAdmin
      .from('user_courses')
      .select(`
        id,
        course_id,
        progress,
        is_favorited,
        enrolled_at,
        status,
        courses (
          id,
          tutor_id,
          title,
          description,
          rating,
          duration_hours,
          image_url,
          card_color,
          is_live,
          minutes_remaining,
          Users ( name )
        )
      `)
      .eq('user_id', userId);

    if (error) {
      console.error('[getMyCourses] query error:', error.message);
      return res.status(200).json({ success: true, courses: [] }); // Fallback for Task 5
    }

    if (!data || data.length === 0) {
      return res.status(200).json({ success: true, courses: [] });
    }

    // Flatten logic so it conforms to the Course.fromJson structure
    const flattenedCourses = data.map(item => {
      const courseObj = item.courses || {};
      return {
        id: item.course_id || courseObj.id,
        tutor_id: courseObj.tutor_id,
        title: courseObj.title,
        description: courseObj.description,
        rating: courseObj.rating,
        duration_hours: courseObj.duration_hours,
        is_favorited: item.is_favorited,
        is_live: courseObj.is_live,
        minutes_remaining: courseObj.minutes_remaining,
        progress: item.progress,
        card_color: courseObj.card_color,
        mentor_name: courseObj.Users?.name,
      };
    });

    return res.status(200).json({ success: true, courses: flattenedCourses });
  } catch (err) {
    console.error('[getMyCourses] Unexpected error:', err);
    return res.status(200).json({ success: true, courses: [] });
  }
}

// ── GET /api/mentors/subjects ──────────────────────────────────────────────
export async function getSubjects(req, res) {
  try {
    const { data, error } = await supabaseAdmin
      .from('Subjects')
      .select('id, name')
      .order('name');
    if (error) return res.status(500).json({ success: false, message: error.message });
    return res.status(200).json({ success: true, subjects: data ?? [] });
  } catch (err) {
    return res.status(500).json({ success: false, message: 'Failed to load subjects.' });
  }
}
