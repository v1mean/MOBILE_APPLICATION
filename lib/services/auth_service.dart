import 'dart:developer';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import '../router.dart';
import 'api_service.dart';

const String _googleWebClientId =
    '914787896690-rtffi9av7ski1dbshc9pauv55vro7pdt.apps.googleusercontent.com';

const String _googleIosClientId =
    '914787896690-qsd2iabddl5j7rd502s6p3tppv8scsvb.apps.googleusercontent.com';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;
  static const platform = MethodChannel('io.jomnes.app/hash');

  Future<void> printDeployKeyHash() async {
    if (!kIsWeb) {
      try {
        final String? hash = await platform.invokeMethod('getKeyHash');
        log('====================================');
        log('FACEBOOK ANDROID KEY HASH: $hash');
        log('====================================');
      } catch (e) {
        log('Failed to get key hash: $e');
      }
    }
  }

  //Google Sign-In (Native / Web)
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
      clientId: _googleIosClientId,       
      serverClientId: _googleWebClientId,
    );

    try {
      
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

  // ── Facebook Sign-In (Native SDK) ──────────────────────────────────────────
  Future<void> signInWithFacebook() async {
    try {
      log('DEBUG: Initiating Facebook OAuth sign-in');
      // ignore: avoid_print
      print('>>> FB: calling signInWithOAuth, kIsWeb=$kIsWeb');
      final bool launched = await supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb ? Uri.base.origin : 'io.jomnes.app://login-callback',
      );
      // ignore: avoid_print
      print('>>> FB: signInWithOAuth launched=$launched');
      // This leaves the app and redirects back after login; the router's
      // onAuthStateChange listener (see router.dart) picks up the session
      // and navigates once it lands — nothing else to do here.
    } catch (e) {
      log('Facebook Sign-In error: $e');
      // ignore: avoid_print
      print('>>> FB ERROR: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    isGuestMode = false;
    try {
      if (!kIsWeb) {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.signOut();
        await FacebookAuth.instance.logOut();
      }
    } catch (_) {
    }
    await supabase.auth.signOut();
  }

  Future<void> updatePassword(String newPassword) async {
    await supabase.auth.updateUser(UserAttributes(password: newPassword));
  }
}
