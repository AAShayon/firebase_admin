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
      final productStream = ref.read(getProductProvider).call(); // This is a Stream
      await for (final products in productStream) {
        state = ProductState.loaded(products);  // Update state when data arrives
      }
    } catch (e) {
      state = ProductState.error(e.toString());
    }
  }
  Future<void> updateProduct(ProductEntity product) async {
    state = const ProductState.loading();
    try {
      await ref.read(updateProductProvider).call(product);
      state = const ProductState.updated(); // Use a new state for clarity
    } catch (e) {
      state = ProductState.error(e.toString());
    }
  }

  // NEW METHOD
  Future<void> deleteProduct(String productId) async {
    state = const ProductState.loading();
    try {
      await ref.read(deleteProductProvider).call(productId);
      state = const ProductState.deleted();
    } catch (e) {
      state = ProductState.error(e.toString());
    }
  }

}