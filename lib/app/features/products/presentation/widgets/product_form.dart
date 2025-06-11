// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:firebase_admin/app/features/products/domain/entities/product_entity.dart';
//
// import 'package:firebase_admin/app/features/products/presentation/widgets/variant_item.dart';
//
// import '../../../../config/widgets/custom_drop_down.dart';
// import '../../data/model/product_model.dart';
//
// // lib/app/features/products/presentation/widgets/product_form.dart
// // (imports)
//
// class ProductForm extends ConsumerWidget {
//   final GlobalKey<FormState> formKey;
//   final TextEditingController titleController;
//   final TextEditingController descriptionController;
//   // MODIFIED: Accept list of controllers
//   final List<TextEditingController> imageUrlControllers;
//   final List<ProductVariantEntity> variants;
//   final ProductCategory selectedCategory;
//   final bool availability;
//   final Function(ProductCategory) onCategoryChanged;
//   final Function(bool) onAvailabilityChanged;
//   final VoidCallback onAddVariant;
//   final Function(ProductVariantEntity) onRemoveVariant;
//   // ADDED: Callbacks for managing image URL fields
//   final VoidCallback onAddImageUrlField;
//   final Function(TextEditingController) onRemoveImageUrlField;
//
//   const ProductForm({
//     super.key,
//     required this.formKey,
//     required this.titleController,
//     required this.descriptionController,
//     required this.imageUrlControllers, // MODIFIED
//     required this.variants,
//     required this.selectedCategory,
//     required this.availability,
//     required this.onCategoryChanged,
//     required this.onAvailabilityChanged,
//     required this.onAddVariant,
//     required this.onRemoveVariant,
//     required this.onAddImageUrlField, // ADDED
//     required this.onRemoveImageUrlField, // ADDED
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return Form(
//       key: formKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           TextFormField(
//             controller: titleController,
//             decoration: const InputDecoration(labelText: 'Product Title'),
//             validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           ),
//           const SizedBox(height: 16),
//           TextFormField(
//             controller: descriptionController,
//             decoration: const InputDecoration(labelText: 'Description'),
//             maxLines: 3,
//             validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           ),
//           const SizedBox(height: 24),
//           const Text('Image URLs', style: TextStyle(fontSize: 18)),
//           // --- NEW: Image URL List ---
//           ...imageUrlControllers.map((controller) {
//             return Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Row(
//                 children: [
//                   Expanded(
//                     child: TextFormField(
//                       controller: controller,
//                       decoration: const InputDecoration(labelText: 'Image URL'),
//                       validator: (value) {
//                         // Only the first one is required
//                         if (imageUrlControllers.first == controller && (value == null || value.isEmpty)) {
//                           return 'At least one image URL is required';
//                         }
//                         return null;
//                       },
//                     ),
//                   ),
//                   // Only show remove button if there is more than one field
//                   if (imageUrlControllers.length > 1)
//                     IconButton(
//                       icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
//                       onPressed: () => onRemoveImageUrlField(controller),
//                     ),
//                 ],
//               ),
//             );
//           }).toList(),
//           TextButton.icon(
//             icon: const Icon(Icons.add),
//             label: const Text('Add Another Image URL'),
//             onPressed: onAddImageUrlField,
//           ),
//           const SizedBox(height: 16),
//           // --- END NEW SECTION ---
//           CustomDropdown<ProductCategory>(
//             value: selectedCategory,
//             labelText: 'Category',
//             items: ProductCategory.values.map((category) {
//               return DropdownMenuItem(
//                 value: category,
//                 child: Text(category.toString().split('.').last),
//               );
//             }).toList(),
//             onChanged: (value) => onCategoryChanged(value!),
//           ),
//           const SizedBox(height: 16),
//           SwitchListTile(
//             title: const Text('Available'),
//             value: availability,
//             onChanged: onAvailabilityChanged,
//           ),
//           const SizedBox(height: 24),
//           const Text('Product Variants', style: TextStyle(fontSize: 18)),
//           ...variants.map((variant) => VariantItem(
//             variant: variant,
//             onDelete: () => onRemoveVariant(variant),
//           )).toList(),
//           ElevatedButton(
//             onPressed: onAddVariant,
//             child: const Text('Add Variant'),
//           ),
//         ],
//       ),
//     );
//   }
// }
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
  // REMOVED: imageUrlControllers and its callbacks are gone
  final List<ProductVariantEntity> variants;
  final ProductCategory selectedCategory;
  final bool availability;
  final Function(ProductCategory?) onCategoryChanged;
  final Function(bool?) onAvailabilityChanged;
  final VoidCallback onAddVariant;
  final Function(ProductVariantEntity) onRemoveVariant;

  const ProductForm({
    super.key,
    required this.formKey,
    required this.titleController,
    required this.descriptionController,
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
            validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
          ),
          const SizedBox(height: 24),
          // --- REMOVED: The entire "Image URLs" section has been deleted from here ---
          CustomDropdown<ProductCategory>(
            value: selectedCategory,
            labelText: 'Category',
            items: ProductCategory.values.map((category) {
              return DropdownMenuItem(
                value: category,
                child: Text(category.toString().split('.').last),
              );
            }).toList(),
            onChanged: (value) => onCategoryChanged(value),
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