
import 'package:firebase_admin/app/features/cart/domain/repositories/cart_repositories.dart';

import '../entities/cart_item_entity.dart';

class GetCartItemsUseCase{
  final CartRepository repository;
  GetCartItemsUseCase(this.repository);
  Stream<List<CartItemEntity>> call(String userId) => repository.getCartItems(userId);
}


