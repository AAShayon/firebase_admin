import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/usecases/add_to_cart_use_case.dart';
import '../../domain/usecases/clear_cart_use_case.dart';
import '../../domain/usecases/get_cart_items_use_case.dart';
import '../../domain/usecases/remove_from_cart_use_cse.dart';
import '../../domain/usecases/update_cart_item_use_case.dart';


// --- Use Case Providers ---
// These wrap your use cases from the service locator, making them available to other providers.

final getCartItemsUseCaseProvider = Provider<GetCartItemsUseCase>((ref) {
  return locator<GetCartItemsUseCase>();
});

final addToCartUseCaseProvider = Provider<AddToCartUseCase>((ref) {
  return locator<AddToCartUseCase>();
});

final updateCartItemQuantityUseCaseProvider = Provider<UpdateCartItemQuantityUseCase>((ref) {
  return locator<UpdateCartItemQuantityUseCase>();
});

final removeFromCartUseCaseProvider = Provider<RemoveFromCartUseCase>((ref) {
  return locator<RemoveFromCartUseCase>();
});

final clearCartUseCaseProvider = Provider<ClearCartUseCase>((ref) {
  return locator<ClearCartUseCase>();
});


// --- Data Provider ---
// This is the primary provider the UI should use to DISPLAY the cart contents.
// It's a family because we need the userId to know which cart to stream.

final cartItemsStreamProvider = StreamProvider.family<List<CartItemEntity>, String>((ref, userId) {
  final getCartItemsUseCase = ref.watch(getCartItemsUseCaseProvider);
  return getCartItemsUseCase.call(userId);
});