import '../../../shared/domain/entities/product_entity.dart';
import '../repositories/wishlist_repository.dart';

class AddToWishlistUseCase {
  final WishlistRepository repository;

  AddToWishlistUseCase(this.repository);

  /// Adds a given product to the specified user's wishlist.
  Future<void> call(String userId, ProductEntity product) {
    return repository.addToWishlist(userId, product);
  }
}