

import '../../data/model/product_model.dart';

class ProductVariantEntity {
  final String size;
  final double price;
  final int quantity;
  final ProductColor color;

  ProductVariantEntity({
    required this.size,
    required this.price,
    required this.quantity,
    required this.color,
  });
}

class ProductEntity {
  final String id;
  final String title;
  final String description;
  final List<ProductVariantEntity> variants;
  final bool availability;
  final String? imageUrl;
  final String? imageLink;
  final ProductCategory category;
  final DateTime createdAt;

  ProductEntity({
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
}