import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/customer/presentation/screens/customer_home_screen.dart';
import 'app_dashboards.dart'; // للتوجه للواجهات بعد التسجيل

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // متغيرات التحكم في إظهار أو إخفاء كلمة المرور وتأكيدها
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // الدور الافتراضي المحدد في القائمة المنسدلة
  String selectedRole = 'customer';
  
  // المدينة الافتراضية (حلفا الجديدة كبداية أولية)
  String selectedCity = 'حلفا الجديدة';
  
  bool isLoading = false;

  final List<Map<String, String>> roles = [
    {'value': 'customer', 'title': 'عميل'},
    {'value': 'merchant', 'title': 'تاجر'},
    {'value': 'driver', 'title': 'سائق'},
  ];

  // قائمة مدن السودان (تبدأ بحلفا الجديدة، وقابلة للتوسعة لاحقاً)
  final List<String> sudanCities = [
    'حلفا الجديدة',
    'الخرطوم',
    'أم درمان',
    'بحري',
    'كسلا',
    'بورتسودان',
    'عطبرة',
    'المدني (ود مدني)',
    'القضارف',
    'الأبيض',
    'النيالا',
  ];

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'انضم إلى عائلة جنبك',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'أدخل بياناتك أدناه لإنشاء حساب جديد وتحديد دورك',
                  style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 32),

              // حقل الاسم الكامل
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // حقل البريد الإلكتروني
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // حقل رقم الهاتف
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'رقم الهاتف',
                  hintText: '09xxxxxxxx',
                  prefixIcon: const Icon(Icons.phone_android_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // قائمة منسدلة لاختيار المدينة (تبدأ بحلفا الجديدة)
              DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon: const Icon(Icons.location_city_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: sudanCities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCity = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // قائمة منسدلة لاختيار الدور
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'نوع الحساب (الدور)',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: roles.map((role) {
                  return DropdownMenuItem(
                    value: role['value'],
                    child: Text(role['title']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // حقل كلمة المرور مع زر الإظهار/الإخفاء
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textGrey,
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
              ),
              const SizedBox(height: 16),

              // حقل تأكيد كلمة المرور مع زر الإظهار/الإخفاء
              TextField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_reset_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppTheme.textGrey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // زر التسجيل
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSignup,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('إنشاء الحساب الان', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignup() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    // التحقق من الحقول الفارغة
    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إكمال جميع الحقول المطلوبة')),
      );
      return;
    }

    // التحقق من تطابق كلمة المرور
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('كلمتا المرور غير متطابقتين'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // 1. إنشاء الحساب في Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. حفظ بيانات المستخدم التفصيلية في Cloud Firestore ربطاً بـ UID
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'name': name,
        'email': email,
        'phone': phone,
        'city': selectedCity,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      // 3. التوجيه التلقائي لواجهة الدور الذي اختاره المستخدم
      Widget targetScreen;
      if (selectedRole == 'merchant') {
        targetScreen = const MerchantDashboardScreen();
      } else if (selectedRole == 'driver') {
        targetScreen = const DriverDashboardScreen();
      } else {
        targetScreen = const CustomerHomeScreen();
      }

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => targetScreen),
        (route) => false,
      );

    } on FirebaseAuthException catch (e) {
      setState(() {
        isLoading = false;
      });

      String message = 'حدث خطأ أثناء إنشاء الحساب';
      if (e.code == 'weak-password') {
        message = 'كلمة المرور ضعيفة جداً';
      } else if (e.code == 'email-already-in-use') {
        message = 'البريد الإلكتروني مستخدم مسبقاً لحساب آخر';
      } else if (e.code == 'invalid-email') {
        message = 'صيغة البريد الإلكتروني غير صالحة';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ غير متوقع: $e'), backgroundColor: Colors.red),
      );
    }
  }
}