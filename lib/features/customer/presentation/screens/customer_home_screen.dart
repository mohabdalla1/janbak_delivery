import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import 'location_picker_screen.dart'; // استيراد شاشة اختيار الموقع

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('جنبك - حلفا الجديدة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () {
              // تسجيل الخروج والعودة للشاشة الموحدة
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. خريطة OpenStreetMap المجانية عبر flutter_map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentDeliveryLocation,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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

          // 2. بطاقة البحث لتحديد أو تغيير موقع التوصيل عند النقر
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () async {
                // الانتقال لشاشة اختيار الموقع الدقيق على الخريطة
                final LatLng? selectedPos = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                );
                
                if (selectedPos != null) {
                  setState(() {
                    _currentDeliveryLocation = selectedPos;
                  });
                  // تحريك الخريطة للموقع الجديد
                  _mapController.move(selectedPos, 15.0);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم تحديث موقع التوصيل بنجاح في حلفا الجديدة')),
                  );
                }
              },
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: AppTheme.textGrey),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'انقر هنا لتحديد موقع التوصيل بدقة في حلفا الجديدة',
                          style: TextStyle(color: AppTheme.textGrey, fontSize: 13),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.my_location_rounded, color: AppTheme.primaryColor, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. شريط سفلي للخدمات السريعة
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'اختر نوع الخدمة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _serviceItem(Icons.restaurant_rounded, 'مطاعم'),
                      _serviceItem(Icons.local_grocery_store_rounded, 'بقالة ومقاضي'),
                      _serviceItem(Icons.local_pharmacy_rounded, 'صيدليات'),
                      _serviceItem(Icons.bolt_rounded, 'خدمات صيانة'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _serviceItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(height: 6),
        Text(
          title,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.secondaryColor),
        ),
      ],
    );
  }
}