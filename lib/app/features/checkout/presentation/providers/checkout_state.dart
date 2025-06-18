import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';

part 'checkout_state.freezed.dart';

@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    UserAddress? shippingAddress,
    UserAddress? billingAddress,
    @Default(true) bool isBillingSameAsShipping,
    @Default('cod') String selectedPaymentMethod,
    required TextEditingController couponController,
    @Default(0.0) double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double discount,
    @Default(false) bool isCouponApplied,
    @Default(false) bool isLoading,
    @Default(false) bool isInitialized,

    // This list holds the items for the current checkout session.
    @Default([]) List<CartItemEntity> itemsToCheckout,
    String? error,
  }) = _CheckoutState;

  const CheckoutState._();
  double get grandTotal => (subtotal + deliveryFee) - discount;
}