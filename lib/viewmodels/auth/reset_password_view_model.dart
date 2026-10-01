import '../../repositories/auth_repository.dart';
import '../base_view_model.dart';
import 'auth_result.dart';

class ResetPasswordViewModel extends BaseViewModel {
  ResetPasswordViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  /// Saves a new password using the token from the reset link.
  Future<AuthResult> updatePassword({
    required String password,
    required String accessToken,
  }) async {
    setBusy(true);
    try {
      final response = await _auth.updatePasswordWithToken(
        password,
        accessToken,
      );
      if (response['success'] == true) {
        return const AuthResult.success();
      }
      return AuthResult.failure(
        response['message'] ?? 'Password update failed',
      );
    } catch (e) {
      return AuthResult.failure('Error: $e');
    } finally {
      setBusy(false);
    }
  }
}
