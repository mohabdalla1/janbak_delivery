import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/app.dart';

void main() {
  testWidgets('JanbakApp Smoke Test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: JanbakApp(),
      ),
    );

    expect(find.textContaining('Janbak | جنبك'), findsOneWidget);
  });
}