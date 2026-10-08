// lib/features/driver/presentation/screens/driver_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // دالة لبدء الرحلة، التحقق من الـ GPS، وتحديث الحالة في قاعدة البيانات
  Future<void> _startJourney(BuildContext context, String orderId, String customerAddress) async {
    // 1. التحقق مما إذا كانت خدمة الموقع (GPS) مفعلة
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('خدمة الموقع معطلة (GPS)'),
            content: const Text('الرجاء تشغيل خدمة تحديد الموقع (GPS) للمتابعة وبدء رحلة التوصيل.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () async {
                  Navigator.pop(context);
                  await Geolocator.openLocationSettings();
                },
                child: const Text('فتح الإعدادات', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
      return;
    }

    // 2. تحديث حالة الطلب في Firestore ليظهر للعميل في التتبع الحي
    await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
      'deliveryStatus': 'on_the_way',
    });

    if (context.mounted) {
      // 3. عرض نافذة تفاصيل الموقع وعنوان العميل مع زر فتح الخريطة
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('بدء الرحلة بنجاح 🚀', style: TextStyle(color: Colors.teal)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('عنوان العميل:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Text(customerAddress.isNotEmpty ? customerAddress : 'لا يوجد عنوان محدد', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              const Text('تم تحديث حالة التتبع للعميل. يمكنك الآن الانتقال إلى موقع العميل عبر الخريطة.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إغلاق', style: TextStyle(color: Colors.teal)),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: () async {
                final query = Uri.encodeComponent(customerAddress);
                final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تعذر فتح الخريطة'), backgroundColor: Colors.red),
                  );
                }
              },
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text('فتح في الخريطة', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }
  }

  // نافذة لعرض محتويات الطلب والمنتجات والكميات بالتفصيل
  void _showOrderDetailsDialog(BuildContext context, Map<String, dynamic> orderData, String orderId) {
    final List items = orderData['items'] ?? [];
    final customerEmail = orderData['customerEmail'] ?? 'غير معروف';
    final totalPrice = orderData['totalPrice'] ?? 0.0;
    final deliveryFee = orderData['deliveryFee'] ?? 0.0;
    final customerAddress = orderData['address'] ?? 'العنوان غير متوفر';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تفاصيل الطلب #${orderId.substring(0, 6)}', style: const TextStyle(color: Colors.teal)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text('العميل: $customerEmail', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('العنوان: $customerAddress', style: const TextStyle(color: Colors.grey)),
              const Divider(),
              const Text('المنتجات المطلوبة:', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item['name']} (×${item['quantity'] ?? 1})')),
                        Text('${(item['price'] as num) * (item['quantity'] ?? 1)} ج.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('سعر التوصيل:'),
                  Text('$deliveryFee ج.س', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('$totalPrice ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق', style: TextStyle(color: Colors.teal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم السائق - جنبَك'),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          tabs: const [
            Tab(text: 'الطلبات المتاحة', icon: Icon(Icons.delivery_dining)),
            Tab(text: 'طلباتي الحالية', icon: Icon(Icons.local_shipping)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) context.go('/login');
            },
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('الرجاء تسجيل الدخول مجدداً'))
          : TabBarView(
              controller: _tabController,
              children: [
                // ---------------- Tab 1: الطلبات غير المسندة والمتاحة للقَبول ----------------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الطلبات الجاهزة للتوصيل:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .where('deliveryStatus', isEqualTo: 'unassigned')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.hourglass_empty, size: 64, color: Colors.grey),
                                    SizedBox(height: 12),
                                    Text('لا توجد طلبات متاحة للتوصيل حالياً', style: TextStyle(fontSize: 16, color: Colors.grey)),
                                  ],
                                ),
                              );
                            }

                            final orders = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                final data = order.data() as Map<String, dynamic>;
                                final orderId = order.id;
                                final totalPrice = data['totalPrice'] ?? 0.0;
                                final deliveryFee = data['deliveryFee'] ?? 0.0;

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('طلب رقم: #${orderId.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            TextButton(
                                              onPressed: () => _showOrderDetailsDialog(context, data, orderId),
                                              child: const Text('عرض المنتجات', style: TextStyle(color: Colors.teal)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('إجمالي الطلب: $totalPrice ج.س'),
                                        Text('رسوم التوصيل: $deliveryFee ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                        const SizedBox(height: 12),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                                            onPressed: () async {
                                              await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                                                'deliveryStatus': 'assigned',
                                                'driverId': user.uid,
                                              });
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  const SnackBar(content: Text('تم قبول الطلب بنجاح! انتقل لتبويب طلباتي الحالية 🚀'), backgroundColor: Colors.teal),
                                                );
                                              }
                                            },
                                            child: const Text('قبول الطلب للتوصيل', style: TextStyle(color: Colors.white)),
                                          ),
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
                ),

                // ---------------- Tab 2: طلبات السائق الحالية وتحديث الحالات ----------------
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('طلباتك قيد التوصيل والمكتملة:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('orders')
                              .where('driverId', isEqualTo: user.uid)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('لم تقم بقبول أي طلبات حتى الآن', style: TextStyle(fontSize: 16, color: Colors.grey)),
                              );
                            }

                            final orders = snapshot.data!.docs;

                            return ListView.builder(
                              itemCount: orders.length,
                              itemBuilder: (context, index) {
                                final order = orders[index];
                                final data = order.data() as Map<String, dynamic>;
                                final orderId = order.id;
                                final deliveryStatus = data['deliveryStatus'] ?? 'assigned';
                                final deliveryFee = data['deliveryFee'] ?? 0.0;
                                final customerEmail = data['customerEmail'] ?? 'عميل';
                                final customerAddress = data['address'] ?? 'العنوان غير متوفر';

                                String statusLabel = 'تم القبول (بانتظار بدء الرحلة)';
                                Color statusColor = Colors.orange;

                                if (deliveryStatus == 'on_the_way') {
                                  statusLabel = 'في الطريق للعميل 🚀';
                                  statusColor = Colors.purple;
                                } else if (deliveryStatus == 'picked_up') {
                                  statusLabel = 'تم الاستلام وفي الطريق';
                                  statusColor = Colors.blue;
                                } else if (deliveryStatus == 'delivered') {
                                  statusLabel = 'تم التوصيل بنجاح ✅';
                                  statusColor = Colors.green;
                                }

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text('طلب #${orderId.substring(0, 6)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                            Chip(
                                              label: Text(statusLabel, style: const TextStyle(color: Colors.white, fontSize: 11)),
                                              backgroundColor: statusColor,
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text('العميل: $customerEmail'),
                                        Text('العنوان: $customerAddress', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                                        Text('أرباح التوصيل: $deliveryFee ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: OutlinedButton(
                                                onPressed: () => _showOrderDetailsDialog(context, data, orderId),
                                                child: const Text('المنتجات'),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (deliveryStatus != 'delivered')
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    backgroundColor: deliveryStatus == 'assigned'
                                                        ? Colors.teal
                                                        : deliveryStatus == 'on_the_way'
                                                            ? Colors.blue
                                                            : Colors.green,
                                                  ),
                                                  onPressed: () async {
                                                    if (deliveryStatus == 'assigned') {
                                                      // الضغط على زر "بداية الرحلة"
                                                      await _startJourney(context, orderId, customerAddress);
                                                    } else if (deliveryStatus == 'on_the_way') {
                                                      // استلام الطلب من التاجر
                                                      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                                                        'deliveryStatus': 'picked_up',
                                                      });
                                                    } else if (deliveryStatus == 'picked_up') {
                                                      // إتمام التوصيل
                                                      await FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                                                        'deliveryStatus': 'delivered',
                                                        'status': 'completed',
                                                      });
                                                    }
                                                  },
                                                  child: Text(
                                                    deliveryStatus == 'assigned'
                                                        ? 'بداية الرحلة'
                                                        : deliveryStatus == 'on_the_way'
                                                            ? 'استلمت الطلب'
                                                            : 'تم التسليم',
                                                    style: const TextStyle(color: Colors.white),
                                                  ),
                                                ),
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
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}