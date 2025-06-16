import '../entities/wishlist_item_entity.dart';
import '../repositories/wishlist_repository.dart';

class GetWishlistItemsUseCase {
  final WishlistRepository repository;

  GetWishlistItemsUseCase(this.repository);

  Stream<List<WishlistItemEntity>> call(String userId) {
    return repository.getWishlistItems(userId);
  }
}