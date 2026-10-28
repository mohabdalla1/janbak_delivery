import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // 1. استيراد حزمة الترجمة المحلية
import 'firebase_options.dart';
import 'core/routing/app_router.dart';

// المزود المسؤول عن حفظ وتغيير لغة التطبيق الحالية (عربي / إنجليزي)
final localeProvider = StateProvider<Locale>((ref) => const Locale('ar'));

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    const ProviderScope(
      child: JanbakApp(),
    ),
  );
}

class JanbakApp extends ConsumerWidget {
  const JanbakApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goRouter = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'جنبَك - Janbak Delivery',
      debugShowCheckedModeBanner: false,
      locale: currentLocale,
      supportedLocales: const [
        Locale('ar', ''),
        Locale('en', ''),
      ],
      // 2. إضافة وفود الترجمة المطلوبة لعناصر Material و TextFields
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
      ),
      routerConfig: goRouter,
    );
  }
}