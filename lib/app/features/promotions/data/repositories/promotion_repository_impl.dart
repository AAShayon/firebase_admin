import '../../domain/entities/promotion_entity.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_data_source.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createPromotion(PromotionEntity promotion) {
    final model = PromotionModel(
        id: promotion.id, title: promotion.title, description: promotion.description,
        imageUrl: promotion.imageUrl, discountType: promotion.discountType,
        discountValue: promotion.discountValue, startDate: promotion.startDate,
        endDate: promotion.endDate, couponCode: promotion.couponCode?.toUpperCase(),
        usageLimit: promotion.usageLimit, timesUsed: promotion.timesUsed, scope: promotion.scope, productIds: promotion.productIds
    );
    return remoteDataSource.createPromotion(model.toJson());
  }

  @override
  Future<void> deletePromotion(String promotionId) => remoteDataSource.deletePromotion(promotionId);

  @override
  Future<void> updatePromotion(PromotionEntity promotion) {
    final model = PromotionModel(
        id: promotion.id,
        title: promotion.title,
        description: promotion.description,
        imageUrl: promotion.imageUrl,
        discountType: promotion.discountType,
        discountValue: promotion.discountValue,
        startDate: promotion.startDate,
        endDate: promotion.endDate,
        couponCode: promotion.couponCode?.toUpperCase(),
        usageLimit: promotion.usageLimit,
        timesUsed: promotion.timesUsed,
        scope: promotion.scope,
        productIds: promotion.productIds
    );
    return remoteDataSource.updatePromotion(promotion.id, model.toJson());
  }

  @override
  Stream<List<PromotionEntity>> getAllPromotions() {
    return remoteDataSource.getAllPromotions().map((snapshot) =>
        snapshot.docs.map((doc) => PromotionModel.fromSnapshot(doc)).toList());
  }

  @override
  Stream<List<PromotionEntity>> getActivePromotions() {
    return remoteDataSource.getActivePromotions().map((snapshot) =>
        snapshot.docs.map((doc) => PromotionModel.fromSnapshot(doc)).toList());
  }

  @override
  Future<PromotionEntity?> validateCoupon(String couponCode, String userId) async {
    final promoQuery = await remoteDataSource.getPromotionByCode(couponCode);
    if (promoQuery.docs.isEmpty) return null;

    final promotion = PromotionModel.fromSnapshot(promoQuery.docs.first);

    if (!promotion.isActive || !promotion.isCouponAvailable) return null;

    final hasRedeemed = await remoteDataSource.getUserRedemption(promotion.id, userId).then((doc) => doc.exists);
    if (hasRedeemed) return null;

    return promotion;
  }

  @override
  Future<void> redeemCoupon(String promotionId, String userId) {
    return remoteDataSource.redeemCoupon(promotionId, userId);
  }
}