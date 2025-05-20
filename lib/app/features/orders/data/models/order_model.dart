// lib/features/orders/data/models/order_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class OrderModel {
  final String id;
  final String customerId;
  final double total;
  final DateTime date;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.customerId,
    required this.total,
    required this.date,
    required this.items,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OrderModel(
      id: doc.id,
      customerId: data['customerId'],
      total: (data['total'] ?? 0).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      items: List<OrderItem>.from(
        (data['items'] ?? []).map((item) => OrderItem.fromMap(item)),
      ),
    );
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
    );
  }
}