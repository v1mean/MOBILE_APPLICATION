import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_application/main.dart';

void main() {
  testWidgets('App launches', (WidgetTester tester) async {
    await tester.pumpWidget(const JomnesApp());
    expect(find.byType(JomnesApp), findsOneWidget);
  });
}