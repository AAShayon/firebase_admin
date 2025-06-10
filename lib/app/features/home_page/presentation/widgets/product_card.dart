// lib/app/features/products/presentation/widgets/product_card.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admin/app/features/products/domain/entities/product_entity.dart';

import 'admin_action_menu.dart';

class ProductCard extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isAdmin;

   const ProductCard({
    super.key,
    this.isAdmin=true,
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
            isAdmin?   Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // --- FIX: Use imageUrls list ---
                  _buildProductImage(),
                  // Admin Menu positioned at the top-right
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
            ):SizedBox.shrink(),
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

  Widget _buildProductImage() {
    // --- FIX: Use the first URL from the list, with a fallback ---
    if (product.imageUrls.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: product.imageUrls.first,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[200],
        ),
        errorWidget: (context, url, error) => const Icon(
          Icons.broken_image,
          color: Colors.grey,
        ),
      );
    } else {
      // Fallback if there are no images
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }
  }
}