import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../providers/product_notifier_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final List<ProductEntity> products;
  final bool isAdmin;
  final ScrollController? scrollController;

  const ProductGrid({
    super.key,
    required this.products,
    this.isAdmin = false,
    this.scrollController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      controller: scrollController,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final hasAvailableStock = product.variants.any((v) => v.quantity > 0);

        return ProductCard(
          product: product,
          isAdmin: isAdmin,
          onTap: () => context.pushNamed(
              AppRoutes.productDetail,
              extra: product
          ),
          onEdit: isAdmin
              ? () => context.pushNamed(
              AppRoutes.addProduct,
              extra: product
          )
              : null,
          onDelete: isAdmin
              ? () => _showDeleteDialog(context, ref, product)
              : null,
          onAddToCart: hasAvailableStock
              ? (key) {
            final runAnimation = ref.read(homeAnimationProvider);
            if (runAnimation != null) {
              runAnimation(key, product);
            }
          }
              : null,
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context,
      WidgetRef ref,
      ProductEntity product
      ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text(
            'Are you sure you want to delete "${product.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(productNotifierProvider.notifier)
                  .deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}