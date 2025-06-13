// lib/app/features/order/data/models/order_model.dart
import '../../../../core/helpers/enums.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final OrderStatus status;
  final String? shippingAddress;
  final String? billingAddress;
  final String? paymentMethod;
  final String? transactionId;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    this.status = OrderStatus.pending,
    this.shippingAddress,
    this.billingAddress,
    this.paymentMethod,
    this.transactionId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'items': items.map((item) => item.toJson()).toList(),
    'totalAmount': totalAmount,
    'orderDate': orderDate.toIso8601String(),
    'status': status.toString().split('.').last,
    'shippingAddress': shippingAddress,
    'billingAddress': billingAddress,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
  };

  factory OrderModel.fromJson(String id, Map<String, dynamic> json) {
    return OrderModel(
      id: id,
      userId: json['userId'],
      items: (json['items'] as List).map((item) => OrderItem.fromJson(item)).toList(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      orderDate: DateTime.parse(json['orderDate']),
      status: OrderStatus.values.firstWhere(
            (e) => e.toString() == 'OrderStatus.${json['status']}',
        orElse: () => OrderStatus.pending,
      ),
      shippingAddress: json['shippingAddress'],
      billingAddress: json['billingAddress'],
      paymentMethod: json['paymentMethod'],
      transactionId: json['transactionId'],
    );
  }
}

class OrderItem {
  final String productId;
  final String productTitle;
  final String variantSize;
  final String variantColorName;
  final double price;
  final int quantity;
  final String? imageUrl;

  OrderItem({
    required this.productId,
    required this.productTitle,
    required this.variantSize,
    required this.variantColorName,
    required this.price,
    required this.quantity,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'productId': productId,
    'productTitle': productTitle,
    'variantSize': variantSize,
    'variantColorName': variantColorName,
    'price': price,
    'quantity': quantity,
    'imageUrl': imageUrl,
  };

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      productTitle: json['productTitle'],
      variantSize: json['variantSize'],
      variantColorName: json['variantColorName'],
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'],
      imageUrl: json['imageUrl'],
    );
  }
}

