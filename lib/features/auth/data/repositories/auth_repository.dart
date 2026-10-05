// lib/features/auth/data/repositories/auth_repository.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';
import 'auth_repository_impl.dart';

/// موفر (Provider) خاص بـ Riverpod لتوفير نسخة من المستودع عبر التطبيق
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl();
});

/// واجهة مستودع المصادقة (Abstract Repository) التي تحدد العقود والوظائف الأساسية
abstract class AuthRepository {
  /// الحصول على المستخدم الحالي المسجل دخوله
  UserModel? get currentUser;

  /// تسجيل الدخول برقم الهاتف وكلمة المرور
  Future<UserModel> login({
    required String phone,
    required String password,
  });

  /// إنشاء حساب جديد (مستخدم، تاجر، أو مندوب توصيل)
  Future<UserModel> register({
    required String name,
    required String phone,
    required String password,
    required UserRole role,
  });

  /// جلب ملف المستخدم بناءً على الـ UID
  Future<UserModel?> getUserProfile(String uid);

  /// تسجيل الخروج
  Future<void> logout();
}