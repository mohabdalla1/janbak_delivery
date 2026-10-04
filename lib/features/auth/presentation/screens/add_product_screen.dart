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

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تسجيل الدخول أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final double? parsedPrice = double.tryParse(priceController.text.trim());
      if (parsedPrice == null) {
        throw Exception('السعر أدخل بشكل غير صحيح');
      }

      final String finalImageUrl = imageUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/150'
          : imageUrlController.text.trim();

      // حفظ المنتج في فايرستور
      await FirebaseFirestore.instance.collection('products').add({
        'merchantId': user.uid,
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'price': parsedPrice,
        'imageUrl': finalImageUrl,
        'isAvailable': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إضافة المنتج بنجاح!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'الرجاء إدخال اسم المنتج'
                    : null,
              ),
              const SizedBox(height: 16),

              // وصف المنتج
              TextFormField(
                controller: descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'وصف المنتج',
                  prefixIcon: const Icon(Icons.description_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'الرجاء إدخال وصف المنتج'
                    : null,
              ),
              const SizedBox(height: 16),

              // السعر
              TextFormField(
                controller: priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'السعر (بالجنيه)',
                  prefixIcon: const Icon(Icons.attach_money_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الرجاء إدخال السعر';
                  }
                  if (double.tryParse(value.trim()) == null) {
                    return 'الرجاء إدخال رقم صحيح';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // رابط الصورة (Image URL)
              TextFormField(
                controller: imageUrlController,
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}), // لإنعاش المعاينة
                decoration: InputDecoration(
                  labelText: 'رابط صورة المنتج (URL)',
                  prefixIcon: const Icon(Icons.image_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // معاينة الصورة إذا تم إدخال رابط
              if (imageUrlController.text.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrlController.text.trim(),
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 80,
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Text(
                          'رابط الصورة غير صالح',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const SizedBox(height: 20),

              // زر الحفظ
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _saveProduct,
                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'حفظ ونشر المنتج',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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