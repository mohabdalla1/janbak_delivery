// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';
import 'auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    // إنشاء مستخدم تجريبي بدورة دور عميل (customer) للتجربة
    _currentUser = UserModel(
      uid: 'usr_janbak_101',
      name: 'محمد إبراهيم',
      phone: phone,
      role: UserRole.customer,
      token: 'mock_token_123456',
    );

    return _currentUser!;
  }
  // أضف تنفيذ دالة register داخل AuthRepositoryImpl:

@override
Future<UserModel> register({
  required String name,
  required String phone,
  required String password,
  required UserRole role,
}) async {
  await Future.delayed(const Duration(seconds: 1)); // محاكاة طلب API

  _currentUser = UserModel(
    uid: 'usr_${DateTime.now().millisecondsSinceEpoch}',
    name: name,
    phone: phone,
    role: role,
    token: 'mock_token_${DateTime.now().millisecondsSinceEpoch}',
  );

  return _currentUser!;
}

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }
}