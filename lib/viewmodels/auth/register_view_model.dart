import '../../repositories/auth_repository.dart';
import '../base_view_model.dart';
import 'auth_result.dart';

class RegisterViewModel extends BaseViewModel {
  RegisterViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    setBusy(true);
    try {
      final response = await _auth.register(email, password, fullName, role);

      if (response['success'] == true) {
        if (response['session'] != null) {
          final finalRole = await _auth.resolveRole(fallback: role);
          return AuthResult.success(role: finalRole);
        }
        return const AuthResult.success(
          hasSession: false,
          message:
              'Registration successful! Please check your email to verify your account before logging in.',
        );
      }

      return AuthResult.failure(response['message'] ?? 'Registration failed');
    } catch (e) {
      return AuthResult.failure('Error connecting to server: $e');
    } finally {
      setBusy(false);
    }
  }

  /// Starts Google sign-in. Returns an error message, or null when it
  /// started; the router sends the user on once the session arrives.
  Future<String?> signInWithGoogle(String role) async {
    setBusy(true);
    try {
      await _auth.signInWithGoogle(role);
      return null;
    } catch (e) {
      return 'Google Login failed: $e';
    } finally {
      setBusy(false);
    }
  }

  /// Starts Facebook sign-in in the browser. Returns an error message, or
  /// null when it started.
  Future<String?> signInWithFacebook(String role) async {
    setBusy(true);
    try {
      await _auth.signInWithFacebook(role);
      return null;
    } catch (e) {
      return 'Facebook Login failed: $e';
    } finally {
      setBusy(false);
    }
  }

  void continueAsGuest() => _auth.enterGuestMode();
}
