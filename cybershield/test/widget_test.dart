import 'package:cybershield/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CyberShieldApp renders MaterialApp', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CyberShieldApp()));
    await tester.pump();
    expect(find.byType(CyberShieldApp), findsOneWidget);
  });
}
