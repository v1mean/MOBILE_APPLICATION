import 'package:add_2_calendar/add_2_calendar.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

/// Bookings between students and teachers.
class BookingRepository {
  Future<Map<String, dynamic>> createBooking({
    required String accessToken,
    required String tutorId,
    String? startTime,
    String? endTime,
    String? bookingDate,
    String? timeSlot,
    double? hourlyRate,
    double? totalPrice,
    String? checkoutSessionId,
  }) => ApiService.createBooking(
    accessToken: accessToken,
    tutorId: tutorId,
    startTime: startTime,
    endTime: endTime,
    bookingDate: bookingDate,
    timeSlot: timeSlot,
    hourlyRate: hourlyRate,
    totalPrice: totalPrice,
    checkoutSessionId: checkoutSessionId,
  );

  /// Every booking made with the signed-in teacher, with student details.
  Future<List<Map<String, dynamic>>> fetchTeacherBookings(String accessToken) =>
      ApiService.fetchTeacherBookings(accessToken);

  /// The teacher's timetable rows from `teacher_schedule_view`.
  Future<List<Map<String, dynamic>>> fetchTeacherSchedule(
    String tutorId,
  ) async {
    final data = await supabaseClient
        .from('teacher_schedule_view')
        .select()
        .eq('tutor_id', tutorId);
    return List<Map<String, dynamic>>.from(data as List);
  }

  /// Live updates of the teacher's bookings.
  Stream<List<Map<String, dynamic>>> watchTeacherBookings(String tutorId) =>
      supabaseClient
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('tutor_id', tutorId);

  /// Opens the device calendar with the lesson pre-filled. Mobile only.
  Future<void> addLessonToCalendar({
    required String title,
    required String description,
    required DateTime start,
    required DateTime end,
  }) async {
    await Add2Calendar.addEvent2Cal(
      Event(
        title: title,
        description: description,
        startDate: start,
        endDate: end,
      ),
    );
  }
}
