import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../home_page/presentation/pages/home_page.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_providers.dart';

class FloatingBasketView extends ConsumerWidget {
  final GlobalKey basketKey;
  final VoidCallback onViewBasket;

  const FloatingBasketView({
    super.key,
    required this.basketKey,
    required this.onViewBasket,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    final addingProductId = ref.watch(addingToCartProvider);

    if (userId == null) return const SizedBox.shrink();

    final cartItemsStream = ref.watch(cartItemsStreamProvider(userId));

    return cartItemsStream.maybeWhen(
      data: (items) {
        final shouldShow = items.isNotEmpty || addingProductId != null;
        if (!shouldShow) return const SizedBox.shrink();

        return Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(50),
            child: InkWell(
              key: basketKey,
              onTap: onViewBasket,
              borderRadius: BorderRadius.circular(50),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: addingProductId != null ? 0.8 : 1.0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    children: [
                      // Show loading indicator or item previews
                      if (addingProductId != null)
                        const Padding(
                          padding: EdgeInsets.only(right: 8),
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                        )
                      else
                        ..._buildItemPreviews(items),

                      const SizedBox(width: 8),
                      const Text(
                        'View Basket',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.shopping_basket_outlined,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              _calculateTotal(items),
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      orElse: () => const SizedBox.shrink(),
    );
  }

  List<Widget> _buildItemPreviews(List<CartItemEntity> items) {
    final previews = items.take(4).toList();
    return List.generate(previews.length, (index) {
      return Align(
        widthFactor: 0.6,
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 16,
            backgroundImage: previews[index].variantImageUrl != null
                ? CachedNetworkImageProvider(previews[index].variantImageUrl!)
                : null,
            child: previews[index].variantImageUrl == null
                ? const Icon(Icons.shopping_cart, size: 16)
                : null,
          ),
        ),
      );
    });
  }

  String _calculateTotal(List<CartItemEntity> items) {
    final double total = items.fold(
        0.0,
            (sum, item) => sum + (item.variantPrice * item.quantity)
    );
    return '\$${total.toStringAsFixed(2)}';
  }
}