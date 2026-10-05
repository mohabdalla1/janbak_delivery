import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/auth/data/repositories/auth_repository.dart';

class DriverScreen extends ConsumerWidget {
  const DriverScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                const Text(
                  'أهلاً بك، كابتن 🛵',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo),
                ),
                Switch(
                  value: true,
                  onChanged: (val) {
                    // TODO: تغيير حالة التوفر (متاح / غير متاح)
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'الطلبات المتاحة للتوصيل قريب منك:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
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
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                        child: const Text('قبول الطلب', style: TextStyle(color: Colors.white)),
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