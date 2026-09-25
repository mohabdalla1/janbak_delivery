import 'package:flutter/material.dart';
// استدعِ الشاشات الخاصة بك هنا لاحقاً عندما نقوم بترتيبها

class AppRoutes {
  // تعريف أسماء المسارات كـ Constants لعدم الوقوع في أخطاء الكتابة
  static const String initialRoute = '/';
  static const String customerHome = '/customer-home';
  static const String driverHome = '/driver-home';
  static const String merchantHome = '/merchant-home';

  // خريطة مسارات التطبيق (Route Generator)
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initialRoute:
        // مؤقتاً نعيد الشاشة الرئيسية أو شاشة البداية، وسنربطها بشاشاتك الفعلية قريباً
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('مرحباً بك في تطبيق جنبك - الصفحة الرئيسية'),
            ),
          ),
        );
        
      // يمكنك إضافة باقي المسارات هنا بسهولة لاحقاً
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('خطأ: المسار غير موجود ${settings.name}'),
            ),
          ),
        );
    }
  }
}
