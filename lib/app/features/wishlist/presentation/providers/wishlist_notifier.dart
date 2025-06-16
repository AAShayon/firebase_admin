import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/domain/entities/product_entity.dart'; // <-- IMPORT THIS
import 'wishlist_providers.dart';
import 'wishlist_state.dart';

class WishlistNotifier extends StateNotifier<WishlistState> {
  final Ref _ref;
  WishlistNotifier(this._ref) : super(const WishlistState.initial());

  // --- THIS IS THE CORRECTED METHOD ---
  // It now accepts the full ProductEntity object.
  Future<void> addToWishlist(String userId, ProductEntity product) async {
    try {
      await _ref.read(addToWishlistUseCaseProvider).call(userId, product);
    } catch (e) {
      if (mounted) {
        state = WishlistState.error(e.toString());
      }
    }
  }

  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      await _ref.read(removeFromWishlistUseCaseProvider).call(userId, productId);
    } catch (e) {
      if (mounted) {
        state = WishlistState.error(e.toString());
      }
    }
  }
}