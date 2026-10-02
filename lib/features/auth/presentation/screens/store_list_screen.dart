import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import 'store_details_screen.dart'; // استيراد شاشة تفاصيل المتجر

class StoreListScreen extends StatelessWidget {
  const StoreListScreen({super.key});

  // بيانات تجريبية مؤقتة للمتاجر لحين إعادة تفعيل Firebase
  final List<Map<String, dynamic>> _mockStores = const [
    {
      'name': 'مطعم النيل الأزرق',
      'category': 'مأكولات ومشاوي',
      'rating': 4.8,
      'time': '20 - 30 دقيقة',
      'isOpen': true,
    },
    {
      'name': 'سوبرماركت البركة',
      'category': 'بقالة ومواد غذائية',
      'rating': 4.6,
      'time': '15 - 25 دقيقة',
      'isOpen': true,
    },
    {
      'name': 'مخبز حلفا الحديث',
      'category': 'مخبوزات ومعجنات',
      'rating': 4.9,
      'time': '10 - 20 دقيقة',
      'isOpen': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المتاجر المتاحة - حلفا الجديدة'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12.0),
        itemCount: _mockStores.length,
        itemBuilder: (context, index) {
          final store = _mockStores[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: const Icon(Icons.storefront_rounded, color: AppTheme.primaryColor),
              ),
              title: Text(
                store['name'],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4.0),
                  Text(store['category'], style: const TextStyle(color: AppTheme.textGrey)),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16.0),
                      const SizedBox(width: 4.0),
                      Text('${store['rating']}'),
                      const SizedBox(width: 16.0),
                      const Icon(Icons.access_time, color: Colors.grey, size: 16.0),
                      const SizedBox(width: 4.0),
                      Text(store['time']),
                    ],
                  ),
                ],
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: store['isOpen'] ? Colors.green.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  store['isOpen'] ? 'مفتوح' : 'مغلق',
                  style: TextStyle(
                    color: store['isOpen'] ? Colors.green : Colors.red,
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                // الانتقال الفوري لشاشة تفاصيل المتجر وإرسال بيانات المتجر معها
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StoreDetailsScreen(storeData: store),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}