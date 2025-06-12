import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';
import 'checkout_state.dart';

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier() : super(CheckoutState(couponController: TextEditingController()));

  void initialize(double subtotal, UserAddress defaultAddress) {
    state = state.copyWith(
      subtotal: subtotal,
      shippingAddress: defaultAddress,
      billingAddress: state.isBillingSameAsShipping ? defaultAddress : null,
      isInitialized: true, // <-- SET THE FLAG HERE
    );
  }

  void selectShippingAddress(UserAddress address) {
    final newFee = _calculateDeliveryFee(address);
    state = state.copyWith(
      shippingAddress: address,
      deliveryFee: newFee,
      // If billing is same as shipping, update it as well
      billingAddress: state.isBillingSameAsShipping ? address : state.billingAddress,
    );
  }

  void selectBillingAddress(UserAddress address) {
    state = state.copyWith(billingAddress: address);
  }

  void toggleBillingAddress(bool isSame) {
    state = state.copyWith(
      isBillingSameAsShipping: isSame,
      // If it's now the same, copy the shipping address to billing
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
      // You can add error handling here, e.g., via another state property
      state = state.copyWith(discount: 0.0, isCouponApplied: false);
    }
  }

  void removeCoupon() {
    state.couponController.clear();
    state = state.copyWith(discount: 0.0, isCouponApplied: false);
  }

  double _calculateDeliveryFee(UserAddress? address) {
    if (address == null) return 0.0;

    if (address.country.toLowerCase() != 'bangladesh') {
      return 10.0; // Other countries: $10
    }
    if (address.city.toLowerCase() == 'dhaka') {
      return 1.0; // Inside Dhaka: $1
    }
    return 1.5; // Other cities in BD: $1.5
  }

  Future<void> placeOrder() async {
    // 1. Validate that addresses and payment methods are selected
    if (state.shippingAddress == null || state.billingAddress == null) {
      // Handle error: show a snackbar or dialog
      return;
    }

    // 2. Set loading state
    state = state.copyWith(isLoading: true);

    // 3. Call your repository/use case to place the order (to be implemented later)
    // For now, we simulate a network call
    await Future.delayed(const Duration(seconds: 2));

    // 4. Handle success or failure
    print('Order Placed!');
    print('Shipping: ${state.shippingAddress?.addressLine1}');
    print('Total: ${state.grandTotal}');

    // 5. Reset state
    state = state.copyWith(isLoading: false);

    // 6. Navigate to an order confirmation page (later)
  }

  @override
  void dispose() {
    state.couponController.dispose();
    super.dispose();
  }
}

