import 'dart:developer';
import 'package:firebase_admin/app/features/search/presentation/providers/search_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_providers.dart';
import '../../../search/presentation/widgets/product_search_bar.dart';
import '../../../search/presentation/widgets/search_results_list.dart';
import '../widgets/product_grid.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for state changes (like 'deleted') to show feedback
    ref.listen(productNotifierProvider, (_, state) {
      state.whenOrNull(
        deleted: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully'))),
        error: (message) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $message"))),
      );
    });

    // Determine if we should show search results or the main grid
    // final isSearching = ref.watch(searchNotifierProvider.select(
    //       (state) => state.maybeWhen(initial: () => false, orElse: () => true),
    // ));
    final searchState = ref.watch(searchNotifierProvider);
    void dismissSearch() {
      FocusScope.of(context).unfocus();
      // Clear the search state, which will make the UI switch back to the product grid
      ref.read(searchNotifierProvider.notifier).clearSearch();
    }
    return Scaffold(
      body: Column(
        children: [
          const ProductSearchBar(),
          Expanded(
            // Build the UI directly based on the search state
            child: searchState.when(
              // **THIS IS THE KEY FIX**
              // When the state is initial (i.e., search is cleared or not started),
              // show the main product grid.
              initial: () => GestureDetector(
                  onTap: dismissSearch,
                  child: _buildMainProductGrid(context, ref)),

              // The other states are for the search results view
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (query, products) => SearchResultsList(products: products),
              error: (message) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text('Search failed: $message', textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the main product grid when not searching.
  Widget _buildMainProductGrid(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsStreamProvider);
    return productsState.when(
      data: (products) => products.isEmpty
          ? const Center(child: Text('No products found. Add one!'))
          : ProductGrid(products: products),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, stackTrace) {
        log("$e");
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Failed to load products: $e', textAlign: TextAlign.center),
          ),
        );
      },
    );
  }

}