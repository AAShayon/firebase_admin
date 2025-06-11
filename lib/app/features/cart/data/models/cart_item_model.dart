class CartItem {
  final String id;
  final String userId;
  final String productId;
  final String productTitle;
  final String variantSize;
  final String variantColorName;
  final double variantPrice;
  final String? variantImageUrl;
  final int quantity;

  CartItem({
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

  /// Converts the CartItem instance to a JSON map for Firestore.
  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'productId': productId,
    'productTitle': productTitle,
    'variantSize': variantSize,
    'variantColorName': variantColorName,
    'variantPrice': variantPrice,
    'variantImageUrl': variantImageUrl,
    'quantity': quantity,
  };

  /// Creates a CartItem instance from a Firestore document ID and data map.
  factory CartItem.fromJson(String id, Map<String, dynamic> json) {
    return CartItem(
      id: id,
      userId: json['userId'],
      productId: json['productId'],
      productTitle: json['productTitle'],
      variantSize: json['variantSize'],
      variantColorName: json['variantColorName'],
      variantPrice: (json['variantPrice'] as num).toDouble(),
      variantImageUrl: json['variantImageUrl'],
      quantity: json['quantity'],
    );
  }
}