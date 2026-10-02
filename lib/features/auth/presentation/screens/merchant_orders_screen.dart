import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MerchantOrdersScreen extends StatelessWidget {
  const MerchantOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الطلبات الواردة'),
        centerTitle: true,
      ),
      body: currentUserId == null
          ? const Center(child: Text('الرجاء تسجيل الدخول مجدداً'))
          : StreamBuilder<QuerySnapshot>(
              // جلب الطلبات التي تخص هذا التاجر وتكون مرتبة حسب الأحدث
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('merchantId', isEqualTo: currentUserId)
                  .orderBy('createdAt', descending: true)
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
                        Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد طلبات واردة حالياً',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text('ستظهر الطلبات الجديدة هنا فور قيام العملاء بالطلب', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                final orders = snapshot.data!.docs;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final orderDoc = orders[index];
                    final order = orderDoc.data() as Map<String, dynamic>;
                    final orderId = orderDoc.id;
                    
                    final status = order['status'] ?? 'pending';
                    final customerName = order['customerName'] ?? 'عميل جنبك';
                    final totalPrice = order['totalPrice'] ?? 0.0;
                    final items = order['items'] as List<dynamic>? ?? [];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // رأس البطاقة: رقم الطلب والحالة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'طلب #${orderId.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),
                            const Divider(height: 24),

                            // بيانات العميل
                            Row(
                              children: [
                                const Icon(Icons.person_outline, size: 18, color: Colors.grey),
                                const SizedBox(width: 8),
                                Text('العميل: $customerName', style: const TextStyle(fontSize: 14)),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // قائمة المنتجات المختصرة
                            const Text('المنتجات المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                            const SizedBox(height: 4),
                            ...items.map((item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('• ${item['name']} (×${item['quantity']})', style: const TextStyle(fontSize: 13)),
                                  Text('${item['price']} جنيه', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                ],
                              ),
                            )),

                            const Divider(height: 24),

                            // السعر الإجمالي وأزرار التحكم بالحالة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'المجموع: $totalPrice جنيه',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                _buildActionButtons(context, orderId, status),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  // شارة تلوين حالة الطلب
  Widget _buildStatusBadge(String status) {
    String text = 'قيد الانتظار';
    Color color = Colors.orange;

    if (status == 'processing') {
      text = 'جاري التجهيز';
      color = Colors.blue;
    } else if (status == 'ready') {
      text = 'جاهز للتوصيل';
      color = Colors.purple;
    } else if (status == 'completed') {
      text = 'مكتمل';
      color = Colors.green;
    } else if (status == 'cancelled') {
      text = 'ملغي';
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // أزرار تحديث حالة الطلب ديناميكياً
  Widget _buildActionButtons(BuildContext context, String orderId, String currentStatus) {
    if (currentStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: () => _updateOrderStatus(context, orderId, 'processing'),
        icon: const Icon(Icons.hourglass_top, size: 16),
        label: const Text('قبول وتجهيز'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
      );
    } else if (currentStatus == 'processing') {
      return ElevatedButton.icon(
        onPressed: () => _updateOrderStatus(context, orderId, 'ready'),
        icon: const Icon(Icons.check_circle_outline, size: 16),
        label: const Text('جاهز للتوصيل'),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
      );
    } else {
      return const Text('مكتمل / بانتظار المندوب', style: TextStyle(color: Colors.grey, fontSize: 12));
    }
  }

  // دالة تحديث الحالة في قاعدة البيانات
  void _updateOrderStatus(BuildContext context, String orderId, String newStatus) async {
    try {
      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم تحديث حالة الطلب بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ أثناء التحديث: $e'), backgroundColor: Colors.red),
      );
    }
  }
}