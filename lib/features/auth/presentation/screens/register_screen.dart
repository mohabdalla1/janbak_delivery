// lib/features/auth/presentation/screens/register_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final String? initialRole; // استقبال الدور المبدئي (إن وجد)

  const RegisterScreen({
    super.key,
    this.initialRole,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  late String _selectedRole;
  String _selectedCategory = 'مطاعم'; // خاص بالتجار (تصنيف المتجر)
  bool _isLoading = false;

  // إحداثيات الخريطة (افتراضياً مركز خريطة السودان/المنطقة)
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(15.3235, 35.5847);
  LatLng? _selectedLocation;

  final List<Map<String, String>> _roles = [
    {'key': 'customer', 'label': 'عميل 🛒'},
    {'key': 'merchant', 'label': 'تاجر 🏪'},
    {'key': 'driver', 'label': 'سائق 🛵'},
  ];

  final List<String> _merchantCategories = ['مطاعم', 'بقالة', 'صيدليات', 'أسر منتجة'];

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'customer';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد موقعك على الخريطة'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // إنشاء الحساب عبر Firebase Auth
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null) {
        // تجهيز بيانات المستخدم الأساسية والموقعية
        Map<String, dynamic> userData = {
          'uid': user.uid,
          'name': _nameController.text.trim(),
          'email': user.email ?? '',
          'role': _selectedRole,
          'address': _addressController.text.trim(),
          'latitude': _selectedLocation!.latitude,
          'longitude': _selectedLocation!.longitude,
          'profileCompleted': true,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // إذا كان التاجر، نضيف تصنيف المتجر
        if (_selectedRole == 'merchant') {
          userData['category'] = _selectedCategory;
        }

        // حفظ البيانات في مجموعة users في Firestore
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set(userData);
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحساب بنجاح! 🚀'), backgroundColor: Colors.teal),
      );

      // التوجيه التلقائي حسب الدور بعد التسجيل الناجح
      switch (_selectedRole) {
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
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل التسجيل: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء حساب جديد - جنبَك'),
        backgroundColor: Colors.teal,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.delivery_dining, size: 60, color: Colors.teal),
              const SizedBox(height: 8),
              const Text(
                'انضم إلى منصة جنبَك',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 20),

              // اسم المستخدم / المتجر
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _selectedRole == 'merchant' ? 'اسم المتجر' : 'الاسم الكامل',
                  prefixIcon: const Icon(Icons.person, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال الاسم' : null,
              ),
              const SizedBox(height: 16),

              // البريد الإلكتروني
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'البريد الإلكتروني',
                  prefixIcon: const Icon(Icons.email, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty || !value.contains('@')
                    ? 'يرجى إدخال بريد إلكتروني صحيح'
                    : null,
              ),
              const SizedBox(height: 16),

              // كلمة المرور
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور',
                  prefixIcon: const Icon(Icons.lock, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.length < 6
                    ? 'كلمة المرور يجب ألا تقل عن 6 أحرف'
                    : null,
              ),
              const SizedBox(height: 16),

              // نوع الحساب (الدور)
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'نوع الحساب',
                  prefixIcon: const Icon(Icons.badge, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role['key'],
                    child: Text(role['label']!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedRole = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // إذا كان الحساب "تاجر"، نظهر له قائمة تصنيف المتجر
              if (_selectedRole == 'merchant') ...[
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'تصنيف المتجر',
                    prefixIcon: const Icon(Icons.storefront, color: Colors.teal),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: _merchantCategories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
                const SizedBox(height: 16),
              ],

              // العنوان النصي التفصيلي
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان التفصيلي (مثال: الحي، الشارع)',
                  prefixIcon: const Icon(Icons.location_on, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال العنوان' : null,
              ),
              const SizedBox(height: 16),

              // خريطة لتحديد الموقع الجغرافي دقيقاً
              const Text(
                'حدد موقعك الجغرافي على الخريطة (انقر لتحديد النقطة):',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _defaultCenter,
                      initialZoom: 14.0,
                      onTap: (tapPosition, point) {
                        setState(() {
                          _selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.janbak.delivery',
                      ),
                      if (_selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _selectedLocation!,
                              width: 40,
                              height: 40,
                              child: const Icon(Icons.location_pin, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر التسجيل
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'إنشاء الحساب',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}