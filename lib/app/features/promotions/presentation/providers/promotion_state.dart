import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/promotion_entity.dart';

part 'promotion_state.freezed.dart';

@freezed
class PromotionState with _$PromotionState {
  const factory PromotionState.initial() = _Initial;
  const factory PromotionState.loading() = _Loading;
  const factory PromotionState.success(String message) = _Success;
  const factory PromotionState.error(String message) = _Error;
  // A special state for when a coupon is validated successfully
  const factory PromotionState.couponValidated(PromotionEntity promotion) = _CouponValidated;
}