import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/enums.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/presentation/providers/promotion_providers.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import 'checkout_state.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(
      CheckoutState(couponController: TextEditingController())
  );
  PromotionEntity? _appliedPromotion;

  /// Initializes the checkout state from the user's full shopping cart.
  void initializeFromCart({
    required List<CartItemEntity> cartItems,
    required UserAddress defaultAddress,
  }) {
    final subtotal = cartItems.fold(0.0, (sum, item) => sum + (item.variantPrice * item.quantity));
    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress),
      itemsToCheckout: cartItems,
    );
  }

  /// Initializes the checkout state for a single "Buy Now" item.
  void initializeForBuyNow({
    required ProductEntity product,
    required ProductVariantEntity variant,
    required UserAddress defaultAddress,
    required int quantity,
    required double finalUnitPrice,
  }) {
    final subtotal = finalUnitPrice * quantity;

    final buyNowItem = CartItemEntity(
      id: '', userId: '', // These are temporary and not used in this context
      productId: product.id,
      productTitle: product.title,
      variantSize: variant.size,
      variantColorName: describeEnum(variant.color),
      variantPrice: finalUnitPrice,
      variantImageUrl: variant.imageUrls.isNotEmpty ? variant.imageUrls.first : null,
      quantity: quantity,
    );

    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress),
      itemsToCheckout: [buyNowItem],
    );
  }

  // --- Methods to update checkout UI state ---
  void selectShippingAddress(UserAddress address) {
    state = state.copyWith(
      shippingAddress: address,
      deliveryFee: _calculateDeliveryFee(address),
      billingAddress: state.isBillingSameAsShipping ? address : state.billingAddress,
    );
  }

  void selectBillingAddress(UserAddress address) {
    state = state.copyWith(billingAddress: address);
  }

  void toggleBillingAddress(bool isSame) {
    state = state.copyWith(
      isBillingSameAsShipping: isSame,
      billingAddress: isSame ? state.shippingAddress : null,
    );
  }

  void selectPaymentMethod(String method) {
    state = state.copyWith(selectedPaymentMethod: method);
  }

  // --- THIS IS THE NEW, FUNCTIONAL applyCoupon METHOD ---
  Future<void> applyCoupon() async {
    final code = state.couponController.text.trim();
    if (code.isEmpty) return;

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      state = state.copyWith(error: 'Please log in to apply coupons.');
      return;
    }

    state = state.copyWith(isLoading: true, error: null); // Start loading, clear previous error

    try {
      final validateUseCase = ref.read(validateCouponUseCaseProvider);
      final validPromotion = await validateUseCase(code, currentUser.id);

      if (validPromotion != null) {
        _appliedPromotion = validPromotion; // Store the valid promotion
        double discountAmount = 0.0;

        // Calculate discount based on type
        if (validPromotion.discountType == DiscountType.fixedAmount) {
          discountAmount = validPromotion.discountValue;
        } else { // Percentage
          discountAmount = state.subtotal * (validPromotion.discountValue / 100);
        }

        state = state.copyWith(
          discount: discountAmount,
          isCouponApplied: true,
          isLoading: false,
        );
      } else {
        _appliedPromotion = null; // Clear any previously applied promotion
        state = state.copyWith(
          discount: 0.0,
          isCouponApplied: false,
          isLoading: false,
          error: 'This coupon is invalid, expired, or has already been used.',
        );
      }
    } catch (e) {
      _appliedPromotion = null;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }


  void removeCoupon() {
    _appliedPromotion = null; // Clear the stored promotion
    state.couponController.clear();
    state = state.copyWith(
      discount: 0.0,
      isCouponApplied: false,
      error: null, // Clear any previous errors
    );
  }

  /// Places the order using the items currently in the state.
  /// This method NO LONGER manages its own loading state.
  Future<void> placeOrder({String? transactionId}) async {
    final currentUser = ref.read(currentUserProvider);
    // Get the items to order DIRECTLY from the current state.
    final itemsToOrder = state.itemsToCheckout;

    if (currentUser == null || state.shippingAddress == null || itemsToOrder.isEmpty) {
      // Throw an error that can be caught by the UI if necessary
      throw Exception("Cannot place order. Missing user, address, or items.");
    }

    // The loading state is now managed entirely by the OrderNotifier and PaymentNotifier,
    // which the UI watches directly. We don't set it here.

    try {
      final userDisplayName = currentUser.displayName;
      String namePrefix;
      if (userDisplayName != null && userDisplayName.isNotEmpty) {
        final rawPrefix = userDisplayName.substring(0, userDisplayName.length > 4 ? 4 : userDisplayName.length);
        namePrefix = '${rawPrefix[0].toUpperCase()}${rawPrefix.substring(1).toLowerCase()}';
      } else {
        namePrefix = 'GuestUser';
      }

      final orderItems = itemsToOrder.map((item) => OrderItemEntity.fromCartItem(item)).toList();

      final newOrder = OrderEntity(
        id: '',
        userId: currentUser.id,
        items: orderItems,
        totalAmount: state.grandTotal,
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
        shippingAddress: _formatAddress(state.shippingAddress),
        billingAddress: _formatAddress(state.billingAddress),
        paymentMethod: state.selectedPaymentMethod,
        transactionId: transactionId,
      );

      // Call the order notifier. Its state change will be picked up by the UI listener.
      await ref.read(orderNotifierProvider.notifier).createOrder(newOrder, namePrefix);

      // Clear the main cart if this was a cart checkout.
      // Heuristic: If the number of items ordered is the same as the number in the cart,
      // it was a cart checkout. This is safer than checking for buyNowItems being null,
      // as the state could change.
      if (_appliedPromotion != null && _appliedPromotion!.couponCode != null) {
        await ref.read(redeemCouponUseCaseProvider).call(_appliedPromotion!.id, currentUser.id);
        // Reset the applied promotion after use
        _appliedPromotion = null;
      }

      final cartItemCount = ref.read(cartItemsStreamProvider(currentUser.id)).value?.length ?? -1;
      if (itemsToOrder.length == cartItemCount && cartItemCount > 0) {
        ref.read(cartNotifierProvider.notifier).clearCart(currentUser.id);
      }

    } catch (e) {
      // The error is primarily handled by the OrderNotifier's state.
      // We just log it here for debugging and re-throw it so the UI's catch block can see it.
      print("Error during placeOrder initiation: $e");
      rethrow;
    }
  }

  // --- Private Helper Methods ---
  double _calculateDeliveryFee(UserAddress? address) {
    if (address == null) return 0.0;
    if (address.country.toLowerCase() != 'bangladesh') return 10.0;
    if (address.city.toLowerCase() == 'dhaka') return 1.0;
    return 1.5;
  }

  String? _formatAddress(UserAddress? address) {
    if (address == null) return null;
    return '${address.addressLine1}, ${address.area ?? ''}, ${address.city}, ${address.state}, ${address.postalCode}, ${address.country}';
  }

  @override
  void dispose() {
    state.couponController.dispose();
    super.dispose();
  }
}