import { supabaseAdmin } from './src/config/supabase.js';

async function test() {
  const { data, error } = await supabaseAdmin.from('teacher_schedule_view').select('booking_id');
  console.log(data);
}
test();
