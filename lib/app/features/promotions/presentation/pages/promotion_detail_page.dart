import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionDetailPage extends ConsumerWidget {
  final PromotionEntity promotion;
  const PromotionDetailPage({super.key, required this.promotion});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the main product stream
    final allProductsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
        appBar: AppBar(title: Text(promotion.title)),
        body: allProductsAsync.when(
          data: (allProducts) {
            // Filter the products based on the promotion's scope
            final List<ProductEntity> promotionProducts;
            if (promotion.scope == PromotionScope.allProducts) {
              promotionProducts = allProducts;
            } else {
              promotionProducts = allProducts
                  .where((p) => promotion.productIds.contains(p.id))
                  .toList();
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      CachedNetworkImage(
                        imageUrl: promotion.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(promotion.description, style: Theme.of(context).textTheme.bodyLarge),
                      ),
                      const Divider(thickness: 8),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text('Applicable Products', style: Theme.of(context).textTheme.headlineSmall),
                      ),
                    ],
                  ),
                ),
                // Use SliverGrid for better performance inside a CustomScrollView
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                      childAspectRatio: 0.70,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        return ProductGrid(products: promotionProducts);
                      },
                      childCount: 1, // The ProductGrid handles its own items
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e,s) => Center(child: Text('Error loading products: $e')),
        )
    );
  }
}