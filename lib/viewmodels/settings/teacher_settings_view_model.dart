import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

/// The teacher's settings screen: account details, and signing out.
class TeacherSettingsViewModel extends BaseViewModel {
  TeacherSettingsViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _auth = authRepository,
       _users = userRepository;

  final AuthRepository _auth;
  final UserRepository _users;

  String _name = 'Teacher';
  String _email = '';
  String _phone = '';
  String _role = 'Teacher';
  String? _avatarUrl;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get subject => 'General';
  String get role => _role;
  String? get avatarUrl => _avatarUrl;

  Future<void> loadProfile() async {
    try {
      final userId = _auth.currentUserId;
      if (userId == null) return;

      // We query the Users table because it contains the phone number.
      final data = await _users.fetchUserRow(
        userId,
        columns: 'name, email, phone, profile_image, role',
      );
      if (data != null) {
        _name = data['name'] ?? 'Teacher';
        _email = data['email'] ?? '';
        _phone = data['phone'] ?? '';
        final rawRole = (data['role'] as String?)?.toLowerCase();
        if (rawRole == 'mentor') {
          _role = 'Teacher / Mentor';
        } else if (rawRole == 'tutor') {
          _role = 'Tutor';
        } else if (rawRole == 'lecturer') {
          _role = 'Lecturer';
        } else {
          // When in the Teacher portal, always show Teacher (even if logged in with same gmail registered as student)
          _role = 'Teacher';
        }
        _avatarUrl = data['profile_image'];
        if (_avatarUrl != null && _avatarUrl!.isEmpty) _avatarUrl = null;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> signOut() => _auth.signOutSession();
}
