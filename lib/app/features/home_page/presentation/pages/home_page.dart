import 'dart:developer';
import 'package:firebase_admin/app/features/home_page/presentation/widgets/product_search_bar.dart';
import 'package:firebase_admin/app/features/home_page/presentation/widgets/search_results_list.dart';
import 'package:firebase_admin/app/features/search/presentation/providers/search_notifier_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_providers.dart';
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
    final isSearching = ref.watch(searchNotifierProvider.select(
          (state) => state.maybeWhen(initial: () => false, orElse: () => true),
    ));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          const ProductSearchBar(),
          Expanded(
            child: isSearching
                ? _buildSearchResults(context, ref)
                : _buildMainProductGrid(context, ref),
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

  /// Builds the search results view when a search is active.
  Widget _buildSearchResults(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchNotifierProvider);
    return searchState.when(
      initial: () => const SizedBox.shrink(), // Should not be reached
      loading: () => const Center(child: CircularProgressIndicator()),
      loaded: (products) => SearchResultsList(products: products),
      error: (message) => Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text('Search failed: $message', textAlign: TextAlign.center),
        ),
      ),
    );
  }
}