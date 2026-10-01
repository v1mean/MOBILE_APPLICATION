import '../../repositories/user_repository.dart';
import '../base_view_model.dart';

/// The teacher's name and avatar, shown at the top of every teacher screen.
mixin TeacherHeader on BaseViewModel {
  String _userName = 'Teacher';
  String? _avatarUrl;

  String get userName => _userName;
  String? get avatarUrl => _avatarUrl;

  /// Reads the name and photo from the `Users` table. True when a row exists.
  Future<bool> loadHeaderFromUsers(UserRepository users, String userId) async {
    final data = await users.fetchUserRow(
      userId,
      columns: 'name, profile_image',
    );
    return _applyHeader(data, nameKey: 'name', avatarKey: 'profile_image');
  }

  /// Reads the name and photo from the `profiles` table. True when a row
  /// exists.
  Future<bool> loadHeaderFromProfiles(
    UserRepository users,
    String userId,
  ) async {
    final data = await users.fetchProfileRow(
      userId,
      columns: 'full_name, avatar_url',
    );
    return _applyHeader(data, nameKey: 'full_name', avatarKey: 'avatar_url');
  }

  bool _applyHeader(
    Map<String, dynamic>? data, {
    required String nameKey,
    required String avatarKey,
  }) {
    if (data == null) return false;

    _userName = data[nameKey] ?? 'Teacher';
    _avatarUrl = data[avatarKey];
    if (_avatarUrl != null && _avatarUrl!.isEmpty) _avatarUrl = null;
    notifyListeners();
    return true;
  }
}
