import 'package:firebase_admin/app/features/products/domain/repositories/product_repository.dart';

import '../entities/product_entity.dart';

class AddProductUseCase{
  final ProductRepository repository;
  AddProductUseCase(this.repository);
  Future<void> call(ProductEntity product) => repository.addProduct(product);

}

