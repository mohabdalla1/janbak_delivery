import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/presentation/screens/location_picker_screen.dart'; // تأكد من مطابقة مسار الاستيراد لديك
import 'order_tracking_screen.dart'; // تأكد من مطابقة مسار الاستيراد لديك

class CartScreen extends StatefulWidget {
  final String storeId;
  final String storeName;
  final List<Map<String, dynamic>> cartItems;

  const CartScreen({
    super.key,
    required this.storeId,
    required this.storeName,
    required this.cartItems,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  bool _isLoading = false;
  final TextEditingController _notesController = TextEditingController();
  LatLng? _deliveryLocation; // متغير لحفظ الموقع الجغرافي المختار للتوصيل

  // حساب الإجمالي الكلي للمنتجات في السلة
  double get _subtotal {
    double total = 0;
    for (var item in widget.cartItems) {
      total += (item['price'] ?? 0) * (item['quantity'] ?? 1);
    }
    return total;
  }

  // رسوم التوصيل الثابتة (أو حسب المنطقة في حلفا الجديدة)
  final double _deliveryFee = 1000.0;

  @override
  Widget build(BuildContext context) {
    double grandTotal = _subtotal + (_subtotal > 0 ? _deliveryFee : 0);

    return Scaffold(
      appBar: AppBar(
        title: Text('سلة المشتريات - ${widget.storeName}'),
        centerTitle: true,
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 12),
                  const Text('السلة فارغة حالياً', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            )
          : Column(
              children: [
                // قائمة المنتجات في السلة
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cartItems.length,
                    itemBuilder: (context, index) {
                      final item = widget.cartItems[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text('${item['price']} ج.س', style: const TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              // تحكم بالكمية
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                                    onPressed: () {
                                      setState(() {
                                        if (item['quantity'] > 1) {
                                          item['quantity']--;
                                        } else {
                                          widget.cartItems.removeAt(index);
                                        }
                                      });
                                    },
                                  ),
                                  Text('${item['quantity']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle_outline, size: 20, color: AppTheme.primaryColor),
                                    onPressed: () {
                                      setState(() {
                                        item['quantity']++;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // قسم اختيار الموقع، الملاحظات وفاتورة الحساب في الأسفل
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4)),
                    ],
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // زر اختيار الموقع على الخريطة
                      ListTile(
                        tileColor: Colors.grey[100],
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        leading: const Icon(Icons.location_on, color: AppTheme.primaryColor),
                        title: Text(
                          _deliveryLocation == null 
                              ? 'اختر موقع التوصيل على الخريطة' 
                              : 'تم تحديد الموقع (${_deliveryLocation!.latitude.toStringAsFixed(3)}, ${_deliveryLocation!.longitude.toStringAsFixed(3)})',
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () async {
                          final LatLng? selectedLoc = await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LocationPickerScreen()),
                          );
                          if (selectedLoc != null) {
                            setState(() {
                              _deliveryLocation = selectedLoc;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          hintText: 'ملاحظات للتاجر أو المندوب (اختياري)...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('مجموع المنتجات:', style: TextStyle(color: Colors.grey)),
                          Text('$_subtotal ج.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('رسوم التوصيل:', style: TextStyle(color: Colors.grey)),
                          Text('$_deliveryFee ج.س', style: const TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المبلغ الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('$grandTotal ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primaryColor)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _isLoading ? null : () => _submitOrder(grandTotal),
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('إرسال الطلب الآن', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  // دالة إرسال الطلب إلى Firestore والانتقال لشاشة التتبع
  Future<void> _submitOrder(double grandTotal) async {
    // التحقق من تحديد الموقع أولاً (اختياري ولكن يفضل الإلزام به)
    if (_deliveryLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء اختيار موقع التوصيل على الخريطة أولاً')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء تسجيل الدخول أولاً لإتمام الطلب')),
        );
        setState(() => _isLoading = false);
        return;
      }

      // حفظ الطلب في مجموعة orders بفايربيس والحصول على مرجع المستند
      DocumentReference orderRef = await FirebaseFirestore.instance.collection('orders').add({
        'customerId': user.uid,
        'customerEmail': user.email ?? 'عميل جنبك',
        'storeId': widget.storeId,
        'storeName': widget.storeName,
        'items': widget.cartItems,
        'subtotal': _subtotal,
        'deliveryFee': _deliveryFee,
        'totalPrice': grandTotal,
        'notes': _notesController.text.trim(),
        'deliveryLocation': {
          'latitude': _deliveryLocation!.latitude,
          'longitude': _deliveryLocation!.longitude,
        },
        'status': 'pending', // (pending, accepted, delivering, completed)
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إرسال طلبك بنجاح!')),
      );

      // الانتقال مباشرة لشاشة تتبع الطلب الحية مع تمرير معرف الطلب
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrderTrackingScreen(orderId: orderRef.id),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء إرسال الطلب: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}