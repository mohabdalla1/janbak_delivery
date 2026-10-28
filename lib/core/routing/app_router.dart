import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:janbak_delivery/features/merchant/presentation/screens/merchant_products_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const CustomerScreen(),
      ),
      GoRoute(
        path: '/merchant',
        builder: (context, state) => const MerchantScreen(),
      ),
      GoRoute(
        path: '/driver',
        builder: (context, state) => const DriverScreen(),
      ),
      GoRoute(
  path: '/merchant/products',
  builder: (context, state) => const MerchantProductsScreen(),
),
    ],
  );
});