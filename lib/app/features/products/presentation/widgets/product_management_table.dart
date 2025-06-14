import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../providers/product_notifier_provider.dart';
import 'product_variant_card.dart'; // Import the new card

class ProductManagementLayout extends ConsumerWidget {
  final List<ProductEntity> products;

  const ProductManagementLayout({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Use the beautiful card list for mobile screens
          return _buildCardList(context, ref);
        } else {
          // Use the more compact DataTable for wider screens
          return _buildDataTable(context, ref);
        }
      },
    );
  }

  // --- Mobile View: A list of cards ---
  Widget _buildCardList(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: product.variants.map((variant) {
            return ProductVariantCard(
              product: product,
              variant: variant,
              onEdit: () => context.pushNamed(AppRoutes.addProduct, extra: product),
              onDelete: () => _showDeleteDialog(context, ref, product),
            );
          }).toList(),
        );
      },
    );
  }

  // --- Desktop View: The DataTable ---
  Widget _buildDataTable(BuildContext context, WidgetRef ref) {
    final List<Map<String, dynamic>> flatProductList = [];
    for (var product in products) {
      for (var variant in product.variants) {
        flatProductList.add({'product': product, 'variant': variant});
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        headingRowColor: WidgetStateProperty.all(Colors.grey.shade200),
        columns: const [
          DataColumn(label: Text('Product Name')),
          DataColumn(label: Text('Variant')),
          DataColumn(label: Text('Availability')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Actions')),
        ],
        rows: flatProductList.map((data) {
          final ProductEntity product = data['product'];
          final ProductVariantEntity variant = data['variant'];
          final bool isInStock = variant.quantity > 0;

          return DataRow(cells: [
            DataCell(Text(product.title)),
            DataCell(Text('${variant.size} - ${variant.color}')),
            DataCell(
              Text(
                isInStock ? 'In Stock' : 'Out of Stock',
                style: TextStyle(color: isInStock ? Colors.green : Colors.red),
              ),
            ),
            DataCell(Text(variant.quantity.toString())),
            DataCell(
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 20),
                    onPressed: () => context.pushNamed(AppRoutes.addProduct, extra: product),
                    tooltip: 'Edit Product',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 20),
                    onPressed: () => _showDeleteDialog(context, ref, product),
                    tooltip: 'Delete Product',
                  ),
                ],
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, ProductEntity product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product?'),
        content: Text('Are you sure you want to delete "${product.title}"? This will remove all its variants and cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
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