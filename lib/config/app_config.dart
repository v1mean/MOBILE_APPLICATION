/// Everything that differs between environments, in one place.
///
/// Each value can be set at build time with `--dart-define=NAME=value`. The
/// defaults are the project's development services, so a plain `flutter run`
/// keeps working.
///
/// Whatever is here ships inside the app and can be read by anyone who has
/// it, so only public identifiers belong in this file. Secret keys (the
/// Supabase service-role key, the Stripe secret key) stay on the backend.
class AppConfig {
  const AppConfig._();

  /// Base URL of the backend API. Empty means "a backend running on this
  /// machine": see [devApiLocalhost] and [devApiEmulator].
  static const apiBaseUrl = String.fromEnvironment('API_BASE_URL');

  /// A locally running backend, as seen from a browser, a desktop build or an
  /// iOS simulator.
  static const devApiLocalhost = 'http://localhost:5005/api';

  /// The same backend as seen from the Android emulator, where `localhost`
  /// is the emulator itself.
  static const devApiEmulator = 'http://10.0.2.2:5005/api';

  static const supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://lfmllyuecleqnympfnqm.supabase.co',
  );

  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
    defaultValue: 'sb_publishable_90gMuHhur1aCcOiYH0Qr_g_B6d_tqrz',
  );

  static const stripePublishableKey = String.fromEnvironment(
    'STRIPE_PUBLISHABLE_KEY',
    defaultValue:
        'pk_test_51UJ6f2B0wqWK1qEi3bVUPVjkVgMHvDSNYX5uPE5upF8jspWGXdpWMrxK5HTuoUkgrlqT1p2YlBzm1U2qUxD6dCnV003xsA7fWa',
  );

  static const facebookAppId = String.fromEnvironment(
    'FACEBOOK_APP_ID',
    defaultValue: '2172302643350758',
  );
}
