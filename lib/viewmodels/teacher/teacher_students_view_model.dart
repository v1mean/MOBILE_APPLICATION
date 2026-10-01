import '../../repositories/auth_repository.dart';
import '../../repositories/booking_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';
import 'teacher_header.dart';

/// A student who has booked the teacher at least once.
class TeacherStudent {
  const TeacherStudent(this.name, this.phone, this.location, this.avatarUrl);

  final String name;
  final String phone;
  final String location;
  final String avatarUrl;
}

class TeacherStudentsViewModel extends BaseViewModel with TeacherHeader {
  TeacherStudentsViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
    required BookingRepository bookingRepository,
  }) : _auth = authRepository,
       _users = userRepository,
       _bookings = bookingRepository;

  final AuthRepository _auth;
  final UserRepository _users;
  final BookingRepository _bookings;

  List<TeacherStudent> _students = [];
  bool _isLoading = true;
  String? _error;

  List<TeacherStudent> get students => _students;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void load() {
    loadHeader();
    loadStudents();
  }

  Future<void> loadHeader() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;
      await loadHeaderFromProfiles(_users, userId);
    } catch (_) {}
  }

  /// Builds the student list from the teacher's bookings, one entry per
  /// student.
  Future<void> loadStudents() async {
    try {
      final accessToken = _auth.accessToken;
      if (accessToken == null) {
        _isLoading = false;
        notifyListeners();
        return;
      }

      final bookings = await _bookings.fetchTeacherBookings(accessToken);

      final Map<String, TeacherStudent> uniqueStudents = {};

      for (final b in bookings) {
        final sId = b['student_id'] as String?;
        if (sId == null || uniqueStudents.containsKey(sId)) continue;

        uniqueStudents[sId] = TeacherStudent(
          b['student_name'] as String? ?? 'Unknown Student',
          b['student_phone'] as String? ?? '',
          b['student_city'] as String? ?? 'No Location',
          b['student_avatar'] as String? ?? '',
        );
      }

      _students = uniqueStudents.values.toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load students.';
      _isLoading = false;
      notifyListeners();
    }
  }
}
