// lib/features/auth/data/repositories/auth_repository_impl.dart

import 'package:firebase_auth/firebase_auth.dart' as fa;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janbak_delivery/core/constants/app_constants.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';
import 'package:janbak_delivery/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    firebaseAuth: fa.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  );
});

class AuthRepositoryImpl implements AuthRepository {
  final fa.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  
  UserModel? _cachedUser;

  AuthRepositoryImpl({
    fa.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fa.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  UserModel? get currentUser => _cachedUser;

  @override
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection(AppConstants.usersCollection).doc(uid).get();
      if (doc.exists && doc.data() != null) {
        _cachedUser = UserModel.fromMap(doc.data()!, doc.id);
        return _cachedUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final uid = credential.user?.uid;
    if (uid == null) throw Exception('فشل في إنشاء الحساب');

    final userModel = UserModel(
      uid: uid,
      email: email,
      name: name,
      phone: phone,
      role: role,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(userModel.toMap());

    _cachedUser = userModel;
  }

  @override
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    
    if (credential.user != null) {
      await getUserProfile(credential.user!.uid);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    _cachedUser = null;
  }
}