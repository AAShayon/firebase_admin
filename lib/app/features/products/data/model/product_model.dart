import 'package:flutter/foundation.dart';

enum ProductCategory { shirt, pant, saree, ecom }
enum ProductColor { red, blue, green, black, white, yellow, custom }

class ProductVariant {
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
  final String? imageUrl;
  final String? imageLink;
  final ProductCategory category;
  final DateTime createdAt;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.variants,
    required this.availability,
    this.imageUrl,
    this.imageLink,
    required this.category,
    required this.createdAt,
  });

  Product copyWith({
    String? id,
    String? title,
    String? description,
    List<ProductVariant>? variants,
    bool? availability,
    String? imageUrl,
    String? imageLink,
    ProductCategory? category,
    DateTime? createdAt,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      variants: variants ?? this.variants,
      availability: availability ?? this.availability,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLink: imageLink ?? this.imageLink,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'variants': variants.map((v) => v.toJson()).toList(),
    'availability': availability,
    'imageUrl': imageUrl,
    'imageLink': imageLink,
    'category': describeEnum(category),
    'createdAt': createdAt.millisecondsSinceEpoch,
  };

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    title: json['title'],
    description: json['description'],
    variants: (json['variants'] as List)
        .map((v) => ProductVariant.fromJson(v))
        .toList(),
    availability: json['availability'],
    imageUrl: json['imageUrl'],
    imageLink: json['imageLink'],
    category: ProductCategory.values.firstWhere(
          (e) => describeEnum(e) == json['category'],
      orElse: () => ProductCategory.ecom,
    ),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt']),
  );
}