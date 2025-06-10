// lib/app/features/products/data/model/product_model.dart
import 'package:flutter/foundation.dart';

// Enums remain the same
enum ProductCategory { shirt, pant, saree, ecom, Apparel, Electronics, Books, Sports, Home }
enum ProductColor { red, blue, green, black, white, yellow, custom }

// ProductVariant remains the same
class ProductVariant {
  // ... no changes here
  final String size;
  final double price;
  final int quantity;
  final ProductColor color;

  ProductVariant({
    required this.size,
    required this.price,
    required this.quantity,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'size': size,
    'price': price,
    'quantity': quantity,
    'color': describeEnum(color),
  };

  factory ProductVariant.fromJson(Map<String, dynamic> json) => ProductVariant(
    size: json['size'],
    price: json['price'] is int ? json['price'].toDouble() : json['price'],
    quantity: json['quantity'],
    color: ProductColor.values.firstWhere(
          (e) => describeEnum(e) == json['color'],
      orElse: () => ProductColor.custom,
    ),
  );
}

class Product {
  final String id;
  final String title;
  final String description;
  final List<ProductVariant> variants;
  final bool availability;
  final List<String> imageUrls; // MODIFIED: Changed field name and type
  final ProductCategory category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.variants,
    required this.availability,
    required this.imageUrls, // MODIFIED
    required this.category,
    required this.createdAt,
  });

  // copyWith is removed for brevity as it's less used with clean architecture models

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'variants': variants.map((v) => v.toJson()).toList(),
    'availability': availability,
    'imageUrls': imageUrls, // MODIFIED
    'category': describeEnum(category),
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Product.fromJson(Map<String, dynamic> json) {
    // --- ROBUST IMAGE HANDLING ---
    // This makes your app compatible with both old (single image) and new (multiple images) data structures in Firestore.
    List<String> images = [];
    if (json['imageUrls'] != null && json['imageUrls'] is List) {
      images = List<String>.from(json['imageUrls']);
    } else if (json['imageUrl'] != null && json['imageUrl'] is String) {
      // Handle old data model (single imageUrl)
      images.add(json['imageUrl']);
    } else if (json['imageLink'] != null && json['imageLink'] is String) {
      // Handle even older data model (single imageLink)
      images.add(json['imageLink']);
    }

    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      variants: (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList(),
      availability: json['availability'],
      imageUrls: images, // MODIFIED
      category: ProductCategory.values.firstWhere(
            (e) => describeEnum(e).toLowerCase() == json['category'].toString().toLowerCase(),
        orElse: () => ProductCategory.ecom,
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
    );
  }
}