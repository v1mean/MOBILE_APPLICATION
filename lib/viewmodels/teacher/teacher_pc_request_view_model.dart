import '../../repositories/auth_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';
import 'teacher_header.dart';

class TeacherPcRequestViewModel extends BaseViewModel with TeacherHeader {
  TeacherPcRequestViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required BookingRepository bookingRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _bookings = bookingRepository;

  final AuthRepository _auth;
  final UserRepository _users;
  final BookingRepository _bookings;

  List<Map<String, dynamic>> _pendingBookings = [];
  bool _isLoadingBookings = true;

  /// Bookings still waiting for the teacher's answer.
  List<Map<String, dynamic>> get pendingBookings => _pendingBookings;
  bool get isLoadingBookings => _isLoadingBookings;

  void load() {
    loadHeader();
    loadBookings();
  }

  Future<void> loadHeader() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      await loadHeaderFromProfiles(_users, userId);
    } catch (_) {}
  }

  Future<void> loadBookings() async {
    try {
      final accessToken = _auth.accessToken;

      if (accessToken == null) {
        _isLoadingBookings = false;
        notifyListeners();
        return;
      }

      final bookings = await _bookings.fetchTeacherBookings(accessToken);

      _pendingBookings = bookings
          .where((booking) => booking['status'] == 'pending')
          .toList();
      _isLoadingBookings = false;
      notifyListeners();
    } catch (e) {
      _isLoadingBookings = false;
      notifyListeners();
    }
  }
}
