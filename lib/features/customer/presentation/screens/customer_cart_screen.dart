// lib/features/customer/presentation/screens/customer_cart_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class CustomerCartScreen extends ConsumerStatefulWidget {
  final String merchantId;
  final List<Map<String, dynamic>> cartItems;
  final double itemsTotal;

  const CustomerCartScreen({
    super.key,
    required this.merchantId,
    required this.cartItems,
    required this.itemsTotal,
  });

  @override
  ConsumerState<CustomerCartScreen> createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends ConsumerState<CustomerCartScreen> {
  final MapController _mapController = MapController();
  final LatLng _defaultCenter = const LatLng(15.3235, 35.5847);
  LatLng? _customerLocation;
  LatLng? _merchantLocation;
  bool _isLoadingMerchant = true;
  bool _isCheckingOut = false;
  double _calculatedDeliveryFee = 0.0;

  late List<Map<String, dynamic>> _mutableCart;

  @override
  void initState() {
    super.initState();
    // نسخ العناصر لتكون قابلة للتعديل والزيادة والنقصان
    _mutableCart = widget.cartItems.map((item) => Map<String, dynamic>.from(item)).toList();
    for (var item in _mutableCart) {
      if (!item.containsKey('quantity')) {
        item['quantity'] = 1;
      }
    }
    _fetchMerchantLocation();
  }

  double get _currentItemsTotal {
    double total = 0.0;
    for (var item in _mutableCart) {
      final price = (item['price'] as num).toDouble();
      final qty = (item['quantity'] as int);
      total += price * qty;
    }
    return total;
  }

  Future<void> _fetchMerchantLocation() async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(widget.merchantId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('latitude') && data.containsKey('longitude')) {
          setState(() {
            _merchantLocation = LatLng(data['latitude'], data['longitude']);
            _isLoadingMerchant = false;
          });
        }
      }
    } catch (e) {
      setState(() => _isLoadingMerchant = false);
    }
  }

  double _calculateDeliveryFee(LatLng merchantLoc, LatLng customerLoc) {
    const Distance distanceCalculator = Distance();
    double distanceInMeters = distanceCalculator.as(LengthUnit.Meter, merchantLoc, customerLoc);
    double distanceInKm = distanceInMeters / 1000;
    double baseFee = 500.0;
    double ratePerKm = 200.0;
    double fee = baseFee + (distanceInKm * ratePerKm);
    return fee < 500.0 ? 500.0 : fee;
  }

  Future<void> _confirmOrder() async {
    if (_customerLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الرجاء تحديد موقع التوصيل على الخريطة أولاً')));
      return;
    }
    if (_merchantLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تحديد موقع المتجر لحساب التوصيل')));
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final double finalTotalPrice = _currentItemsTotal + _calculatedDeliveryFee;

      await FirebaseFirestore.instance.collection('orders').add({
        'customerId': user.uid,
        'customerEmail': user.email ?? 'عميل',
        'merchantId': widget.merchantId,
        'items': _mutableCart,
        'itemsTotal': _currentItemsTotal,
        'deliveryFee': _calculatedDeliveryFee,
        'totalPrice': finalTotalPrice,
        'customerLatitude': _customerLocation!.latitude,
        'customerLongitude': _customerLocation!.longitude,
        'status': 'pending',
        'deliveryStatus': 'unassigned',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إرسال طلبك بنجاح! 🚀'), backgroundColor: Colors.teal));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _isCheckingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTotal = _currentItemsTotal;

    return Scaffold(
      appBar: AppBar(title: const Text('السلة وإتمام الطلب'), backgroundColor: Colors.teal),
      body: _isLoadingMerchant
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('محتويات السلة والكميات:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal)),
                  const SizedBox(height: 8),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _mutableCart.length,
                    itemBuilder: (context, index) {
                      final item = _mutableCart[index];
                      final price = (item['price'] as num).toDouble();
                      final qty = (item['quantity'] as int);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(item['name'] ?? ''),
                          subtitle: Text('السعر: $price ج.س'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    if (qty > 1) {
                                      item['quantity'] = qty - 1;
                                    } else {
                                      _mutableCart.removeAt(index);
                                    }
                                  });
                                },
                              ),
                              Text('$qty', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline, color: Colors.teal),
                                onPressed: () {
                                  setState(() {
                                    item['quantity'] = qty + 1;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 24),
                  const Text('حدد مكان التوصيل على الخريطة:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _merchantLocation ?? _defaultCenter,
                          initialZoom: 14.0,
                          onTap: (tapPos, point) {
                            setState(() {
                              _customerLocation = point;
                              if (_merchantLocation != null) {
                                _calculatedDeliveryFee = _calculateDeliveryFee(_merchantLocation!, point);
                              }
                            });
                          },
                        ),
                        children: [
                          TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.janbak.delivery'),
                          MarkerLayer(
                            markers: [
                              if (_merchantLocation != null)
                                Marker(point: _merchantLocation!, width: 40, height: 40, child: const Icon(Icons.store, color: Colors.orange, size: 38)),
                              if (_customerLocation != null)
                                Marker(point: _customerLocation!, width: 40, height: 40, child: const Icon(Icons.location_on, color: Colors.green, size: 40)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('مجموع المنتجات:'),
                            Text('$currentTotal ج.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ]),
                          const SizedBox(height: 8),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('سعر التوصيل:'),
                            Text(_customerLocation == null ? 'حدد موقعك أولاً' : '$_calculatedDeliveryFee ج.س',
                                style: TextStyle(fontWeight: FontWeight.bold, color: _customerLocation == null ? Colors.grey : Colors.teal)),
                          ]),
                          const Divider(height: 20),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            const Text('الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            Text('${currentTotal + _calculatedDeliveryFee} ج.س',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.teal)),
                          ]),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      onPressed: _isCheckingOut || _mutableCart.isEmpty ? null : _confirmOrder,
                      child: _isCheckingOut
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('تأكيد وإرسال الطلب', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}