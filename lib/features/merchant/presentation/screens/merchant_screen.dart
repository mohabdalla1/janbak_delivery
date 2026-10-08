import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

class MerchantDashboardScreen extends ConsumerStatefulWidget {
  const MerchantDashboardScreen({super.key});

  @override
  ConsumerState<MerchantDashboardScreen> createState() => _MerchantDashboardScreenState();
}

class _MerchantDashboardScreenState extends ConsumerState<MerchantDashboardScreen> with SingleTickerProviderStateMixin {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم التاجر - جنبَك',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'منتجاتي', icon: Icon(Icons.inventory_2)),
            Tab(text: 'الطلبات الواردة', icon: Icon(Icons.list_alt)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          MerchantProductsTab(),
          MerchantOrdersTab(),
        ],
      ),
    );
  }
}

// ==========================================
// 1. تبويب منتجات التاجر
// ==========================================
class MerchantProductsTab extends StatefulWidget {
  const MerchantProductsTab({super.key});

  @override
  State<MerchantProductsTab> createState() => _MerchantProductsTabState();
}

class _MerchantProductsTabState extends State<MerchantProductsTab> {
  void _showAddProductDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController priceController = TextEditingController();
    final TextEditingController descController = TextEditingController();
    
    String? base64Image;
    XFile? pickedImageFile;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> pickImage() async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
              if (image != null) {
                final bytes = await image.readAsBytes();
                setStateDialog(() {
                  pickedImageFile = image;
                  base64Image = base64Encode(bytes);
                });
              }
            }

            return AlertDialog(
              title: const Text('إضافة منتج جديد'),
              content: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // اختيار صورة المنتج
                      GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          height: 120,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.teal.withValues(alpha: 0.5)),
                          ),
                          child: pickedImageFile != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: kIsWeb
                                      ? Image.network(pickedImageFile!.path, fit: BoxFit.cover)
                                      : Image.file(File(pickedImageFile!.path), fit: BoxFit.cover),
                                )
                              : const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_a_photo, size: 40, color: Colors.teal),
                                    SizedBox(height: 8),
                                    Text('انقر لاختيار صورة المنتج', style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  ],
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // اسم المنتج
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'اسم المنتج', border: OutlineInputBorder()),
                        validator: (val) => val == null || val.isEmpty ? 'يرجى إدخال اسم المنتج' : null,
                      ),
                      const SizedBox(height: 12),

                      // السعر
                      TextFormField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'السعر (ج.س)', border: OutlineInputBorder()),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'يرجى إدخال السعر';
                          if (double.tryParse(val) == null) return 'يرجى إدخال رقم صحيح';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // الوصف
                      TextFormField(
                        controller: descController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'وصف المنتج (اختياري)', border: OutlineInputBorder()),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                  onPressed: isSaving
                      ? null
                      : () async {
                          if (!_formKey.currentState!.validate()) return;
                          
                          setStateDialog(() => isSaving = true);
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) return;

                            await FirebaseFirestore.instance.collection('products').add({
                              'merchantId': user.uid,
                              'name': nameController.text.trim(),
                              'price': double.parse(priceController.text.trim()),
                              'description': descController.text.trim(),
                              'imageUrl': base64Image ?? '',
                              'createdAt': FieldValue.serverTimestamp(),
                            });

                            if (!context.mounted) return;
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('تمت إضافة المنتج بنجاح! 🚀'), backgroundColor: Colors.teal),
                            );
                          } catch (e) {
                            setStateDialog(() => isSaving = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
                            );
                          }
                        },
                  child: isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Text('حفظ', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('إضافة منتج', style: TextStyle(color: Colors.white)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('merchantId', isEqualTo: user?.uid ?? '')
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
                  Icon(Icons.inventory_2_outlined, size: 70, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('لا توجد منتجات مضافة بعد.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          final products = snapshot.data!.docs;

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: products.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemBuilder: (context, index) {
              final doc = products[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? '';
              final price = data['price'] ?? 0.0;
              final desc = data['description'] ?? '';
              final imageUrl = data['imageUrl'] ?? '';

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: Container(
                        width: double.infinity,
                        color: Colors.grey[100],
                        child: imageUrl.isNotEmpty
                            ? Image.memory(base64Decode(imageUrl), fit: BoxFit.cover)
                            : const Icon(Icons.fastfood, size: 40, color: Colors.teal),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                                Text(desc, style: TextStyle(color: Colors.grey[600], fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('$price ج.س', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold, fontSize: 13)),
                                IconButton(
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                  onPressed: () async {
                                    await FirebaseFirestore.instance.collection('products').doc(doc.id).delete();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('تم حذف المنتج بنجاح')),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ==========================================
// 2. تبويب طلبات العملاء الواردة للتاجر
// ==========================================
class MerchantOrdersTab extends StatelessWidget {
  const MerchantOrdersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('merchantId', isEqualTo: user?.uid ?? '')
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
                Icon(Icons.receipt_long_outlined, size: 70, color: Colors.grey),
                SizedBox(height: 12),
                Text('لا توجد طلبات واردة حالياً.', style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          );
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            final orderDoc = orders[index];
            final orderData = orderDoc.data() as Map<String, dynamic>;
            final customerName = orderData['customerName'] ?? 'عميل';
            final customerPhone = orderData['customerPhone'] ?? 'غير متوفر';
            final totalPrice = orderData['totalPrice'] ?? 0.0;
            final status = orderData['status'] ?? 'pending';
            final items = (orderData['items'] as List?) ?? [];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('العميل: $customerName', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Chip(
                          label: Text(
                            status == 'pending' ? 'قيد الانتظار' : (status == 'accepted' ? 'تم القبول' : 'مكتمل'),
                            style: const TextStyle(color: Colors.white, fontSize: 11),
                          ),
                          backgroundColor: status == 'pending' ? Colors.orange : Colors.teal,
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                    Text('الهاتف: $customerPhone', style: TextStyle(color: Colors.grey[700], fontSize: 13)),
                    const Divider(height: 16),
                    const Text('المنتجات المطلوبة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(height: 6),
                    ...items.map<Widget>((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('• ${item['name']} (x${item['quantity'] ?? 1})', style: const TextStyle(fontSize: 13)),
                            Text('${item['price']} ج.س', style: const TextStyle(fontSize: 13, color: Colors.teal)),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('الإجمالي: $totalPrice ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.teal)),
                        if (status == 'pending')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, minimumSize: const Size(90, 32)),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('orders').doc(orderDoc.id).update({
                                'status': 'accepted',
                              });
                            },
                            child: const Text('قبول الطلب', style: TextStyle(color: Colors.white, fontSize: 12)),
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