import 'package:firebase_admin/app/features/promotions/presentation/pages/promotions_management_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../providers/product_notifier_provider.dart';
import '../providers/product_providers.dart';


import '../widgets/product_management_table.dart';

class ProductsTable extends ConsumerWidget {
  const ProductsTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    ref.listen(productNotifierProvider, (previous, next) {
      next.maybeWhen(
        deleted: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product deleted successfully'), backgroundColor: Colors.green),
          );
          ref.invalidate(productsStreamProvider);
        },
        error: (message) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
        ),
        orElse: () {},
      );
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(productsStreamProvider),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Images'),
                      onPressed: () => context.pushNamed(AppRoutes.addGalleryImage),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Product'),
                      onPressed: () => context.pushNamed(AppRoutes.addProduct),
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.event),
                      label: const Text('Promotion'),
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>PromotionsManagementPage()));
                      },
                      style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold)
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              productsAsync.when(
                data: (products) {
                  if (products.isEmpty) {
                    return const Center(
                      heightFactor: 10,
                      child: Text('No products found. Add one to get started!'),
                    );
                  }
                  // --- USE THE NEW RESPONSIVE LAYOUT WIDGET ---
                  return ProductManagementLayout(products: products);
                },
                loading: () => const Center(heightFactor: 10, child: CircularProgressIndicator()),
                error: (e, s) => Center(heightFactor: 10, child: Text('Failed to load products: $e')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}