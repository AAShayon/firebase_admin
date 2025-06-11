import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_admin/app/core/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/domain/entities/product_entity.dart';
import '../providers/search_notifier_provider.dart';


class SearchResultsList extends ConsumerWidget {
  final List<ProductEntity> products;

  const SearchResultsList({super.key, required this.products});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No products found for your search.'),
        ),
      );
    }

    // A ListView is perfect for displaying search results.
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        final firstImageUrl = product.variants
            .firstWhere((v) => v.imageUrls.isNotEmpty, orElse: () => product.variants.first)
            .imageUrls
            .firstOrNull;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ListTile(
            leading: firstImageUrl != null
                ? CircleAvatar(
              backgroundImage: CachedNetworkImageProvider(firstImageUrl),
              backgroundColor: Colors.grey[200],
            )
                : const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.image_not_supported, color: Colors.white),
            ),
            title: Text(product.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(
              'Price: \$${product.variants.firstOrNull?.price.toStringAsFixed(2) ?? 'N/A'}',
            ),
            onTap: () {
              context.pushNamed(AppRoutes.productDetail, extra: product);
            },
          ),
        );
      },
    );
  }
}