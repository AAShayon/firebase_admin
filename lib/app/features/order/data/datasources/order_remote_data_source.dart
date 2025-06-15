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

    try {
      return await _firestore.runTransaction((transaction) async {
        // 1. Get and increment the counter atomically
        final counterSnapshot = await transaction.get(counterRef);
        if (!counterSnapshot.exists) {
          transaction.set(counterRef, {'currentNumber': 1});
        }

        final currentNumber = counterSnapshot.exists
            ? (counterSnapshot.data()!['currentNumber'] as int) + 1
            : 1;

        // 2. Generate order ID
        final orderId = '${namePrefix}Order${currentNumber.toString().padLeft(7, '0')}';

        // 3. Prepare all product updates first
        final List<Map<String, dynamic>> orderItems = orderData['items'];
        final Map<String, Map<String, dynamic>> productUpdates = {};

        for (final item in orderItems) {
          final productId = item['productId'];
          final productRef = _firestore.collection('products').doc(productId);
          final productDoc = await transaction.get(productRef);

          if (!productDoc.exists) {
            throw Exception('Product with ID $productId not found.');
          }

          final productData = productDoc.data()!;
          final List<dynamic> variants = productData['variants'] ?? [];

          final variantIndex = variants.indexWhere((v) =>
          (v['size']?.toString().toLowerCase() ?? '') ==
              (item['variantSize']?.toString().toLowerCase() ?? '') &&
              (v['color']?.toString().toLowerCase() ?? '') ==
                  (item['variantColorName']?.toString().toLowerCase() ?? ''));

          if (variantIndex == -1) {
            throw Exception('Variant (Size: ${item['variantSize']}, Color: ${item['variantColorName']}) for ${productData['title']} not found.');
          }

          final currentQuantity = variants[variantIndex]['quantity'] as int;
          final orderedQuantity = item['quantity'] as int;

          if (currentQuantity < orderedQuantity) {
            throw Exception('Insufficient stock for ${productData['title']} (Size: ${item['variantSize']}, Color: ${item['variantColorName']}). Available: $currentQuantity, Requested: $orderedQuantity');
          }

          // Create a deep copy of variants to modify
          final updatedVariants = List<dynamic>.from(variants);
          updatedVariants[variantIndex] = {
            ...updatedVariants[variantIndex],
            'quantity': currentQuantity - orderedQuantity
          };

          productUpdates[productRef.path] = {'variants': updatedVariants};
        }

        // 4. Apply all product updates
        productUpdates.forEach((path, updateData) {
          transaction.update(_firestore.doc(path), updateData);
        });

        // 5. Create the order
        transaction.set(ordersRef.doc(orderId), {
          ...orderData,
          'id': orderId,
          'orderDate': FieldValue.serverTimestamp(), // Use server timestamp
        });

        // 6. Update the counter
        transaction.update(counterRef, {'currentNumber': currentNumber});

        return orderId;
      });
    } catch (e) {
      // Handle transaction failures specifically
      if (e is FirebaseException && e.code == 'aborted') {
        throw Exception('Transaction failed due to concurrent modification. Please try again.');
      }
      rethrow;
    }
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