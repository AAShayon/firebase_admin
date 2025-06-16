import '../../../shared/data/model/product_model.dart';
import '../../../shared/domain/entities/product_entity.dart';

import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';



class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});
  // Helper to convert entity to model
  Product _toModel(ProductEntity entity) {
    return Product(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      variants: entity.variants.map((v) => ProductVariant(
        size: v.size,
        price: v.price,
        quantity: v.quantity,
        imageUrls: v.imageUrls,
        color: v.color,
      )).toList(),
      availability: entity.availability,

      category: entity.category,
      createdAt: entity.createdAt,
    );
  }

  // Helper to convert model to entity
  ProductEntity _toEntity(Product model) {
    return ProductEntity(
      id: model.id,
      title: model.title,
      description: model.description,
      variants: model.variants.map((v) => ProductVariantEntity(
        size: v.size,
        price: v.price,
        imageUrls: v.imageUrls,
        quantity: v.quantity,
        color: v.color,
      )).toList(),
      availability: model.availability,
      category: model.category,
      createdAt: model.createdAt,
    );
  }

  // @override
  // Future<void> addProduct(ProductEntity product) async {
  //   // Convert Entity to Model
  //   final productModel = Product(
  //     id: product.id,
  //     title: product.title,
  //     description: product.description,
  //     variants: product.variants.map((v) => ProductVariant(
  //       size: v.size,
  //       price: v.price,
  //       quantity: v.quantity,
  //       color: v.color,
  //     )).toList(),
  //     availability: product.availability,
  //     imageUrl: product.imageUrl,
  //     imageLink: product.imageLink,
  //     category: product.category,
  //     createdAt: product.createdAt,
  //   );
  //
  //   await remoteDataSource.addProduct(productModel);
  // }
  @override
  Future<void> addProduct(ProductEntity product) async {
    final productModel = _toModel(product);
    await remoteDataSource.addProduct(productModel);
  }
  @override
  Future<void> updateProduct(ProductEntity product) async {
    final productModel = _toModel(product);
    await remoteDataSource.updateProduct(productModel);
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await remoteDataSource.deleteProduct(productId);
  }
  @override
  Stream<List<ProductEntity>> getProducts() {
    return remoteDataSource.getProducts().map((productModels) {
      return productModels.map((model) => _toEntity(model)).toList();
    });
  }
  @override
  Future<List<ProductEntity>> searchProducts(String query) async {
    final productModels = await remoteDataSource.searchProducts(query);
    return productModels.map((model) => _toEntity(model)).toList();
  }
  @override
  Future<void> addToWishlist(String productId, String userId) async {
    await remoteDataSource.addToWishlist(productId, userId);
  }
}