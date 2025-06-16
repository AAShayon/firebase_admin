import '../repositories/wishlist_repository.dart';

class GetWishlistIdsUseCase {
  final WishlistRepository repository;

  GetWishlistIdsUseCase(this.repository);

  Stream<Set<String>> call(String userId) {
    return repository.getWishlistIds(userId);
  }
}