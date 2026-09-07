import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

// Google OAuth Client IDs — from Google Cloud Console → APIs & Services → Credentials
const String _googleWebClientId =
    '195451924820-t2oelk513pt235jd5t29np6quccd17rs.apps.googleusercontent.com';
const String _googleIosClientId =
    '421524422569-0e5cmrce442ln2j29s5apga9vin6ht9b.apps.googleusercontent.com';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ── Google Sign-In (Native — Fast) ─────────────────────────────────────────
  // Uses google_sign_in to get an idToken natively, then exchanges it with
  // Supabase. ~3x faster than OAuth redirect — never opens an external browser.
  Future<void> signInWithGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: _googleIosClientId,       // Used on iOS
      serverClientId: _googleWebClientId, // Used on Android + backend validation
    );

    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return; // User cancelled — not an error

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw Exception('Google Sign-In failed: No ID Token received.');
      }

      // Exchange the Google idToken directly with Supabase — no redirect needed
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // Sync user to backend (assigns 'student' role if first login)
      final session = supabase.auth.currentSession;
      if (session != null) {
        await ApiService.syncSocialUser(session.accessToken);
      }
    } catch (e) {
      log('Google Sign-In error: $e');
      rethrow;
    }
  }

  // ── Apple Sign-In ──────────────────────────────────────────────────────────
  // Full production implementation using a cryptographic nonce.
  // Requires: paid Apple Developer account + Services ID configured in Supabase.
  // Until then: surfaces a friendly "coming soon" message via AppleSignInNotConfiguredException.
  Future<void> signInWithApple() async {
    try {
      // Generate a raw nonce and its SHA-256 hash
      final String rawNonce = supabase.auth.generateRawNonce();
      final String hashedNonce =
          sha256.convert(utf8.encode(rawNonce)).toString();

      // Request Apple ID credential (shows native Apple sheet)
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final String? identityToken = credential.identityToken;
      if (identityToken == null) {
        throw Exception('Apple Sign-In failed: No Identity Token received.');
      }

      // Exchange with Supabase using the raw nonce for verification
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: identityToken,
        nonce: rawNonce,
      );

      // Sync user to backend (assigns 'student' role if first login)
      final session = supabase.auth.currentSession;
      if (session != null) {
        await ApiService.syncSocialUser(session.accessToken);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      // User cancelled the Apple sheet — not an error, just ignore it
      if (e.code == AuthorizationErrorCode.canceled) return;
      // Any other Apple authorization error → likely not configured yet
      log('Apple Sign-In not configured: $e');
      throw AppleSignInNotConfiguredException();
    } catch (e) {
      log('Apple Sign-In error: $e');
      // Treat any other failure as "not configured" to show a friendly message
      throw AppleSignInNotConfiguredException();
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {
      // Google wasn't used — ignore
    }
    await supabase.auth.signOut();
  }
}

/// Thrown by [AuthService.signInWithApple] when Apple Sign-In is not yet
/// configured (no Apple Developer account / Supabase Services ID).
/// Catch this to show a user-friendly "coming soon" message.
class AppleSignInNotConfiguredException implements Exception {
  final String message;
  AppleSignInNotConfiguredException()
      : message =
            'Apple Sign-In is coming soon (Developer configuration required).';

  @override
  String toString() => message;
}