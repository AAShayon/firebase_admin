import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


import '../../../shared/domain/entities/product_entity.dart';
import 'admin_action_menu.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAdmin;

  const ProductCard({
    super.key,
    this.isAdmin = true,
    required this.product,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap, // Handle tap on the whole card
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with Admin Menu Overlay
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // This now correctly finds the first available image
                  _buildProductImage(),
                  // Admin Menu positioned at the top-right
                  if (isAdmin)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: AdminActionMenu(
                        onEdit: onEdit,
                        onDelete: onDelete,
                      ),
                    ),
                ],
              ),
            ),
            // Product details
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.variants.isNotEmpty)
                    Text(
                      '\$${product.variants.first.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Finds the first image URL from the list of variants.
  /// It iterates through variants until it finds one with images.
  Widget _buildProductImage() {
    String? firstImageUrl;

    // Iterate through variants to find the first one with an image.
    for (final variant in product.variants) {
      if (variant.imageUrls.isNotEmpty) {
        firstImageUrl = variant.imageUrls.first;
        break; // Found an image, no need to look further.
      }
    }

    // If an image URL was found, display it.
    if (firstImageUrl != null) {
      return CachedNetworkImage(
        imageUrl: firstImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      );
    } else {
      // Fallback if no variant has any images.
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }
  }
}