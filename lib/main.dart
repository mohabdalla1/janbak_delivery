import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // 1. استيراد خيارات الفايربيز الخاصة بمشروعك
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/services/notification_service.dart';

void main() async {
  // 1. إجبار الفلاتر على تهيئة الـ Binding
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 2. تهيئة فايربيس بالخيارات المحددة للمنصة الحالية
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // 3. تهيئة خدمة الإشعارات وانتظار اكتمالها
    await NotificationService.initNotifications();
  } catch (e) {
    debugPrint('خطأ رئيسي في تهيئة فايربيس أو الإشعارات: $e');
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