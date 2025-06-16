
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../shared/data/model/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<void> addProduct(Product product);
  Stream<List<Product>> getProducts();
  Future<void> updateProduct(Product product); // ADDED
  Future<void> deleteProduct(String productId); // ADDED
  Future<List<Product>> searchProducts(String query);
  Future<void> addToWishlist(String productId, String userId);

}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

  // NEW METHOD
  @override
  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toJson());
  }

  // NEW METHOD
  @override
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
  }
  @override
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).set(product.toJson());
  }

  @override
  Stream<List<Product>> getProducts() {
    return _firestore
        .collection('products')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Product.fromJson(doc.data() as Map<String, dynamic>);
        } catch (e) {
          log("Error parsing product ${doc.id}: $e");
          return Product(id: doc.id, title: 'Error: Invalid Data', description: '', variants: [], availability: false, category: ProductCategory.ecom, createdAt: DateTime.now());
        }
      }).toList();
    });
  }
  @override
  Future<List<Product>> searchProducts(String query) async {
    // 1. Get the full list of products one time.
    final allProducts = await getProducts().first;

    // 2. If the query is empty, return an empty list.
    if (query.isEmpty) {
      return [];
    }

    // 3. Filter the list in-memory (client-side).
    final lowerCaseQuery = query.toLowerCase();
    return allProducts.where((product) {
      final titleMatches = product.title.toLowerCase().contains(lowerCaseQuery);
      final idMatches = product.id.toLowerCase().contains(lowerCaseQuery);
      // You could also search descriptions, categories, etc.
      // final descriptionMatches = product.description.toLowerCase().contains(lowerCaseQuery);

      return titleMatches || idMatches;
    }).toList();
  }
  @override
  Future<void> addToWishlist(String productId, String userId) async {
    await _firestore.collection('wishlist').add({
      'productId': productId,
      'userId': userId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }


}
