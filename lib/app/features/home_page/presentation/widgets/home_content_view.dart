import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/presentation/providers/promotion_providers.dart';
import '../../../promotions/presentation/widgets/promotion_banner_card.dart';
import '../../../promotions/presentation/widgets/promotional_products_section.dart';
import 'category_pills.dart';

class HomeContentView extends ConsumerWidget {
  const HomeContentView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RefreshIndicator(
      onRefresh: () async {
        // Invalidate providers to refetch data
        ref.invalidate(productsStreamProvider);
        ref.invalidate(activePromotionsStreamProvider);
      },
      child: CustomScrollView(
        slivers: [
          _buildPromoBannerSliver(ref, context),
          _buildPromoProductsSliver(ref),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CategoryPills(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text("For You", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          _buildProductGridSliver(ref),
        ],
      ),
    );
  }

  /// Builds the top promotional banner.
  Widget _buildPromoBannerSliver(WidgetRef ref, BuildContext context) {
    final activePromosAsync = ref.watch(activePromotionsStreamProvider);
    return SliverToBoxAdapter(
      child: activePromosAsync.when(
        data: (promos) => promos.isEmpty
            ? const SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: PromotionBannerCard(
            promotion: promos.first,
            onViewAll: () => context.pushNamed(AppRoutes.promotionDetail, extra: promos.first),
          ),
        ),
        loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => const SizedBox.shrink(), // Optionally show an error message
      ),
    );
  }

  /// Builds the horizontally-scrolling section for products on promotion.
  Widget _buildPromoProductsSliver(WidgetRef ref) {
    final activePromosAsync = ref.watch(activePromotionsStreamProvider);
    final productsState = ref.watch(productsStreamProvider);

    return SliverToBoxAdapter(
      child: activePromosAsync.when(
        data: (promos) {
          if (promos.isEmpty || promos.first.scope != PromotionScope.specificProducts) {
            return const SizedBox.shrink();
          }
          final bannerPromo = promos.first;

          return productsState.when(
            data: (allProducts) {
              final promoProducts = allProducts.where((p) => bannerPromo.productIds.contains(p.id)).toList();
              if (promoProducts.isEmpty) return const SizedBox.shrink();
              return PromotionalProductsSection(promotion: bannerPromo, products: promoProducts);
            },
            loading: () => const SizedBox.shrink(), // Don't show a loader here, let the promo banner show it
            error: (e, s) => const SizedBox.shrink(),
          );
        },
        loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => const SizedBox.shrink(),
      ),
    );
  }

  /// Builds the main grid of products.
  Widget _buildProductGridSliver(WidgetRef ref) {
    final productsState = ref.watch(productsStreamProvider);
    final activePromos = ref.watch(activePromotionsStreamProvider).valueOrNull;

    // Safely find the first active promotion
    final PromotionEntity? activePromo = activePromos?.firstWhereOrNull((p) => p.isActive);

    return productsState.when(
      data: (products) {
        if (products.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('No products found.')));
        }
        // Pass the list of products and the potentially null promotion to the grid.
        return ProductGrid(products: products, promotion: activePromo);
      },
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverFillRemaining(child: Center(child: Text('Failed to load products: $e'))),
    );
  }
}