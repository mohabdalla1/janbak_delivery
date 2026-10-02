import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';

class OrderTrackingScreen extends StatelessWidget {
  final String orderId; // معرف الطلب المراد تتبعه

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تتبع الطلب - جنبك'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('orders').doc(orderId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'لم يتم العثور على تفاصيل هذا الطلب',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
              ),
            );
          }

          final orderData = snapshot.data!.data() as Map<String, dynamic>;
          final currentStatus = orderData['status'] ?? 'قيد الانتظار';
          final customerName = orderData['customerName'] ?? 'عميل جنبك';
          final totalPrice = orderData['totalPrice'] ?? '0';

          // إحداثيات افتراضية (مثلاً حلفا الجديدة، السودان) أو جلبها من المستند إذا وجدت
          // يمكن حفظ lat و lng للسائق في الـ order وثم قراءتها هنا لتتحرك الخريطة حياً
          final double driverLat = orderData['driverLat'] ?? 15.3229;
          final double driverLng = orderData['driverLng'] ?? 35.5461;

          return Column(
            children: [
              // 1. الخريطة المجانية التفاعلية في الأعلى (OpenStreetMap)
              SizedBox(
                height: 250,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(driverLat, driverLng),
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
                          point: LatLng(driverLat, driverLng),
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.delivery_dining_rounded,
                            size: 40,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // 2. تفاصيل الحالة والخطوات الزمنية في الأسفل
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // بطاقة معلومات الطلب الأساسية
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.2)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'طلب رقم: ${orderId.substring(0, 6).toUpperCase()}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                const SizedBox(height: 4),
                                Text('العميل: $customerName', style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
                              ],
                            ),
                            Text(
                              '$totalPrice جنيه',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primaryColor),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      const Text(
                        'حالة سير الطلب',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // خطوات تتبع الطلب بشكل بصري
                      Expanded(
                        child: ListView(
                          children: [
                            _buildTrackingStep(
                              title: 'تم استلام طلبك',
                              subtitle: 'تم تسجيل الطلب بنجاح وإرساله للتاجر',
                              isActive: _isStepPassed('قيد الانتظار', currentStatus),
                              isCurrent: currentStatus == 'قيد الانتظار',
                            ),
                            _buildTrackingStep(
                              title: 'جاري التجهيز',
                              subtitle: 'التاجر يقوم بتجهيز طلبك الآن',
                              isActive: _isStepPassed('جاري التجهيز', currentStatus),
                              isCurrent: currentStatus == 'جاري التجهيز',
                            ),
                            _buildTrackingStep(
                              title: 'في طريقها للتوصيل',
                              subtitle: 'السائق استلم الطلب وهو متحرك إليك الآن',
                              isActive: _isStepPassed('في طريقها للتوصيل', currentStatus),
                              isCurrent: currentStatus == 'في طريقها للتوصيل',
                            ),
                            _buildTrackingStep(
                              title: 'تم التوصيل',
                              subtitle: 'تم تسليم الطلب بنجاح. شكراً لاستخدامك جنبك',
                              isActive: _isStepPassed('تم التوصيل', currentStatus),
                              isCurrent: currentStatus == 'تم التوصيل',
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  bool _isStepPassed(String stepStatus, String currentStatus) {
    List<String> statuses = ['قيد الانتظار', 'جاري التجهيز', 'في طريقها للتوصيل', 'تم التوصيل'];
    int currentIndex = statuses.indexOf(currentStatus);
    int stepIndex = statuses.indexOf(stepStatus);
    return currentIndex >= stepIndex;
  }

  Widget _buildTrackingStep({
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
                border: Border.all(
                  color: isCurrent ? AppTheme.primaryColor : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Center(
                child: Icon(
                  isActive ? Icons.check : Icons.circle,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 35,
                color: isActive ? AppTheme.primaryColor : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.black : AppTheme.textGrey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ],
    );
  }
}