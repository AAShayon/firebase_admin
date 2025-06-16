import '../repositories/wishlist_repository.dart';

class RemoveFromWishlistUseCase {
  final WishlistRepository repository;

  RemoveFromWishlistUseCase(this.repository);

  /// Removes a product from the specified user's wishlist using its ID.
  Future<void> call(String userId, String productId) {
    return repository.removeFromWishlist(userId, productId);
  }
}