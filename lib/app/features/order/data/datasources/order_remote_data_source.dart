import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/helpers/enums.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  // --- THIS IS NOW THE ONLY createOrder METHOD ---
  Future<String> createOrder(Map<String, dynamic> orderData, String namePrefix);

  // The rest of the interface is correct
  Stream<List<OrderModel>> getUserOrders(String userId);
  Stream<List<OrderModel>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<DocumentSnapshot> getOrderById(String orderId);
  Stream<DocumentSnapshot> watchOrderById(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrderRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // --- THIS IS THE IMPLEMENTATION FOR THE NEW createOrder ---
  @override
  Future<String> createOrder(Map<String, dynamic> orderData, String namePrefix) async {
    final counterRef = _firestore.collection('counters').doc('order_counter');

    // A Firestore Transaction handles reads and writes together atomically.
    return _firestore.runTransaction((transaction) async {
      // --- 1. ID Generation (within the transaction) ---
      final counterSnapshot = await transaction.get(counterRef);
      if (!counterSnapshot.exists) {
        throw Exception("Critical Error: 'order_counter' document not found.");
      }
      final currentNumber = counterSnapshot.data()!['currentNumber'] as int;
      final newNumber = currentNumber + 1;
      final newOrderId = '${namePrefix}Order${newNumber.toString().padLeft(7, '0')}';

      // --- 2. Stock Update Logic (within the transaction) ---
      final List<Map<String, dynamic>> orderItems = orderData['items'];
      for (final item in orderItems) {
        final productId = item['productId'];
        final productRef = _firestore.collection('products').doc(productId);

        // Read the product document *inside* the transaction.
        final productDoc = await transaction.get(productRef);
        if (!productDoc.exists) {
          throw Exception('Product with ID $productId not found.');
        }

        final productData = productDoc.data()!;
        final List<dynamic> variants = productData['variants'] ?? [];

        final variantIndex = variants.indexWhere((v) =>
        v['size'] == item['variantSize'] &&
            v['colorName'] == item['variantColorName']);

        if (variantIndex != -1) {
          final currentQuantity = variants[variantIndex]['quantity'] as int;
          final newQuantity = currentQuantity - (item['quantity'] as int);

          if (newQuantity < 0) {
            throw Exception('Insufficient stock for ${productData['title']}.');
          }

          variants[variantIndex]['quantity'] = newQuantity;
          // Queue the update for the product document.
          transaction.update(productRef, {'variants': variants});
        } else {
          throw Exception('Variant for ${productData['title']} not found.');
        }
      }

      // --- 3. Order Creation (within the transaction) ---
      final newOrderRef = _firestore.collection('orders').doc(newOrderId);
      transaction.set(newOrderRef, orderData);

      // --- 4. Counter Update (within the transaction) ---
      transaction.update(counterRef, {'currentNumber': newNumber});

      // All operations will be committed together by Firestore.
      return newOrderId;
    });
  }

  // --- THE OLD createOrder(OrderModel order) METHOD HAS BEEN DELETED ---

  @override
  Stream<List<OrderModel>> getUserOrders(String userId) {
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
  }

  @override
  Stream<List<OrderModel>> getAllOrders() {
    return _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList());
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

  @override
  Stream<DocumentSnapshot> watchOrderById(String orderId) {
    return _firestore.collection('orders').doc(orderId).snapshots();
  }
}