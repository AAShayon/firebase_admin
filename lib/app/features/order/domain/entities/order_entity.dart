// lib/app/features/order/domain/entities/order_entity.dart
import '../../../../core/helpers/enums.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';

class OrderEntity {
  final String id;
  final String userId;
  final List<OrderItemEntity> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? shippingAddress;
  final String? billingAddress;
  final String? paymentMethod;
  final String? transactionId;

  OrderEntity({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
    this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.transactionId,
  });
}

// ... inside your order_entity.dart file, update the OrderItemEntity class

class OrderItemEntity {
  final String productId;
  final String productTitle;
  final String variantSize;
  final String variantColorName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItemEntity({
    required this.productId,
    required this.productTitle,
    required this.variantSize,
    required this.variantColorName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  /// --- ADD THIS FACTORY CONSTRUCTOR ---
  /// Creates an OrderItemEntity from a JSON map (from Firestore).
  factory OrderItemEntity.fromJson(Map<String, dynamic> json) {
    return OrderItemEntity(
      productId: json['productId'] ?? '',
      productTitle: json['productTitle'] ?? 'Unknown Product',
      variantSize: json['variantSize'] ?? 'N/A',
      variantColorName: json['variantColorName'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      imageUrl: json['imageUrl'],
    );
  }
  factory OrderItemEntity.fromCartItem(CartItemEntity cartItem) {
    return OrderItemEntity(
      productId: cartItem.productId,
      productTitle: cartItem.productTitle,
      variantSize: cartItem.variantSize,
      variantColorName: cartItem.variantColorName,
      price: cartItem.variantPrice,
      quantity: cartItem.quantity,
      imageUrl: cartItem.variantImageUrl,
    );
  }


  // Also add a toJson method, which is needed when you create an order
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'variantSize': variantSize,
      'variantColorName': variantColorName,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }
}