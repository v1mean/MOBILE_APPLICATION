import { supabaseAdmin } from "../config/supabase.js";

export async function createNotification({ userId, type, title, body, data }) {
  const { error } = await supabaseAdmin.from("notifications").insert({
    user_id: userId,
    type,
    title,
    body: body || null,
    data: data || null,
  });

  if (error) {
    console.error(`[createNotification] failed to insert (${type}):`, error.message);
  }
}
