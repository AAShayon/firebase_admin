import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../shared/domain/entities/product_entity.dart';

class ProductVariantCard extends StatelessWidget {
  final ProductEntity product;
  final ProductVariantEntity variant;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductVariantCard({
    super.key,
    required this.product,
    required this.variant,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final bool isInStock = variant.quantity > 0;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: variant.imageUrls.isNotEmpty ? variant.imageUrls.first : '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => const Icon(Icons.image_not_supported),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Variant: ${variant.size} - ${variant.color}',
                    style: textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        isInStock ? Icons.check_circle : Icons.cancel,
                        color: isInStock ? Colors.green.shade600 : Colors.red.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Stock: ${variant.quantity}',
                        style: textTheme.bodyMedium?.copyWith(
                          color: isInStock ? Colors.green.shade700 : Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action Buttons
            Column(
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.edit, color: colorScheme.primary),
                  onPressed: onEdit,
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.delete_outline, color: colorScheme.error),
                  onPressed: onDelete,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}