import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

class MerchantProductsScreen extends ConsumerStatefulWidget {
  const MerchantProductsScreen({super.key});

  @override
  ConsumerState<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends ConsumerState<MerchantProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text(
          'إدارة منتجات المتجر',
          style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.go('/merchant'),
        ),
      ),
      body: currentUser == null
          ? const Center(child: Text('يرجى تسجيل الدخول مجدداً', style: TextStyle(fontFamily: 'Cairo')))
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث عن منتج...',
                      hintStyle: const TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Colors.teal),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('merchantId', isEqualTo: currentUser.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator(color: Colors.teal));
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'لا توجد منتجات مضافة حالياً',
                                style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Cairo', fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        );
                      }

                      final products = snapshot.data!.docs.where((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toString().toLowerCase();
                        return name.contains(_searchQuery);
                      }).toList();

                      if (products.isEmpty) {
                        return const Center(
                          child: Text(
                            'لا توجد نتائج تطابق بحثك',
                            style: TextStyle(fontFamily: 'Cairo', color: Colors.grey),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final productDoc = products[index];
                          final product = productDoc.data() as Map<String, dynamic>;
                          final productName = product['name'] ?? 'منتج بدون اسم';
                          final productPrice = product['price']?.toString() ?? '0';
                          final productDesc = product['description'] ?? 'لا يوجد وصف للمنتج';
                          final productImage = product['image'] ?? '';

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: productImage.isNotEmpty
                                        ? Image.network(
                                            productImage,
                                            width: 70,
                                            height: 70,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
                                          )
                                        : _buildPlaceholderImage(),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          productName,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          productDesc,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '$productPrice د.ل',
                                          style: const TextStyle(
                                            fontFamily: 'Cairo',
                                            color: Colors.teal,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  PopupMenuButton<String>(
                                    onSelected: (value) {
                                      if (value == 'delete') {
                                        _confirmDelete(context, productDoc.id);
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Row(
                                          children: [
                                            Icon(Icons.delete_outline, color: Colors.red, size: 20),
                                            SizedBox(width: 8),
                                            Text('حذف', style: TextStyle(fontFamily: 'Cairo', color: Colors.red)),
                                          ],
                                        ),
                                      ),
                                    ],
                                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddProductDialog(context, currentUser?.uid),
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.shopping_bag_outlined, color: Colors.teal, size: 30),
    );
  }

  void _confirmDelete(BuildContext context, String productId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنتج نهائياً؟', style: TextStyle(fontFamily: 'Cairo')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('products').doc(productId).delete();
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String? merchantId) {
    if (merchantId == null) return;
    
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    
    XFile? pickedImage;
    bool isUploading = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('إضافة منتج جديد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final ImagePicker picker = ImagePicker();
                    final image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      setDialogState(() {
                        pickedImage = image;
                      });
                    }
                  },
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.teal.shade200, style: BorderStyle.solid),
                    ),
                    child: pickedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: kIsWeb
                                ? Image.network(pickedImage!.path, fit: BoxFit.cover)
                                : Image.file(File(pickedImage!.path), fit: BoxFit.cover),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 35, color: Colors.teal),
                              SizedBox(height: 6),
                              Text('اضغط لاختيار صورة المنتج من الجهاز', style: TextStyle(fontFamily: 'Cairo', color: Colors.teal, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'اسم المنتج',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'السعر (د.ل)',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'وصف المنتج',
                    labelStyle: const TextStyle(fontFamily: 'Cairo'),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isUploading ? null : () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: isUploading
                  ? null
                  : () async {
                      if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                        setDialogState(() {
                          isUploading = true;
                        });

                        try {
                          String imageUrl = '';

                          if (pickedImage != null) {
                            final fileName = '${DateTime.now().millisecondsSinceEpoch}_${pickedImage!.name}';
                            final refStorage = FirebaseStorage.instance.ref().child('products_images/$fileName');

                            if (kIsWeb) {
                              final bytes = await pickedImage!.readAsBytes();
                              await refStorage.putData(bytes);
                            } else {
                              await refStorage.putFile(File(pickedImage!.path));
                            }

                            imageUrl = await refStorage.getDownloadURL();
                          }

                          await FirebaseFirestore.instance.collection('products').add({
                            'name': nameController.text.trim(),
                            'price': double.tryParse(priceController.text) ?? 0.0,
                            'description': descController.text.trim(),
                            'image': imageUrl,
                            'merchantId': merchantId,
                            'createdAt': FieldValue.serverTimestamp(),
                          });

                          if (context.mounted) Navigator.pop(context);
                        } catch (e) {
                          setDialogState(() {
                            isUploading = false;
                          });
                          // ignore: use_build_context_synchronously
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('حدث خطأ أثناء الرفع: $e'), backgroundColor: Colors.red),
                          );
                        }
                      }
                    },
              child: isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('حفظ المنتج', style: TextStyle(fontFamily: 'Cairo')),
            ),
          ],
        ),
      ),
    );
  }
}