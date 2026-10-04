import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../domain/user_model.dart';

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(authRepository: ref.watch(authRepositoryProvider));
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  final AuthRepository _authRepository;

  AuthController({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const AsyncData(null));

  /// تسجيل الدخول بواسطة البريد الإلكتروني وكلمة المرور
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    });
  }

  /// إنشاء حساب جديد وتخزين البيانات في Firestore
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      // 1. إنشاء الحساب في Firebase Auth
      final userCredential = await _authRepository.signUpWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // 2. تجهيز بيانات المستخدم
        final newUser = UserModel(
          uid: userCredential.user!.uid,
          name: name,
          phone: phone,
          email: email,
          role: role,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // 3. حفظ بيانات البروفايل في Firestore
        await _authRepository.createUserProfile(newUser);
      }
    });
  }

  /// تسجيل الخروج
  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _authRepository.signOut());
  }
}