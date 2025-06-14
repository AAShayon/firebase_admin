import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/helpers/enums.dart';
import '../../domain/entities/order_entity.dart';

// This is the complete and final OrderModel.
// It extends the domain entity and handles all Firestore conversions.
class OrderModel extends OrderEntity {
  OrderModel({
    required super.id,
    required super.userId,
    required super.items,
    required super.totalAmount,
    required super.orderDate,
    required super.status,
    super.shippingAddress,
    super.billingAddress,
    required super.paymentMethod,
    super.transactionId,
  });

  /// FACTORY for reading data from Firestore.
  /// Creates an OrderModel from a Firestore DocumentSnapshot.
  factory OrderModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      // It's crucial that OrderItemEntity has a .fromJson factory
      items: (data['items'] as List<dynamic>? ?? [])
          .map((itemData) => OrderItemEntity.fromJson(itemData as Map<String, dynamic>))
          .toList(),
      totalAmount: (data['totalAmount'] as num?)?.toDouble() ?? 0.0,
      // Handle both Timestamp and String for backward compatibility if needed
      orderDate: data['orderDate'] is Timestamp
          ? (data['orderDate'] as Timestamp).toDate()
          : DateTime.tryParse(data['orderDate'] as String? ?? '') ?? DateTime.now(),
      status: _stringToOrderStatus(data['status']),
      shippingAddress: data['shippingAddress'],
      billingAddress: data['billingAddress'],
      paymentMethod: data['paymentMethod'] ?? 'Unknown',
      transactionId: data['transactionId'],
    );
  }

  /// METHOD for writing data to Firestore.
  /// Converts the OrderModel instance into a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(), // Assumes OrderItemEntity has toJson
      'totalAmount': totalAmount,
      'orderDate': FieldValue.serverTimestamp(), // Best practice: let the server set the time
      'status': status.toString().split('.').last, // e.g., 'pending'
      'shippingAddress': shippingAddress,
      'billingAddress': billingAddress,
      'paymentMethod': paymentMethod,
      'transactionId': transactionId,
    };
  }

  /// Helper function to safely convert a String from Firestore to an OrderStatus enum.
  static OrderStatus _stringToOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'accepted':
        return OrderStatus.accepted;
      case 'packaging':
        return OrderStatus.packaging;
      case 'readyfordelivery':
        return OrderStatus.readyForDelivery;
      case 'shipping':
        return OrderStatus.shipping;
      case 'completed':
        return OrderStatus.completed;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}