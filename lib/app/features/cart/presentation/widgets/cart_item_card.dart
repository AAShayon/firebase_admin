import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';


import '../../domain/entities/cart_item_entity.dart';
import '../providers/cart_notifier_provider.dart';

class CartItemCard extends ConsumerWidget {
  final CartItemEntity item;
  final String userId; // Needed to perform actions

  const CartItemCard({
    super.key,
    required this.item,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                item.variantImageUrl ?? 'https://via.placeholder.com/150/FFFFFF/000000?text=No+Image',
                width: 90,
                height: 90,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.image_not_supported, size: 90),
              ),
            ),
            const SizedBox(width: 16),
            // Product Details and Actions
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productTitle,
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Size: ${item.variantSize}, Color: ${item.variantColorName}',
                    style: textTheme.bodySmall?.copyWith(color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(item.variantPrice),
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Quantity Controller
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, size: 22),
                        onPressed: item.quantity > 1 ? () {
                          ref.read(cartNotifierProvider.notifier).updateItemQuantity(
                              userId, item.id, item.quantity - 1);
                        } : null, // Disable if quantity is 1
                      ),
                      Text(
                        item.quantity.toString(),
                        style: textTheme.titleMedium,
                      ),
                      IconButton(
                        icon: Icon(Icons.add_circle_outline, size: 22, color: colorScheme.primary),
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).updateItemQuantity(
                              userId, item.id, item.quantity + 1);
                        },
                      ),
                      const Spacer(),
                      // Remove Button
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: colorScheme.error),
                        onPressed: () {
                          ref.read(cartNotifierProvider.notifier).removeFromCart(userId, item.id);
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}