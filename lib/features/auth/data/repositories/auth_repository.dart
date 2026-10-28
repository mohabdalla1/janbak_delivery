import 'package:firebase_auth/firebase_auth.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';


abstract class AuthRepository {
  User? get currentUser;
  
  Future<UserModel?> getUserProfile(String uid);
  
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String phone,
    required UserRole role,
  });

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> signOut();
}