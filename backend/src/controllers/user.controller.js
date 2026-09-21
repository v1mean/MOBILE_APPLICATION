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

    // Step 1: Build tutor_profiles query
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
        review_count,
        availability!inner(day_of_week, start_time, end_time, is_available),
        tutor_subjects(subject_id, Subjects(id, name))
      `)
      .eq('is_available', true);

    // Price filters
    if (minPrice && minPrice !== '') dbQuery = dbQuery.gte('hourly_rate', parseFloat(minPrice));
    if (maxPrice && maxPrice !== '') dbQuery = dbQuery.lte('hourly_rate', parseFloat(maxPrice));

    // Location filter
    if (city && city.trim()) dbQuery = dbQuery.ilike('location', `%${city.trim()}%`);

    // Availability filter
    if (day_of_week && day_of_week.trim()) {
      dbQuery = dbQuery
        .eq('availability.day_of_week', day_of_week.trim())
        .eq('availability.is_available', true);
    }

    const { data: tutors, error: tutorError } = await dbQuery
      .order('rating', { ascending: false })
      .limit(50);

    if (tutorError) {
      console.error('[getFilteredMentors] tutor query error:', tutorError.message);
      return res.status(500).json({ success: false, message: tutorError.message });
    }

    if (!tutors || tutors.length === 0) {
      return res.status(200).json({ success: true, mentors: [] });
    }

    // Step 2: Filter by subject_id if provided
    let filteredTutors = tutors;
    if (subject_id && subject_id.trim()) {
      filteredTutors = tutors.filter(t =>
        (t.tutor_subjects || []).some(ts => ts.subject_id === subject_id.trim())
      );
    }

    // Step 3: Manual join with Users table
    const userIds = [...new Set(filteredTutors.map(t => t.user_id))];
    const { data: users, error: usersError } = await supabaseAdmin
      .from('Users')
      .select('user_id, name, email, profile_image')
      .in('user_id', userIds);

    if (usersError) {
      console.warn('[getFilteredMentors] Users join warning:', usersError.message);
    }

    const usersMap = {};
    (users || []).forEach(u => { usersMap[u.user_id] = u; });

    // Step 4: Keyword search after join
    let result = filteredTutors
      .map(t => ({
        ...t,
        user: usersMap[t.user_id] || null,
      }))
      .filter(t => t.user !== null);

    if (query && query.trim()) {
      const q = query.trim().toLowerCase();
      result = result.filter(t =>
        (t.bio || '').toLowerCase().includes(q) ||
        (t.user?.name || '').toLowerCase().includes(q) ||
        (t.tutor_subjects || []).some(ts =>
          (ts.Subjects?.name || '').toLowerCase().includes(q)
        )
      );
    }

    return res.status(200).json({ success: true, mentors: result });
  } catch (err) {
    console.error('[getFilteredMentors] Unexpected error:', err);
    return res.status(500).json({ success: false, message: 'Search failed.' });
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
