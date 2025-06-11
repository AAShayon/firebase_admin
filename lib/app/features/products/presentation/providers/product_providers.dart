import 'package:firebase_admin/app/core/di/injector.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/add_product_use_case.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/products/domain/entities/product_entity.dart';

import '../../domain/usecases/delete_product_use_case.dart';
import '../../domain/usecases/search_product_use_case.dart';
import '../../domain/usecases/update_product_use_case.dart';

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
final searchProductProvider = Provider<SearchProductUseCase>((ref) {
  return locator<SearchProductUseCase>(); // Assuming you use GetIt/locator
});
