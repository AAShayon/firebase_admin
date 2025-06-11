// lib/app/features/products/presentation/pages/home_page.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_providers.dart';
import '../widgets/product_grid.dart'; // Import the new widget

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsStreamProvider);

    // Listen for state changes (like 'deleted') to show feedback
    ref.listen(productNotifierProvider, (_, state) {
      state.whenOrNull(
        deleted: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully'))),
        error: (message) => ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $message"))),
      );
    });

    return Scaffold(
      body: productsState.when(
        data: (products) => products.isEmpty
            ? const Center(child: Text('No products found. Add one!'))
            : ProductGrid(products: products), // Use the new dedicated widget
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
      ),
    );
  }
}