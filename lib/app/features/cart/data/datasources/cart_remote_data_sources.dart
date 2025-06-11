import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_item_model.dart';

abstract class CartRemoteDataSource {
  Stream<List<CartItem>> getCartItems(String userId);
  Future<void> addToCart(CartItem item);
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity);
  Future<void> removeFromCart(String userId, String cartItemId);
  Future<void> clearCart(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final FirebaseFirestore _firestore;

  CartRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  // This helper function remains the same as it's independent of the collection path.
  String _generateCartItemId(String productId, String variantSize, String variantColorName) {
    final sizeSafe = variantSize.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    final colorSafe = variantColorName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
    return '${productId}_${sizeSafe}_$colorSafe';
  }

  @override
  Future<void> addToCart(CartItem item) async {
    final cartItemId = _generateCartItemId(item.productId, item.variantSize, item.variantColorName);

    // UPDATED: Changed the collection path from a subcollection of 'users'
    // to a new top-level 'carts' collection.
    final cartItemRef = _firestore
        .collection('carts')
        .doc(item.userId) // The user's ID is the document for their cart.
        .collection('items') // The cart items are in a subcollection.
        .doc(cartItemId);

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(cartItemRef);

      if (snapshot.exists) {
        final existingQuantity = (snapshot.data()! as Map<String, dynamic>)['quantity'] as int;
        transaction.update(cartItemRef, {'quantity': existingQuantity + item.quantity});
      } else {
        final newItemWithId = CartItem(
          id: cartItemId,
          userId: item.userId,
          productId: item.productId,
          productTitle: item.productTitle,
          variantSize: item.variantSize,
          variantColorName: item.variantColorName,
          variantPrice: item.variantPrice,
          variantImageUrl: item.variantImageUrl,
          quantity: item.quantity,
        );
        transaction.set(cartItemRef, newItemWithId.toJson());
      }
    });
  }

  @override
  Stream<List<CartItem>> getCartItems(String userId) {
    // UPDATED: Changed the collection path to point to the new 'carts' collection.
    return _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return CartItem.fromJson(doc.id, doc.data());
      }).toList();
    });
  }

  @override
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity) async {
    if (newQuantity <= 0) {
      // This correctly calls the updated removeFromCart method below.
      await removeFromCart(userId, cartItemId);
    } else {
      // UPDATED: Changed the collection path.
      await _firestore
          .collection('carts')
          .doc(userId)
          .collection('items')
          .doc(cartItemId)
          .update({'quantity': newQuantity});
    }
  }

  @override
  Future<void> removeFromCart(String userId, String cartItemId) async {
    // UPDATED: Changed the collection path.
    await _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .doc(cartItemId)
        .delete();
  }

  @override
  Future<void> clearCart(String userId) async {
    // UPDATED: Changed the collection path.
    final cartItemsCollection = _firestore
        .collection('carts')
        .doc(userId)
        .collection('items');

    final cartSnapshot = await cartItemsCollection.get();

    if (cartSnapshot.docs.isEmpty) return;

    final WriteBatch batch = _firestore.batch();
    for (final doc in cartSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}