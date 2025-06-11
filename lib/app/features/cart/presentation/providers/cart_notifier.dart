import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'cart_providers.dart';
import 'cart_state.dart';

class CartNotifier extends StateNotifier<CartState> {
  final Ref _ref;

  CartNotifier(this._ref) : super(const CartState.initial());

  /// Adds an item to the user's cart.
  Future<void> addToCart(CartItemEntity item) async {
    state = const CartState.loading();
    try {
      await _ref.read(addToCartUseCaseProvider).call(item);
      state = const CartState.success('Item added to cart!');
    } catch (e) {
      state = CartState.error(e.toString());
    }
  }

  /// Updates the quantity of a specific item in the cart.
  Future<void> updateItemQuantity(
    String userId,
    String cartItemId,
    int newQuantity,
  ) async {
    state = const CartState.loading();
    try {
      await _ref
          .read(updateCartItemQuantityUseCaseProvider)
          .call(userId, cartItemId, newQuantity);
      state = const CartState.success('Cart updated.');
    } catch (e) {
      state = CartState.error(e.toString());
    }
  }

  /// Removes a specific item from the user's cart.
  Future<void> removeFromCart(String userId, String cartItemId) async {
    state = const CartState.loading();
    try {
      await _ref.read(removeFromCartUseCaseProvider).call(userId, cartItemId);
      state = const CartState.success('Item removed from cart.');
    } catch (e) {
      state = CartState.error(e.toString());
    }
  }

  /// Removes all items from the user's cart.
  Future<void> clearCart(String userId) async {
    state = const CartState.loading();
    try {
      await _ref.read(clearCartUseCaseProvider).call(userId);
      state = const CartState.success('Cart has been cleared.');
    } catch (e) {
      state = CartState.error(e.toString());
    }
  }
}
