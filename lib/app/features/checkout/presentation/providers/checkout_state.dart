import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../user_profile/domain/entities/user_profile_entity.dart';

part 'checkout_state.freezed.dart';

@freezed
class CheckoutState with _$CheckoutState {
  const factory CheckoutState({
    // Address selection
    UserAddress? shippingAddress,
    UserAddress? billingAddress,
    @Default(true) bool isBillingSameAsShipping,

    // Payment
    @Default('cod') String selectedPaymentMethod,

    // Coupon and Totals
    required TextEditingController couponController,
    @Default(0.0) double subtotal,
    @Default(0.0) double deliveryFee,
    @Default(0.0) double discount,
    @Default(false) bool isCouponApplied,

    // Status
    @Default(false) bool isLoading,

    // ---- ADD THIS LINE ----
    @Default(false) bool isInitialized,

  }) = _CheckoutState;

  const CheckoutState._();
  double get grandTotal => (subtotal + deliveryFee) - discount;
}