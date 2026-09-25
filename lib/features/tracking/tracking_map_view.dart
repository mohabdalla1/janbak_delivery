import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TrackingMapView extends StatelessWidget {
  const TrackingMapView({super.key});

    @override
      Widget build(BuildContext context) {
          // إحداثيات افتراضية (مثلاً مدينة الخرطوم / أو الرياض حسب رغبتك)
              final LatLng sudanLocation = const LatLng(15.5007, 32.5599);

                  return Scaffold(
                        appBar: AppBar(
                                title: const Text('تتبع الطلب لحظياً — جنبك'),
                                        backgroundColor: const Color(0xFFFF6A1F),
                                              ),
                                                    body: FlutterMap(
                                                            options: MapOptions(
                                                                      initialCenter: sudanLocation,
                                                                                initialZoom: 14.0,
                                                                                        ),
                                                                                                children: [
                                                                                                          // طبقة خريطة OpenStreetMap المجانية
                                                                                                                    TileLayer(
                                                                                                                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                                                                                                                            userAgentPackageName: 'com.janbak.delivery',
                                                                                                                                                      ),
                                                                                                                                                                // علامات المواقع (المتجر، السائق، العميل)
                                                                                                                                                                          MarkerLayer(
                                                                                                                                                                                      markers: [
                                                                                                                                                                                                    Marker(
                                                                                                                                                                                                                    point: sudanLocation,
                                                                                                                                                                                                                                    width: 80,
                                                                                                                                                                                                                                                    height: 80,
                                                                                                                                                                                                                                                                    child: const Column(
                                                                                                                                                                                                                                                                                      children: [
                                                                                                                                                                                                                                                                                                          Icon(Icons.delivery_dining, color: Color(0xFFFF6A1F), size: 40),
                                                                                                                                                                                                                                                                                                                              Text('السائق جنبك', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                                                                                                                                                                                                                                                                                                                                                ],
                                                                                                                                                                                                                                                                                                                                                                ),
                                                                                                                                                                                                                                                                                                                                                                              ),
                                                                                                                                                                                                                                                                                                                                                                                          ],
                                                                                                                                                                                                                                                                                                                                                                                                    ),
                                                                                                                                                                                                                                                                                                                                                                                                            ],
                                                                                                                                                                                                                                                                                                                                                                                                                  ),
                                                                                                                                                                                                                                                                                                                                                                                                                      );
                                                                                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                                                                                                        }
                                                                                                                                                                                                                                                                                                                                                                                                                        
