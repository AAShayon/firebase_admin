import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/wishlist_item_entity.dart';

class WishlistItemModel extends WishlistItemEntity {
  WishlistItemModel({
    required super.productId,
    required super.productTitle,
    required super.price,
    super.imageUrl,
    required super.addedAt,
    required super.isInStock,
  });

  factory WishlistItemModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WishlistItemModel(
      productId: doc.id,
      productTitle: data['productTitle'] ?? 'Unknown Product',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      imageUrl: data['imageUrl'],
      addedAt: (data['addedAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isInStock: data['isInStock'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTitle': productTitle,
      'price': price,
      'imageUrl': imageUrl,
      'addedAt': FieldValue.serverTimestamp(),
      'isInStock': isInStock,
    };
  }
}