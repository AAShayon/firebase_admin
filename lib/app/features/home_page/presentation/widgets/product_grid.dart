// lib/app/features/products/presentation/widgets/product_grid.dart
import 'package:firebase_admin/app/core/routes/app_router.dart';
import 'package:firebase_admin/app/features/home_page/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_admin/app/features/products/presentation/providers/product_notifier_provider.dart';

import '../../../shared/domain/entities/product_entity.dart';

class ProductGrid extends ConsumerWidget {
  final List<ProductEntity> products;

  const ProductGrid({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
        childAspectRatio: 0.75, // Adjusted for better card appearance
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      padding: const EdgeInsets.all(8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          // Navigate to details/edit page on tap
          onTap: () => context.pushNamed(AppRoutes.productDetail, extra: product),
          // Also provide the same navigation for the explicit edit button
          onEdit: () => context.pushNamed(AppRoutes.addProduct, extra: product),
          // Show a confirmation dialog on delete
          onDelete: () => _showDeleteDialog(context, ref, product),
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