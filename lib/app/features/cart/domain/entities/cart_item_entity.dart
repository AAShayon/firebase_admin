class CartItemEntity {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final String variantSize;
  final String variantColorName;
  final double variantPrice;
  final String? variantImageUrl;
  final int quantity;

  CartItemEntity({
    required this.id,
    required this.userId,
    required this.productId,
    required this.productTitle,
    required this.variantSize,
    required this.variantColorName,
    required this.variantPrice,
    this.variantImageUrl,
    required this.quantity,
  });
}