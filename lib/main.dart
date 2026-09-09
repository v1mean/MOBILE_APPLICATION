import 'package:mobile_application/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'router.dart';
import 'theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Handy shortcut you'll use everywhere in the app
final JomnesDB = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: 'https://lfmllyuecleqnympfnqm.supabase.co',
    publishableKey: 'sb_publishable_90gMuHhur1aCcOiYH0Qr_g_B6d_tqrz',
  );

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
