import '../../domain/entities/wishlist_item_entity.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../domain/repositories/wishlist_repository.dart';
import '../datasources/wishlist_remote_data_source.dart';
import '../models/wishlist_item_model.dart';

class WishlistRepositoryImpl implements WishlistRepository {

  final WishlistRemoteDataSource remoteDataSource;

  WishlistRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addToWishlist(String userId, ProductEntity product) {
    final wishlistItem = WishlistItemModel(
      productId: product.id,
      productTitle: product.title,
      price: product.variants.first.price,
      imageUrl: product.variants.first.imageUrls.isNotEmpty ? product.variants.first.imageUrls.first : null,
      addedAt: DateTime.now(),
      isInStock: product.availability,
    );


    return remoteDataSource.addToWishlist(userId, wishlistItem);
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) {
    return remoteDataSource.removeFromWishlist(userId, productId);
  }

  @override
  Stream<List<WishlistItemEntity>> getWishlistItems(String userId) {
    // 1. Get the raw QuerySnapshot stream from the data source.
    return remoteDataSource.watchWishlistItems(userId).map((snapshot) {
      // 2. Map the raw documents into our clean WishlistItemEntity objects.
      //    Since WishlistItemModel extends WishlistItemEntity, this works directly.
      return snapshot.docs.map((doc) => WishlistItemModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Stream<Set<String>> getWishlistIds(String userId) {
    return remoteDataSource.watchWishlistItems(userId).map((snapshot) {
      // Just map the document IDs into a Set for quick lookups.
      return snapshot.docs.map((doc) => doc.id).toSet();
    });
  }
}