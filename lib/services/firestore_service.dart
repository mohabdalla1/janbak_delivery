import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

    // جلب المتاجر لعرضها في واجهة العميل
      Stream<QuerySnapshot> getStores() {
          return _db.collection('stores').snapshots();
            }

              // إرسال طلب جديد من العميل
                Future<void> createOrder({
                    required String customerName,
                        required String storeName,
                            required String items,
                                required double price,
                                  }) async {
                                      await _db.collection('orders').add({
                                            'customerName': customerName,
                                                  'storeName': storeName,
                                                        'items': items,
                                                              'price': price,
                                                                    'status': 'قيد التجهيز',
                                                                          'createdAt': FieldValue.serverTimestamp(),
                                                                              });
                                                                                }

                                                                                  // جلب الطلبات الواردة للتاجر
                                                                                    Stream<QuerySnapshot> getMerchantOrders() {
                                                                                        return _db.collection('orders').orderBy('createdAt', descending: true).snapshots();
                                                                                          }

                                                                                            // تحديث حالة الطلب من قبل التاجر أو السائق
                                                                                              Future<void> updateOrderStatus(String orderId, String newStatus) async {
                                                                                                  await _db.collection('orders').doc(orderId).update({
                                                                                                        'status': newStatus,
                                                                                                            });
                                                                                                              }

                                                                                                                // جلب الطلبات المتاحة للتوصيل للسائقين
                                                                                                                  Stream<QuerySnapshot> getAvailableDeliveries() {
                                                                                                                      return _db.collection('orders').where('status', isEqualTo: 'بانتظار السائق').snapshots();
                                                                                                                        }
                                                                                                                        }
                                                                                                                        