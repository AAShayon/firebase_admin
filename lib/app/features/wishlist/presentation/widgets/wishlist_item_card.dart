import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../domain/entities/wishlist_item_entity.dart';
import '../providers/wishlist_notifier_provider.dart';

class WishlistItemCard extends ConsumerWidget {
  final WishlistItemEntity item;
  const WishlistItemCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    // This provider will fetch the full product details when needed.
    final productProvider = ref.watch(singleProductProvider(item.productId));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: InkWell(
        onTap: () {
          // Navigate to product detail page when the card is tapped
          productProvider.whenData((product) {
            if (product != null) {
              context.pushNamed(AppRoutes.productDetail, extra: product);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl ?? '',
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorWidget: (c,u,e) => const Icon(Icons.image_not_supported),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.productTitle, style: textTheme.titleMedium, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('\$${item.price.toStringAsFixed(2)}', style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    if (item.isInStock)
                      const Text('In Stock', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                    else
                      const Text('Out of Stock', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                tooltip: 'Remove from Wishlist',
                onPressed: () {
                  final userId = ref.read(currentUserProvider)?.id;
                  if (userId != null) {
                    ref.read(wishlistNotifierProvider.notifier).removeFromWishlist(userId, item.productId);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}