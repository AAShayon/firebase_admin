import '../../../shared/domain/entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;
  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product) {
    return repository.updateProduct(product);
  }
}