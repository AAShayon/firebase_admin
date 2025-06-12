// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'checkout_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$CheckoutState {
  // Address selection
  UserAddress? get shippingAddress => throw _privateConstructorUsedError;
  UserAddress? get billingAddress => throw _privateConstructorUsedError;
  bool get isBillingSameAsShipping =>
      throw _privateConstructorUsedError; // Payment
  String get selectedPaymentMethod =>
      throw _privateConstructorUsedError; // Coupon and Totals
  TextEditingController get couponController =>
      throw _privateConstructorUsedError;
  double get subtotal => throw _privateConstructorUsedError;
  double get deliveryFee => throw _privateConstructorUsedError;
  double get discount => throw _privateConstructorUsedError;
  bool get isCouponApplied => throw _privateConstructorUsedError; // Status
  bool get isLoading =>
      throw _privateConstructorUsedError; // ---- ADD THIS LINE ----
  bool get isInitialized => throw _privateConstructorUsedError;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CheckoutStateCopyWith<CheckoutState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CheckoutStateCopyWith<$Res> {
  factory $CheckoutStateCopyWith(
    CheckoutState value,
    $Res Function(CheckoutState) then,
  ) = _$CheckoutStateCopyWithImpl<$Res, CheckoutState>;
  @useResult
  $Res call({
    UserAddress? shippingAddress,
    UserAddress? billingAddress,
    bool isBillingSameAsShipping,
    String selectedPaymentMethod,
    TextEditingController couponController,
    double subtotal,
    double deliveryFee,
    double discount,
    bool isCouponApplied,
    bool isLoading,
    bool isInitialized,
  });
}

/// @nodoc
class _$CheckoutStateCopyWithImpl<$Res, $Val extends CheckoutState>
    implements $CheckoutStateCopyWith<$Res> {
  _$CheckoutStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shippingAddress = freezed,
    Object? billingAddress = freezed,
    Object? isBillingSameAsShipping = null,
    Object? selectedPaymentMethod = null,
    Object? couponController = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? isCouponApplied = null,
    Object? isLoading = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _value.copyWith(
            shippingAddress:
                freezed == shippingAddress
                    ? _value.shippingAddress
                    : shippingAddress // ignore: cast_nullable_to_non_nullable
                        as UserAddress?,
            billingAddress:
                freezed == billingAddress
                    ? _value.billingAddress
                    : billingAddress // ignore: cast_nullable_to_non_nullable
                        as UserAddress?,
            isBillingSameAsShipping:
                null == isBillingSameAsShipping
                    ? _value.isBillingSameAsShipping
                    : isBillingSameAsShipping // ignore: cast_nullable_to_non_nullable
                        as bool,
            selectedPaymentMethod:
                null == selectedPaymentMethod
                    ? _value.selectedPaymentMethod
                    : selectedPaymentMethod // ignore: cast_nullable_to_non_nullable
                        as String,
            couponController:
                null == couponController
                    ? _value.couponController
                    : couponController // ignore: cast_nullable_to_non_nullable
                        as TextEditingController,
            subtotal:
                null == subtotal
                    ? _value.subtotal
                    : subtotal // ignore: cast_nullable_to_non_nullable
                        as double,
            deliveryFee:
                null == deliveryFee
                    ? _value.deliveryFee
                    : deliveryFee // ignore: cast_nullable_to_non_nullable
                        as double,
            discount:
                null == discount
                    ? _value.discount
                    : discount // ignore: cast_nullable_to_non_nullable
                        as double,
            isCouponApplied:
                null == isCouponApplied
                    ? _value.isCouponApplied
                    : isCouponApplied // ignore: cast_nullable_to_non_nullable
                        as bool,
            isLoading:
                null == isLoading
                    ? _value.isLoading
                    : isLoading // ignore: cast_nullable_to_non_nullable
                        as bool,
            isInitialized:
                null == isInitialized
                    ? _value.isInitialized
                    : isInitialized // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CheckoutStateImplCopyWith<$Res>
    implements $CheckoutStateCopyWith<$Res> {
  factory _$$CheckoutStateImplCopyWith(
    _$CheckoutStateImpl value,
    $Res Function(_$CheckoutStateImpl) then,
  ) = __$$CheckoutStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    UserAddress? shippingAddress,
    UserAddress? billingAddress,
    bool isBillingSameAsShipping,
    String selectedPaymentMethod,
    TextEditingController couponController,
    double subtotal,
    double deliveryFee,
    double discount,
    bool isCouponApplied,
    bool isLoading,
    bool isInitialized,
  });
}

/// @nodoc
class __$$CheckoutStateImplCopyWithImpl<$Res>
    extends _$CheckoutStateCopyWithImpl<$Res, _$CheckoutStateImpl>
    implements _$$CheckoutStateImplCopyWith<$Res> {
  __$$CheckoutStateImplCopyWithImpl(
    _$CheckoutStateImpl _value,
    $Res Function(_$CheckoutStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? shippingAddress = freezed,
    Object? billingAddress = freezed,
    Object? isBillingSameAsShipping = null,
    Object? selectedPaymentMethod = null,
    Object? couponController = null,
    Object? subtotal = null,
    Object? deliveryFee = null,
    Object? discount = null,
    Object? isCouponApplied = null,
    Object? isLoading = null,
    Object? isInitialized = null,
  }) {
    return _then(
      _$CheckoutStateImpl(
        shippingAddress:
            freezed == shippingAddress
                ? _value.shippingAddress
                : shippingAddress // ignore: cast_nullable_to_non_nullable
                    as UserAddress?,
        billingAddress:
            freezed == billingAddress
                ? _value.billingAddress
                : billingAddress // ignore: cast_nullable_to_non_nullable
                    as UserAddress?,
        isBillingSameAsShipping:
            null == isBillingSameAsShipping
                ? _value.isBillingSameAsShipping
                : isBillingSameAsShipping // ignore: cast_nullable_to_non_nullable
                    as bool,
        selectedPaymentMethod:
            null == selectedPaymentMethod
                ? _value.selectedPaymentMethod
                : selectedPaymentMethod // ignore: cast_nullable_to_non_nullable
                    as String,
        couponController:
            null == couponController
                ? _value.couponController
                : couponController // ignore: cast_nullable_to_non_nullable
                    as TextEditingController,
        subtotal:
            null == subtotal
                ? _value.subtotal
                : subtotal // ignore: cast_nullable_to_non_nullable
                    as double,
        deliveryFee:
            null == deliveryFee
                ? _value.deliveryFee
                : deliveryFee // ignore: cast_nullable_to_non_nullable
                    as double,
        discount:
            null == discount
                ? _value.discount
                : discount // ignore: cast_nullable_to_non_nullable
                    as double,
        isCouponApplied:
            null == isCouponApplied
                ? _value.isCouponApplied
                : isCouponApplied // ignore: cast_nullable_to_non_nullable
                    as bool,
        isLoading:
            null == isLoading
                ? _value.isLoading
                : isLoading // ignore: cast_nullable_to_non_nullable
                    as bool,
        isInitialized:
            null == isInitialized
                ? _value.isInitialized
                : isInitialized // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$CheckoutStateImpl extends _CheckoutState {
  const _$CheckoutStateImpl({
    this.shippingAddress,
    this.billingAddress,
    this.isBillingSameAsShipping = true,
    this.selectedPaymentMethod = 'cod',
    required this.couponController,
    this.subtotal = 0.0,
    this.deliveryFee = 0.0,
    this.discount = 0.0,
    this.isCouponApplied = false,
    this.isLoading = false,
    this.isInitialized = false,
  }) : super._();

  // Address selection
  @override
  final UserAddress? shippingAddress;
  @override
  final UserAddress? billingAddress;
  @override
  @JsonKey()
  final bool isBillingSameAsShipping;
  // Payment
  @override
  @JsonKey()
  final String selectedPaymentMethod;
  // Coupon and Totals
  @override
  final TextEditingController couponController;
  @override
  @JsonKey()
  final double subtotal;
  @override
  @JsonKey()
  final double deliveryFee;
  @override
  @JsonKey()
  final double discount;
  @override
  @JsonKey()
  final bool isCouponApplied;
  // Status
  @override
  @JsonKey()
  final bool isLoading;
  // ---- ADD THIS LINE ----
  @override
  @JsonKey()
  final bool isInitialized;

  @override
  String toString() {
    return 'CheckoutState(shippingAddress: $shippingAddress, billingAddress: $billingAddress, isBillingSameAsShipping: $isBillingSameAsShipping, selectedPaymentMethod: $selectedPaymentMethod, couponController: $couponController, subtotal: $subtotal, deliveryFee: $deliveryFee, discount: $discount, isCouponApplied: $isCouponApplied, isLoading: $isLoading, isInitialized: $isInitialized)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CheckoutStateImpl &&
            (identical(other.shippingAddress, shippingAddress) ||
                other.shippingAddress == shippingAddress) &&
            (identical(other.billingAddress, billingAddress) ||
                other.billingAddress == billingAddress) &&
            (identical(
                  other.isBillingSameAsShipping,
                  isBillingSameAsShipping,
                ) ||
                other.isBillingSameAsShipping == isBillingSameAsShipping) &&
            (identical(other.selectedPaymentMethod, selectedPaymentMethod) ||
                other.selectedPaymentMethod == selectedPaymentMethod) &&
            (identical(other.couponController, couponController) ||
                other.couponController == couponController) &&
            (identical(other.subtotal, subtotal) ||
                other.subtotal == subtotal) &&
            (identical(other.deliveryFee, deliveryFee) ||
                other.deliveryFee == deliveryFee) &&
            (identical(other.discount, discount) ||
                other.discount == discount) &&
            (identical(other.isCouponApplied, isCouponApplied) ||
                other.isCouponApplied == isCouponApplied) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.isInitialized, isInitialized) ||
                other.isInitialized == isInitialized));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    shippingAddress,
    billingAddress,
    isBillingSameAsShipping,
    selectedPaymentMethod,
    couponController,
    subtotal,
    deliveryFee,
    discount,
    isCouponApplied,
    isLoading,
    isInitialized,
  );

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CheckoutStateImplCopyWith<_$CheckoutStateImpl> get copyWith =>
      __$$CheckoutStateImplCopyWithImpl<_$CheckoutStateImpl>(this, _$identity);
}

abstract class _CheckoutState extends CheckoutState {
  const factory _CheckoutState({
    final UserAddress? shippingAddress,
    final UserAddress? billingAddress,
    final bool isBillingSameAsShipping,
    final String selectedPaymentMethod,
    required final TextEditingController couponController,
    final double subtotal,
    final double deliveryFee,
    final double discount,
    final bool isCouponApplied,
    final bool isLoading,
    final bool isInitialized,
  }) = _$CheckoutStateImpl;
  const _CheckoutState._() : super._();

  // Address selection
  @override
  UserAddress? get shippingAddress;
  @override
  UserAddress? get billingAddress;
  @override
  bool get isBillingSameAsShipping; // Payment
  @override
  String get selectedPaymentMethod; // Coupon and Totals
  @override
  TextEditingController get couponController;
  @override
  double get subtotal;
  @override
  double get deliveryFee;
  @override
  double get discount;
  @override
  bool get isCouponApplied; // Status
  @override
  bool get isLoading; // ---- ADD THIS LINE ----
  @override
  bool get isInitialized;

  /// Create a copy of CheckoutState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CheckoutStateImplCopyWith<_$CheckoutStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
