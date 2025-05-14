class ProductEntity {
  final String id;
  final String name;
  final String description;
  final String? imageUrl;
  final List<ProductSizeEntity> sizes;
  final DateTime createdAt;
  final DateTime updatedAt;

  ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    this.imageUrl,
    required this.sizes,
    required this.createdAt,
    required this.updatedAt,
  });
}

class ProductSizeEntity {
  final String size;
  final double price;
  final int quantity;

  ProductSizeEntity({
    required this.size,
    required this.price,
    required this.quantity,
  });
}