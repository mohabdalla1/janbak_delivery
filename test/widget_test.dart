// test/widget_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/main.dart'; // تأكد أن هذا يطابق اسم ملف الـ main أو الـ App لديك

void main() {
  testWidgets('JanbakApp Smoke Test', (WidgetTester tester) async {
    // بناء التطبيق مغلفاً بـ ProviderScope ليعمل مع Riverpod
    await tester.pumpWidget(
      const ProviderScope(
        child: JanbakApp(),
      ),
    );

    // التحقق من أن التطبيق يتم تحميله بنجاح دون أخطاء
    expect(find.byType(JanbakApp), findsOneWidget);
  });
}