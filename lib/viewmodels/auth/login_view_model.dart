import 'package:flutter/foundation.dart';
import '../../repositories/auth_repository.dart';
import '../base_view_model.dart';
import 'auth_result.dart';

class LoginViewModel extends BaseViewModel {
  LoginViewModel({required AuthRepository authRepository})
    : _auth = authRepository;

  final AuthRepository _auth;

  Future<AuthResult> login({
    required String email,
    required String password,
    required String role,
  }) async {
    setBusy(true);
    try {
      final response = await _auth.loginWithEmail(email, password, role);

      if (response['success'] == true) {
        final finalRole = await _auth.resolveRole(fallback: role);
        final notice = roleMismatchNotice(
          chosenRole: role,
          accountRole: finalRole,
        );
        return AuthResult.success(
          message: notice ?? response['message'] ?? 'Login Successful',
          role: finalRole,
        );
      }

      String errorMessage = response['message'] ?? 'Login failed';
      if (errorMessage == 'Email not confirmed') {
        errorMessage = 'Please confirm your email address before logging in.';
      }
      return AuthResult.failure(errorMessage);
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
      debugPrint('Google Login error: $e');
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
