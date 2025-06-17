import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../products/presentation/providers/product_providers.dart';

class ProductSelectionDialog extends ConsumerStatefulWidget {
  final List<String> preselectedIds;
  const ProductSelectionDialog({super.key, required this.preselectedIds});

  @override
  ConsumerState<ProductSelectionDialog> createState() => _ProductSelectionDialogState();
}

class _ProductSelectionDialogState extends ConsumerState<ProductSelectionDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.preselectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return AlertDialog(
      title: const Text('Select Products for Promotion'),
      content: SizedBox(
        width: double.maxFinite,
        child: productsAsync.when(
          data: (products) => ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final isSelected = _selectedIds.contains(product.id);
              return CheckboxListTile(
                title: Text(product.title),
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedIds.add(product.id);
                    } else {
                      _selectedIds.remove(product.id);
                    }
                  });
                },
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e,s) => Text('Error: $e'),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_selectedIds.toList()),
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}