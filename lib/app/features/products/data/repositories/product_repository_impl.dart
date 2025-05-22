// import 'package:dartz/dartz.dart';
// import '../../domain/entities/product_entity.dart';
// import '../../domain/repositories/product_repository.dart';
// import '../datasources/product_remote_data_source.dart';
// import '../../../../core/errors/failures.dart';
//
// class ProductRepositoryImpl implements ProductRepository {
//   final ProductRemoteDataSource remoteDataSource;
//
//   ProductRepositoryImpl({required this.remoteDataSource});
//
//   @override
//   Future<Either<Failure, List<ProductEntity>>> getProducts() {
//     return _handle(() => remoteDataSource.getProducts());
//   }
//
//   @override
//   Future<Either<Failure, String>> createProduct(ProductEntity product) {
//     return _handle(() => remoteDataSource.createProduct(product));
//   }
//
//   @override
//   Future<Either<Failure, void>> deleteProduct(String id) {
//     return _handle(() => remoteDataSource.deleteProduct(id));
//   }
//
//   @override
//   Future<Either<Failure, void>> updateProduct(ProductEntity product) {
//     return _handle(() => remoteDataSource.updateProduct(product));
//   }
//
//   @override
//   Future<Either<Failure, ProductEntity>> getProductById(String id) {
//     return _handle(() => remoteDataSource.getProductById(id));
//   }
//
//   Future<Either<Failure, T>> _handle<T>(Future<T> Function() task) async {
//     try {
//       final result = await task();
//       return Right(result);
//     } on ProductFailure catch (e) {
//       return Left(e); // Just return the caught ProductFailure directly
//     } on AuthFailure catch (e) {
//       return Left(e); // Handle AuthFailure if needed
//     } on StoreFailure catch (e) {
//       return Left(e); // Handle StoreFailure if needed
//     } catch (e) {
//       // For unexpected errors, create a generic Failure subtype
//       return Left(ProductFailure(message: e.toString()));
//       // Or create a new GenericFailure class if you prefer:
//       // return Left(GenericFailure(message: e.toString()));
//     }
//   }
// }

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_data_source.dart';
import '../model/product_model.dart';


class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> addProduct(ProductEntity product) async {
    // Convert Entity to Model
    final productModel = Product(
      id: product.id,
      title: product.title,
      description: product.description,
      variants: product.variants.map((v) => ProductVariant(
        size: v.size,
        price: v.price,
        quantity: v.quantity,
        color: v.color,
      )).toList(),
      availability: product.availability,
      imageUrl: product.imageUrl,
      imageLink: product.imageLink,
      category: product.category,
      createdAt: product.createdAt,
    );

    await remoteDataSource.addProduct(productModel);
  }

  @override
  Stream<List<ProductEntity>> getProducts() {
    return remoteDataSource.getProducts().map((productModels) {
      return productModels.map((model) => ProductEntity(
        id: model.id,
        title: model.title,
        description: model.description,
        variants: model.variants.map((v) => ProductVariantEntity(
          size: v.size,
          price: v.price,
          quantity: v.quantity,
          color: v.color,
        )).toList(),
        availability: model.availability,
        imageUrl: model.imageUrl,
        imageLink: model.imageLink,
        category: model.category,
        createdAt: model.createdAt,
      )).toList();
    });
  }
}