


import '../repositories/cart_repositories.dart';

class UpdateCartItemQuantityUseCase{
  final CartRepository repository;
  UpdateCartItemQuantityUseCase(this.repository);
  Future<void> call(String userId, String cartItemId, int newQuantity) => repository.updateCartItemQuantity(userId, cartItemId, newQuantity);
}