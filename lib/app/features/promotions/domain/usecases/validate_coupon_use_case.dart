import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class ValidateCouponUseCase {
  final PromotionRepository repository;
  ValidateCouponUseCase(this.repository);

  Future<PromotionEntity?> call(String couponCode, String userId) {
    return repository.validateCoupon(couponCode, userId);
  }
}

