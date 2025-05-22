import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/widgets/responsive_scaffold.dart';
import '../../../products/domain/entities/product_entity.dart';
import '../../../products/presentation/providers/product_notifier_provider.dart';



class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productNotifierProvider);

    return ResponsiveScaffold(
      title: 'Our Products',
      body: productsState.when(
        initial: () => const Center(child: Text('Loading products...')),
        loading: () => const Center(child: CircularProgressIndicator()),
        loaded: (products) => products.isEmpty
            ? const Center(child: Text('No products available'))
            : GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 3 : 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          padding: const EdgeInsets.all(8),
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ProductCard(product: product);
          },
        ),
        error: (message) => Center(child: Text(message)),
        added: () => const HomePage(),
      ),
    );
  }
}



class ProductCard extends StatelessWidget {
  final ProductEntity product; // Replace with your model

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼 Cached image with shimmer effect
          Expanded(
            child: product.imageUrl != null
                ? CachedNetworkImage(
              imageUrl: product.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.broken_image),
            )
                : Container(
              color: Colors.grey[300],
              child: const Center(
                child: Icon(Icons.image_not_supported, size: 48),
              ),
            ),
          ),

          // 📦 Product details
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${product.variants.first.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.green[700],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
