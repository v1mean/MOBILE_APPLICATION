import 'dart:async';
import '../../repositories/auth_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';
import 'teacher_header.dart';

class TeacherSchedulesViewModel extends BaseViewModel with TeacherHeader {
  TeacherSchedulesViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required BookingRepository bookingRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _bookings = bookingRepository;

  final AuthRepository _auth;
  final UserRepository _users;
  final BookingRepository _bookings;

  List<Map<String, dynamic>> _scheduleBookings = [];
  bool _isLoading = true;
  StreamSubscription? _bookingSubscription;

  /// Called when a new booking arrives while the screen is open, so the view
  /// can play its alert sound.
  void Function()? onNewBooking;

  List<Map<String, dynamic>> get scheduleBookings => _scheduleBookings;
  bool get isLoading => _isLoading;

  /// One entry per student in the schedule.
  List<Map<String, dynamic>> get uniqueStudents {
    final Map<String, Map<String, dynamic>> map = {};
    for (var b in _scheduleBookings) {
      final sId = b['student_id']?.toString() ?? '';
      if (sId.isNotEmpty) {
        map[sId] = {
          'name': b['student_name'] ?? 'Student',
          'avatar': b['student_avatar'],
          'location': b['student_location'] ?? 'Online',
        };
      }
    }
    return map.values.toList();
  }

  void load() {
    loadHeader();
    _watchBookings();
  }

  Future<void> loadHeader() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      await loadHeaderFromProfiles(_users, userId);
    } catch (_) {}
  }

  /// Loads the schedule, then reloads it whenever a new booking comes in.
  Future<void> _watchBookings() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;

    await loadSchedule();

    int? previousCount;

    _bookingSubscription = _bookings.watchTeacherBookings(userId).listen((
      data,
    ) async {
      final currentCount = data.length;

      if (previousCount != null && currentCount > previousCount!) {
        // New booking received!
        onNewBooking?.call();
        await loadSchedule();
      }
      previousCount = currentCount;
    });
  }

  Future<void> loadSchedule() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;

      _scheduleBookings = await _bookings.fetchTeacherSchedule(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _bookingSubscription?.cancel();
    super.dispose();
  }
}
