import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

/// The student's settings screen: who is signed in, and signing out.
class SettingsViewModel extends BaseViewModel {
  SettingsViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _auth = authRepository,
       _users = userRepository;

  final AuthRepository _auth;
  final UserRepository _users;

  UserProfile? _userProfile;

  String get displayName {
    if (_userProfile?.name.isNotEmpty == true) return _userProfile!.name;
    return _auth.metadataName ?? 'Student';
  }

  String get displayEmail {
    if (_userProfile?.email.isNotEmpty == true) return _userProfile!.email;
    return _auth.currentEmail ?? '';
  }

  String get displayRole {
    if (_userProfile?.role.isNotEmpty == true) return _userProfile!.role;
    return 'Student';
  }

  String? get avatarUrl {
    if (_userProfile?.profileImage.isNotEmpty == true) {
      return _userProfile!.profileImage;
    }
    final metaAvatar = _auth.metadataAvatar;
    return metaAvatar != null && metaAvatar.isNotEmpty ? metaAvatar : null;
  }

  Future<void> loadUserProfile() async {
    final userId = _auth.currentUserId;
    if (userId == null) return;
    try {
      final data = await _users.fetchUserRow(userId);
      if (data != null) {
        _userProfile = UserProfile.fromJson(data);
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> signOut() => _auth.signOut();
}
