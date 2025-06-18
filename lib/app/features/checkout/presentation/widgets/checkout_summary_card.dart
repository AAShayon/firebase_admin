import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/checkout_notifier_provider.dart';

/// A card that displays the breakdown of the order total, including subtotal,
/// delivery fees, discounts, and provides an interface for applying coupons.
///
/// This widget is a [ConsumerWidget], so it rebuilds automatically whenever
/// the [checkoutNotifierProvider] state changes.
class CheckoutSummaryCard extends ConsumerWidget {
  const CheckoutSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH the provider to get the entire, up-to-date state.
    //    Any change to this state will cause this widget to rebuild.
    final checkoutState = ref.watch(checkoutNotifierProvider);

    // 2. READ the notifier to get a reference to its methods.
    //    We use `ref.read` because we only want to call the methods in callbacks,
    //    not rebuild the widget when the notifier instance itself changes.
    final checkoutNotifier = ref.read(checkoutNotifierProvider.notifier);

    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Order Summary',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // --- REACTIVE COUPON SECTION ---
            TextFormField(
              controller: checkoutState.couponController,
              readOnly: checkoutState.isCouponApplied, // Disable input if coupon is applied
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                // Display the error message directly from the state if it exists
                errorText: checkoutState.error,
                hintText: 'Enter coupon code',
                border: const OutlineInputBorder(),
                // Show a loading indicator, a clear button, or an apply button based on the state
                suffixIcon: checkoutState.isLoading
                    ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                    : checkoutState.isCouponApplied
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: checkoutNotifier.removeCoupon,
                  tooltip: 'Remove Coupon',
                )
                    : TextButton(
                  onPressed: checkoutNotifier.applyCoupon,
                  child: const Text('APPLY'),
                ),
              ),
            ),
            if (checkoutState.isCouponApplied && checkoutState.error == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Coupon applied successfully!',
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            // --- END OF COUPON SECTION ---

            const Divider(height: 32),

            // Price Details now read directly from the state
            _buildSummaryRow(
              context,
              'Subtotal',
              currencyFormat.format(checkoutState.subtotal),
            ),
            _buildSummaryRow(
              context,
              'Delivery Fee',
              currencyFormat.format(checkoutState.deliveryFee),
            ),
            if (checkoutState.discount > 0)
              _buildSummaryRow(
                context,
                'Discount',
                '- ${currencyFormat.format(checkoutState.discount)}',
                color: Colors.green.shade700,
              ),
            const Divider(),
            _buildSummaryRow(
              context,
              'Grand Total',
              currencyFormat.format(checkoutState.grandTotal),
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  /// A private helper to build a consistent row for the summary card.
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