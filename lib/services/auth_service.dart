import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

const String _googleWebClientId =
    '914787896690-rtffi9av7ski1dbshc9pauv55vro7pdt.apps.googleusercontent.com';

const String _googleIosClientId =
    '914787896690-qsd2iabddl5j7rd502s6p3tppv8scsvb.apps.googleusercontent.com';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ── Google Sign-In (Native / Web) ──────────────────────────────────────────
  Future<void> signInWithGoogle() async {
    if (kIsWeb) {
      log('DEBUG: Initiating Google OAuth sign-in for Web');
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'http://localhost:8080',
        queryParams: {'prompt': 'select_account'},
      );
      return;
    }

    // Native Mobile (Android & iOS)
    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: _googleIosClientId,       // Used on iOS
      serverClientId: _googleWebClientId, // Used on Android + iOS backend validation
    );

    try {
      // Force account chooser prompt so it never silently auto-selects cached account
      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        log('DEBUG: Google Sign-In cancelled by user.');
        return; 
      }

      log('DEBUG: Google account selected: ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;
      final String? accessToken = googleAuth.accessToken;

      log('DEBUG: ID Token received. Length: ${idToken?.length ?? 0}');
      log('DEBUG: Access Token received. Length: ${accessToken?.length ?? 0}');
      log('DEBUG: serverClientId = $_googleWebClientId');

      if (idToken == null) {
        throw Exception(
          'Google Sign-In failed: No ID Token received. '
          'Check that serverClientId matches a Web Client ID in Google Cloud Console.',
        );
      }
      final AuthResponse response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      log('DEBUG: Supabase signInWithIdToken succeeded. UID: ${response.user?.id}');
      log('Google Login successful, UID: ${response.user?.id}');

      final session = supabase.auth.currentSession;
      if (session != null) {
        ApiService.syncSocialUser(session.accessToken); 
      }
    } on AuthApiException catch (e) {
      log('DEBUG: AuthApiException — statusCode: ${e.statusCode}, message: ${e.message}');
      rethrow;
    } catch (e) {
      log('Google Sign-In error: $e');
      rethrow;
    }
  }

  // ── Facebook Sign-In (Supabase OAuth) ──────────────────────────────────────
  Future<void> signInWithFacebook() async {
    try {
      log('DEBUG: Initiating Facebook OAuth sign-in');
      await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb ? null : 'io.jomnes.app://login-callback',
      );
      // On mobile, this launches the system browser/custom tab for Facebook.
      // Once authenticated, Supabase redirects to io.jomnes.app://login-callback,
      // where onAuthStateChange in router.dart detects the session and triggers
      // ApiService.syncSocialUser.
    } catch (e) {
      log('Facebook Sign-In error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
      }
    } catch (_) {
    }
    await supabase.auth.signOut();
  }
}
