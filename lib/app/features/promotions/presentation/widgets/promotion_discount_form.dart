import 'package:flutter/material.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionDiscountForm extends StatelessWidget {
  final DiscountType discountType;
  final TextEditingController discountValueController;
  final ValueChanged<DiscountType> onDiscountTypeChanged;

  const PromotionDiscountForm({
    super.key,
    required this.discountType,
    required this.discountValueController,
    required this.onDiscountTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Discount Details', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            SegmentedButton<DiscountType>(
              segments: const [
                ButtonSegment(value: DiscountType.percentage, label: Text('% Percentage'), icon: Icon(Icons.percent)),
                ButtonSegment(value: DiscountType.fixedAmount, label: Text('\$ Fixed Amount'), icon: Icon(Icons.attach_money)),
              ],
              selected: {discountType},
              onSelectionChanged: (newSelection) => onDiscountTypeChanged(newSelection.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: discountValueController,
              decoration: InputDecoration(
                labelText: 'Discount Value *',
                prefixIcon: Icon(discountType == DiscountType.percentage ? Icons.percent : Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Value is required';
                if (double.tryParse(value) == null) return 'Must be a valid number';
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}