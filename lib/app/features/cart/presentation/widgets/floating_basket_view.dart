import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_providers.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    // This provider will need to be created, similar to currentUserProvider
    final userId = ref.watch(currentUserProvider)?.id;

    if (userId == null) {
      return const SizedBox.shrink(); // Don't show if not logged in
    }

    final cartItemsStream = ref.watch(cartItemsStreamProvider(userId));

    return cartItemsStream.maybeWhen(
      data: (items) {
        if (items.isEmpty) {
          return const SizedBox.shrink(); // Hide if cart is empty
        }
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
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    // Item previews
                    ..._buildItemPreviews(items),
                    const SizedBox(width: 8),
                    // View Basket text
                    const Text(
                      'View Basket',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Spacer(),
                    // Basket Icon and total
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shopping_basket_outlined, color: Colors.white, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            _calculateTotal(items),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  ],
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
    // Show up to 4 item images
    final previews = items.take(4).toList();
    return List.generate(previews.length, (index) {
      return Align(
        widthFactor: 0.6, // Overlap the images
        child: CircleAvatar(
          radius: 18,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 16,
            backgroundImage: previews[index].variantImageUrl != null
                ? CachedNetworkImageProvider(previews[index].variantImageUrl!)
                : null,
            child: previews[index].variantImageUrl == null ? const Icon(Icons.shopping_cart) : null,
          ),
        ),
      );
    });
  }

  String _calculateTotal(List<CartItemEntity> items) {
    final double total = items.fold(0.0, (sum, item) => sum + (item.variantPrice * item.quantity));
    return '\$${total.toStringAsFixed(2)}';
  }
}