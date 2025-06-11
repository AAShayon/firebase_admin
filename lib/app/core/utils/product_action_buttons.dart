import 'package:flutter/material.dart';
import 'quantity_selector.dart';

class ProductActionButtons extends StatelessWidget {
  final bool isInStock;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final bool showQuantitySelector;
  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  const ProductActionButtons({
    super.key,
    required this.isInStock,
    required this.onAddToCart,
    required this.onBuyNow,
    this.showQuantitySelector = false,
    this.quantity = 1,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // The outer container with shadow has been removed.
    // The content is now directly returned.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The quantity selector is now part of the main buttons widget flow.
          if (showQuantitySelector)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: QuantitySelector(
                quantity: quantity,
                onDecrement: onDecrement,
                onIncrement: onIncrement,
              ),
            ),
          Row(
            children: [
              // Add to Cart / Update Cart Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isInStock ? onAddToCart : null,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text(showQuantitySelector ? 'Update Cart' : 'Add to Cart'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.secondary,
                    foregroundColor: theme.colorScheme.onSecondary,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Buy Now Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isInStock ? onBuyNow : null,
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Buy Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}