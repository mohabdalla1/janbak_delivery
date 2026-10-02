import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'add_product_screen.dart'; // شاشة إضافة منتج جديد

class MerchantProductsScreen extends StatelessWidget {
  const MerchantProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة منتجات المتجر'),
        centerTitle: true,
      ),
      body: currentUserId == null
          ? const Center(child: Text('الرجاء تسجيل الدخول مجدداً'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('products')
                  .where('merchantId', isEqualTo: currentUserId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد منتجات مضافة حالياً',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text('اضغط على زر الإضافة في الأسفل لإضافة أول منتج', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final products = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index].data() as Map<String, dynamic>;
                    final productId = products[index].id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // صورة المنتج
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: product['imageUrl'] != null && product['imageUrl'].toString().isNotEmpty
                                  ? Image.network(
                                      product['imageUrl'],
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _placeholderImage(),
                                    )
                                  : _placeholderImage(),
                            ),
                            const SizedBox(width: 16),
                            // تفاصيل المنتج
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product['name'] ?? '',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    product['description'] ?? '',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${product['price']} جنيه',
                                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                ],
                              ),
                            ),
                            // زر الحذف
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () => _deleteProduct(context, productId),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('إضافة منتج جديد'),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 70,
      height: 70,
      color: Colors.grey[200],
      child: const Icon(Icons.fastfood_rounded, color: Colors.grey),
    );
  }

  void _deleteProduct(BuildContext context, String productId) async {
    bool confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('حذف المنتج'),
            content: const Text('هل أنت متأكد من رغبتك في حذف هذا المنتج نهائياً؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
              TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await FirebaseFirestore.instance.collection('products').doc(productId).delete();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حذف المنتج بنجاح')));
    }
  }
}