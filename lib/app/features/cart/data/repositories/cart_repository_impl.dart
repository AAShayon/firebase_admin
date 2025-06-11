import '../../domain/entities/cart_item_entity.dart';
import '../../domain/repositories/cart_repositories.dart';
import '../datasources/cart_remote_data_sources.dart';
import '../models/cart_item_model.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl({required this.remoteDataSource});

  /// Converts a [CartItemEntity] from the domain layer to a [CartItem] model for the data layer.
  CartItem _toModel(CartItemEntity entity) {
    return CartItem(
      // The ID from the entity might be a placeholder. The datasource will manage the real ID.
      id: entity.id,
      userId: entity.userId,
      productId: entity.productId,
      productTitle: entity.productTitle,
      variantSize: entity.variantSize,
      variantColorName: entity.variantColorName,
      variantPrice: entity.variantPrice,
      variantImageUrl: entity.variantImageUrl,
      quantity: entity.quantity,
    );
  }

  /// Converts a [CartItem] model from the data layer to a [CartItemEntity] for the domain layer.
  CartItemEntity _toEntity(CartItem model) {
    return CartItemEntity(
      id: model.id,
      userId: model.userId,
      productId: model.productId,
      productTitle: model.productTitle,
      variantSize: model.variantSize,
      variantColorName: model.variantColorName,
      variantPrice: model.variantPrice,
      variantImageUrl: model.variantImageUrl,
      quantity: model.quantity,
    );
  }

  @override
  Future<void> addToCart(CartItemEntity item) async {
    final cartItemModel = _toModel(item);
    await remoteDataSource.addToCart(cartItemModel);
  }

  @override
  Future<void> clearCart(String userId) async {
    await remoteDataSource.clearCart(userId);
  }

  @override
  Stream<List<CartItemEntity>> getCartItems(String userId) {
    return remoteDataSource.getCartItems(userId).map((cartModels) {
      return cartModels.map((model) => _toEntity(model)).toList();
    });
  }

  @override
  Future<void> removeFromCart(String userId, String cartItemId) async {
    await remoteDataSource.removeFromCart(userId, cartItemId);
  }

  @override
  Future<void> updateCartItemQuantity(String userId, String cartItemId, int newQuantity) async {
    await remoteDataSource.updateCartItemQuantity(userId, cartItemId, newQuantity);
  }
}