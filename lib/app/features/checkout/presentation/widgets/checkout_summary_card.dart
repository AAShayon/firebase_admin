import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/presentation/providers/promotion_providers.dart';
import '../providers/checkout_notifier_provider.dart';

class CheckoutSummaryCard extends ConsumerWidget {
  const CheckoutSummaryCard({super.key});

  /// A private method to check if any item in the cart has an automatic promotion.
  /// Returns the found promotion, or null if none are found.
  PromotionEntity? _findActiveProductPromotion(
      WidgetRef ref,
      List<PromotionEntity> promotions,
      ) {
    final checkoutState = ref.watch(checkoutNotifierProvider);

    // --- THIS IS THE MODIFIED LOGIC ---
    // Find the first promotion that is for specific products and matches an item in the cart.
    // We NO LONGER check if `couponCode == null`.
    final foundPromotion = promotions.firstWhereOrNull(
          (promo) =>
      // Rule 1: Must be a product-specific promotion.
      promo.scope == PromotionScope.specificProducts &&
          // Rule 2: Check if any cart item's ID is in this promotion's product list.
          checkoutState.itemsToCheckout.any((item) => promo.productIds.contains(item.productId)),
    );

    return foundPromotion;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final checkoutState = ref.watch(checkoutNotifierProvider);
    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    final promotionsAsyncValue = ref.watch(activePromotionsStreamProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            promotionsAsyncValue.when(
              data: (promotions) {
                // The check is now more robust.
                final activeProductPromotion = _findActiveProductPromotion(ref, promotions);
                final isCouponFieldDisabled = activeProductPromotion != null;

                if (isCouponFieldDisabled) {
                  return _buildPromotionMessage(context, "This order contains items with promotional pricing, so coupons cannot be applied.");
                } else {
                  return _buildCouponEntry(context, checkoutState, checkoutNotifier);
                }
              },
              loading: () => _buildCouponEntry(
                context,
                checkoutState,
                checkoutNotifier,
                isCheckingPromotions: true,
              ),
              error: (err, stack) => _buildCouponEntry(context, checkoutState, checkoutNotifier),
            ),

            const Divider(height: 32),

            _buildSummaryRow(context, 'Subtotal', currencyFormat.format(checkoutState.subtotal)),
            _buildSummaryRow(context, 'Delivery Fee', currencyFormat.format(checkoutState.deliveryFee)),
            if (checkoutState.discount > 0)
              _buildSummaryRow(context, 'Discount', '- ${currencyFormat.format(checkoutState.discount)}', color: Colors.green.shade700),
            const Divider(),
            _buildSummaryRow(context, 'Grand Total', currencyFormat.format(checkoutState.grandTotal), isTotal: true),
          ],
        ),
      ),
    );
  }

  // Changed the message to be more generic
  Widget _buildPromotionMessage(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildCouponEntry(
      BuildContext context,
      checkoutState,
      checkoutNotifier, {
        bool isCheckingPromotions = false,
      }) {
    final bool isReadOnly = checkoutState.isCouponApplied || isCheckingPromotions;
    final String hintText = isCheckingPromotions ? 'Checking for promotions...' : 'Enter coupon code';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: checkoutState.couponController,
          readOnly: isReadOnly,
          decoration: InputDecoration(
            labelText: 'Coupon Code',
            errorText: checkoutState.error,
            hintText: hintText,
            border: const OutlineInputBorder(),
            suffixIcon: isCheckingPromotions
                ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                : checkoutState.isLoading
                ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                : checkoutState.isCouponApplied
                ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: checkoutNotifier.removeCoupon, tooltip: 'Remove Coupon')
                : TextButton(onPressed: checkoutNotifier.applyCoupon, child: const Text('APPLY')),
          ),
        ),
        if (checkoutState.isCouponApplied && checkoutState.error == null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text('Coupon applied successfully!', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String amount, {Color? color, bool isTotal = false}) {
    final textStyle = isTotal
        ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyLarge;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: textStyle),
          Text(amount, style: textStyle?.copyWith(color: color)),
        ],
      ),
    );
  }
}