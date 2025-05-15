// // lib/features/products/presentation/providers/products_provider.dart
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
//
// import '../../domain/entities/product_entity.dart';
// import '../../domain/usecases/get_products_usecase.dart';
//
// class ProductsProvider with ChangeNotifier {
//   final GetProductsUseCase getProductsUseCase;
//
//   ProductsProvider({required this.getProductsUseCase});
//
//   List<ProductEntity> _products = [];
//   List<ProductEntity> get products => _products;
//
//   List<ProductEntity> get recentProducts => _products.take(5).toList();
//
//   int get outOfStockCount => _products
//       .where((product) => product.sizes.every((size) => size.quantity == 0))
//       .length;
//
//   int get lowStockCount => _products
//       .where((product) => product.sizes.any((size) => size.quantity < 5))
//       .length;
//
//   Future<void> loadProducts() async {
//     // _products = await getProductsUseCase();
//     notifyListeners();
//   }
// }