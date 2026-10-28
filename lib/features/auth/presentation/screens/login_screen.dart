// lib/features/auth/presentation/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';
=======
import 'package:janbak_delivery/features/auth/presentation/controllers/auth_controller.dart';
import 'package:janbak_delivery/features/auth/domain/models/user_model.dart';
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

<<<<<<< HEAD
=======
  // دالة تسجيل الدخول المربوطة بـ AuthController مع التوجيه المباشر حسب الدور
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final role = await ref.read(authControllerProvider.notifier).signIn(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

<<<<<<< HEAD
      try {
        // 1. تنفيذ تسجيل الدخول
        await ref.read(authRepositoryProvider).signInWithEmailAndPassword(
              email: _emailController.text.trim(),
              password: _passwordController.text.trim(),
            );

        // 2. الحصول على المستخدم الحالي بعد النجاح
        final currentUser = FirebaseAuth.instance.currentUser;

        if (currentUser != null) {
          // 3. جلب دور المستخدم من قاعدة بيانات Firestore
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUser.uid)
              .get();

          if (!mounted) return;

          if (userDoc.exists) {
            final role = userDoc.data()?['role'];

            // 4. التوجيه بناءً على الدور المخزن
            switch (role) {
              case 'customer':
                context.go('/customer');
                break;
              case 'merchant':
                context.go('/merchant');
                break;
              case 'driver':
                context.go('/driver');
                break;
              default:
                context.go('/customer');
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('بيانات المستخدم غير موجودة في قاعدة البيانات'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (!mounted) return;
=======
      if (!mounted) return;

      if (role != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسجيل الدخول بنجاح!'),
            backgroundColor: Colors.teal,
          ),
        );

        // التوجيه المباشر والسلس بناءً على الدور
        switch (role) {
          case UserRole.customer:
            context.go('/customer');
            break;
          case UserRole.merchant:
            context.go('/merchant');
            break;
          case UserRole.driver:
            context.go('/driver');
            break;
          case UserRole.admin:
            context.go('/customer');
            break;
        }
      } else {
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('خطأ: تأكد من البريد الإلكتروني أو كلمة المرور'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
<<<<<<< HEAD
                  Center(
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 90,
                      width: 90,
                      fit: BoxFit.contain,
=======
                  // شعار التطبيق (تأكد من مطابقة مسار الصورة مع مسار الشعار في مشروعك وpubspec.yaml)
                  Center(
                    child: SizedBox(
                      height: 90,
                      width: 90,
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.contain,
                      ),
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'مرحباً بك مجدداً في "جنبَك"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'سجل دخولك للمتابعة واستكشاف الطلبات',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32),
<<<<<<< HEAD
=======

                  // حقل البريد الإلكتروني
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'البريد الإلكتروني',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال البريد الإلكتروني';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'يرجى إدخال كلمة المرور';
                      }
                      if (value.length < 6) {
                        return 'كلمة المرور يجب ألا تقل عن 6 أحرف';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
<<<<<<< HEAD
=======
Align(
  alignment: Alignment.centerLeft,
  child: TextButton(
    onPressed: () => context.push('/forgot-password'),
    child: const Text(
      'نسيت كلمة المرور؟',
      style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
    ),
  ),
),
                  // زر تسجيل الدخول
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('ليس لديك حساب؟'),
                      TextButton(
                        onPressed: () {
<<<<<<< HEAD
                          context.go('/register');
=======
                          context.go('/register'); 
>>>>>>> 96da7dbc061abcd5f1fe7e326427fb75d7b737ac
                        },
                        child: const Text('إنشاء حساب جديد'),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}