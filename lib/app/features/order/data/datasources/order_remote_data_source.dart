// lib/app/features/order/data/datasources/order_remote_data_source.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/helpers/enums.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<String> createOrder(OrderModel order);
  Stream<List<OrderModel>> getUserOrders(String userId);
  Stream<List<OrderModel>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<DocumentSnapshot> getOrderById(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<String> createOrder(OrderModel order) async {
    final batch = _firestore.batch();

    // 1. Create order document
    final orderRef = _firestore.collection('orders').doc(order.id);
    batch.set(orderRef, order.toJson());

    // 2. Clear cart items
    final cartItemsRef = _firestore
        .collection('carts')
        .doc(order.userId)
        .collection('items');

    final cartSnapshot = await cartItemsRef.get();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
    return orderRef.id;
  }

  @override
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      // Use the new, correct fromSnapshot factory
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    });
  }


  @override
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) {
      // Use the new, correct fromSnapshot factory
      return snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': newStatus.toString().split('.').last,
    });
  }
  @override
  Future<DocumentSnapshot> getOrderById(String orderId) {
    return _firestore.collection('orders').doc(orderId).get();
  }
}