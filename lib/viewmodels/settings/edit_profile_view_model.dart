import '../../models/user_profile.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

/// The values the edit-profile form starts with.
class ProfileForm {
  const ProfileForm({
    required this.email,
    required this.name,
    required this.role,
    this.phone,
    this.location,
  });

  final String email;
  final String name;
  final String role;

  /// Null when there is no saved profile to read them from.
  final String? phone;
  final String? location;
}

/// Outcome of saving the profile or uploading a photo.
class ProfileActionResult {
  const ProfileActionResult.success() : success = true, message = null;
  const ProfileActionResult.failure(this.message) : success = false;

  final bool success;
  final String? message;
}

class EditProfileViewModel extends BaseViewModel {
  EditProfileViewModel({
    required AuthRepository authRepository,
    required UserRepository userRepository,
  }) : _auth = authRepository,
       _users = userRepository;

  final AuthRepository _auth;
  final UserRepository _users;

  String? _avatarUrl;
  bool _isFetching = true;
  bool _isUploadingAvatar = false;

  String? get avatarUrl => _avatarUrl;
  bool get isFetching => _isFetching;
  bool get isUploadingAvatar => _isUploadingAvatar;
  bool get isSignedIn => _auth.currentSession != null;

  /// Loads the saved profile, falling back to the sign-in provider's name and
  /// photo. Completes with null when nobody is signed in.
  Future<ProfileForm?> loadProfile() async {
    final userId = _auth.currentUserId;

    if (userId == null) {
      _isFetching = false;
      notifyListeners();
      return null;
    }

    final email = _auth.currentEmail ?? '';
    final metaName = _auth.metadataName ?? 'Student';
    final metaAvatar = _auth.metadataAvatar;

    ProfileForm form = ProfileForm(
      email: email,
      name: metaName,
      role: 'Student',
    );

    try {
      final data = await _users.fetchUserRow(userId);

      if (data != null) {
        final profile = UserProfile.fromJson(data);
        form = ProfileForm(
          email: email,
          name: profile.name.isNotEmpty ? profile.name : metaName,
          phone: profile.phone,
          location: profile.location,
          role: profile.role.isNotEmpty ? profile.role : 'Student',
        );
        _avatarUrl = profile.profileImage.isNotEmpty
            ? profile.profileImage
            : metaAvatar;
      } else {
        if (metaAvatar != null) _avatarUrl = metaAvatar;
      }
    } catch (_) {
      if (metaAvatar != null) _avatarUrl = metaAvatar;
    }

    _isFetching = false;
    notifyListeners();
    return form;
  }

  /// Uses [url] as the avatar; it is saved with the rest of the profile.
  void selectAvatar(String url) {
    _avatarUrl = url;
    notifyListeners();
  }

  Future<ProfileActionResult> saveProfile({
    required String name,
    required String phone,
    required String location,
    required String role,
  }) async {
    final accessToken = _auth.accessToken;
    if (accessToken == null) {
      return const ProfileActionResult.failure(null);
    }

    setBusy(true);
    try {
      final result = await _users.updateProfile(
        accessToken: accessToken,
        name: name,
        phone: phone,
        location: location,
        role: role.isNotEmpty ? role : 'Student',
        profileImage: _avatarUrl,
      );

      if (result['success'] == true) {
        return const ProfileActionResult.success();
      }
      return ProfileActionResult.failure(
        result['message'] ?? 'Failed to update profile.',
      );
    } catch (e) {
      return ProfileActionResult.failure('Failed to update: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Uploads the photo at [filePath] and uses it as the avatar.
  Future<ProfileActionResult> uploadAvatar(String filePath) async {
    final accessToken = _auth.accessToken;
    if (accessToken == null) {
      return const ProfileActionResult.failure(null);
    }

    _isUploadingAvatar = true;
    notifyListeners();
    try {
      final result = await _users.uploadAvatar(filePath, accessToken);
      if (result['success'] == true) {
        // The timestamp makes the image widget fetch the new photo instead
        // of showing the cached one.
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        _avatarUrl = '${result['avatarUrl']}?t=$timestamp';
        return const ProfileActionResult.success();
      }
      return ProfileActionResult.failure(
        result['message'] ?? 'Upload failed. Try again.',
      );
    } catch (e) {
      return ProfileActionResult.failure('Upload error: $e');
    } finally {
      _isUploadingAvatar = false;
      notifyListeners();
    }
  }
}
