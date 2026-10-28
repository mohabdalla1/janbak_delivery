import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

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
              if (context.mounted) {
                context.go('/login');
              }
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
                children: [
                  ListTile(
                    leading: const Icon(Icons.inventory, color: Colors.teal),
                    title: const Text('إدارة منتجات المتجر'),
                    subtitle: const Text('إضافة، تعديل، أو حذف المنتجات'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // الانتقال إلى صفحة إدارة المنتجات
                      context.go('/merchant/products');
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.list_alt, color: Colors.orange),
                    title: const Text('الطلبات الواردة'),
                    subtitle: const Text('متابعة طلبات الزبائن وتجهيزها'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // يمكنك إضافة مسار الطلبات الواردة هنا لاحقاً
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: قسم الطلبات الواردة')),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.analytics, color: Colors.blue),
                    title: const Text('المبيعات والأرباح'),
                    subtitle: const Text('تقرير الأداء المالي اليومي والشهري'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // يمكنك إضافة مسار التقارير هنا لاحقاً
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('قريباً: قسم المبيعات والأرباح')),
                      );
                    },
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