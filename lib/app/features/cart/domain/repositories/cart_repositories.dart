import '../entities/cart_item_entity.dart';

abstract class CartRepository {
  /// Retrieves a real-time stream of cart items for a given user.
  Stream<List<CartItemEntity>> getCartItems(String userId);

  /// Adds an item to the cart. If the item (product + variant) already exists,
  /// its quantity is updated.
  /// The passed entity's `id` can be a placeholder, as the data source will generate the final ID.
  Future<void> addToCart(CartItemEntity item);

  /// Updates the quantity of a specific item in the cart, identified by its unique [cartItemId].
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity);

  /// Removes a specific item from the cart using its unique [cartItemId].
  Future<void> removeFromCart(String userId, String cartItemId);

  /// Removes all items from the user's cart.
  Future<void> clearCart(String userId);
}