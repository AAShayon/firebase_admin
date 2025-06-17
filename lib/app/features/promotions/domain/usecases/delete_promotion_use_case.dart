import '../repositories/promotion_repository.dart';


class DeletePromotionUseCase {
  final PromotionRepository repository;
  DeletePromotionUseCase(this.repository);

  Future<void> call(String promotionId) {
    return repository.deletePromotion(promotionId);
  }
}