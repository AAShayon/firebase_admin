// lib/app/features/products/presentation/widgets/variant_selector.dart
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_admin/app/features/shared/domain/entities/product_entity.dart';
import 'color_chip.dart';

class VariantSelector extends StatelessWidget {
  final ProductEntity product;
  final ProductVariantEntity selectedVariant;
  final ValueChanged<ProductVariantEntity> onVariantSelected;

  const VariantSelector({
    super.key,
    required this.product,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    // --- DATA PREPARATION ---
    // 1. Get a list of all unique colors available for the ENTIRE product.
    final allUniqueColors = product.variants.map((v) => v.color).toSet().toList();

    // 2. Get a list of all unique sizes available for the ENTIRE product.
    final allUniqueSizes = product.variants.map((v) => v.size).toSet().toList();

    // 3. Get a Set of available sizes ONLY for the currently selected color.
    //    This is used to enable/disable the size chips.
    final availableSizesForSelectedColor = product.variants
        .where((v) => v.color == selectedVariant.color)
        .map((v) => v.size)
        .toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- COLOR SELECTOR ---
        Text('Color', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12.0,
          children: allUniqueColors.map((color) {
            final isSelected = color == selectedVariant.color;
            return ColorChip(
              colorString: describeEnum(color),
              isSelected: isSelected,
              onTap: () {
                // Find a variant with the new color but try to keep the current size.
                ProductVariantEntity? newVariant = product.variants.firstWhereOrNull(
                      (v) => v.color == color && v.size == selectedVariant.size,
                );

                // If that size doesn't exist for the new color, fall back to the first available variant of that new color.
                newVariant ??= product.variants.firstWhere(
                      (v) => v.color == color,
                );

                onVariantSelected(newVariant);
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // --- SIZE SELECTOR ---
        Text('Size', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10.0,
          children: allUniqueSizes.map((size) {
            final isSelected = size == selectedVariant.size;
            // Determine if this size is available for the currently selected color.
            final isAvailable = availableSizesForSelectedColor.contains(size);

            return ChoiceChip(
              label: Text(size),
              selected: isSelected,
              // The `onSelected` callback is the key. It's null if the chip is disabled.
              onSelected: isAvailable
                  ? (selected) {
                if (selected) {
                  // Find the precise variant that matches the current color and the newly selected size.
                  final newVariant = product.variants.firstWhere(
                        (v) => v.color == selectedVariant.color && v.size == size,
                  );
                  onVariantSelected(newVariant);
                }
              }
                  : null, // This disables the chip!

              // --- VISUAL STYLING FOR DISABLED STATE ---
              selectedColor: Theme.of(context).colorScheme.primary,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : isAvailable
                    ? null // Default text color for available, unselected chips
                    : Colors.grey, // Greyed-out text for disabled chips
              ),
              backgroundColor: isAvailable ? null : Colors.grey.shade200,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            );
          }).toList(),
        ),
      ],
    );
  }
}