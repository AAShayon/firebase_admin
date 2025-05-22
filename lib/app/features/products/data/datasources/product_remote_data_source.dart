
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../model/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<void> addProduct(Product product);
  Stream<List<Product>> getProducts();
  // Future<void> createProduct(ProductEntity product);
  // Stream<List<Product>> getProducts();
  // Future<ProductEntity> getProductById(String id);
  // Future<void> updateProduct(ProductEntity product);
  // Future<void> deleteProduct(String id);
  // Future<String> uploadImage(File image);
}

// class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
//   final FirebaseFirestore _firestore = FirebaseProvider.firestore;
//   final FirebaseStorage _storage = FirebaseProvider.storage;
//
//   @override
//   Future<String> createProduct(ProductEntity product) async {
//     try {
//       final docRef = await _firestore.collection('products').add({
//         'name': product.name,
//         'description': product.description,
//         'imageUrl': product.imageUrl,
//         'createdAt': FieldValue.serverTimestamp(),
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       final batch = _firestore.batch();
//       for (final size in product.sizes) {
//         final sizeRef = docRef.collection('sizes').doc();
//         batch.set(sizeRef, {
//           'size': size.size,
//           'price': size.price,
//           'quantity': size.quantity,
//         });
//       }
//       await batch.commit();
//
//       return docRef.id;
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure();
//     }
//   }
//
//   @override
//   Future<List<ProductEntity>> getProducts() async {
//     try {
//       final snapshot = await _firestore.collection('products').get();
//       return await Future.wait(
//         snapshot.docs.map((doc) => _parseProduct(doc)).toList(),
//       );
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure();
//     }
//   }
//
//   Future<ProductEntity> _parseProduct(DocumentSnapshot doc) async {
//     final sizesSnapshot = await doc.reference.collection('sizes').get();
//     final sizes = sizesSnapshot.docs.map((sizeDoc) {
//       return ProductSizeEntity(
//         size: sizeDoc['size'],
//         price: sizeDoc['price'].toDouble(),
//         quantity: sizeDoc['quantity'],
//       );
//     }).toList();
//
//     return ProductEntity(
//       id: doc.id,
//       name: doc['name'],
//       description: doc['description'],
//       imageUrl: doc['imageUrl'],
//       sizes: sizes,
//       createdAt: (doc['createdAt'] as Timestamp).toDate(),
//       updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
//     );
//   }
//
//   @override
//   Future<String> uploadImage(File image) async {
//     try {
//       final ref = _storage.ref().child('products/${DateTime.now().millisecondsSinceEpoch}');
//       final uploadTask = ref.putFile(image);
//       final snapshot = await uploadTask;
//       return await snapshot.ref.getDownloadURL();
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure(message: 'Failed to upload image');
//     }
//   }
//
//   @override
//   Future<void> deleteProduct(String id) async {
//     try {
//       final docRef = _firestore.collection('products').doc(id);
//
//       // Delete sizes
//       final sizesSnapshot = await docRef.collection('sizes').get();
//       for (final doc in sizesSnapshot.docs) {
//         await doc.reference.delete();
//       }
//
//       // Delete product document
//       await docRef.delete();
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure();
//     }
//   }
//
//
//   @override
//   Future<ProductEntity> getProductById(String id) async {
//     try {
//       final doc = await _firestore.collection('products').doc(id).get();
//
//       if (!doc.exists) {
//         throw ProductFailure(message: 'Product not found');
//       }
//
//       final sizesSnapshot = await doc.reference.collection('sizes').get();
//       final sizes = sizesSnapshot.docs.map((sizeDoc) {
//         return ProductSizeEntity(
//           size: sizeDoc['size'],
//           price: sizeDoc['price'].toDouble(),
//           quantity: sizeDoc['quantity'],
//         );
//       }).toList();
//
//       return ProductEntity(
//         id: doc.id,
//         name: doc['name'],
//         description: doc['description'],
//         imageUrl: doc['imageUrl'],
//         sizes: sizes,
//         createdAt: (doc['createdAt'] as Timestamp).toDate(),
//         updatedAt: (doc['updatedAt'] as Timestamp).toDate(),
//       );
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure(message: 'Failed to fetch product by ID');
//     }
//   }
//
//
//   @override
//   Future<void> updateProduct(ProductEntity product) async {
//     try {
//       final docRef = _firestore.collection('products').doc(product.id);
//
//       await docRef.update({
//         'name': product.name,
//         'description': product.description,
//         'imageUrl': product.imageUrl,
//         'updatedAt': FieldValue.serverTimestamp(),
//       });
//
//       // Delete old sizes
//       final sizesRef = docRef.collection('sizes');
//       final sizesSnapshot = await sizesRef.get();
//       for (final doc in sizesSnapshot.docs) {
//         await doc.reference.delete();
//       }
//
//       // Add updated sizes
//       final batch = _firestore.batch();
//       for (final size in product.sizes) {
//         final sizeRef = sizesRef.doc();
//         batch.set(sizeRef, {
//           'size': size.size,
//           'price': size.price,
//           'quantity': size.quantity,
//         });
//       }
//       await batch.commit();
//
//     } on FirebaseException catch (e) {
//       throw ProductFailure.fromCode(e.code);
//     } catch (_) {
//       throw const ProductFailure();
//     }
//   }
//
// // Implement other methods similarly
// }
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ProductRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  })  : _firestore = firestore,
        _storage = storage;

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
        .map((snapshot) => snapshot.docs
        .map((doc) => Product.fromJson(doc.data()))
        .toList());
  }
}