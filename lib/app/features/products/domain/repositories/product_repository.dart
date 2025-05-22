
import '../entities/product_entity.dart';

abstract class ProductRepository {

  Future<void> addProduct(ProductEntity product);
  Stream<List<ProductEntity>> getProducts();

}



// Future<Either<Failure, List<ProductEntity>>> getProducts();
// Future<Either<Failure, String>> createProduct(ProductEntity product);
// Future<Either<Failure, void>> updateProduct(ProductEntity product);
// Future<Either<Failure, void>> deleteProduct(String id);
// Future<Either<Failure, ProductEntity>> getProductById(String id);