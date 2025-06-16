import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/wishlist_item_model.dart';

// This is the contract for what the data source can do.
abstract class WishlistRemoteDataSource {
  Future<void> addToWishlist(String userId, WishlistItemModel item);
  Future<void> removeFromWishlist(String userId, String productId);
  Stream<QuerySnapshot> watchWishlistItems(String userId);
}

// This is the implementation that uses Firebase.
class WishlistRemoteDataSourceImpl implements WishlistRemoteDataSource {
  final FirebaseFirestore _firestore;
  WishlistRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  /// Adds a document to the user's private wishlist subcollection.
  /// The document ID is the product's ID to prevent duplicates.
  @override
  Future<void> addToWishlist(String userId, WishlistItemModel item) {
    return _firestore
        .collection('users') // Path starts at users
        .doc(userId)
        .collection('wishlists') // The private subcollection
        .doc(item.productId)
        .set(item.toJson());
  }

  /// Removes a document from the user's private wishlist subcollection.
  @override
  Future<void> removeFromWishlist(String userId, String productId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wishlists')
        .doc(productId)
        .delete();
  }

  /// Watches for real-time changes in the user's private wishlist subcollection.
  @override
  Stream<QuerySnapshot> watchWishlistItems(String userId) {
    return _firestore.collection('users').doc(userId).collection('wishlists').orderBy('addedAt', descending: true).snapshots();
  }
}