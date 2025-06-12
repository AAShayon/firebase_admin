import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CheckoutSummaryCard extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final TextEditingController couponController;
  final bool isCouponApplied;
  final VoidCallback onApplyCoupon;
  final VoidCallback onRemoveCoupon;

  const CheckoutSummaryCard({
    super.key,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.couponController,
    required this.isCouponApplied,
    required this.onApplyCoupon,
    required this.onRemoveCoupon,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order Summary', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            // Coupon Code
            TextField(
              controller: couponController,
              readOnly: isCouponApplied,
              decoration: InputDecoration(
                labelText: 'Coupon Code',
                hintText: 'Enter coupon code',
                border: const OutlineInputBorder(),
                suffixIcon: isCouponApplied
                    ? IconButton(icon: const Icon(Icons.clear, color: Colors.red), onPressed: onRemoveCoupon, tooltip: 'Remove Coupon',)
                    : TextButton(onPressed: onApplyCoupon, child: const Text('APPLY')),
              ),
            ),
            if (isCouponApplied)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('Coupon "FirstOrder" applied!', style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold)),
              ),
            const Divider(height: 32),
            // Price Details
            _buildSummaryRow('Subtotal', currencyFormat.format(subtotal)),
            _buildSummaryRow('Delivery Fee', currencyFormat.format(deliveryFee)),
            if (discount > 0)
              _buildSummaryRow('Discount', '- ${currencyFormat.format(discount)}', color: Colors.green.shade700),
            const Divider(),
            _buildSummaryRow('Grand Total', currencyFormat.format(total), isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, String amount, {Color? color, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(amount, style: TextStyle(fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal, color: color)),
        ],
      ),
    );
  }
}