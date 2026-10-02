import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app_dashboards.dart';

class CompleteMerchantProfileScreen extends StatefulWidget {
  const CompleteMerchantProfileScreen({super.key});

  @override
  State<CompleteMerchantProfileScreen> createState() => _CompleteMerchantProfileScreenState();
}

class _CompleteMerchantProfileScreenState extends State<CompleteMerchantProfileScreen> {
  final TextEditingController storeNameController = TextEditingController();
  String? selectedActivity;
  bool isLoading = false;

  final List<String> merchantActivities = [
    'صيدلية',
    'مطعم',
    'كافيه',
    'مغلق',
    'سوبر ماركت',
    'شركة',
    'منتجات منزلية',
  ];

  @override
  void dispose() {
    storeNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إكمال بيانات المتجر'),
        automaticallyImplyLeading: false, // منع الرجوع للخلف لتعبئة البيانات الإجبارية
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'خطوة واحدة وتكون جاهزاً!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'أدخل اسم متجرك وحدد نشاطك التجاري ليبدأ العملاء في رؤيتك',
                style: TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // حقل اسم المتجر
              TextField(
                controller: storeNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المتجر / النشاط',
                  prefixIcon: const Icon(Icons.store_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // قائمة منسدلة للنشاط التجاري
              DropdownButtonFormField<String>(
                value: selectedActivity,
                decoration: InputDecoration(
                  labelText: 'نوع النشاط التجاري',
                  prefixIcon: const Icon(Icons.category_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: merchantActivities.map((activity) {
                  return DropdownMenuItem(value: activity, child: Text(activity));
                }).toList(),
                onChanged: (value) => setState(() => selectedActivity = value),
              ),
              const Spacer(),

              // زر الحفظ والانتقال لوحة التحكم
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveMerchantData,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ والانتقال لوحة التحكم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveMerchantData() async {
    final storeName = storeNameController.text.trim();

    if (storeName.isEmpty || selectedActivity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال اسم المتجر واختيار النشاط'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // تحديث مستند التاجر في Firestore بالبيانات الإضافية
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'storeName': storeName,
          'merchantActivity': selectedActivity,
          'isProfileCompleted': true,
        });
      }

      if (!mounted) return;
      setState(() => isLoading = false);

      // الانتقال لوحة تحكم التاجر نهائياً
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MerchantDashboardScreen()),
        (route) => false,
      );
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
      );
    }
  }
}