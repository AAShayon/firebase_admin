import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class CreatePromotionUseCase {
  final PromotionRepository repository;

  CreatePromotionUseCase(this.repository);

  Future<void> call(PromotionEntity promotion) {
    return repository.createPromotion(promotion);
  }
}