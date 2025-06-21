import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/presentation/providers/promotion_providers.dart';
import '../../../shared/data/model/product_model.dart';
import '../providers/product_providers.dart';
import '../widgets/product_grid.dart';

class CategoryProductsPage extends ConsumerWidget {
  final ProductCategory category;

  const CategoryProductsPage({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productsStreamProvider);
    final activePromos = ref.watch(activePromotionsStreamProvider).valueOrNull;
    final PromotionEntity? activePromo = activePromos?.firstWhereOrNull((p) => p.isActive);

    // Format the category name for the AppBar title
    final categoryName = category.name[0].toUpperCase() + category.name.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: productsState.when(
        data: (products) {
          // Filter products based on the passed category
          final filteredProducts = products.where((p) => p.category == category).toList();

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Text('No products found in this category.'),
            );
          }

          // Use a CustomScrollView to contain the SliverGrid
          return CustomScrollView(
            slivers: [
              // Add some padding around the grid
              SliverPadding(
                padding: const EdgeInsets.all(12.0),
                sliver: ProductGrid(
                  products: filteredProducts,
                  promotion: activePromo,
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load products: $e')),
      ),
    );
  }
}