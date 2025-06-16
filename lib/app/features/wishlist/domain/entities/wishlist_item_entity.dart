// This entity now holds all the data needed to display a wishlist item.
class WishlistItemEntity {
  final String productId;
  final String productTitle;
  final double price;
  final String? imageUrl;
  final DateTime addedAt;
  final bool isInStock; // To show availability status

  WishlistItemEntity({
    required this.productId,
    required this.productTitle,
    required this.price,
    this.imageUrl,
    required this.addedAt,
    required this.isInStock,
  });
}