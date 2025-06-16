


import '../../../shared/domain/entities/product_entity.dart';

abstract class ProductRepository {

  Future<void> addProduct(ProductEntity product);
  Stream<List<ProductEntity>> getProducts();
  Future<void> updateProduct(ProductEntity product); // ADDED
  Future<void> deleteProduct(String productId);
  Future<List<ProductEntity>> searchProducts(String query);
}
