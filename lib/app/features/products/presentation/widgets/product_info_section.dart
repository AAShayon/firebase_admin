import 'package:flutter/material.dart';
import '../../../shared/domain/entities/product_entity.dart';

class ProductInfoSection extends StatelessWidget {
  final ProductEntity product;
  final ProductVariantEntity selectedVariant;

  const ProductInfoSection({
    super.key,
    required this.product,
    required this.selectedVariant,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.title,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${selectedVariant.price.toStringAsFixed(2)}',
            style: textTheme.headlineSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            selectedVariant.quantity > 0
                ? 'In Stock (${selectedVariant.quantity} available)'
                : 'Out of Stock',
            style: TextStyle(
              color: selectedVariant.quantity > 0
                  ? Colors.green.shade700
                  : Colors.red.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Divider(height: 32, thickness: 1),
        ],
      ),
    );
  }
}