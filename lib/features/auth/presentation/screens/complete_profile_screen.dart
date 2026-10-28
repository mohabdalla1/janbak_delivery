import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:janbak_delivery/features/merchant/presentation/screens/merchant_screen.dart';



class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _storeNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // المدن المتاحة وتبدأ بحلفا الجديدة
  final List<String> _cities = [
    'حلفا الجديدة',
    'الخرطوم',
    'ودمدني',
    'كسلا',
    'بورتسودان',
    'عطبرة',
  ];
  String _selectedCity = 'حلفا الجديدة';

  // إحداثيات حلفا الجديدة الافتراضية
  final LatLng _newHalfaCenter = const LatLng(15.3235, 35.5847);
  LatLng? _selectedLocation;
  final MapController _mapController = MapController();

  bool _isLoading = false;

  @override
  void dispose() {
    _storeNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  // حفظ البيانات في Firestore
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تحديد موقع المتجر على الخريطة')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'role': 'merchant',
        'storeName': _storeNameController.text.trim(),
        'city': _selectedCity,
        'storeAddress': _addressController.text.trim(),
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
        'profileCompleted': true,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MerchantDashboardScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء الحفظ: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إكمال بيانات المتجر'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'أهلاً بك يا تاجر! يرجى إكمال بيانات متجرك:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 20),

              // اسم المتجر
              TextFormField(
                controller: _storeNameController,
                decoration: InputDecoration(
                  labelText: 'اسم المتجر',
                  prefixIcon: const Icon(Icons.store, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال اسم المتجر' : null,
              ),
              const SizedBox(height: 16),

              // قائمة اختيار المدينة
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: InputDecoration(
                  labelText: 'المدينة',
                  prefixIcon: const Icon(Icons.location_city, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: _cities.map((city) {
                  return DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCity = value!;
                    if (_selectedCity == 'حلفا الجديدة') {
                      _mapController.move(_newHalfaCenter, 14.0);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // العنوان التفصيلي
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'العنوان التفصيلي (مثلاً: السوق التجاري...)',
                  prefixIcon: const Icon(Icons.map, color: Colors.teal),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                validator: (value) => value == null || value.isEmpty ? 'يرجى إدخال العنوان التفصيلي' : null,
              ),
              const SizedBox(height: 20),

              const Text(
                'حدد موقع متجرك على الخريطة (انقر على الخريطة للتحديد):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),

              // الخريطة المجانية (OpenStreetMap)
              SizedBox(
                height: 300,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('users')
                        .where('role', isEqualTo: 'merchant')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final List<Marker> markers = [];

                      // إضافة علامة موقع التاجر الحالي (أخضر)
                      if (_selectedLocation != null) {
                        markers.add(
                          Marker(
                            point: _selectedLocation!,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_on, color: Colors.green, size: 40),
                          ),
                        );
                      }

                      // عرض باقي المتاجر المسجلة (حمر)
                      if (snapshot.hasData) {
                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          if (data.containsKey('latitude') && data.containsKey('longitude')) {
                            final lat = data['latitude'];
                            final lng = data['longitude'];
                            final docId = doc.id;

                            if (docId != FirebaseAuth.instance.currentUser?.uid && lat != null && lng != null) {
                              markers.add(
                                Marker(
                                  point: LatLng(lat, lng),
                                  width: 35,
                                  height: 35,
                                  child: const Icon(Icons.store, color: Colors.red, size: 30),
                                ),
                              );
                            }
                          }
                        }
                      }

                      return FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _newHalfaCenter, // مركز حلفا الجديدة
                          initialZoom: 14.0,
                          onTap: (tapPosition, point) {
                            setState(() {
                              _selectedLocation = point;
                            });
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.janbak.delivery',
                          ),
                          MarkerLayer(markers: markers),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر الحفظ
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'حفظ ومتابعة إلى لوحة التحكم',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}