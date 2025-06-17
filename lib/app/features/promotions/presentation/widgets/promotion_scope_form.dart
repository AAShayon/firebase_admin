import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promotion_entity.dart';
import 'product_selection_dialog.dart';

class PromotionScopeForm extends ConsumerWidget {
  final PromotionScope scope;
  final List<String> selectedProductIds;
  final ValueChanged<PromotionScope> onScopeChanged;
  final ValueChanged<List<String>> onProductsChanged;

  const PromotionScopeForm({
    super.key, required this.scope, required this.selectedProductIds,
    required this.onScopeChanged, required this.onProductsChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Promotion Scope', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            RadioListTile<PromotionScope>(
              title: const Text('All Products'),
              value: PromotionScope.allProducts,
              groupValue: scope,
              onChanged: (value) => onScopeChanged(value!),
            ),
            RadioListTile<PromotionScope>(
              title: const Text('Specific Products'),
              value: PromotionScope.specificProducts,
              groupValue: scope,
              onChanged: (value) => onScopeChanged(value!),
            ),
            if (scope == PromotionScope.specificProducts)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Selected Products: ${selectedProductIds.length}'),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        final result = await showDialog<List<String>>(
                          context: context,
                          builder: (_) => ProductSelectionDialog(preselectedIds: selectedProductIds),
                        );
                        if (result != null) {
                          onProductsChanged(result);
                        }
                      },
                      child: const Text('Select Products'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}