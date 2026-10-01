import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/guest_mode.dart';
import '../services/supabase_service.dart';

/// Sign-in, sign-out and session state. The rest of the app reads the
/// signed-in user from here rather than from Supabase directly.
class AuthRepository {
  AuthRepository({AuthService? authService}) : _injectedAuthService = authService;

  final AuthService? _injectedAuthService;
  AuthService? _lazyAuthService;

  // Created on first use: AuthService reads the Supabase client when built.
  AuthService get _authService =>
      _injectedAuthService ?? (_lazyAuthService ??= AuthService());

  Session? get currentSession => supabaseClient.auth.currentSession;
  User? get currentUser => supabaseClient.auth.currentUser;
  String? get currentUserId => currentSession?.user.id;
  String? get accessToken => currentSession?.accessToken;
  String? get currentEmail => currentUser?.email;

  Stream<AuthState> get authStateChanges =>
      supabaseClient.auth.onAuthStateChange;

  bool get isGuest => isGuestMode;
  void enterGuestMode() => isGuestMode = true;

  /// Name from the sign-in provider's metadata, falling back to the part of
  /// the email before the @.
  String? get metadataName {
    final user = currentUser;
    final value =
        user?.userMetadata?['full_name'] ??
        user?.userMetadata?['name'] ??
        user?.email?.split('@').first;
    return value?.toString();
  }

  /// Avatar from the sign-in provider's metadata, when it is a URL string.
  String? get metadataAvatar {
    final user = currentUser;
    final dynamic picture =
        user?.userMetadata?['avatar_url'] ?? user?.userMetadata?['picture'];
    return picture is String ? picture : null;
  }

  /// Logs in through the backend and stores the returned session locally.
  Future<Map<String, dynamic>> loginWithEmail(
    String email,
    String password,
    String role,
  ) async {
    final response = await ApiService.loginUser(email, password, role);

    if (response['success'] == true) {
      try {
        final session = response['session'];
        if (session != null && session['refresh_token'] != null) {
          await supabaseClient.auth.setSession(
            session['refresh_token'],
            accessToken: session['access_token'],
          );
        } else if (response['token'] != null) {
          try {
            await supabaseClient.auth.setSession(response['token']);
          } catch (e) {
            // Ignore if not a valid refresh token
          }
        }
      } catch (e) {
        // Ignore session sync errors if the backend doesn't provide valid tokens
      }
    }

    return response;
  }

  Future<Map<String, dynamic>> register(
    String email,
    String password,
    String fullName,
    String role,
  ) => ApiService.registerUser(email, password, fullName, role);

  /// The signed-in account's stored role, or [fallback] when there is no
  /// session or no role on record.
  Future<String> resolveRole({required String fallback}) async {
    final session = currentSession;
    if (session == null) return fallback;

    try {
      final data = await supabaseClient
          .from('profiles')
          .select('role')
          .eq('id', session.user.id)
          .maybeSingle();
      if (data != null && data['role'] != null) {
        return data['role'];
      }
    } catch (_) {}

    return fallback;
  }

  Future<Map<String, dynamic>> requestPasswordReset(String email) =>
      ApiService.requestPasswordReset(email);

  /// Sets a new password using the token from a password-reset link.
  Future<Map<String, dynamic>> updatePasswordWithToken(
    String newPassword,
    String accessToken,
  ) => ApiService.updatePassword(newPassword, accessToken);

  /// Changes the password of the signed-in user.
  Future<void> updatePassword(String newPassword) =>
      _authService.updatePassword(newPassword);

  Future<void> signInWithGoogle(String role) =>
      _authService.signInWithGoogle(role);

  Future<void> signInWithFacebook(String role) =>
      _authService.signInWithFacebook(role);

  /// Leaves guest mode, signs out of Google/Facebook and ends the session.
  Future<void> signOut() => _authService.signOut();

  /// Ends the Supabase session only.
  Future<void> signOutSession() => supabaseClient.auth.signOut();

  Future<void> syncSocialUser(String accessToken, String role) =>
      ApiService.syncSocialUser(accessToken, role);
}
