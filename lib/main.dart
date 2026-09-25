 import 'package:flutter/material.dart';
import 'config/theme/app_theme.dart';
import 'config/routes/app_router.dart';
import 'core/constants/app_constants.dart';

void main() {
  runApp(const JanbakApp());
}

class JanbakApp extends StatelessWidget {
  const JanbakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      // ربط الثيم الموحد الذي أنشأناه
      theme: AppTheme.lightTheme,
      // تحديد المسار الابتدائي للتطبيق
      initialRoute: AppRoutes.initialRoute,
      // ربط نظام التنقل والمسارات
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}
                                                               