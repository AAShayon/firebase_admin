import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PromotionRulesForm extends StatelessWidget {
  final TextEditingController couponCodeController;
  final TextEditingController usageLimitController;

  const PromotionRulesForm({
    super.key,
    required this.couponCodeController,
    required this.usageLimitController,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rules & Limits', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            TextFormField(
              controller: couponCodeController,
              decoration: const InputDecoration(
                labelText: 'Coupon Code (Optional)',
                hintText: 'e.g., SUMMER24',
                helperText: 'Leave empty if this is a general sale.',
              ),
              // Ensure coupon codes are uppercase and have no spaces
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                _UpperCaseTextFormatter(),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: usageLimitController,
              decoration: const InputDecoration(
                labelText: 'Total Usage Limit (Optional)',
                hintText: 'e.g., 100',
                helperText: 'Leave empty for unlimited uses.',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }
}

// A simple formatter to convert input to uppercase automatically
class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}