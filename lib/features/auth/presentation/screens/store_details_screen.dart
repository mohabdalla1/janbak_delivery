import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'cart_screen.dart'; // استيراد شاشة السلة التي أنشأناها

class StoreDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> storeData;

  const StoreDetailsScreen({super.key, required this.storeData});

  @override
  State<StoreDetailsScreen> createState() => _StoreDetailsScreenState();
}

class _StoreDetailsScreenState extends State<StoreDetailsScreen> {
  // سلة المشتريات المحلية داخل هذا المتجر
  final List<Map<String, dynamic>> _cartItems = [];

  // بيانات تجريبية للمنتجات داخل المتجر
  final List<Map<String, dynamic>> _mockProducts = const [
    {
      'id': 'p1',
      'name': 'وجبة مشاوي مشكلة',
      'description': 'سيخ كباب، سيخ شيش طاووق، مع رغيف وصلصة ثوم وبطاطس',
      'price': 4500.0,
      'image': '🍖',
    },
    {
      'id': 'p2',
      'name': 'نصف صدمة فراخ بروستد',
      'description': '4 قطع مقرمشة مع بطاطس، ثومية، وخبز',
      'price': 3800.0,
      'image': '🍗',
    },
    {
      'id': 'p3',
      'name': 'عصير ليمون بالنعناع',
      'description': 'طازج ومنعش محضر يومياً',
      'price': 1000.0,
      'image': '🍹',
    },
    {
      'id': 'p4',
      'name': 'عبوة مياه غازية',
      'description': 'بيبسي أو سفن أب بارد',
      'price': 800.0,
      'image': '🥤',
    },
  ];

  // دالة لإضافة منتج للسلة أو زيادة كميته
  void _addToCart(Map<String, dynamic> product) {
    setState(() {
      final index = _cartItems.indexWhere((item) => item['id'] == product['id']);
      if (index >= 0) {
        _cartItems[index]['quantity']++;
      } else {
        _cartItems.add({
          'id': product['id'],
          'name': product['name'],
          'price': product['price'],
          'quantity': 1,
        });
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تمت إضافة (${product['name']}) إلى السلة'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // حساب إجمالي عدد القطع في السلة
  int get _totalCartItemsCount {
    int count = 0;
    for (var item in _cartItems) {
      count += (item['quantity'] as int);
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    final storeName = widget.storeData['name'] ?? 'المتجر';
    final storeId = widget.storeData['id'] ?? 'store_123'; // معرف المتجر

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // رأس الصفحة (App Bar مع خلفية متجر)
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                storeName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
              background: Container(
                color: AppTheme.primaryColor,
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 80,
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),

          // معلومات المتجر السريعة
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.storeData['category'] ?? 'مأكولات',
                        style: const TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text('${widget.storeData['rating'] ?? 4.8} (تقييمات العملاء)', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: (widget.storeData['isOpen'] ?? true) ? Colors.green.shade50 : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      (widget.storeData['isOpen'] ?? true) ? 'مفتوح حالياً' : 'مغلق',
                      style: TextStyle(
                        color: (widget.storeData['isOpen'] ?? true) ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'قائمة المنتجات والوجبات',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // قائمة المنتجات داخل المتجر
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final product = _mockProducts[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: Colors.orange.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(product['image'], style: const TextStyle(fontSize: 28)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product['description'],
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${product['price']} ج.س',
                                style: const TextStyle(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_shopping_cart_rounded, color: AppTheme.primaryColor),
                          onPressed: () => _addToCart(product),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: _mockProducts.length,
            ),
          ),
          
          const SliverToBoxAdapter(
            child: SizedBox(height: 80),
          ),
        ],
      ),

      // زر السلة العائم في الأسفل
      bottomNavigationBar: _cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CartScreen(
                          storeId: storeId,
                          storeName: storeName,
                          cartItems: _cartItems,
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shopping_bag_outlined, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        'عرض السلة ($_totalCartItemsCount منتج)',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}