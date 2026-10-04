import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/user_model.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);

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
    redirect: (context, state) async {
      final firebaseUser = authRepo.currentUser;
      final isLoggingIn = state.matchedLocation == '/login';

      if (firebaseUser == null) {
        return isLoggingIn ? null : '/login';
      }

      final profile = await authRepo.getUserProfile(firebaseUser.uid);
      if (profile == null) {
        return '/login';
      }

      switch (profile.role) {
        case UserRole.customer:
          return '/customer';
        case UserRole.merchant:
          return '/merchant';
        case UserRole.driver:
          return '/driver';
        case UserRole.admin:
          return '/customer';
      }
    },
  );
});