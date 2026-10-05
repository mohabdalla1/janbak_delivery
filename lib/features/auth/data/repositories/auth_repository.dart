import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/core/constants/app_constants.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';

// المزود الخاص بمستودع المصادقة
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    firebaseAuth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  })  : _firebaseAuth = firebaseAuth,
        _firestore = firestore;

  // الحصول على المستخدم الحالي المسجل في Firebase Auth
  User? get currentUser => _firebaseAuth.currentUser;

  // جلب الملف الشخصي للمستخدم من فايرستور
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // تسجيل حساب جديد وحفظ بياناته في Firestore
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    // 1. إنشاء الحساب في Firebase Auth
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) throw Exception('فشل في إنشاء الحساب');

    // 2. بناء نموذج المستخدم مع تمرير الحقول المطلوبة (بما فيها updatedAt)
    final userModel = UserModel(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // 3. حفظ بيانات المستخدم في مجموعة المستخدمين بـ Firestore
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(userModel.toMap());
  }

  // تسجيل الدخول
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // تسجيل الخروج
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}