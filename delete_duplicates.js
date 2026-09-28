import { supabaseAdmin } from './backend/src/config/supabase.js';

async function deduplicateBookings() {
  console.log("Fetching all bookings...");
  const { data: bookings, error } = await supabaseAdmin
    .from('bookings')
    .select('id, student_id, tutor_id, booking_date, start_time, created_at')
    .order('created_at', { ascending: true });

  if (error) {
    console.error("Error fetching bookings:", error);
    return;
  }

  const seen = new Set();
  const toDelete = [];

  for (const booking of bookings) {
    // Generate a unique signature for this exact student + tutor + time
    // We normalize start_time by trimming milliseconds if they exist, or just use the exact start_time
    const sig = `${booking.student_id}_${booking.tutor_id}_${booking.booking_date}_${booking.start_time}`;
    
    if (seen.has(sig)) {
      toDelete.push(booking.id);
    } else {
      seen.add(sig);
    }
  }

  console.log(`Found ${bookings.length} total bookings.`);
  console.log(`Found ${toDelete.length} duplicate bookings to remove.`);

  if (toDelete.length > 0) {
    console.log("Deleting duplicates...");
    // Supabase allows deleting by an array of IDs using .in()
    // We do it in batches to be safe
    const batchSize = 100;
    for (let i = 0; i < toDelete.length; i += batchSize) {
      const batch = toDelete.slice(i, i + batchSize);
      const { error: deleteError } = await supabaseAdmin
        .from('bookings')
        .delete()
        .in('id', batch);
        
      if (deleteError) {
        console.error("Error deleting batch:", deleteError);
      } else {
        console.log(`Deleted batch of ${batch.length} duplicates.`);
      }
    }
    console.log("Deduplication complete!");
  } else {
    console.log("No duplicates found. Database is clean.");
  }
}

deduplicateBookings();
