// lib/app/features/products/domain/entities/product_entity.dart

import '../../data/model/product_model.dart'; // Assuming you have this for enums

class ProductVariantEntity {
  final String size;
  final double price;
  final int quantity;
  final List<String> imageUrls;
  final ProductColor color;

  ProductVariantEntity({
    required this.size,
    required this.price,
    required this.quantity,
    required this.imageUrls,
    required this.color,
  });
  factory ProductVariantEntity.empty() {
    return ProductVariantEntity(
      size: 'N/A',
      price: 0.0,
      quantity: 0,
      imageUrls: [],
      color: ProductColor.custom,
    );
  }
}

class ProductEntity {
  final String id;
  final String title;
  final String description;
  final List<ProductVariantEntity> variants;
  final bool availability;

  final ProductCategory category;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.variants,
    required this.availability,
    required this.category,
    required this.createdAt,
  });

}