import 'package:firebase_admin/app/features/shared/domain/entities/product_entity.dart';
import 'package:flutter/material.dart';


class VariantItem extends StatelessWidget {
  final ProductVariantEntity variant;
  final VoidCallback onDelete;

  const VariantItem({
    super.key,
    required this.variant,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text('Size: ${variant.size}'),
        subtitle: Text(
          'Color: ${variant.color.toString().split('.').last}\n'
              'Price: \$${variant.price.toStringAsFixed(2)}\n'
              'Quantity: ${variant.quantity}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ),
    );
  }
}