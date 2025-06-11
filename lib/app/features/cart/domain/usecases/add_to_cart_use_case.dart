import 'package:firebase_admin/app/features/cart/domain/repositories/cart_repositories.dart';

import '../entities/cart_item_entity.dart';


class AddToCartUseCase{
  final CartRepository repository;
  AddToCartUseCase(this.repository);
  Future<void> call(CartItemEntity item) => repository.addToCart(item);

}