import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janbak_delivery/main.dart';

void main() {
  testWidgets('Janbak app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JanbakApp());

    // Verify that our splash screen text is present.
    expect(find.text('تطبيق جنبك'), findsOneWidget);
    expect(find.text('ابدأ الاستخدام'), findsOneWidget);
  });
}