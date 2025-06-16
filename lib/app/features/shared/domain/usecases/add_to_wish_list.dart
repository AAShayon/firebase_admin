import 'package:firebase_admin/app/features/shared/domain/repositories/product_repository.dart';

class AddToWishListUseCase {
  final ProductRepository repository;

  AddToWishListUseCase(this.repository);

  Future<void> call(String productId, String userId) {
    return repository.addToWishlist(productId, userId);
  }
}
