import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/services.dart';
import 'router.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await Supabase.initialize(
    url: 'https://wlyknabitdvynmfeqcuy.supabase.co',
    publishableKey: 'sb_publishable_Caawyy6UyVUEGKAsCZKdaQ_TZSZjYtt',
  );

  setupDeepLinkListener();

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
