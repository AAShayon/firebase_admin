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

  @override
  Future<String> createOrder(Map<String, dynamic> orderData, String namePrefix) async {
    final counterRef = _firestore.collection('counters').doc('order_counter');
    final ordersRef = _firestore.collection('orders');

    return _firestore.runTransaction((transaction) async {
      // 1. Get and increment the counter atomically
      final counterSnapshot = await transaction.get(counterRef);
      if (!counterSnapshot.exists) {
        // Initialize counter if it doesn't exist
        transaction.set(counterRef, {'currentNumber': 1});
      }

      final currentNumber = counterSnapshot.exists
          ? (counterSnapshot.data()!['currentNumber'] as int) + 1
          : 1;

      // 2. Generate order ID
      final orderId = '${namePrefix}Order${currentNumber.toString().padLeft(7, '0')}';

      // 3. Update stock quantities
      final List<Map<String, dynamic>> orderItems = orderData['items'];
      for (final item in orderItems) {
        final productRef = _firestore.collection('products').doc(item['productId']);
        final productDoc = await transaction.get(productRef);

        if (!productDoc.exists) {
          throw Exception('Product with ID ${item['productId']} not found.');
        }

        final productData = productDoc.data()!;
        final List<dynamic> variants = productData['variants'] ?? [];

        final variantIndex = variants.indexWhere((v) =>
        (v['size']?.toString().toLowerCase() ?? '') ==
            (item['variantSize']?.toString().toLowerCase() ?? '') &&
            (v['color']?.toString().toLowerCase() ?? '') ==
                (item['variantColorName']?.toString().toLowerCase() ?? ''));

        if (variantIndex == -1) {
          throw Exception('Variant not found for product ${productData['title']}');
        }

        final currentQuantity = variants[variantIndex]['quantity'] as int;
        final orderedQuantity = item['quantity'] as int;

        if (currentQuantity < orderedQuantity) {
          throw Exception('Insufficient stock for ${productData['title']}');
        }

        variants[variantIndex]['quantity'] = currentQuantity - orderedQuantity;
        transaction.update(productRef, {'variants': variants});
      }

      // 4. Create the order with the generated ID
      final newOrderRef = ordersRef.doc(orderId);
      transaction.set(newOrderRef, {
        ...orderData,
        'id': orderId, // Include the generated ID in the document
      });

      // 5. Update the counter
      transaction.update(counterRef, {'currentNumber': currentNumber});

      return orderId;
    });
  }
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