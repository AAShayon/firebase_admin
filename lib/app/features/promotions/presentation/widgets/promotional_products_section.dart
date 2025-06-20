import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../../products/presentation/widgets/product_card.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../shared/domain/entities/product_entity.dart';

class PromotionalProductsSection extends ConsumerWidget {
  final PromotionEntity promotion;
  final List<ProductEntity> products;

  const PromotionalProductsSection({
    super.key,
    required this.promotion,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAnimation = ref.read(homeAnimationProvider);
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(promotion.title, style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () => context.pushNamed(AppRoutes.promotionDetail, extra: promotion),
                child: const Text('View All'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280, // A fixed height for the horizontal list view
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 170, // A fixed width for each card in the list
                child: ProductCard(
                  product: product,
                  onAddToCart: (key) {
                    if (runAnimation != null) {
                      runAnimation(key, product,promotion);
                    }
                  },
                  promotion: promotion,
                  onTap: () => context.pushNamed(AppRoutes.productDetail, extra: product),
                  // We don't need add to cart/admin buttons in this compact view
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}