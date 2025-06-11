import '../../../shared/domain/entities/product_entity.dart';
import '../repositories/product_repository.dart';


class GetProductUseCase{
  final ProductRepository repository;
  GetProductUseCase(this.repository);
  Stream<List<ProductEntity>> call() => repository.getProducts();

}

