import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart'; // 1. استيراد فايربيس
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'package:janbak_delivery/features/auth/services/notification_service.dart'; // استيراد خدمة الإشعارات (تأكد من مسار الملف إذا كان في مجلد فرعي)
// ملاحظة: إذا كان لديك ملف firebase_options.generated (الخاص بإعدادات الويب/المنصات)، يمكنك استيراده هكذا:
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة فايربيس بشكل آمن ومحمي لمنع أي شاشة بيضاء
  try {
    // إذا كنت تعمل على الويب ولديك ملف firebase_options.dart، استبدل الدالة أدناه بـ:
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    await Firebase.initializeApp();
    
    // تفعيل وتهيئة خدمة الإشعارات
    NotificationService.initNotifications();
  } catch (e) {
    debugPrint('خطأ في تهيئة فايربيس أو الإشعارات: $e');
  }

  runApp(const JanbakApp());
}

class JanbakApp extends StatefulWidget {
  const JanbakApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _JanbakAppState? state = context.findAncestorStateOfType<_JanbakAppState>();
    state?.changeLanguage(newLocale);
  }

  @override
  State<JanbakApp> createState() => _JanbakAppState();
}

class _JanbakAppState extends State<JanbakApp> {
  Locale _currentLocale = const Locale('ar', 'AE');

  void changeLanguage(Locale locale) {
    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'جنبك - Janbak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: _currentLocale,
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const LoginScreen(),
    );
  }
}