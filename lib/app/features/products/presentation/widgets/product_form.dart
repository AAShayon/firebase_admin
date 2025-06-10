import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/features/products/domain/entities/product_entity.dart';

import 'package:firebase_admin/app/features/products/presentation/widgets/variant_item.dart';

import '../../../../config/widgets/custom_drop_down.dart';
import '../../data/model/product_model.dart';

class ProductForm extends ConsumerWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController imageLinkController;
  final List<ProductVariantEntity> variants;
  final ProductCategory selectedCategory;
  final bool availability;
  final Function(ProductCategory) onCategoryChanged;
  final Function(bool) onAvailabilityChanged;
  final VoidCallback onAddVariant;
  final Function(ProductVariantEntity) onRemoveVariant;

  const ProductForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
    required this.imageLinkController,
    required this.variants,
    required this.selectedCategory,
    required this.availability,
    required this.onCategoryChanged,
    required this.onAvailabilityChanged,
    required this.onAddVariant,
    required this.onRemoveVariant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: titleController,
            decoration: const InputDecoration(labelText: 'Product Title'),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: imageLinkController,
            decoration: const InputDecoration(labelText: 'Image URL'),
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          CustomDropdown<ProductCategory>(
            value: selectedCategory,
            labelText: 'Category',
            items: ProductCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) => onCategoryChanged(value!),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Available'),
            value: availability,
            onChanged: onAvailabilityChanged,
          ),
          const SizedBox(height: 24),
          const Text('Product Variants', style: TextStyle(fontSize: 18)),
          ...variants.map((variant) => VariantItem(
            variant: variant,
            onDelete: () => onRemoveVariant(variant),
          )).toList(),
          ElevatedButton(
            onPressed: onAddVariant,
            child: const Text('Add Variant'),
          ),
        ],
      ),
    );
  }
}