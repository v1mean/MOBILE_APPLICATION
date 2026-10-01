import '../../repositories/auth_repository.dart';
import '../base_view_model.dart';
import 'auth_result.dart';

class ForgotPasswordViewModel extends BaseViewModel {
  ForgotPasswordViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  /// Asks the backend to email a reset link. The result always carries a
  /// message to show.
  Future<AuthResult> requestReset(String email) async {
    setBusy(true);
    try {
      final response = await _auth.requestPasswordReset(email);
      final String message =
          response['message'] ?? 'Check your email for reset instructions';
      return response['success'] == true
          ? AuthResult.success(message: message)
          : AuthResult.failure(message);
    } catch (e) {
      return AuthResult.failure('Error: $e');
    } finally {
      setBusy(false);
    }
  }
}
