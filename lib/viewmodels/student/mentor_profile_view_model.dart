import 'package:flutter/foundation.dart';
import '../../models/mentor.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/mentor_repository.dart';
import '../../repositories/payment_repository.dart';
import '../../repositories/student_notification_repository.dart';
import '../base_view_model.dart';

/// What happened when the student tapped "Book Class".
enum PaymentStart {
  /// No session: send the student to log in.
  notLoggedIn,

  /// Web: the browser is leaving for Stripe Checkout.
  redirecting,

  /// Mobile: the payment sheet completed.
  paid,

  /// Mobile: the payment sheet was closed or the payment was declined.
  cancelled,

  /// The payment could not be started.
  error,
}

enum BookingStatus { notLoggedIn, booked, rejected, error }

class BookingResult {
  const BookingResult(this.status, [this.message]);

  final BookingStatus status;

  /// The backend's reason when the booking was rejected.
  final String? message;
}

class MentorProfileViewModel extends BaseViewModel {
  MentorProfileViewModel({
    required this.mentorId,
    this.checkoutSessionId,
    required AuthRepository authRepository,
    required MentorRepository mentorRepository,
    required BookingRepository bookingRepository,
    required PaymentRepository paymentRepository,
    required StudentNotificationRepository notificationRepository,
  }) : _auth = authRepository,
       _mentors = mentorRepository,
       _bookings = bookingRepository,
       _payments = paymentRepository,
       _notifications = notificationRepository;

  final String mentorId;

  /// Set when the browser returns from Stripe Checkout (web payments only).
  final String? checkoutSessionId;

  final AuthRepository _auth;
  final MentorRepository _mentors;
  final BookingRepository _bookings;
  final PaymentRepository _payments;
  final StudentNotificationRepository _notifications;

  Mentor? _mentor;
  bool _isLoading = true;
  bool _isBooking = false;
  bool _isFollowing = false;
  List<Map<String, dynamic>> _reviews = [];

  Mentor? get mentor => _mentor;
  bool get isLoading => _isLoading;
  bool get isBooking => _isBooking;
  bool get isFollowing => _isFollowing;
  List<Map<String, dynamic>> get reviews => _reviews;

  /// Loads the mentor and their reviews. Completes with true when the page
  /// was opened by a paid Stripe Checkout return, so the booking sheet should
  /// open straight away.
  Future<bool> load() async {
    _loadReviews();
    await _loadMentor();
    return _canResumeWebCheckout();
  }

  Future<void> _loadMentor() async {
    final mentor = await _mentors.fetchMentorDetail(mentorId);
    if (mentor != null) _mentor = mentor;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadReviews() async {
    try {
      _reviews = await _mentors.fetchReviews(mentorId);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> _canResumeWebCheckout() async {
    final sessionId = checkoutSessionId;
    if (sessionId == null || _mentor == null) return false;
    return _payments.isCheckoutSessionUsable(sessionId);
  }

  void toggleFollowing() {
    _isFollowing = !_isFollowing;
    notifyListeners();
  }

  /// Takes payment for one session. On mobile the booking sheet opens after
  /// [PaymentStart.paid]; on web it opens when the browser comes back.
  Future<PaymentStart> startPayment() async {
    _isBooking = true;
    notifyListeners();

    if (_auth.currentSession == null) return PaymentStart.notLoggedIn;

    try {
      if (kIsWeb) {
        final started = await _payments.startWebCheckout(_mentor!.id);
        if (!started) {
          _isBooking = false;
          notifyListeners();
          return PaymentStart.error;
        }
        return PaymentStart.redirecting;
      }

      final paymentSuccess = await _payments.payWithSheet(_mentor!.id);
      _isBooking = false;
      notifyListeners();
      return paymentSuccess ? PaymentStart.paid : PaymentStart.cancelled;
    } catch (e) {
      debugPrint('Stripe initialization error: $e');
      _isBooking = false;
      notifyListeners();
      return PaymentStart.error;
    }
  }

  /// Books a one-hour session starting at [time] (for example '2:00 PM') on
  /// [date], then records a notification and offers the calendar entry.
  Future<BookingResult> confirmBooking(DateTime date, String time) async {
    _isBooking = true;
    notifyListeners();

    final accessToken = _auth.accessToken;
    if (accessToken == null) {
      return const BookingResult(BookingStatus.notLoggedIn);
    }

    try {
      // Calculate start time
      int hour = int.parse(time.split(':')[0]);
      if (time.contains('PM') && hour != 12) hour += 12;
      final startTime = DateTime(date.year, date.month, date.day, hour, 0);
      final endTime = startTime.add(const Duration(hours: 1));
      final bookingDate = date.toIso8601String().split('T')[0];

      final res = await _bookings.createBooking(
        accessToken: accessToken,
        tutorId: _mentor!.id,
        startTime: startTime.toIso8601String(),
        endTime: endTime.toIso8601String(),
        bookingDate: bookingDate,
        timeSlot: time,
        hourlyRate: _mentor!.bookingPrice,
        totalPrice: _mentor!.bookingPrice,
        checkoutSessionId: checkoutSessionId,
      );

      _isBooking = false;
      notifyListeners();

      if (res['success'] != true) {
        return BookingResult(
          BookingStatus.rejected,
          res['message'] ?? 'Failed to book',
        );
      }

      // Device notifications and the calendar plugin are mobile-only.
      if (!kIsWeb) {
        await _notifications.showDeviceNotification(
          title: 'Booking Confirmed! 🎉',
          body: 'Request sent to ${_mentor!.name}!',
        );
      }
      await _notifications.add(
        title: 'Booking Confirmed! 🎉',
        body:
            'Your class with ${_mentor!.name} on $bookingDate at $time has been scheduled.',
        type: 'booking',
        route: '/courses',
      );

      if (!kIsWeb) {
        await _bookings.addLessonToCalendar(
          title: 'Lesson with ${_mentor!.name}',
          description: 'Jomnes App - Study Session',
          start: startTime,
          end: endTime,
        );
      }

      return const BookingResult(BookingStatus.booked);
    } catch (e) {
      _isBooking = false;
      notifyListeners();
      return const BookingResult(BookingStatus.error);
    }
  }
}
