import { supabaseAdmin } from "../config/supabase.js";

// ── POST /api/bookings/create ──────────────────────────────────────────────
export async function createBooking(req, res) {
  try {
    const studentId = req.user.id;
    const { tutor_id, start_time, end_time, hourly_rate, total_price, course_id } = req.body;

    if (!tutor_id) {
      return res.status(400).json({ success: false, message: "Missing tutor_id" });
    }

    // 1. Create booking row
    const { data: booking, error: bookingError } = await supabaseAdmin
      .from('bookings')
      .insert({
        student_id: studentId,
        tutor_id,
        course_id: course_id || null,
        start_time: start_time || new Date().toISOString(),
        end_time: end_time || new Date(Date.now() + 3600000).toISOString(),
        hourly_rate: hourly_rate || 0,
        total_price: total_price || 0,
        status: 'pending',
        booking_date: req.body.booking_date || start_time?.split('T')[0] || new Date().toISOString().split('T')[0],
        time_slot: req.body.time_slot || null,
      })
      .select()
      .single();

    if (bookingError) {
      console.error("[createBooking] bookings error:", bookingError.message);
      return res.status(500).json({ success: false, message: bookingError.message });
    }

    // 2. If course_id is provided, also add to user_courses
    if (course_id) {
      await supabaseAdmin.from('user_courses').insert({
        user_id: studentId, course_id, progress: 0, status: 'ongoing',
      });
    } else {
      // Find a course that belongs to this tutor to add to user_courses
      const { data: tutorCourses } = await supabaseAdmin
        .from('courses')
        .select('id, title')
        .eq('tutor_id', tutor_id);
        
      if (tutorCourses && tutorCourses.length > 0) {
        const { data: userEnrolled } = await supabaseAdmin
           .from('user_courses')
           .select('course_id')
           .eq('user_id', studentId);
        
        const enrolledIds = (userEnrolled || []).map(u => u.course_id);
        const availableCourses = tutorCourses.filter(c => !enrolledIds.includes(c.id));
        
        if (availableCourses.length > 0) {
           await supabaseAdmin.from('user_courses').insert({
              user_id: studentId, course_id: availableCourses[0].id, progress: 0, status: 'ongoing'
           });
        } else {
           // User enrolled in all tutor's courses, create a new 1-on-1 session course
           const { data: newCourse } = await supabaseAdmin.from('courses').insert({
              tutor_id,
              title: `Private Session: ${tutorCourses[0].title}`,
              description: '1-on-1 Booking.',
              rating: 5.0,
              duration_hours: 1,
              card_color: 'blue',
              is_featured: false
           }).select('id').single();
           
           if (newCourse) {
               await supabaseAdmin.from('user_courses').insert({
                  user_id: studentId, course_id: newCourse.id, progress: 0, status: 'ongoing'
               });
           }
        }
      } else {
         // Tutor has NO courses in DB, create one automatically
         const { data: newCourse } = await supabaseAdmin.from('courses').insert({
            tutor_id,
            title: `1-on-1 Session with Mentor`,
            description: 'Private booking.',
            rating: 5.0,
            duration_hours: 1,
            card_color: 'blue',
            is_featured: false
         }).select('id').single();
         
         if (newCourse) {
             await supabaseAdmin.from('user_courses').insert({
                user_id: studentId, course_id: newCourse.id, progress: 0, status: 'ongoing'
             });
          }
      }
    }

    return res.status(200).json({ success: true, booking });
  } catch (err) {
    console.error("[createBooking] Unexpected error:", err);
    return res.status(500).json({ success: false, message: "Booking failed." });
  }
}
  // ── GET /api/bookings/teachers ─────────────────────────────────────────────

export async function getTeacherBookings(req, res) {
  try {
    const teacherId = req.user.id;

    const { data: bookings, error: bookingsError } = await supabaseAdmin
      .from('bookings')
      .select('*')
      .eq('tutor_id', teacherId)
      .order('start_time', { ascending: true });

    if (bookingsError) {
      console.error(
        '[getTeacherBookings] bookings error:',
        bookingsError.message
      );

      return res.status(500).json({
        success: false,
        message: bookingsError.message,
      });
    }

    const studentIds = [
      ...new Set(
        (bookings || [])
          .map((booking) => booking.student_id)
          .filter(Boolean)
      ),
    ];

    let students = [];

    if (studentIds.length > 0) {
      const { data: studentProfiles, error: studentsError } =
        await supabaseAdmin
          .from('profiles')
          .select('id, full_name, avatar_url, phone, city')
          .in('id', studentIds);

      if (studentsError) {
        console.error(
          '[getTeacherBookings] students error:',
          studentsError.message
        );
      } else {
        students = studentProfiles || [];
      }
    }

    const result = (bookings || []).map((booking) => {
      const student = students.find(
        (item) => item.id === booking.student_id
      );

      return {
        id: booking.id,
        student_id: booking.student_id,
        student_name: student?.full_name || 'Unknown Student',
        student_avatar: student?.avatar_url || '',
        student_phone: student?.phone || '',
        student_city: student?.city || '',
        tutor_id: booking.tutor_id,
        course_id: booking.course_id,
        start_time: booking.start_time,
        end_time: booking.end_time,
        hourly_rate: booking.hourly_rate,
        total_price: booking.total_price,
        status: booking.status,
        created_at: booking.created_at,
      };
    });

    return res.status(200).json({
      success: true,
      bookings: result,
    });
  } catch (err) {
    console.error('[getTeacherBookings] Unexpected error:', err);

    return res.status(500).json({
      success: false,
      message: 'Failed to fetch teacher bookings.',
    });
  }
}

export async function updateBookingStatus(req, res) {
  try {
    const teacherId = req.user.id;
    const { id } = req.params;
    const { status } = req.body;

    if (!['confirmed', 'canceled'].includes(status)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid booking status',
      });
    }

    const { data: booking, error } = await supabaseAdmin
      .from('bookings')
      .update({
        status,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .eq('tutor_id', teacherId)
      .select()
      .single();

    if (error) {
      console.error('[updateBookingStatus] error:', error.message);

      return res.status(500).json({
        success: false,
        message: error.message,
      });
    }

    return res.status(200).json({
      success: true,
      booking,
    });
  } catch (err) {
    console.error('[updateBookingStatus] Unexpected error:', err);

    return res.status(500).json({
      success: false,
      message: 'Failed to update booking status.',
    });
  }
}

