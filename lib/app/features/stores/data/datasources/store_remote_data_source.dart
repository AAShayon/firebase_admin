
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/network/firebase_provider.dart';

import '../../domain/entities/store_entity.dart';

abstract class StoreRemoteDataSource {
  Future<String> createStore(StoreEntity store);
  Future<List<StoreEntity>> getStores();
  Future<void> linkProductToStore(String storeId, String productId);
  // Future<List<ProductEntity>> getStoreProducts(String storeId);
}

class StoreRemoteDataSourceImpl implements StoreRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseProvider.firestore;

  @override
  Future<String> createStore(StoreEntity store) async {
    try {
      final docRef = await _firestore.collection('stores').add({
        'name': store.name,
        'productIds': store.productIds,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } on FirebaseException catch (e) {
      throw StoreFailure.fromCode(e.code);
    } catch (_) {
      throw const StoreFailure();
    }
  }

  @override
  Future<List<StoreEntity>> getStores() async {
    try {
      final snapshot = await _firestore
          .collection('stores')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return StoreEntity(
          id: doc.id,
          name: doc['name'],
          productIds: List<String>.from(doc['productIds'] ?? []),
          createdAt: (doc['createdAt'] as Timestamp).toDate(),
        );
      }).toList();
    } on FirebaseException catch (e) {
      throw StoreFailure.fromCode(e.code);
    } catch (_) {
      throw const StoreFailure();
    }
  }

  @override
  Future<void> linkProductToStore(String storeId, String productId) async {
    try {
      final batch = _firestore.batch();

      // Add to store's productIds array
      final storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'productIds': FieldValue.arrayUnion([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Create mapping document
      final mappingRef = _firestore.collection('product_store_mapping').doc();
      batch.set(mappingRef, {
        'productId': productId,
        'storeId': storeId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } on FirebaseException catch (e) {
      throw StoreFailure.fromCode(e.code);
    } catch (_) {
      throw const StoreFailure();
    }
  }

  // @override
  // Future<List<ProductEntity>> getStoreProducts(String storeId) async {
  //   try {
  //     // First get the store to verify it exists
  //     final storeDoc = await _firestore.collection('stores').doc(storeId).get();
  //     if (!storeDoc.exists) {
  //       throw const StoreFailure(message: 'Store not found');
  //     }
  //
  //     // Get all products referenced in the store
  //     final productIds = List<String>.from(storeDoc['productIds'] ?? []);
  //     if (productIds.isEmpty) return [];
  //
  //     // Fetch all products in parallel
  //     final products = await Future.wait(
  //       productIds.map((productId) async {
  //         final productDoc = await _firestore
  //             .collection('products')
  //             .doc(productId)
  //             .get();
  //
  //         if (!productDoc.exists) {
  //           throw const StoreFailure(message: 'Product not found');
  //         }
  //
  //         // Get sizes subcollection
  //         final sizesSnapshot = await productDoc.reference
  //             .collection('sizes')
  //             .get();
  //
  //         final sizes = sizesSnapshot.docs.map((sizeDoc) {
  //           return ProductSizeEntity(
  //             size: sizeDoc['size'],
  //             price: sizeDoc['price'].toDouble(),
  //             quantity: sizeDoc['quantity'],
  //           );
  //         }).toList();
  //
  //         return ProductEntity(
  //           id: productDoc.id,
  //           name: productDoc['name'],
  //           description: productDoc['description'],
  //           imageUrl: productDoc['imageUrl'],
  //           sizes: sizes,
  //           createdAt: (productDoc['createdAt'] as Timestamp).toDate(),
  //           updatedAt: (productDoc['updatedAt'] as Timestamp).toDate(),
  //         );
  //       }),
  //     );
  //
  //     return products;
  //   } on FirebaseException catch (e) {
  //     throw StoreFailure.fromCode(e.code);
  //   } on StoreFailure {
  //     rethrow;
  //   } catch (_) {
  //     throw const StoreFailure();
  //   }
  // }

  // Additional useful methods
  Future<List<StoreEntity>> getStoresContainingProduct(String productId) async {
    try {
      final querySnapshot = await _firestore
          .collection('product_store_mapping')
          .where('productId', isEqualTo: productId)
          .get();

      if (querySnapshot.docs.isEmpty) return [];

      return await Future.wait(
        querySnapshot.docs.map((doc) async {
          final storeDoc = await _firestore
              .collection('stores')
              .doc(doc['storeId'])
              .get();

          return StoreEntity(
            id: storeDoc.id,
            name: storeDoc['name'],
            productIds: List<String>.from(storeDoc['productIds'] ?? []),
            createdAt: (storeDoc['createdAt'] as Timestamp).toDate(),
          );
        }),
      );
    } on FirebaseException catch (e) {
      throw StoreFailure.fromCode(e.code);
    } catch (_) {
      throw const StoreFailure();
    }
  }

  Future<void> unlinkProductFromStore(String storeId, String productId) async {
    try {
      final batch = _firestore.batch();

      // Remove from store's productIds array
      final storeRef = _firestore.collection('stores').doc(storeId);
      batch.update(storeRef, {
        'productIds': FieldValue.arrayRemove([productId]),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete mapping documents (there might be multiple)
      final mappingQuery = await _firestore
          .collection('product_store_mapping')
          .where('storeId', isEqualTo: storeId)
          .where('productId', isEqualTo: productId)
          .get();

      for (final doc in mappingQuery.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      throw StoreFailure.fromCode(e.code);
    } catch (_) {
      throw const StoreFailure();
    }
  }
}