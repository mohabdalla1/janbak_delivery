// lib/features/merchant/models/product_model.dart

class ProductModel {
  final String id;
  final String merchantId;
  final String name;
  final double price;
  final String description;
  final String imageUrl;
  final bool isAvailable;

  ProductModel({
    required this.id,
    required this.merchantId,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl,
    this.isAvailable = true,
  });

  // تحويل البيانات من Firestore
  factory ProductModel.fromMap(String id, Map<String, dynamic> map) {
    return ProductModel(
      id: id,
      merchantId: map['merchantId'] ?? '',
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      isAvailable: map['isAvailable'] ?? true,
    );
  }

  // تحويل البيانات إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'merchantId': merchantId,
      'name': name,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
    };
  }
}