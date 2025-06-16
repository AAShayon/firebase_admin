import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../../domain/usecase/add_to_wishlist_use_case.dart';
import '../../domain/usecase/get_wishlist_ids_use_case.dart';
import '../../domain/usecase/get_wishlist_items_use_case.dart';
import '../../domain/usecase/remove_from_wishlist_use_case.dart';


// --- USE CASE PROVIDERS (Corrected) ---
final addToWishlistUseCaseProvider = Provider<AddToWishlistUseCase>((ref) => locator<AddToWishlistUseCase>());
final removeFromWishlistUseCaseProvider = Provider<RemoveFromWishlistUseCase>((ref) => locator<RemoveFromWishlistUseCase>());
final getWishlistIdsUseCaseProvider = Provider<GetWishlistIdsUseCase>((ref) => locator<GetWishlistIdsUseCase>());
// Correctly named use case provider
final getWishlistItemsUseCaseProvider = Provider<GetWishlistItemsUseCase>((ref) => locator<GetWishlistItemsUseCase>());


// --- UI DATA PROVIDERS ---

/// This provider gives a Set of product IDs that are in the current user's wishlist.
/// The ProductCard watches this to know if its heart icon should be filled or not.
final wishlistIdsProvider = StreamProvider.autoDispose.family<Set<String>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value({});

  final useCase = ref.watch(getWishlistIdsUseCaseProvider);
  return useCase(userId);
});

/// This provider gives the full list of WishlistItemEntity objects for the WishlistPage UI.
/// It no longer provides ProductEntity, but the denormalized item data.
final wishlistItemsProvider = StreamProvider.autoDispose.family<List<WishlistItemEntity>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value([]);

  final useCase = ref.watch(getWishlistItemsUseCaseProvider);
  return useCase(userId);
});