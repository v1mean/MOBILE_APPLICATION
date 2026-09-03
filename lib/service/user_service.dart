import 'api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getMyProfile(String token) async {
    return await _api.get('/api/users/me', token: token);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String token,
    String? fullName,
  }) async {
    return await _api.patch('/api/users/me', {
      if (fullName != null) 'fullName': fullName,
    }, token: token);
  }

  Future<Map<String, dynamic>> updatePreferences({
    required String token,
    bool? notificationsEnabled,
    bool? emailUpdates,
    bool? darkMode,
    String? language,
  }) async {
    return await _api.patch('/api/users/me/preferences', {
      if (notificationsEnabled != null)
        'notificationsEnabled': notificationsEnabled,
      if (emailUpdates != null) 'emailUpdates': emailUpdates,
      if (darkMode != null) 'darkMode': darkMode,
      if (language != null) 'language': language,
    }, token: token);
  }
}
