import 'package:flutter/foundation.dart';

enum ProductCategory { food, ecom, car, house }

class Product {
  final String id;
  final String title;
  final String description;
  final double price;
  final int quantity;
  final String size;
  final bool availability;
  final String? imageUrl; // if uploading image
  final String? imageLink; // if external link provided
  final ProductCategory category;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
    required this.size,
    required this.availability,
    this.imageUrl,
    this.imageLink,
    required this.category,
  });

  // ✅ Add copyWith method
  Product copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    int? quantity,
    String? size,
    bool? availability,
    String? imageUrl,
    String? imageLink,
    ProductCategory? category,
  }) {
    return Product(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      size: size ?? this.size,
      availability: availability ?? this.availability,
      imageUrl: imageUrl ?? this.imageUrl,
      imageLink: imageLink ?? this.imageLink,
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'quantity': quantity,
      'size': size,
      'availability': availability,
      'imageUrl': imageUrl,
      'imageLink': imageLink,
      'category': describeEnum(category),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'] is int ? json['price'].toDouble() : json['price'],
      quantity: json['quantity'],
      size: json['size'],
      availability: json['availability'],
      imageUrl: json['imageUrl'],
      imageLink: json['imageLink'],
      category: ProductCategory.values.firstWhere(
              (e) => describeEnum(e) == json['category']),
    );
  }
}