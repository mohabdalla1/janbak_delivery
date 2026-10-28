// lib/features/auth/domain/auth_repository.dart

import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  /// الحصول على المستخدم الحالي المخزن مؤقتاً
  UserModel? get currentUser;

  /// جلب بيانات الملف الشخصي للمستخدم من قاعدة البيانات باستخدام الـ UID
  Future<UserModel?> getUserProfile(String uid);

  /// إنشاء حساب جديد بالبريد وكلمة المرور مع حفظ بيانات المستخدم ودوره
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  /// تسجيل الدخول بالبريد وكلمة المرور
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// تسجيل الخروج
  Future<void> signOut();
}