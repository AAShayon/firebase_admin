
import 'package:firebase_admin/app/core/di/injector.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/add_product_use_case.dart';
import 'package:firebase_admin/app/features/products/domain/usecases/get_products_usecase.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addProductProvider=Provider<AddProductUseCase>((ref){
  return locator<AddProductUseCase>();
});
final getProductProvider=Provider<GetProductUseCase>((ref){
  return locator<GetProductUseCase>();
});