// lib/main.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_web_plugins/url_strategy.dart'; // أضف هذا السطر
import 'firebase_options.dart'; 
import 'core/routing/app_router.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تفعيل الروابط النظيفة بدون علامة # (تعمل بكفاءة على Firebase)
  usePathUrlStrategy();

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

    return MaterialApp.router(
      title: 'جنبَك - Janbak Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.teal,
        fontFamily: 'Cairo',
      ),
      routerConfig: goRouter,
    );
  }
}