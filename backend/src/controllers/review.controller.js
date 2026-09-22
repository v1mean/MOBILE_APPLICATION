import { supabaseAdmin } from "../config/supabase.js";

// ── POST /api/reviews ──────────────────────────────────────────────
export async function createReview(req, res) {
  try {
    const studentId = req.user.id;
    const { mentor_id, rating, comment } = req.body;

    if (!mentor_id || !rating) {
      return res.status(400).json({ success: false, message: "Missing mentor_id or rating" });
    }

    const { data: review, error } = await supabaseAdmin
      .from('reviews')
      .insert({
        student_id: studentId,
        tutor_id: mentor_id,
        rating: rating,
        comment: comment || null,
      })
      .select()
      .single();

    if (error) {
      console.error("[createReview] insert error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }
    
    // Auto-update rating in tutor_profiles
    // Note: User says "the SQL trigger handles the math", so we might not need to manually calculate it,
    // but just in case, we'll let the trigger do its job.

    return res.status(200).json({ success: true, review });
  } catch (err) {
    console.error("[createReview] error:", err);
    return res.status(500).json({ success: false, message: "Review submission failed." });
  }
}

// ── GET /api/reviews/mentor/:id ────────────────────────────────────
export async function getMentorReviews(req, res) {
  try {
    const mentorId = req.params.id;
    
    const { data: reviews, error } = await supabaseAdmin
      .from('reviews')
      .select('id, rating, comment, created_at, profiles!student_id(full_name, avatar_url)')
      .eq('tutor_id', mentorId)
      .order('created_at', { ascending: false })
      .limit(10);

    if (error) {
      console.error("[getMentorReviews] query error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, reviews });
  } catch (err) {
    console.error("[getMentorReviews] error:", err);
    return res.status(500).json({ success: false, message: "Failed to fetch reviews." });
  }
}
