import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../home_page/presentation/pages/home_page.dart'; // Import for homeAnimationProvider
import '../../../shared/domain/entities/product_entity.dart';
import '../providers/product_notifier_provider.dart';
import 'product_card.dart';

class ProductGrid extends ConsumerWidget {
  final List<ProductEntity> products;
  final bool isAdmin; // Allow toggling admin view if needed

  const ProductGrid({
    super.key,
    required this.products,
    this.isAdmin = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 4. Read the animation function from the provider.
    final runAnimation = ref.watch(homeAnimationProvider);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        childAspectRatio: 0.70, // Adjusted for better card appearance
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      padding: const EdgeInsets.all(12),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isAdmin: isAdmin,
          onTap: () => context.pushNamed(AppRoutes.productDetail, extra: product),
          onEdit: () => context.pushNamed(AppRoutes.addProduct, extra: product),
          onDelete: () => _showDeleteDialog(context, ref, product),
          // 5. Pass the function to the card if it's available.
          onAddToCart: (key) {
            if (runAnimation != null) {
              runAnimation(key, product);
            }
          },
        );
      },
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, ProductEntity product) {
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
              ref.read(productNotifierProvider.notifier).deleteProduct(product.id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}