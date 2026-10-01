import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/theme/app_theme.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController imageUrlController = TextEditingController();

  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    imageUrlController.dispose();
    super.dispose();
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // حفظ المنتج في فايرستور
      await FirebaseFirestore.instance.collection('products').add({
        'merchantId': user.uid,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': double.parse(priceController.text.trim()),
        'imageUrl': imageUrlController.text.trim().isEmpty
            ? 'https://via.placeholder.com/150'
            : imageUrlController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إضافة المنتج بنجاح!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إضافة منتج جديد - جنبك'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'أدخل تفاصيل المنتج الجديد لعرضه للعملاء',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 14),
              ),
              const SizedBox(height: 20),

              // اسم المنتج
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'اسم المنتج',
                  prefixIcon: const Icon(Icons.shopping_bag_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال اسم المنتج' : null,
              ),
              const SizedBox(height: 16),

              // وصف المنتج
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف المنتج',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال وصف المنتج' : null,
              ),
              const SizedBox(height: 16),

              // السعر
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'السعر (بالجنيه)',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value!.isEmpty ? 'الرجاء إدخال السعر' : null,
              ),
              const SizedBox(height: 16),

              // رابط الصورة (Image URL)
              TextFormField(
                controller: imageUrlController,
                decoration: InputDecoration(
                  labelText: 'رابط صورة المنتج (URL)',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              // زر الحفظ
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProduct,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('حفظ ونشر المنتج', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}