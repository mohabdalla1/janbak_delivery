import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/domain/models/user_model.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
// استيراد الشاشات الفرعية
import '../../features/customer/presentation/screens/customer_screen.dart';
import '../../features/merchant/presentation/screens/merchant_screen.dart';
import '../../features/driver/presentation/screens/driver_screen.dart';


/// كلاس مساعد لتحويل Stream إلى Listenable ليعمل مع GoRouter
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// 1. مزود لجلب بيانات الملف الشخصي للمستخدم الحالي
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  if (user == null) return null;
  return await authRepo.getUserProfile(user.uid);
});

/// 2. إعدادات الـ GoRouter والتوجيه الذكي
final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(FirebaseAuth.instance.authStateChanges()),
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.teal)),
        ),
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
    ],
    redirect: (context, state) {
      final firebaseUser = authRepo.currentUser;
      final location = state.matchedLocation;
      final isLoggingIn = location == '/login';
      final isRegistering = location == '/register';
      final isSplash = location == '/splash';

      // أ. إذا لم يكن المستخدم مسجلاً في Firebase Auth
      if (firebaseUser == null) {
        return (isLoggingIn || isRegistering) ? null : '/login';
      }

      // ب. قراءة بيانات البروفايل للتحقق من دور المستخدم (Role)
      final profileAsync = ref.read(userProfileProvider);

      return profileAsync.when(
        data: (profile) {
          if (profile == null) return '/login';

          final targetPath = switch (profile.role) {
            UserRole.customer => '/customer',
            UserRole.merchant => '/merchant',
            UserRole.driver => '/driver',
            UserRole.admin => '/customer',
          };

          if (isLoggingIn || isRegistering || isSplash) {
            return targetPath;
          }

          return null;
        },
        loading: () => isSplash ? null : '/splash',
        error: (_, __) => '/login',
      );
    },
  );
});