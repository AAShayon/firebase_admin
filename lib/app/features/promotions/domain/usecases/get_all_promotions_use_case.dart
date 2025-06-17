import '../entities/promotion_entity.dart';
import '../repositories/promotion_repository.dart';

class GetAllPromotionsUseCase {
  final PromotionRepository repository;
  GetAllPromotionsUseCase(this.repository);

  Stream<List<PromotionEntity>> call() {
    return repository.getAllPromotions();
  }
}