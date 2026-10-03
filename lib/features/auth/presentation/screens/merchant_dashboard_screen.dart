import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/theme/app_theme.dart';
import 'login_screen.dart';
import 'merchant_products_screen.dart';
import 'merchant_orders_screen.dart';
import 'add_product_screen.dart'; // افترض وجود صفحة إضافة المنتجات هنا

class MerchantDashboardScreen extends StatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  State<MerchantDashboardScreen> createState() =>
      _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends State<MerchantDashboardScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  bool _isUpdatingStatus = false;

  /// تسجيل الخروج بأمان مع التحقق من Context
  Future<void> _handleSignOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تسجيل الخروج، يرجى المحاولة لاحقاً'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// تحديث حالة الطلب في Firestore
  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    setState(() => _isUpdatingStatus = true);
    try {
      await FirebaseFirestore.instance
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم تحديث حالة الطلب إلى "$newStatus" بنجاح'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء تحديث حالة الطلب'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUpdatingStatus = false);
      }
    }
  }

  /// الانتقال إلى شاشة إضافة منتج جديد
  void _navigateToAddProduct() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddProductScreen(), // غير اسم الشاشة حسب مشروعك
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم التاجر'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: _handleSignOut,
          ),
        ],
      ),

      // *** زر الإضافة العائم (+) ***
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        label: const Text(
          'إضافة منتج',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // كارت معلومات التاجر
            _buildMerchantHeaderCard(),
            const SizedBox(height: 16),

            // أزرار التنقل السريع
            _buildQuickNavButtons(),
            const SizedBox(height: 24),

            // عنوان الطلبات الواردة
            const Text(
              'الطلبات الواردة الحديثة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // قائمة الطلبات الواردة من StreamBuilder
            _buildRecentOrdersStream(),
            
            // مساحة إضافية لتجنب تغطية FloatingActionButton للطلبات في الأسفل
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  /// كارت الترحيب وهويّة التاجر
  Widget _buildMerchantHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor,
            child: Icon(
              Icons.storefront_rounded,
              size: 35,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أهلاً بك، أيها التاجر',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentUser?.email ?? 'متجر جنبك الرئيسي',
                  style: const TextStyle(
                    color: AppTheme.textGrey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// أزرار التنقل السريع للطلبات والمنتجات
  Widget _buildQuickNavButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MerchantProductsScreen(),
                ),
              );
            },
            icon: const Icon(Icons.inventory_2_outlined),
            label: const Text('إدارة المنتجات'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MerchantOrdersScreen(),
                ),
              );
            },
            icon: const Icon(Icons.list_alt_rounded),
            label: const Text('كل الطلبات'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// بناء قائمة الطلبات الواردة الحديثة
  Widget _buildRecentOrdersStream() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24.0),
              child: Text(
                'حدث خطأ أثناء تحميل الطلبات',
                style: TextStyle(
                  color: Colors.red.shade700,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 60,
                    color: AppTheme.textGrey.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'لا توجد طلبات واردة حالياً',
                    style: TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderData = orders[index].data() as Map<String, dynamic>;
            final orderId = orders[index].id;
            final customerName = orderData['customerName'] ?? 'عميل جنبك';
            final orderStatus = orderData['status'] ?? 'قيد الانتظار';
            final totalPrice = orderData['totalPrice'] ?? '0';

            final shortOrderId = orderId.length >= 6
                ? orderId.substring(0, 6).toUpperCase()
                : orderId.toUpperCase();

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'طلب رقم: $shortOrderId',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.orange),
                          ),
                          child: Text(
                            orderStatus.toString(),
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      'العميل: $customerName',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الإجمالي: $totalPrice جنيه',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _isUpdatingStatus ||
                                  orderStatus == 'جاري التجهيز'
                              ? null
                              : () =>
                                  _updateOrderStatus(orderId, 'جاري التجهيز'),
                          icon: const Icon(
                            Icons.hourglass_top_rounded,
                            size: 16,
                          ),
                          label: const Text('قبول وتجهيز'),
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
    );
  }
}