import 'package:firebase_admin/app/features/products/presentation/providers/product_providers.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_entity.dart';


class ProductNotifier extends StateNotifier<ProductState> {
  final Ref ref;

  ProductNotifier(this.ref) : super(const ProductState.initial());

  Future<void> addProduct(ProductEntity product) async {
    state = const ProductState.loading();
    try {
      await ref.read(addProductProvider).call(product);
      state = const ProductState.added();
      await getProducts();
    } catch (e) {
      state = ProductState.error(e.toString());
    }
  }

  Future<void> getProducts() async {
    state = const ProductState.loading();
    try {
        ref.read(getProductProvider).call();
    state = const ProductState.loaded([]);
    } catch (e) {
      state = ProductState.error(e.toString());
    }
  }
}