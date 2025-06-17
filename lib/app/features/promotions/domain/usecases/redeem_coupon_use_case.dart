import '../repositories/promotion_repository.dart';

class RedeemCouponUseCase {
  final PromotionRepository repository;
  RedeemCouponUseCase(this.repository);

  Future<void> call(String promotionId, String userId) {
    return repository.redeemCoupon(promotionId, userId);
  }
}