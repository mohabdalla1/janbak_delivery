import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img; // مكتبة ضغط ومعالجة الصور
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

// نموذج المنتج
class ProductModel {
  final String id;
  final String merchantId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;

  ProductModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      merchantId: map['merchantId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
    );
  }
}

class MerchantProductsScreen extends ConsumerStatefulWidget {
  final String merchantId;

  const MerchantProductsScreen({super.key, required this.merchantId});

  @override
  ConsumerState<MerchantProductsScreen> createState() => _MerchantProductsScreenState();
}

class _MerchantProductsScreenState extends ConsumerState<MerchantProductsScreen> with SingleTickerProviderStateMixin {
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
        title: const Text('لوحة تحكم التاجر - جنبَك', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.fastfood), text: 'إدارة المنتجات'),
            Tab(icon: Icon(Icons.list_alt), text: 'الطلبات الواردة'),
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
        children: [
          MerchantProductsTab(merchantId: widget.merchantId),
          IncomingOrdersTab(merchantId: widget.merchantId),
        ],
      ),
    );
  }
}

// تبويب إدارة المنتجات
class MerchantProductsTab extends StatelessWidget {
  final String merchantId;

  const MerchantProductsTab({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .where('merchantId', isEqualTo: merchantId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.storefront, size: 70, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('لا توجد منتجات مضافة بعد', style: TextStyle(fontSize: 18, color: Colors.grey)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    onPressed: () => _showAddProductDialog(context, merchantId),
                    icon: const Icon(Icons.add, color: Colors.white),
                    label: const Text('إضافة منتج جديد', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          }

          final docs = snapshot.data!.docs;

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final docId = docs[index].id;
              final data = docs[index].data() as Map<String, dynamic>;
              final product = ProductModel.fromMap(docId, data);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: product.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: product.imageUrl.startsWith('http')
                              ? Image.network(product.imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                              : Image.memory(
                                  base64Decode(product.imageUrl),
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                        )
                      : const Icon(Icons.fastfood, size: 40, color: Colors.teal),
                  title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${product.price} ج.س\n${product.description}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await FirebaseFirestore.instance.collection('products').doc(product.id).delete();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم حذف المنتج بنجاح')),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () => _showAddProductDialog(context, merchantId),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context, String merchantId) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final descController = TextEditingController();
    Uint8List? selectedImageBytes;
    bool isSaving = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة منتج جديد'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 110,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.teal, width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      backgroundColor: Colors.grey[100],
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () async {
                      try {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );
                        if (result != null && result.files.first.bytes != null) {
                          Uint8List rawBytes = result.files.first.bytes!;

                          try {
                            img.Image? image = img.decodeImage(rawBytes);
                            if (image != null) {
                              img.Image resized = img.copyResize(image, width: 400);
                              rawBytes = Uint8List.fromList(img.encodeJpg(resized, quality: 70));
                            }
                          } catch (e) {
                            // استخدام الصورة الأصلية في حال فشل المعالجة
                          }

                          setState(() {
                            selectedImageBytes = rawBytes;
                          });
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('خطأ في اختيار الصورة: $e')),
                        );
                      }
                    },
                    child: selectedImageBytes != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              selectedImageBytes!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 110,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.teal, size: 36),
                              SizedBox(height: 6),
                              Text('اضغط لاختيار صورة المنتج', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(controller: nameController, decoration: const InputDecoration(labelText: 'اسم المنتج')),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: 'السعر (ج.س)'), keyboardType: TextInputType.number),
                TextField(controller: descController, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 2),
                if (isSaving) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                  const SizedBox(height: 8),
                  const Text('جاري الضغط وحفظ المنتج...'),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              onPressed: isSaving ? null : () async {
                if (nameController.text.isNotEmpty && priceController.text.isNotEmpty) {
                  setState(() { isSaving = true; });
                  try {
                    String imageBase64String = '';
                    if (selectedImageBytes != null) {
                      imageBase64String = base64Encode(selectedImageBytes!);
                    }

                    final newProduct = ProductModel(
                      id: '',
                      merchantId: merchantId,
                      name: nameController.text,
                      price: double.tryParse(priceController.text) ?? 0.0,
                      description: descController.text,
                      imageUrl: imageBase64String,
                    );

                    await FirebaseFirestore.instance.collection('products').add(newProduct.toMap());
                    
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تم إضافة المنتج بنجاح!'), backgroundColor: Colors.teal),
                    );
                  } catch (e) {
                    setState(() { isSaving = false; });
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e')),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('الرجاء إدخال اسم المنتج والسعر على الأقل')),
                  );
                }
              },
              child: const Text('حفظ', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// تبويب الطلبات الواردة المحدث
class IncomingOrdersTab extends StatelessWidget {
  final String merchantId;

  const IncomingOrdersTab({super.key, required this.merchantId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('لا توجد طلبات واردة حالياً.', style: TextStyle(fontSize: 18, color: Colors.grey)),
          );
        }

        final docs = snapshot.data!.docs;

        final sortedDocs = List.from(docs);
        sortedDocs.sort((a, b) {
          final tA = (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          final tB = (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
          if (tA == null || tB == null) return 0;
          return tB.compareTo(tA);
        });

        return ListView.builder(
          itemCount: sortedDocs.length,
          itemBuilder: (context, index) {
            final docId = sortedDocs[index].id;
            final data = sortedDocs[index].data() as Map<String, dynamic>;
            final customerEmail = data['customerEmail'] ?? 'عميل مجهول';
            final customerAddress = data['customerAddress'] ?? 'لم يتم تحديد العنوان';
            final totalPrice = (data['totalPrice'] ?? 0.0).toDouble();
            final status = data['status'] ?? 'قيد الانتظار';
            final items = (data['items'] as List<dynamic>? ) ?? [];

            final shortId = docId.length > 6 ? docId.substring(0, 6).toUpperCase() : docId;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.teal[50],
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shopping_bag, color: Colors.teal),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('طلب رقم: #$shortId', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('العميل: $customerEmail', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                        // زر قبول الطلب أو عرض الحالة الحالية
                        if (status == 'قيد الانتظار')
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () async {
                              await FirebaseFirestore.instance.collection('orders').doc(docId).update({
                                'status': 'جاري تجهيز الطلب وانتظار السائق',
                              });
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('تم قبول الطلب، جاري التجهيز وانتظار السائق 📦'),
                                  backgroundColor: Colors.teal,
                                ),
                              );
                            },
                            child: const Text('قبول الطلب', style: TextStyle(color: Colors.white)),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange),
                            ),
                            child: Text(
                              status,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const Divider(height: 20),
                    // عرض عنوان العميل بوضوح
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'عنوان العميل: $customerAddress',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('الإجمالي: $totalPrice ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 15)),
                    const SizedBox(height: 12),
                    const Text('المنتجات المطلوبة:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    ...items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${item['name']}', style: const TextStyle(fontSize: 14)),
                          Text('${item['price']} ج.س', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
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