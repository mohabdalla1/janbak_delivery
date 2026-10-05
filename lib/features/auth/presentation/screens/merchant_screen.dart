import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/auth_repository.dart';

class MerchantScreen extends ConsumerWidget {
  const MerchantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة تحكم التاجر - جنبَك'),
        backgroundColor: Colors.teal,
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
            const Text(
              'مرحباً بك، شريك النجاح 📈',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(Icons.inventory, color: Colors.teal),
                    title: Text('إدارة منتجات المتجر'),
                    subtitle: Text('إضافة، تعديل، أو حذف المنتجات'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.list_alt, color: Colors.orange),
                    title: Text('الطلبات الواردة'),
                    subtitle: Text('متابعة طلبات الزبائن وتجهيزها'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  Divider(),
                  ListTile(
                    leading: Icon(Icons.analytics, color: Colors.blue),
                    title: Text('المبيعات والأرباح'),
                    subtitle: Text('تقرير الأداء المالي اليومي والشهري'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}