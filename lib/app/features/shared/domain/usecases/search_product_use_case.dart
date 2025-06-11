import '../../../shared/domain/entities/product_entity.dart';
import '../repositories/product_repository.dart';

class SearchProductUseCase {
  final ProductRepository repository;
  SearchProductUseCase(this.repository);
  Future<List<ProductEntity>> call(String query) async {
    return repository.searchProducts(query);
  }

}