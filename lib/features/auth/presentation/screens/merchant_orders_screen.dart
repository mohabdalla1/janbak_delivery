import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          ? const Center(
              child: Text('الرجاء تسجيل الدخول مجدداً'),
            )
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where(
                    'merchantId',
                    isEqualTo: currentUserId,
                  )
                  .orderBy(
                    'createdAt',
                    descending: true,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'حدث خطأ أثناء تحميل الطلبات:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.assignment_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد طلبات واردة حالياً',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'ستظهر الطلبات الجديدة هنا فور قيام العملاء بالطلب',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
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
                    final orderData =
                        orderDoc.data() as Map<String, dynamic>;

                    final orderId = orderDoc.id;
                    final status =
                        orderData['status'] as String? ?? 'pending';
                    final customerName =
                        orderData['customerName'] as String? ?? 'عميل جنبك';
                    final totalPrice = orderData['totalPrice'] ?? 0;
                    final items = orderData['items'] is List
                        ? List<dynamic>.from(orderData['items'] as List)
                        : <dynamic>[];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // رأس البطاقة: رقم الطلب والحالة
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'طلب #${_shortOrderId(orderId)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                _buildStatusBadge(status),
                              ],
                            ),

                            const Divider(height: 24),

                            // بيانات العميل
                            Row(
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'العميل: $customerName',
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            const Text(
                              'المنتجات المطلوبة:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            if (items.isEmpty)
                              const Text(
                                'لا توجد منتجات',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              ...items.map(
                                (item) {
                                  final itemData = item is Map
                                      ? Map<String, dynamic>.from(item)
                                      : <String, dynamic>{};

                                  final itemName =
                                      itemData['name'] ?? 'منتج';
                                  final quantity =
                                      itemData['quantity'] ?? 1;
                                  final price = itemData['price'] ?? 0;

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '• $itemName (×$quantity)',
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '$price جنيه',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),

                            const Divider(height: 24),

                            // السعر الإجمالي وأزرار التحكم
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                  child: Text(
                                    'المجموع: $totalPrice جنيه',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                _buildActionButtons(
                                  context,
                                  orderId,
                                  status,
                                ),
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

  String _shortOrderId(String orderId) {
    if (orderId.length <= 6) {
      return orderId.toUpperCase();
    }

    return orderId.substring(0, 6).toUpperCase();
  }

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
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    String orderId,
    String currentStatus,
  ) {
    if (currentStatus == 'pending') {
      return ElevatedButton.icon(
        onPressed: () {
          _updateOrderStatus(
            context,
            orderId,
            'processing',
          );
        },
        icon: const Icon(
          Icons.hourglass_top,
          size: 16,
        ),
        label: const Text('قبول وتجهيز'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
      );
    }

    if (currentStatus == 'processing') {
      return ElevatedButton.icon(
        onPressed: () {
          _updateOrderStatus(
            context,
            orderId,
            'ready',
          );
        },
        icon: const Icon(
          Icons.check_circle_outline,
          size: 16,
        ),
        label: const Text('جاهز للتوصيل'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple,
          foregroundColor: Colors.white,
        ),
      );
    }

    return const Flexible(
      child: Text(
        'مكتمل / بانتظار المندوب',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Future<void> _updateOrderStatus(
    BuildContext context,
    String orderId,
    String newStatus,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تحديث حالة الطلب بنجاح'),
        ),
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ أثناء التحديث: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
