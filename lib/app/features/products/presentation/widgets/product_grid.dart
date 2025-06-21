import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../home_page/presentation/providers/home_page_providers.dart';
import '../../../promotions/domain/entities/promotion_entity.dart'; // <-- IMPORT THIS
import '../../../shared/domain/entities/product_entity.dart';
import '../providers/product_notifier_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final List<ProductEntity> products;
  final bool isAdmin;
  final PromotionEntity? promotion; // <-- ADD THIS NEW PROPERTY

  const ProductGrid({
    super.key,
    required this.products,
    this.isAdmin = false,
    this.promotion, // <-- ADD TO CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runAnimation = ref.read(homeAnimationProvider);

    return SliverGrid.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];

        return ProductCard(
          product: product,
          isAdmin: isAdmin,
          promotion: promotion, // <-- PASS THE PROMOTION DOWN TO THE CARD
          onTap: () => context.pushNamed(AppRoutes.productDetail, extra: product),
          onEdit: isAdmin ? () => context.pushNamed(AppRoutes.addProduct, extra: product) : null,
          onDelete: isAdmin ? () => _showDeleteDialog(context, ref, product) : null,
          onAddToCart: (key) {
            if (runAnimation != null) {
              runAnimation(key, product,promotion);
            }
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(productNotifierProvider.notifier).deleteProduct(product.id);
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}