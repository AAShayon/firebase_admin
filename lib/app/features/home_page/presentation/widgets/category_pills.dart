import 'package:flutter/material.dart';
import '../../../shared/data/model/product_model.dart'; // For the enum

class CategoryPills extends StatelessWidget {
  const CategoryPills({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      ProductCategory.Apparel, ProductCategory.Electronics,
      ProductCategory.Home, ProductCategory.Books, ProductCategory.Sports
    ];

    return SizedBox(
      height: 50,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index];
          return ActionChip(
            label: Text(category.name),
            onPressed: () {
              // TODO: Implement category filter logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Tapped on ${category.name}')),
              );
            },
          );
        },
      ),
    );
  }
}