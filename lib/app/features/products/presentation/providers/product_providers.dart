import 'package:firebase_admin/app/core/di/injector.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/domain/entities/product_entity.dart';
import '../../../shared/domain/usecases/add_product_use_case.dart';
import '../../../shared/domain/usecases/delete_product_use_case.dart';
import '../../../shared/domain/usecases/get_products_usecase.dart';
import '../../../shared/domain/usecases/search_product_use_case.dart';
import '../../../shared/domain/usecases/update_product_use_case.dart';


// Existing providers
final addProductProvider = Provider<AddProductUseCase>((ref) {
  return locator<AddProductUseCase>();
});

final getProductProvider = Provider<GetProductUseCase>((ref) {
  return locator<GetProductUseCase>();
});

final productsStreamProvider = StreamProvider<List<ProductEntity>>((ref) {
  return ref.read(getProductProvider).call();
});
final updateProductProvider = Provider<UpdateProductUseCase>((ref) {
  return locator<UpdateProductUseCase>(); // Assuming you use GetIt/locator
});

final deleteProductProvider = Provider<DeleteProductUseCase>((ref) {
  return locator<DeleteProductUseCase>(); // Assuming you use GetIt/locator
});
