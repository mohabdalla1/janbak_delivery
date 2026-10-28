// lib/features/merchant/providers/product_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';

// Stream لجلب منتجات التاجر الحالي لحظياً
final merchantProductsProvider = StreamProvider.family<List<ProductModel>, String>((ref, merchantId) {
  return FirebaseFirestore.instance
      .collection('products')
      .where('merchantId', isEqualTo: merchantId)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.id, doc.data()))
          .toList());
});

// وحدة التحكم بالعمليات (إضافة، تعديل، حذف)
final productControllerProvider = Provider((ref) => ProductController());

class ProductController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // إضافة منتج جديد
  Future<void> addProduct(ProductModel product) async {
    await _firestore.collection('products').add(product.toMap());
  }

  // تعديل منتج
  Future<void> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    await _firestore.collection('products').doc(productId).update(updatedData);
  }

  // حذف منتج
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
}