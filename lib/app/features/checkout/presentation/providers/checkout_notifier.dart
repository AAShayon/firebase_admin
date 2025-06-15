import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import '../../../../core/helpers/enums.dart'; // Ensure you have this enum file
import 'checkout_state.dart';

// This is the complete and correct Notifier.
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final Ref ref;

  CheckoutNotifier(this.ref) : super(
    // Initialize with a coupon controller.
      CheckoutState(couponController: TextEditingController())
  );

  // Method to initialize the checkout state with data from the cart.
  void initialize(double subtotal, UserAddress defaultAddress) {
    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true,
      deliveryFee: _calculateDeliveryFee(defaultAddress), // Also calculate initial fee
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
  // --- The main logic to place the order ---
  Future<void> placeOrder(List<CartItemEntity> cartItems, String? transactionId) async {
    final currentUser = ref.read(currentUserProvider);
    final userDisplayName = currentUser?.displayName;
    if (currentUser == null || state.shippingAddress == null || cartItems.isEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true);

    try {
      final orderItems = cartItems.map((cartItem) => OrderItemEntity(
        productId: cartItem.productId,
        productTitle: cartItem.productTitle,
        variantSize: cartItem.variantSize,
        variantColorName: cartItem.variantColorName,
        price: cartItem.variantPrice,
        quantity: cartItem.quantity,
        imageUrl: cartItem.variantImageUrl,
      )).toList();
      String namePrefix;
      if (userDisplayName != null && userDisplayName.isNotEmpty) {
        // Take the first 4 letters, handling names shorter than 4.
        final rawPrefix = userDisplayName.substring(0, userDisplayName.length > 4 ? 4 : userDisplayName.length);
        // Capitalize the first letter for a clean "Fabia" look.
        namePrefix = '${rawPrefix[0].toUpperCase()}${rawPrefix.substring(1).toLowerCase()}';
      } else {
        namePrefix = 'GuestUser';
      }


      final newOrder = OrderEntity(
        id:  '',
        userId: currentUser.id,
        items: orderItems,
        totalAmount: state.grandTotal,
        orderDate: DateTime.now(),
        status: OrderStatus.pending,
        shippingAddress: _formatAddress(state.shippingAddress),
        billingAddress: (state.isBillingSameAsShipping)
            ? _formatAddress(state.shippingAddress)
            : _formatAddress(state.billingAddress),
        paymentMethod: state.selectedPaymentMethod,
        transactionId: transactionId,
      );

      // THIS IS THE KEY CONNECTION
      await ref.read(orderNotifierProvider.notifier).createOrder(newOrder,namePrefix);
      ref.read(cartNotifierProvider.notifier).clearCart(currentUser.id);

      state = state.copyWith(isLoading: false);

    } catch (e) {
      // If something goes wrong before calling the order notifier
      state = state.copyWith(isLoading: false);
      // You could also set an error state here
    }
  }


  @override
  void dispose() {
    state.couponController.dispose();
    super.dispose();
  }
}