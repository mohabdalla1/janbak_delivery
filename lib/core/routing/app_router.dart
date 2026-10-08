// lib/core/router/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

// استيراد الشاشات الأساسية
import 'package:janbak_delivery/features/auth/presentation/screens/login_screen.dart';
import 'package:janbak_delivery/features/auth/presentation/screens/splash_screen.dart';
import 'package:janbak_delivery/features/auth/presentation/screens/register_screen.dart';
import 'package:janbak_delivery/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:janbak_delivery/features/customer/presentation/screens/customer_screen.dart';
import 'package:janbak_delivery/features/customer/presentation/screens/customer_cart_screen.dart';
import 'package:janbak_delivery/features/merchant/presentation/screens/merchant_screen.dart';
import 'package:janbak_delivery/features/driver/presentation/screens/driver_dashboard_screen.dart';

// تعريف appRouterProvider ليتطابق مع الاستدعاء في app.dart
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: FirebaseAuth.instance.currentUser == null ? '/login' : '/customer',
    routes: [
      // 0. شاشة البداية (Splash)
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // 1. تسجيل الدخول
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // 2. إنشاء حساب جديد مع استقبال الدور المبدئي (ان وجد)
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          final initialRole = state.extra as String?;
          return RegisterScreen(initialRole: initialRole);
        },
      ),

      // 3. نسيت كلمة المرور
      GoRoute(
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 4. واجهة العميل الرئيسية
      GoRoute(
        path: '/customer',
        name: 'customer',
        builder: (context, state) => const CustomerScreen(),
      ),

      // 5. شاشة السلة والخريطة وحساب التوصيل
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) {
          final extraData = state.extra as Map<String, dynamic>? ?? {};
          final merchantId = extraData['merchantId'] as String? ?? '';
          final cartItems = (extraData['cartItems'] as List?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [];
          final itemsTotal = (extraData['itemsTotal'] as num?)?.toDouble() ?? 0.0;

          return CustomerCartScreen(
            merchantId: merchantId,
            cartItems: cartItems,
            itemsTotal: itemsTotal,
          );
        },
      ),

      // 6. لوحة تحكم التاجر
      GoRoute(
        path: '/merchant',
        name: 'merchant',
        builder: (context, state) => const MerchantDashboardScreen(),
      ),

      // 7. لوحة تحكم السائق
      GoRoute(
        path: '/driver',
        name: 'driver',
        builder: (context, state) => const DriverDashboardScreen(),
      ),
    ],

    // إعادة التوجيه التلقائي للمستخدمين غير المسجلين
    redirect: (context, state) {
      final loggedIn = FirebaseAuth.instance.currentUser != null;
      final loggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password';

      if (!loggedIn && !loggingIn) return '/login';
      if (loggedIn && loggingIn) return '/customer';
      return null;
    },
  );
});