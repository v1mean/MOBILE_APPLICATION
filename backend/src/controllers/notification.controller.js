import { supabaseAdmin } from "../config/supabase.js";

// ── GET /api/notifications ─────────────────────────────────────────────────
export async function getNotifications(req, res) {
  try {
    const userId = req.user.id;

    const { data, error } = await supabaseAdmin
      .from("notifications")
      .select("*")
      .eq("user_id", userId)
      .order("created_at", { ascending: false })
      .limit(50);

    if (error) {
      console.error("[getNotifications] error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true, notifications: data || [] });
  } catch (err) {
    console.error("[getNotifications] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Failed to fetch notifications." });
  }
}

// ── PATCH /api/notifications/:id/read ──────────────────────────────────────
export async function markNotificationRead(req, res) {
  try {
    const userId = req.user.id;
    const { id } = req.params;

    const { error } = await supabaseAdmin
      .from("notifications")
      .update({ is_read: true })
      .eq("id", id)
      .eq("user_id", userId);

    if (error) {
      console.error("[markNotificationRead] error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error("[markNotificationRead] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Failed to update notification." });
  }
}

// ── PATCH /api/notifications/read-all ──────────────────────────────────────
export async function markAllNotificationsRead(req, res) {
  try {
    const userId = req.user.id;

    const { error } = await supabaseAdmin
      .from("notifications")
      .update({ is_read: true })
      .eq("user_id", userId)
      .eq("is_read", false);

    if (error) {
      console.error("[markAllNotificationsRead] error:", error.message);
      return res.status(500).json({ success: false, message: error.message });
    }

    return res.status(200).json({ success: true });
  } catch (err) {
    console.error("[markAllNotificationsRead] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Failed to update notifications." });
  }
}
