import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Core and Feature imports
import '../../../../core/helpers/enums.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import 'checkout_state.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(
      CheckoutState(couponController: TextEditingController())
  );

  /// --- METHOD 1: For checking out from the full cart ---
  void initializeFromCart(double subtotal, UserAddress defaultAddress) {
    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress),
      buyNowItems: null, // CRITICAL: Ensure this is null for a cart checkout
    );
  }

  /// --- METHOD 2: For the "Buy Now" feature ---
  void initializeForBuyNow({
    required ProductEntity product,
    required ProductVariantEntity variant,
    required UserAddress defaultAddress,
    required int quantity,
  }) {
    final subtotal = variant.price * quantity;

    // Create a temporary CartItemEntity to represent this single purchase
    final buyNowItem = CartItemEntity(
      id: '', userId: '', // These are temporary and not used in this context
      productId: product.id,
      productTitle: product.title,
      variantSize: variant.size,
      variantColorName:describeEnum(variant.color),
      variantPrice: variant.price,
      variantImageUrl: variant.imageUrls.isNotEmpty ? variant.imageUrls.first : null,
      quantity: quantity,
    );

    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress),
      buyNowItems: [buyNowItem], // Store the single item in the state
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

  void applyCoupon() {
    if (state.couponController.text.trim().toLowerCase() == 'firstorder') {
      state = state.copyWith(discount: 5.0, isCouponApplied: true);
    } else {
      state = state.copyWith(discount: 0.0, isCouponApplied: false);
    }
  }

  void removeCoupon() {
    state.couponController.clear();
    state = state.copyWith(discount: 0.0, isCouponApplied: false);
  }

  /// Places the order using either the full cart or the single "Buy Now" item.
  Future<void> placeOrder(
      List<CartItemEntity> itemsToOrder, {
        String? transactionId,
      }) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null || state.shippingAddress == null || itemsToOrder.isEmpty) {
      return;
    }

    if (state.isLoading) return;
    state = state.copyWith(isLoading: true);

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

      await ref.read(orderNotifierProvider.notifier).createOrder(newOrder, namePrefix);

      // Only clear the user's main cart if this was a cart checkout.
      if (state.buyNowItems == null) {
        ref.read(cartNotifierProvider.notifier).clearCart(currentUser.id);
      }
      

    } catch (e) {
      print("Error in placeOrder: $e");
    } finally {
      if (mounted) {
        state = state.copyWith(isLoading: false);
      }
    }
  }

  double _calculateDeliveryFee(UserAddress? address) {
    if (address == null) return 0.0;
    if (address.country.toLowerCase() != 'bangladesh') return 10.0;
    if (address.city.toLowerCase() == 'dhaka') return 1.0;
    return 1.5;
  }
  String? _formatAddress(UserAddress? address) {
    if (address == null) return null;
    // This creates a clean, readable string. Adjust fields as needed.
    return '${address.addressLine1}, ${address.area ?? ''}, ${address.city}, ${address.state}, ${address.postalCode}, ${address.country}';
  }

  @override
  void dispose() {
    state.couponController.dispose();
    super.dispose();
  }
}