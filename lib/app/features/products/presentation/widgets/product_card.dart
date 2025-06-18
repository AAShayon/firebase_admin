import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../../home_page/presentation/widgets/admin_action_menu.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';

class ProductCard extends ConsumerWidget {
  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isAdmin;
  final ValueSetter<GlobalKey>? onAddToCart;
  final PromotionEntity? promotion; // <-- THE NEW, OPTIONAL PROPERTY

  const ProductCard({
    super.key,
    this.isAdmin = false,
    required this.product,
    required this.onTap,
    this.onEdit,
    this.onDelete,
    this.onAddToCart,
    this.promotion, // <-- ADDED TO THE CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addButtonKey = GlobalKey();
    final currentlyAddingId = ref.watch(addingToCartProvider);
    final isAdding = currentlyAddingId == product.id;
    final currentUser = ref.watch(currentUserProvider);

    final wishlistIdsAsync = ref.watch(wishlistIdsProvider(currentUser?.id ?? ''));
    final bool isInWishlist = wishlistIdsAsync.when(
      data: (ids) => ids.contains(product.id),
      loading: () => false,
      error: (e, s) => false,
    );

    final hasAvailableStock = product.variants.any((v) => v.quantity > 0);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildProductImage(),
                  if (isAdmin && onEdit != null && onDelete != null)
                    Positioned(top: 4, right: 4, child: AdminActionMenu(onEdit: onEdit!, onDelete: onDelete!)),
                  if (hasAvailableStock && onAddToCart != null)
                    Positioned(bottom: 8, left: 8, child: _buildAddToCartButton(context, ref, isAdding, addButtonKey)),
                  if (!hasAvailableStock)
                    _buildOutOfStockBadge(),
                  Positioned(bottom: 8, right: 8, child: _buildWishlistButton(context, ref, isInWishlist)),
                ],
              ),
            ),
            // The info section is now separate and handles promotional pricing
            _buildProductInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage() {
    String? firstImageUrl;
    if (product.variants.isNotEmpty && product.variants.first.imageUrls.isNotEmpty) {
      firstImageUrl = product.variants.first.imageUrls.first;
    }

    if (firstImageUrl != null && firstImageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: firstImageUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(color: Colors.grey[200]),
        errorWidget: (context, url, error) => const Icon(Icons.broken_image, color: Colors.grey),
      );
    } else {
      return Container(
        color: Colors.grey[200],
        child: const Center(child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey)),
      );
    }
  }

  // --- THIS IS THE FINAL, CORRECTED INFO WIDGET ---
  Widget _buildProductInfo(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    if (product.variants.isEmpty) {
      return const Padding(padding: EdgeInsets.all(8.0), child: Text('Not Available'));
    }

    final originalPrice = product.variants.first.price;
    double? discountedPrice;

    // Calculate the discounted price if a valid promotion exists for this product
    if (promotion != null && promotion!.isActive) {
      if (promotion!.scope == PromotionScope.allProducts || promotion!.productIds.contains(product.id)) {
        if (promotion!.discountType == DiscountType.fixedAmount) {
          discountedPrice = originalPrice - promotion!.discountValue;
        } else { // Percentage
          discountedPrice = originalPrice * (1 - (promotion!.discountValue / 100));
        }
      }
    }

    // Ensure the price doesn't go below zero
    if (discountedPrice != null && discountedPrice < 0) discountedPrice = 0;

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            product.title,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          // Price display logic
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                currencyFormat.format(discountedPrice ?? originalPrice),
                style: textTheme.bodyMedium?.copyWith(
                  color: discountedPrice != null ? Colors.blue : colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              // Show original price with strikethrough ONLY if there's a discount
              if (discountedPrice != null)
                Text(
                  currencyFormat.format(originalPrice),
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.red,
                    decoration: TextDecoration.lineThrough,
                    fontSize: 10
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context, WidgetRef ref, bool isAdding, GlobalKey addButtonKey) {
    return GestureDetector(
      onTap: isAdding ? null : () {
        if (onAddToCart != null) onAddToCart!(addButtonKey);
      },
      child: Container(
        key: addButtonKey, width: 36, height: 36,
        decoration: BoxDecoration(
          color: isAdding ? Colors.grey.shade400 : Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: isAdding
            ? const Center(child: SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)))
            : const Icon(Icons.add_shopping_cart, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildWishlistButton(BuildContext context, WidgetRef ref, bool isInWishlist) {
    return GestureDetector(
      onTap: () {
        final currentUser = ref.read(currentUserProvider);
        if (currentUser == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to use the wishlist.')));
          return;
        }
        final notifier = ref.read(wishlistNotifierProvider.notifier);
        if (isInWishlist) {
          notifier.removeFromWishlist(currentUser.id, product.id);
        } else {
          notifier.addToWishlist(currentUser.id, product);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isInWishlist ? Colors.pink.shade300 : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildOutOfStockBadge() {
    return Positioned(
      bottom: 8,
      left: 8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
        child: const Text('Out of Stock', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }
}