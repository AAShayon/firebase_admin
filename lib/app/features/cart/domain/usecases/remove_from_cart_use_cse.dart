

import '../repositories/cart_repositories.dart';

class RemoveFromCartUseCase{
  final CartRepository repository;
  RemoveFromCartUseCase(this.repository);
  Future<void> call(String userId, String cartItemId) => repository.removeFromCart(userId, cartItemId);
}