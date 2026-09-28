const fs = require('fs');
let file = 'backend/src/controllers/booking.controller.js';
let content = fs.readFileSync(file, 'utf8');

const targetStr = `    if (!tutor_id) {
      return res.status(400).json({ success: false, message: "Missing tutor_id" });
    }`;

const replaceStr = `    if (!tutor_id) {
      return res.status(400).json({ success: false, message: "Missing tutor_id" });
    }

    // Check if the student already booked this exact tutor and time
    const bDate = req.body.booking_date || start_time?.split('T')[0] || new Date().toISOString().split('T')[0];
    let query = supabaseAdmin
      .from('bookings')
      .select('id')
      .eq('student_id', studentId)
      .eq('tutor_id', tutor_id)
      .eq('booking_date', bDate)
      .neq('status', 'canceled');
      
    if (start_time) {
      query = query.eq('start_time', start_time);
    }
    
    const { data: existingBookings } = await query;
    if (existingBookings && existingBookings.length > 0) {
      return res.status(400).json({ success: false, message: "You have already booked this slot!" });
    }`;

content = content.replace(targetStr, replaceStr);
fs.writeFileSync(file, content);
