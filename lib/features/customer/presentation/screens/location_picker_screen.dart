import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_theme.dart';

class LocationPickerScreen extends StatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  // مركز خريطة حلفا الجديدة الافتراضي
  final MapController _mapController = MapController();

  LatLng _selectedLocation = const LatLng(15.3215, 35.5833);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('حدد موقع التوصيل في حلفا الجديدة'),
      ),
      body: Stack(
        children: [
          // الخريطة الأساسية
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 15.0,
              onPositionChanged: (position, hasGesture) {
                if (hasGesture) {
                  setState(() {
                    _selectedLocation = position.center;
                  });
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.janbak.delivery',
              ),
            ],
          ),

          // دبوس ثابت في منتصف الخريطة
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 35),
              child: Icon(
                Icons.location_pin,
                size: 50,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // زر العودة إلى الموقع الافتراضي في حلفا الجديدة
          Positioned(
            top: 16,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                const defaultLocation = LatLng(15.3215, 35.5833);

                _mapController.move(defaultLocation, 15.0);

                setState(() {
                  _selectedLocation = defaultLocation;
                });
              },
              child: const Icon(
                Icons.my_location,
                color: AppTheme.primaryColor,
              ),
            ),
          ),

          // لوحة سفلية لتأكيد الموقع المختار
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
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
                    'موقع التوصيل المحدد',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'خط العرض: ${_selectedLocation.latitude.toStringAsFixed(4)}، '
                    'خط الطول: ${_selectedLocation.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: AppTheme.textGrey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context, _selectedLocation);
                      },
                      child: const Text(
                        'تأكيد هذا الموقع ومتابعة الطلب',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
