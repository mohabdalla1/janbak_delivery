import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/user_model.dart';

// 1. مزود لمراقبة وحفظ بيانات الملف الشخصي للمستخدم الحالي
final userProfileProvider = FutureProvider<UserModel?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  final user = authRepo.currentUser;
  if (user == null) return null;
  return await authRepo.getUserProfile(user.uid);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final profileAsync = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('تسجيل الدخول - جنبَك')),
        ),
      ),
      GoRoute(
        path: '/customer',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('لوحة العميل - جنبَك')),
        ),
      ),
      GoRoute(
        path: '/merchant',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('لوحة التاجر')),
        ),
      ),
      GoRoute(
        path: '/driver',
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('لوحة السائق')),
        ),
      ),
    ],
    redirect: (context, state) {
      final firebaseUser = authRepo.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';
      final isSplash = state.matchedLocation == '/splash';

      // 1. إذا لم يكن المستخدم مسجلاً في Firebase Auth
      if (firebaseUser == null) {
        return isLoggingIn ? null : '/login';
      }

      // 2. استخدام حالة التحميل اللحظية للملف الشخصي
      return profileAsync.when(
        data: (profile) {
          if (profile == null) return '/login';

          final targetPath = switch (profile.role) {
            UserRole.customer => '/customer',
            UserRole.merchant => '/merchant',
            UserRole.driver => '/driver',
            UserRole.admin => '/customer',
          };

          // توجيه المستخدم إلى لوحته المخصصة إذا كان في شاشة الدخول أو الـ Splash
          if (isLoggingIn || isSplash) {
            return targetPath;
          }

          return null; // السماح بالتنقل الطبيعي داخل اللوحة
        },
        loading: () => isSplash ? null : '/splash',
        error: (_, __) => '/login',
      );
    },
  );
});