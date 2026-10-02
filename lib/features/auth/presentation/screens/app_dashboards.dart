import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/theme/app_theme.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

// ==========================================
// 1. لوحة تحكم التاجر (Merchant Dashboard)
// ==========================================
class MerchantDashboardScreen extends StatelessWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final merchantId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم التاجر - جنبك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        // جلب الطلبات الخاصة بهذا التاجر فقط
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('merchantId', isEqualTo: merchantId)
            .snapshots(),
        builder: (context, snapshot) {
          int totalOrders = 0;
          int completedOrders = 0;
          double totalEarnings = 0.0;

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            totalOrders = docs.length;
            for (var doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final status = data['status'] ?? '';
              final price = (data['totalPrice'] ?? 0).toDouble();

              if (status == 'تم التوصيل') {
                completedOrders++;
                totalEarnings += price;
              }
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ترحيب وزر إضافة منتج جديد
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مرحباً بك، التاجر الكريم',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AddProductScreen()),
                        );
                      },
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('منتج جديد'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // بطاقات الإحصائيات الحية
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        title: 'إجمالي الأرباح',
                        value: '$totalEarnings جنيه',
                        icon: Icons.account_balance_wallet_rounded,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        title: 'الطلبات المكتملة',
                        value: '$completedOrders / $totalOrders',
                        icon: Icons.check_circle_outline_rounded,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'الطلبات الواردة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                // قائمة الطلبات الحية
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40.0),
                      child: Text('لا توجد طلبات واردة حالياً', style: TextStyle(color: AppTheme.textGrey)),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final orderDoc = snapshot.data!.docs[index];
                      final orderData = orderDoc.data() as Map<String, dynamic>;
                      final orderId = orderDoc.id;
                      final status = orderData['status'] ?? 'قيد الانتظار';
                      final price = orderData['totalPrice'] ?? 0;
                      final customerName = orderData['customerName'] ?? 'عميل';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text('طلب #${orderId.substring(0, 6).toUpperCase()} - $customerName'),
                          subtitle: Text('الحالة: $status\nالسعر: $price جنيه'),
                          isThreeLine: true,
                          trailing: DropdownButton<String>(
                            value: ['قيد الانتظار', 'جاري التجهيز', 'في طريقها للتوصيل', 'تم التوصيل'].contains(status) 
                                ? status 
                                : 'قيد الانتظار',
                            items: ['قيد الانتظار', 'جاري التجهيز', 'في طريقها للتوصيل', 'تم التوصيل']
                                .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                                .toList(),
                            onChanged: (newStatus) async {
                              if (newStatus != null) {
                                await FirebaseFirestore.instance
                                    .collection('orders')
                                    .doc(orderId)
                                    .update({'status': newStatus});
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: .3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(title, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// ==========================================
// 2. لوحة تحكم السائق (Driver Dashboard)
// ==========================================
class DriverDashboardScreen extends StatelessWidget {
  const DriverDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم السائق - جنبك'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'أهلاً بك يا قائد التوصيل!\nقريباً ستظهر هنا الطلبات المتاحة للتوصيل.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: AppTheme.textGrey),
        ),
      ),
    );
  }
}