<<<<<<< HEAD
=======
// lib/core/router/app_router.dart

>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:janbak_delivery/features/merchant/presentation/screens/merchant_products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/customer/presentation/screens/customer_screen.dart';
import '../../features/merchant/presentation/screens/merchant_screen.dart';
import '../../features/driver/presentation/screens/driver_screen.dart';

/// صفحة الـ Splash التي تفحص حالة المستخدم وتوجهه تلقائياً حسبدوره
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // انتظار بسيط لضمان تحميل البيئة وعرض الشعار/التحميل
    await Future.delayed(const Duration(milliseconds: 800));
    final user = FirebaseAuth.instance.currentUser;
    if (!mounted) return;

    if (user == null) {
      context.go('/login');
    } else {
      try {
        // جلب دور المستخدم من قاعدة البيانات
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!mounted) return;

        if (userDoc.exists) {
          final role = userDoc.data()?['role'];

          // توجيه المستخدم حسب دوره المخصص
          switch (role) {
            case 'customer':
              context.go('/customer');
              break;
            case 'merchant':
              context.go('/merchant');
              break;
            case 'driver':
              context.go('/driver');
              break;
            default:
              context.go('/customer');
          }
        } else {
          context.go('/login');
        }
      } catch (e) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ),
    );
  }
}

/// إعدادات الـ GoRouter المستقرة
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
=======

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
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
    routes: [
      // 0. شاشة البداية (Splash)
      GoRoute(
<<<<<<< HEAD
        path: '/splash',
=======
        path: '/',
        name: 'splash',
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
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
<<<<<<< HEAD
=======
        path: '/forgot-password',
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // 4. واجهة العميل الرئيسية
      GoRoute(
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
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
      GoRoute(
  path: '/merchant/products',
  builder: (context, state) => const MerchantProductsScreen(),
),
    ],
<<<<<<< HEAD
=======

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
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
  );
});