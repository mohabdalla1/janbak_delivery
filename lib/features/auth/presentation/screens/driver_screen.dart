import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:url_launcher/url_launcher.dart';

class DriverScreen extends ConsumerWidget {
  const DriverScreen({super.key});

  Future<void> _openMapRoute(String merchantAddress, String customerAddress) async {
    final origin = Uri.encodeComponent(merchantAddress);
    final destination = Uri.encodeComponent(customerAddress);
    final url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=$origin&destination=$destination');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDriverEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('لوحة السائق / الكابتن - جنبَك', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.indigo,
          elevation: 0,
          bottom: const TabBar(
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'الطلبات المتاحة', icon: Icon(Icons.list_alt)),
              Tab(text: 'طلباتي النشطة', icon: Icon(Icons.local_shipping)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await ref.read(authRepositoryProvider).signOut();
              },
              tooltip: 'تسجيل الخروج',
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // التبويب الأول: الطلبات المتاحة (قيد الانتظار)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('status', isEqualTo: 'قيد الانتظار')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('لا توجد طلبات متاحة حالياً للتوصيل.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final docId = docs[index].id;
                    final data = docs[index].data() as Map<String, dynamic>;
                    final customerAddress = data['customerAddress'] ?? 'عنوان غير متوفر';
                    final totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
                    final items = (data['items'] as List<dynamic>? ) ?? [];
                    final shortId = docId.length > 6 ? docId.substring(0, 6).toUpperCase() : docId;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('طلب رقم: #$shortId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                                Text('$totalPrice ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16)),
                              ],
                            ),
                            const Divider(),
                            const SizedBox(height: 4),
                            Text('وجهة التوصيل: $customerAddress', style: const TextStyle(fontSize: 14)),
                            const SizedBox(height: 8),
                            Text('عدد المنتجات: ${items.length}', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () async {
                                  try {
                                    await FirebaseFirestore.instance.collection('orders').doc(docId).update({
                                      'status': 'جاري التوصيل',
                                      'driverEmail': currentDriverEmail,
                                    });
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم قبول الطلب بنجاح! انتقل إلى طلباتك النشطة.'), backgroundColor: Colors.teal),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                                  }
                                },
                                icon: const Icon(Icons.check_circle, color: Colors.white),
                                label: const Text('قبول الطلب وتوصيله', style: TextStyle(color: Colors.white)),
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

            // التبويب الثاني: طلباتي النشطة الخاصة بهذا السائق
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .where('driverEmail', isEqualTo: currentDriverEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('ليس لديك طلبات نشطة حالياً.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                  );
                }

                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  padding: const EdgeInsets.all(12),
                  itemBuilder: (context, index) {
                    final docId = docs[index].id;
                    final data = docs[index].data() as Map<String, dynamic>;
                    final status = data['status'] ?? 'جاري التوصيل';
                    final customerAddress = data['customerAddress'] ?? 'عنوان غير متوفر';
                    final totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
                    final merchantId = data['merchantId'] ?? '';
                    final shortId = docId.length > 6 ? docId.substring(0, 6).toUpperCase() : docId;

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance.collection('users').doc(merchantId).get(),
                      builder: (context, merchantSnapshot) {
                        String merchantAddress = 'عنوان المتجر';
                        if (merchantSnapshot.hasData && merchantSnapshot.data!.exists) {
                          final mData = merchantSnapshot.data!.data() as Map<String, dynamic>;
                          merchantAddress = mData['storeAddress'] ?? mData['address'] ?? 'عنوان المتجر';
                        }

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('طلب رقم: #$shortId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.indigo)),
                                    Chip(
                                      label: Text(status, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                      backgroundColor: status == 'تم التوصيل' ? Colors.green : Colors.orange,
                                    ),
                                  ],
                                ),
                                const Divider(),
                                Text('موقع المتجر: $merchantAddress', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                const SizedBox(height: 4),
                                Text('وجهة العميل: $customerAddress', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text('الإجمالي: $totalPrice ج.س', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.teal,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: () => _openMapRoute(merchantAddress, customerAddress),
                                        icon: const Icon(Icons.map, size: 16, color: Colors.white),
                                        label: const Text('الخريطة', style: TextStyle(color: Colors.white)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.green,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                        ),
                                        onPressed: status == 'تم التوصيل' ? null : () async {
                                          try {
                                            await FirebaseFirestore.instance.collection('orders').doc(docId).update({
                                              'status': 'تم التوصيل',
                                            });
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('تم تحديث الطلب إلى "تم التوصيل" بنجاح! 🎉')),
                                            );
                                          } catch (e) {
                                            if (!context.mounted) return;
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                                          }
                                        },
                                        icon: const Icon(Icons.done_all, size: 16, color: Colors.white),
                                        label: const Text('تم التوصيل', style: TextStyle(color: Colors.white)),
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}