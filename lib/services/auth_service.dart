import 'dart:convert';
import 'dart:developer';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

const String _googleWebClientId =
    '421524422569-umor5co1gdlr529vbpuntsqa77ghnbs3.apps.googleusercontent.com';

// const String _googleIosClientId =
//     '421524422569-0e5cmrce442ln2j29s5apga9vin6ht9b.apps.googleusercontent.com';

class AuthService {
  final SupabaseClient supabase = Supabase.instance.client;

  // ── Google Sign-In (Native / Web) ──────────────────────────────────────────
  Future<void> signInWithGoogle() async {

    final GoogleSignIn googleSignIn = GoogleSignIn(
      serverClientId: _googleWebClientId,
);

    try {
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

  Future<void> signInWithApple() async {
    try {
     
      final String rawNonce = supabase.auth.generateRawNonce();
      final String hashedNonce =
          sha256.convert(utf8.encode(rawNonce)).toString();

      
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

     
      await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: identityToken,
        nonce: rawNonce,
      );

     
      final session = supabase.auth.currentSession;
      if (session != null) {
        await ApiService.syncSocialUser(session.accessToken);
      }
    } on SignInWithAppleAuthorizationException catch (e) {
     
      if (e.code == AuthorizationErrorCode.canceled) return;
     
      log('Apple Sign-In not configured: $e');
      throw AppleSignInNotConfiguredException();
    } catch (e) {
      log('Apple Sign-In error: $e');
      
      throw AppleSignInNotConfiguredException();
    }
  }

  Future<void> signOut() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut();
    } catch (_) {
    }
    await supabase.auth.signOut();
  }
}

class AppleSignInNotConfiguredException implements Exception {
  final String message;
  AppleSignInNotConfiguredException()
      : message =
            'Apple Sign-In is coming soon (Developer configuration required).';

  @override
  String toString() => message;
}