import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:mobile_application/main.dart';

void main() {
  setUpAll(() async {
    // JomnesApp reads the Supabase client at build time (via router.dart's
    // top-level _authRefresh), so it must be initialized before pumping.
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(
      url: 'https://test.supabase.co',
      publishableKey: 'test-anon-key',
    );
  });

  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const JomnesApp());
    // Let the splash screen's entrance animation (flutter_animate) finish
    // so its timer doesn't outlive the test.
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(JomnesApp), findsOneWidget);
  });
}