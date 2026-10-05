// lib/features/auth/presentation/controllers/auth_controller.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';

final authControllerProvider = AsyncNotifierProvider<AuthController, UserModel?>(() {
  return AuthController();
});

class AuthController extends AsyncNotifier<UserModel?> {
  @override
  FutureOr<UserModel?> build() {
    return null;
  }

  Future<void> login({required String phone, required String password}) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await authRepository.login(phone: phone, password: password);
    });
  }

  /// دالة إنشاء حساب جديد
  Future<void> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  }) async {
    final authRepository = ref.read(authRepositoryProvider);
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return await authRepository.register(
        name: name,
        phone: phone,
        password: password,
        role: role,
      );
    });
  }
}