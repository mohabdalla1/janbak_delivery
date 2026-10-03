import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'location_picker_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  const CustomerHomeScreen({super.key});

  @override
  State<CustomerHomeScreen> createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  // إحداثيات مركز مدينة حلفا الجديدة
  final LatLng halfaNewCenter = const LatLng(15.3215, 35.5833);

  // إحداثيات الموقع الحالي المختار للتوصيل
  LatLng _currentDeliveryLocation = const LatLng(15.3215, 35.5833);

  final MapController _mapController = MapController();

  // القسم المختار للفلترة
  String _selectedCategory = 'الكل';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جنبك - حلفا الجديدة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.35,
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentDeliveryLocation,
                initialZoom: 15.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.janbak.delivery',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentDeliveryLocation,
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.location_pin,
                        size: 45,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // بطاقة تحديد موقع التوصيل
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                final LatLng? selectedPos = await Navigator.push<LatLng>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LocationPickerScreen(),
                  ),
                );

                // مهم: فحص mounted بعد await
                if (!mounted) return;

                if (selectedPos == null) return;

                setState(() {
                  _currentDeliveryLocation = selectedPos;
                });

                _mapController.move(selectedPos, 15.0);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'تم تحديث موقع التوصيل بنجاح في حلفا الجديدة',
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: AppTheme.textGrey,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'انقر هنا لتحديد موقع التوصيل بدقة في حلفا الجديدة',
                          style: TextStyle(
                            color: AppTheme.textGrey,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.my_location_rounded,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // قائمة المتاجر والخدمات
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // مقبض السحب
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text(
                        'اختر نوع الخدمة',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // أزرار الفلترة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _serviceItem(
                            Icons.storefront_rounded,
                            'الكل',
                          ),
                          _serviceItem(
                            Icons.restaurant_rounded,
                            'مطاعم',
                          ),
                          _serviceItem(
                            Icons.local_grocery_store_rounded,
                            'بقالة',
                          ),
                          _serviceItem(
                            Icons.local_pharmacy_rounded,
                            'صيدليات',
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Text(
                        'المتاجر المتاحة ($_selectedCategory)',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.secondaryColor,
                        ),
                      ),
                      const SizedBox(height: 10),

                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('merchants')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            if (snapshot.hasError) {
                              return const Center(
                                child: Text(
                                  'حدث خطأ أثناء تحميل المتاجر',
                                  style: TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            if (!snapshot.hasData ||
                                snapshot.data!.docs.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons
                                          .store_mall_directory_outlined,
                                      size: 60,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'لا توجد متاجر مسجلة حالياً',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            var merchants = snapshot.data!.docs;

                            // فلترة المتاجر حسب القسم
                            if (_selectedCategory != 'الكل') {
                              merchants = merchants.where((doc) {
                                final data =
                                    doc.data() as Map<String, dynamic>;

                                final activity =
                                    data['merchantActivity'] ?? '';

                                return activity
                                    .toString()
                                    .contains(_selectedCategory);
                              }).toList();
                            }

                            if (merchants.isEmpty) {
                              return const Center(
                                child: Text(
                                  'لا توجد متاجر في هذا القسم حالياً',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              );
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: merchants.length,
                              itemBuilder: (context, index) {
                                final merchantData = merchants[index].data()
                                    as Map<String, dynamic>;

                                final storeName =
                                    merchantData['storeName'] ??
                                        'متجر جنبك';

                                final merchantActivity =
                                    merchantData['merchantActivity'] ??
                                        'نشاط عام';

                                final isOpen =
                                    merchantData['isOpen'] ?? true;

                                return Card(
                                  margin: const EdgeInsets.only(
                                    bottom: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  elevation: 2,
                                  child: ListTile(
                                    contentPadding:
                                        const EdgeInsets.all(12),
                                    leading: CircleAvatar(
                                      radius: 26,
                                      backgroundColor: AppTheme
                                          .primaryColor
                                          .withValues(alpha: 0.1),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: AppTheme.primaryColor,
                                      ),
                                    ),
                                    title: Text(
                                      storeName.toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: 4),
                                        Text(
                                          'النشاط: ${merchantActivity.toString()}',
                                          style: const TextStyle(
                                            color: AppTheme.textGrey,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isOpen == true
                                                    ? Colors.green
                                                    : Colors.red,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isOpen == true
                                                  ? 'مفتوح'
                                                  : 'مغلق',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isOpen == true
                                                    ? Colors.green
                                                    : Colors.red,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    trailing: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                    onTap: () {
                                      // TODO:
                                      // الانتقال إلى شاشة منتجات المتجر
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _serviceItem(IconData icon, String title) {
    final bool isSelected = _selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCategory = title;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : AppTheme.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? AppTheme.primaryColor
                  : AppTheme.secondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
