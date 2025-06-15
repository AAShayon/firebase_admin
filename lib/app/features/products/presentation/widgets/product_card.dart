import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../../home_page/presentation/widgets/admin_action_menu.dart';
import '../../../shared/domain/entities/product_entity.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;
  final ValueSetter<GlobalKey>? onAddToCart;

  const ProductCard({
    super.key,
    this.isAdmin = false,
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addButtonKey = GlobalKey();
    final currentlyAddingId = ref.watch(addingToCartProvider);
    final isAdding = currentlyAddingId == product.id;

    // Check if any variant has stock available
    final hasAvailableStock = product.variants.any((v) => v.quantity > 0);
    final firstAvailableVariant = product.variants.firstWhere(
          (v) => v.quantity > 0,
      orElse: () => product.variants.first,
    );

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (isAdmin && onEdit != null && onDelete != null)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: AdminActionMenu(
                        onEdit: onEdit!,
                        onDelete: onDelete!,
                      ),
                    ),
                  if (hasAvailableStock && onAddToCart != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: isAdding
                            ? null
                            : () {
                          if (firstAvailableVariant.quantity > 0) {
                            onAddToCart!(addButtonKey);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('This product is out of stock'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          key: addButtonKey,
                          width: 36,
                          height: 36,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: isAdding
                              ? const Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            ),
                          )
                              : const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ),
                  if (!hasAvailableStock)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        log('Favorite');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.favorite, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
                    maxLines: 1,
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
    String? firstImageUrl;
    for (final variant in product.variants) {
      if (variant.imageUrls.isNotEmpty) {
        firstImageUrl = variant.imageUrls.first;
        break;
      }
    }
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
      return Container(
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
        ),
      );
    }
  }
}