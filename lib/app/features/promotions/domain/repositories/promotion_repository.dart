import '../entities/promotion_entity.dart';

abstract class PromotionRepository {
  Future<void> createPromotion(PromotionEntity promotion);
  Future<void> updatePromotion(PromotionEntity promotion);
  Future<void> deletePromotion(String promotionId);
  Stream<List<PromotionEntity>> getAllPromotions(); // For admin
  Stream<List<PromotionEntity>> getActivePromotions(); // For users
  Future<PromotionEntity?> validateCoupon(String couponCode, String userId);
  Future<void> redeemCoupon(String promotionId, String userId);
}