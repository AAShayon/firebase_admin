import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetActivePromotionsUseCase {
  final PromotionRepository repository;
  GetActivePromotionsUseCase(this.repository);

  Stream<List<PromotionEntity>> call() {
    return repository.getActivePromotions();
  }
}