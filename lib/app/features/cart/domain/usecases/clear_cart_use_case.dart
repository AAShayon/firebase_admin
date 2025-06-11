import '../repositories/cart_repositories.dart';

class ClearCartUseCase {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  Future<void> call(String userId) => repository.clearCart(userId);
}
