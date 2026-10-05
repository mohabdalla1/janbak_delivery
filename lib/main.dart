import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // هذا الملف يتم توليده تلقائياً في الخطوة 3
import 'core/routing/app_router.dart'; // استدعاء ملف الـ Router الخاص بك

void main() async {
  // 1. ضمان تهيئة ودائع الفلاتر
  WidgetsFlutterBinding.ensureInitialized();

  // 2. تهيئة Firebase باستخدام الخيارات الخاصة بالمنصة الحالية (Android/iOS/Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. تشغيل التطبيق مع تفعيل ProviderScope لـ Riverpod
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
    // جلب ملف الـ GoRouter الذي قمت بإعداده مسبقاً
    final goRouter = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'جنبَك - Janbak Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo', // أو الخط المعتمد لديك
      ),
      routerConfig: goRouter,
    );
  }
}