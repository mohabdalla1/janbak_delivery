import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import 'login_screen.dart';

class DriverDashboardScreen extends StatefulWidget {
  const DriverDashboardScreen({super.key});

  @override
  State<DriverDashboardScreen> createState() => _DriverDashboardScreenState();
}

class _DriverDashboardScreenState extends State<DriverDashboardScreen> with SingleTickerProviderStateMixin {
  final User? currentUser = FirebaseAuth.instance.currentUser;
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
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: 30,
              width: 30,
            ),
            const SizedBox(width: 10),
            const Text('لوحة تحكم السائق - جنبك'),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          tabs: const [
            Tab(text: 'الطلبات المتاحة'),
            Tab(text: 'طلباتي الحالية'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // التبويب الأول: الطلبات المتاحة للتوصيل
          _buildAvailableOrdersList(),
          
          // التبويب الثاني: طلبات هذا السائق الخاصة
          _buildMyAssignedOrdersList(),
        ],
      ),
    );
  }

  // 1. قائمة الطلبات المتاحة لكل السائقين
  Widget _buildAvailableOrdersList() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('status', whereIn: ['pending', 'جاري التجهيز', 'جاهز للتوصيل'])
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState('لا توجد طلبات متاحة للتوصيل حالياً');
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;
              
              return _buildOrderCard(orderId, orderData, isAvailable: true);
            },
          );
        },
      ),
    );
  }

  // 2. قائمة الطلبات الخاصة بهذا السائق فقط
  Widget _buildMyAssignedOrdersList() {
    if (currentUser == null) {
      return const Center(child: Text('يجب تسجيل الدخول لعرض طلباتك'));
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .where('driverId', isEqualTo: currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _buildEmptyState('ليس لديك أي طلبات قيد التوصيل حالياً');
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final orderData = orders[index].data() as Map<String, dynamic>;
              final orderId = orders[index].id;

              return _buildOrderCard(orderId, orderData, isAvailable: false);
            },
          );
        },
      ),
    );
  }

  // تصميم بطاقة الطلب الموحدة مع خريطة الموقع
  Widget _buildOrderCard(String orderId, Map<String, dynamic> orderData, {required bool isAvailable}) {
    final customerEmail = orderData['customerEmail'] ?? 'عميل جنبك';
    final orderStatus = orderData['status'] ?? 'pending';
    final totalPrice = orderData['totalPrice'] ?? '0';
    
    // استخراج الإحداثيات بشكل آمن سواء كانت مخزنة في Map باسم deliveryLocation أو بشكل مباشر
    double lat = 15.3215; // إحداثيات افتراضية لوسط حلفا الجديدة
    double lng = 35.5833;

    if (orderData['deliveryLocation'] != null && orderData['deliveryLocation'] is Map) {
      final locMap = orderData['deliveryLocation'] as Map<String, dynamic>;
      lat = (locMap['latitude'] ?? 15.3215).toDouble();
      lng = (locMap['longitude'] ?? 35.5833).toDouble();
    } else {
      lat = (orderData['latitude'] ?? 15.3215).toDouble();
      lng = (orderData['longitude'] ?? 35.5833).toDouble();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'طلب رقم: ${orderId.substring(0, 6).toUpperCase()}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue),
                  ),
                  child: Text(
                    orderStatus,
                    style: const TextStyle(color: Colors.blue, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text('العميل: $customerEmail', style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 4),
            Text('المبلغ المطلوب: $totalPrice ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            const SizedBox(height: 8),

            // زر عرض الخريطة وموقع التوصيل
            TextButton.icon(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => _showOrderMap(context, lat, lng, customerEmail),
              icon: const Icon(Icons.map_rounded, color: Colors.blue, size: 18),
              label: const Text('عرض الموقع على الخريطة', style: TextStyle(color: Colors.blue)),
            ),
            
            const SizedBox(height: 12),
            
            // الأزرار التفاعلية بناءً على حالة الطلب
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isAvailable && (orderStatus == 'pending' || orderStatus == 'جاري التجهيز' || orderStatus == 'جاهز للتوصيل'))
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                        'status': 'في طريقها للتوصيل',
                        'driverId': currentUser?.uid,
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم قبول الطلب بنجاح! انتقل إلى طلباتك الحالية'), backgroundColor: Colors.green),
                      );
                    },
                    icon: const Icon(Icons.delivery_dining, size: 18),
                    label: const Text('استلام الطلب والتحرك'),
                  ),
                
                if (!isAvailable && orderStatus == 'في طريقها للتوصيل')
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                    onPressed: () {
                      FirebaseFirestore.instance.collection('orders').doc(orderId).update({
                        'status': 'تم التوصيل',
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('تم تأكيد التوصيل بنجاح'), backgroundColor: Colors.green),
                      );
                    },
                    icon: const Icon(Icons.check_circle_rounded, size: 18),
                    label: const Text('تأكيد التوصيل'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // نافذة منبثقة تعرض الخريطة (BottomSheet)
  void _showOrderMap(BuildContext context, double lat, double lng, String customerName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'موقع تسليم الطلب: $customerName',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(lat, lng),
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
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: const Icon(
                              Icons.location_pin,
                              color: Colors.red,
                              size: 40,
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
        );
      },
    );
  }

  // واجهة عند فراغ القائمة
  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.electric_scooter_outlined, size: 60, color: AppTheme.textGrey.withValues(alpha: 0.5)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: AppTheme.textGrey, fontSize: 15),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}