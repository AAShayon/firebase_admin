import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import 'home_page_state.dart';

class HomePageNotifier extends StateNotifier<HomePageState> {
  final Ref _ref;
  HomePageNotifier(this._ref) : super(const HomePageState());

  // Method to handle the entire add-to-cart process
  Future<void> addToCart(ProductEntity product, PromotionEntity? promotion, BuildContext context) async {
    if (state.isAddingToCart) return; // Prevent double taps

    state = state.copyWith(isAddingToCart: true, cartProductId: product.id);

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentUser = _ref.read(currentUserProvider);

    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Please log in to add items to your cart.')));
      state = state.copyWith(isAddingToCart: false, cartProductId: null);
      return;
    }

    try {
      final selectedVariant = product.variants.firstWhere((v) => v.quantity > 0, orElse: () => product.variants.first);
      final finalPrice = calculateFinalPrice(
        product: product,
        variant: selectedVariant,
        promotion: promotion,
      );

      final cartItem = CartItemEntity(
        id: '', userId: currentUser.id, productId: product.id,
        productTitle: product.title,
        variantSize: selectedVariant.size,
        variantColorName: describeEnum(selectedVariant.color),
        variantPrice: finalPrice,
        variantImageUrl: selectedVariant.imageUrls.isNotEmpty ? selectedVariant.imageUrls.first : null,
        quantity: 1,
      );

      await _ref.read(cartNotifierProvider.notifier).addToCart(cartItem);
      scaffoldMessenger.showSnackBar(SnackBar(
        content: Text('${product.title} added to cart!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    } catch (e) {
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Failed to add item: ${e.toString()}'), backgroundColor: Colors.red));
    } finally {
      // Use a timer to reset the loading state after animation is likely complete
      await Future.delayed(const Duration(milliseconds: 700));
      if(mounted) {
        state = state.copyWith(isAddingToCart: false, cartProductId: null);
      }
    }
  }
}