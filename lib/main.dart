import 'repositories/student_notification_repository.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:mobile_application/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_application/services/notification_service.dart';
import 'package:provider/provider.dart';
import 'app_providers.dart';
import 'config/app_config.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initialize();
  final studentNotifications = StudentNotificationRepository();
  await studentNotifications.init();

  Stripe.publishableKey = AppConfig.stripePublishableKey;


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    publishableKey: AppConfig.supabasePublishableKey,
  );

  if (kIsWeb) {
    await FacebookAuth.i.webAndDesktopInitialize(
      appId: AppConfig.facebookAppId,
      cookie: true,
      xfbml: true,
      version: 'v18.0',
    );
  }

  setupDeepLinkListener();

  AuthService().printDeployKeyHash();
  runApp(JomnesApp(studentNotifications: studentNotifications));
}

class JomnesApp extends StatelessWidget {
  const JomnesApp({super.key, this.studentNotifications});

  /// Already-loaded notification store from main(); when omitted (tests) a
  /// new one is created.
  final StudentNotificationRepository? studentNotifications;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: buildAppProviders(studentNotifications: studentNotifications),
      child: MaterialApp.router(
        title: 'Jomnes',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        scaffoldMessengerKey: scaffoldMessengerKey,
        routerConfig: router,
      ),
    );
  }
}
