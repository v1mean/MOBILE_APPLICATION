import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mobile_application/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/notification_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handy shortcut you'll use everywhere in the app
final JomnesDB = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Load .env file FIRST before anything else reads it ──────────────────
  await dotenv.load(fileName: '.env');

  // ── 2. Initialize Stripe with publishable key from .env ───────────────────
  Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY']!;

  // ── 3. Initialize Supabase with credentials from .env ─────────────────────
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );

  // ── 4. Facebook Web SDK (web only) ────────────────────────────────────────
  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: dotenv.env['FACEBOOK_APP_ID']!,
      cookie: true,
      xfbml: true,
      version: 'v18.0',
    );
  }

  // ── 5. Device setup ────────────────────────────────────────────────────────
  await NotificationService.initialize();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  setupDeepLinkListener();

  AuthService().printDeployKeyHash();
  runApp(const JomnesApp());
}

class JomnesApp extends StatelessWidget {
  const JomnesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Jomnes',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
