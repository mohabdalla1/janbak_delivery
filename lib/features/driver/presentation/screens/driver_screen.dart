import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

// مزود محلي لحالة توفر السائق
final driverAvailabilityProvider = StateProvider<bool>((ref) => true);

class DriverScreen extends ConsumerWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAvailable = ref.watch(driverAvailabilityProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة السائق - جنبَك'),
        backgroundColor: Colors.indigo,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'أهلاً بك، كابتن 🛵',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo,
                  ),
                ),
                Switch(
                  value: isAvailable,
                  onChanged: (val) async {
                    ref.read(driverAvailabilityProvider.notifier).state = val;
                    
                    try {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .update({
                          'isAvailable': val,
                          'updatedAt': FieldValue.serverTimestamp(),
                        });
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('فشل تحديث الحالة: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isAvailable
                  ? 'حالتك الآن: متاح لتلقي الطلبات ✅'
                  : 'حالتك الآن: غير متاح ⛔',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isAvailable ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'الطلبات المتاحة للتوصيل قريب منك:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.indigoAccent,
                        child: Icon(Icons.delivery_dining, color: Colors.white),
                      ),
                      title: Text('طلب رقم #${1020 + index}'),
                      subtitle: const Text('من متجر: السعادة - إلى: حي الرياض'),
                      trailing: ElevatedButton(
                        onPressed: isAvailable
                            ? () {
                                // منطق قبول الطلب
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('قبول الطلب',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}