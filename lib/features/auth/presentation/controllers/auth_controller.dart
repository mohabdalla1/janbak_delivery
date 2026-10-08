// lib/features/auth/presentation/controllers/auth_controller.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/features/auth/domain/auth_repository.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

// المزود الخاص بالتحكم في عمليات المصادقة
final authControllerProvider = StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AsyncValue.data(null));

  // دالة التسجيل (متوافق مع استدعاء register_screen)
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    return signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );
  }

  // دالة إنشاء حساب جديد (الأساسية)
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
        name: name,
        phone: phone,
        role: role,
      );
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // دالة تسجيل الدخول (مُعدّلة لتُعيد الـ UserRole لتسهيل التوجيه)
  Future<UserRole?> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncValue.loading();
    try {
      // 1. تسجيل الدخول وجلب الملف الشخصي وتخزينه في _cachedUser تلقائياً
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. سحب المستخدم الحالي لمعرفة دوره
      final user = _authRepository.currentUser;
      
      state = const AsyncValue.data(null);
      
      // 3. إرجاع دور المستخدم
      return user?.role;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}