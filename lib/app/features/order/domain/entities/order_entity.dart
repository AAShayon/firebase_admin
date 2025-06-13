// lib/app/features/order/domain/entities/order_entity.dart
import '../../../../core/helpers/enums.dart';

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
}