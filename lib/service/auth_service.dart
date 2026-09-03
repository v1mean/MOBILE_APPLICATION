import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> login(String email, String password) async {
    return await _api.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
  ) async {
    return await _api.post('/api/auth/register', {
      'email': email,
      'password': password,
      'fullName': fullName,
    });
  }

  Future<Map<String, dynamic>> forgotPassword(String email) async {
    return await _api.post('/api/auth/forgot-password', {'email': email});
  }

  Future<Map<String, dynamic>> updatePassword(
    String newPassword,
    String token,
  ) async {
    return await _api.patch('/api/auth/update-password', {
      'newPassword': newPassword,
    }, token: token);
  }

  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    return await _api.get('/api/users/me', token: token);
  }

  Future<void> googleSync(String token) async {
    await _api.post('/api/auth/google-sync', {}, token: token);
  }
}
