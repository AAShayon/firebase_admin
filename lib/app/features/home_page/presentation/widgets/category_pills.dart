import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../products/presentation/providers/product_providers.dart';

class CategoryPills extends ConsumerWidget {
  const CategoryPills({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(productsStreamProvider);

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return const SizedBox.shrink();
        }

        // Get unique categories and sort them alphabetically
        final categories = products.map((p) => p.category).toSet().toList();
        categories.sort((a, b) => a.name.compareTo(b.name));

        return SizedBox(
          height: 40,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8.0),
            itemBuilder: (context, index) {
              final category = categories[index];
              final categoryName = category.name[0].toUpperCase() + category.name.substring(1);

              return ActionChip(
                label: Text(categoryName),
                onPressed: () {
                  // Navigate to the new page with the category as an argument
                  context.pushNamed(
                    AppRoutes.categoryProducts,
                    extra: category,
                  );
                },
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(height: 40),
      error: (e, s) => const SizedBox.shrink(),
    );
  }
}