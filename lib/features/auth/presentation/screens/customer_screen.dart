import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:janbak_delivery/features/auth/data/repositories/auth_repository_impl.dart';

// نموذج المنتج في السلة
class CartProduct {
  final String id;
  final String merchantId;
  final String name;
  final double price;
  final String imageUrl;
  final String description;

  CartProduct({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.description,
  });
}

// مقدم حالة السلة (Riverpod StateNotifier)
class CartNotifier extends StateNotifier<List<CartProduct>> {
  CartNotifier() : super([]);

  void addItem(CartProduct product) {
    state = [...state, product];
  }

  void removeItem(String productId) {
    state = state.where((item) => item.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get totalPrice {
    return state.fold(0, (sum, item) => sum + item.price);
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartProduct>>((ref) {
  return CartNotifier();
});

class CustomerScreen extends ConsumerStatefulWidget {
  const CustomerScreen({super.key});

  @override
  ConsumerState<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends ConsumerState<CustomerScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة العميل - جنبَك',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          // أيقونة السلة مع العداد
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart, size: 26),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (cartItems.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${cartItems.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authRepositoryProvider).signOut();
            },
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'أهلاً بك، يا عميلنا العزيز 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 16),

            // مستطيل البحث الذكي
            TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'ابحث عن منتج أو اسم متجر...',
                prefixIcon: const Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            const SizedBox(height: 20),

            if (_searchQuery.isNotEmpty) ...[
              const Text(
                'المتاجر المطابقة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').where('role', isEqualTo: 'merchant').snapshots(),
                builder: (context, merchantSnapshot) {
                  if (!merchantSnapshot.hasData) return const SizedBox.shrink();
                  
                  final matchingMerchants = merchantSnapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final storeName = (data['storeName'] ?? '').toString().toLowerCase();
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    return storeName.contains(_searchQuery) || name.contains(_searchQuery);
                  }).toList();

                  if (matchingMerchants.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.only(bottom: 12.0),
                      child: Text('لا توجد متاجر تطابق بحثك.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    );
                  }

                  return ListView.builder(
                    itemCount: matchingMerchants.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final mDoc = matchingMerchants[index];
                      final mData = mDoc.data() as Map<String, dynamic>;
                      final merchantId = mDoc.id;
                      final storeName = mData['storeName'] ?? mData['name'] ?? 'متجر';
                      final storeAddress = mData['storeAddress'] ?? mData['address'] ?? 'عنوان غير متوفر';

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: ListTile(
                          leading: const CircleAvatar(backgroundColor: Colors.teal, child: Icon(Icons.store, color: Colors.white)),
                          title: Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('العنوان: $storeAddress', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MerchantStoreScreen(
                                  productId: '',
                                  merchantId: merchantId,
                                  productName: storeName,
                                  productPrice: 0.0,
                                  productDescription: 'منتجات متجر $storeName',
                                  productImageUrl: '',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'المنتجات المطابقة:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
            ] else ...[
              const Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.teal),
                  SizedBox(width: 8),
                  Text(
                    'المنتجات المتاحة للطلب',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Divider(color: Colors.teal, thickness: 1.5),
              const SizedBox(height: 12),
            ],

            // قائمة المنتجات
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text(
                        'لا توجد منتجات مضافة حالياً.',
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString().toLowerCase();
                  final description = (data['description'] ?? '').toString().toLowerCase();
                  if (_searchQuery.isEmpty) return true;
                  return name.contains(_searchQuery) || description.contains(_searchQuery);
                }).toList();

                if (filteredDocs.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text('لا توجد منتجات تطابق بحثك.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                    ),
                  );
                }

                return GridView.builder(
                  itemCount: filteredDocs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final docId = filteredDocs[index].id;
                    final data = filteredDocs[index].data() as Map<String, dynamic>;
                    final merchantId = data['merchantId'] ?? '';
                    final name = data['name'] ?? '';
                    final price = (data['price'] ?? 0.0).toDouble();
                    final description = data['description'] ?? '';
                    final imageUrl = data['imageUrl'] ?? '';

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MerchantStoreScreen(
                              productId: docId,
                              merchantId: merchantId,
                              productName: name,
                              productPrice: price,
                              productDescription: description,
                              productImageUrl: imageUrl,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 5,
                              child: Container(
                                width: double.infinity,
                                color: Colors.grey[100],
                                child: imageUrl.isNotEmpty
                                    ? (imageUrl.startsWith('http')
                                        ? Image.network(imageUrl, fit: BoxFit.cover)
                                        : Image.memory(
                                            base64Decode(imageUrl),
                                            fit: BoxFit.cover,
                                          ))
                                    : const Icon(
                                        Icons.fastfood,
                                        size: 45,
                                        color: Colors.teal,
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          description,
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 11,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$price ج.س',
                                          style: const TextStyle(
                                            color: Colors.teal,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 30,
                                          width: 30,
                                          child: IconButton(
                                            padding: EdgeInsets.zero,
                                            style: IconButton.styleFrom(
                                              backgroundColor: Colors.teal,
                                              foregroundColor: Colors.white,
                                            ),
                                            icon: const Icon(Icons.add, size: 18),
                                            onPressed: () {
                                              ref.read(cartProvider.notifier).addItem(
                                                    CartProduct(
                                                      id: docId,
                                                      merchantId: merchantId,
                                                      name: name,
                                                      price: price,
                                                      imageUrl: imageUrl,
                                                      description: description,
                                                    ),
                                                  );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                SnackBar(
                                                  content: Text('تمت إضافة $name للسلة'),
                                                  duration: const Duration(seconds: 1),
                                                  behavior: SnackBarBehavior.floating,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
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
          ],
        ),
      ),
    );
  }
}

// شاشة تفاصيل المنتج والمتجر
class MerchantStoreScreen extends ConsumerWidget {
  final String productId;
  final String merchantId;
  final String productName;
  final double productPrice;
  final String productDescription;
  final String productImageUrl;

  const MerchantStoreScreen({
    super.key,
    required this.productId,
    required this.merchantId,
    required this.productName,
    required this.productPrice,
    required this.productDescription,
    required this.productImageUrl,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(productName),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (productImageUrl.isNotEmpty)
              Container(
                height: 250,
                width: double.infinity,
                color: Colors.grey[200],
                child: productImageUrl.startsWith('http')
                    ? Image.network(productImageUrl, fit: BoxFit.cover)
                    : Image.memory(base64Decode(productImageUrl), fit: BoxFit.cover),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (productId.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            productName,
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '$productPrice ج.س',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text('التفاصيل:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(
                      productDescription.isNotEmpty ? productDescription : 'لا توجد تفاصيل إضافية.',
                      style: TextStyle(color: Colors.grey[700], fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                        onPressed: () {
                          ref.read(cartProvider.notifier).addItem(
                                CartProduct(
                                  id: productId,
                                  merchantId: merchantId,
                                  name: productName,
                                  price: productPrice,
                                  imageUrl: productImageUrl,
                                  description: productDescription,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تمت إضافة $productName للسلة بنجاح!'),
                              backgroundColor: Colors.teal,
                            ),
                          );
                        },
                        icon: const Icon(Icons.shopping_cart_checkout, color: Colors.white),
                        label: const Text('إضافة إلى السلة', style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Divider(thickness: 1.5),
                    const SizedBox(height: 12),
                  ],

                  // معلومات المتجر
                  FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance.collection('users').doc(merchantId).get(),
                    builder: (context, merchantSnapshot) {
                      String storeName = 'متجر التاجر';
                      String storeAddress = 'العنوان غير متوفر';
                      String storeEmail = '';

                      if (merchantSnapshot.hasData && merchantSnapshot.data!.exists) {
                        final mData = merchantSnapshot.data!.data() as Map<String, dynamic>;
                        storeName = mData['storeName'] ?? mData['name'] ?? 'متجر التاجر';
                        storeAddress = mData['storeAddress'] ?? mData['address'] ?? 'العنوان غير متوفر';
                        storeEmail = mData['email'] ?? '';
                      }

                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          children: [
                            const CircleAvatar(
                              backgroundColor: Colors.teal,
                              radius: 25,
                              child: Icon(Icons.store, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(storeName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text('العنوان: $storeAddress', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                                  if (storeEmail.isNotEmpty)
                                    Text('البريد: $storeEmail', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'منتجات هذا المتجر:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),

                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('products')
                        .where('merchantId', isEqualTo: merchantId)
                        .snapshots(),
                    builder: (context, productsSnapshot) {
                      if (productsSnapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!productsSnapshot.hasData || productsSnapshot.data!.docs.isEmpty) {
                        return const Text('لا توجد منتجات أخرى لهذا المتجر.', style: TextStyle(color: Colors.grey));
                      }

                      final otherDocs = productsSnapshot.data!.docs
                          .where((doc) => doc.id != productId)
                          .toList();

                      if (otherDocs.isEmpty) {
                        return const Text('لا توجد منتجات أخرى حالياً.', style: TextStyle(color: Colors.grey));
                      }

                      return ListView.builder(
                        itemCount: otherDocs.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final oDocId = otherDocs[index].id;
                          final oData = otherDocs[index].data() as Map<String, dynamic>;
                          final oName = oData['name'] ?? '';
                          final oPrice = (oData['price'] ?? 0.0).toDouble();
                          final oDesc = oData['description'] ?? '';
                          final oImage = oData['imageUrl'] ?? '';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: oImage.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: oImage.startsWith('http')
                                          ? Image.network(oImage, width: 50, height: 50, fit: BoxFit.cover)
                                          : Image.memory(base64Decode(oImage), width: 50, height: 50, fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.fastfood, size: 40, color: Colors.teal),
                              title: Text(oName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('$oPrice ج.س', style: const TextStyle(color: Colors.teal)),
                              trailing: IconButton(
                                icon: const Icon(Icons.add_shopping_cart, color: Colors.teal),
                                onPressed: () {
                                  ref.read(cartProvider.notifier).addItem(
                                        CartProduct(
                                          id: oDocId,
                                          merchantId: merchantId,
                                          name: oName,
                                          price: oPrice,
                                          imageUrl: oImage,
                                          description: oDesc,
                                        ),
                                      );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('تمت إضافة $oName للسلة'), duration: const Duration(seconds: 1)),
                                  );
                                },
                              ),
                              onTap: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MerchantStoreScreen(
                                      productId: oDocId,
                                      merchantId: merchantId,
                                      productName: oName,
                                      productPrice: oPrice,
                                      productDescription: oDesc,
                                      productImageUrl: oImage,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
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

// شاشة السلة مع إرسال الطلب لـ Firestore
class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, WidgetRef ref, List<CartProduct> cartItems) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تسجيل الدخول أولاً لإتمام الطلب')),
      );
      return;
    }

    // إظهار مؤشر التحميل
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // تجميع المنتجات حسب كل تاجر (Merchant) لإنشاء طلب مستقل لكل تاجر
      final Map<String, List<CartProduct>> itemsByMerchant = {};
      for (var item in cartItems) {
        if (!itemsByMerchant.containsKey(item.merchantId)) {
          itemsByMerchant[item.merchantId] = [];
        }
        itemsByMerchant[item.merchantId]!.add(item);
      }

      // حفظ طلب لكل تاجر في مجموعة 'orders' في Firestore
      for (var entry in itemsByMerchant.entries) {
        final merchantId = entry.key;
        final products = entry.value;
        final merchantTotal = products.fold(0.0, (sum, p) => sum + p.price);

        await FirebaseFirestore.instance.collection('orders').add({
          'customerId': user.uid,
          'customerEmail': user.email ?? '',
          'merchantId': merchantId,
          'items': products.map((p) => {
                'productId': p.id,
                'name': p.name,
                'price': p.price,
                'description': p.description,
              }).toList(),
          'totalPrice': merchantTotal,
          'status': 'pending', // قيد الانتظار من التاجر
          'deliveryStatus': 'unassigned', // لم يُسند لسائق بعد
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // إفراغ السلة
      ref.read(cartProvider.notifier).clearCart();

      // إغلاق مؤشر التحميل
      Navigator.pop(context);

      // العودة للشاشة الرئيسية مع رسالة نجاح
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 تم إرسال طلبك بنجاح وسيتم متابعته من قبل التاجر والسائقين!'),
          backgroundColor: Colors.teal,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // إغلاق التحميل
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('سلة المشتريات'), backgroundColor: Colors.teal),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'السلة فارغة حالياً 🛒',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        child: ListTile(
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${item.price} ج.س', style: const TextStyle(color: Colors.teal)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => cartNotifier.removeItem(item.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الإجمالي: ${cartNotifier.totalPrice} ج.س',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                        onPressed: () => _checkout(context, ref, cartItems),
                        child: const Text(
                          'تأكيد الطلب',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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