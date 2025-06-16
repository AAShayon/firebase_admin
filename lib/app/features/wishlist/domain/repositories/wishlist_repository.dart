import '../entities/wishlist_item_entity.dart';
import '../../../shared/domain/entities/product_entity.dart'; // We still need this to add an item

abstract class WishlistRepository {
  // We pass the full product to get its details
  Future<void> addToWishlist(String userId, ProductEntity product);
  Future<void> removeFromWishlist(String userId, String productId);
  Stream<List<WishlistItemEntity>> getWishlistItems(String userId);
  Stream<Set<String>> getWishlistIds(String userId); // This is still useful for the heart icon
}