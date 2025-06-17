import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/cart_item_entity.dart';

class CartSummary extends StatelessWidget {
  final List<CartItemEntity> items;
  final VoidCallback onCheckout; // <-- 1. ADD THIS NEW PARAMETER

  const CartSummary({
    super.key,
    required this.items,
    required this.onCheckout, // <-- 2. MAKE IT REQUIRED IN THE CONSTRUCTOR
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final double subtotal = items.fold(0.0, (sum, item) => sum + (item.variantPrice * item.quantity));

    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Subtotal', style: textTheme.bodyLarge),
              Text(currencyFormat.format(subtotal), style: textTheme.bodyLarge),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Shipping', style: textTheme.bodyLarge),
              Text('Free', style: textTheme.bodyLarge?.copyWith(color: Colors.green)),
            ],
          ),
          const Divider(height: 24, thickness: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              Text(
                currencyFormat.format(subtotal),
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              // --- 3. USE THE CALLBACK HERE ---
              // The button now calls the function that was passed in from the parent.
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
              ),
              child: const Text('Proceed to Checkout'),
            ),
          ),
        ],
      ),
    );
  }
}