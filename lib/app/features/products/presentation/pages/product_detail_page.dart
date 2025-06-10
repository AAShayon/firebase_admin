// lib/app/features/products/presentation/pages/product_detail_page.dart
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import '../../data/model/product_model.dart';
import '../../domain/entities/product_entity.dart';
import '../widgets/product_image_slider.dart';
import '../widgets/variant_selector.dart';

class ProductDetailPage extends StatefulWidget {
  final ProductEntity product;
  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  late ProductVariantEntity _selectedVariant;
  // Controller to programmatically control the image slider
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();

    // --- UPDATE THIS BLOCK ---
    // Default to the first variant in the list (index 0).
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    } else {
      // Fallback for products with no variants, remains the same.
      _selectedVariant = ProductVariantEntity(size: 'N/A', price: 0, quantity: 0, color: ProductColor.custom);
    }
  }

  // The rest of the file remains exactly the same.
  // The _onVariantSelected method is already correct.
  // The build method is already correct.
  // The _buildActionButtons method is already correct.

  void _onVariantSelected(ProductVariantEntity newVariant) {
    setState(() {
      _selectedVariant = newVariant;
    });

    final variantIndex = widget.product.variants.indexOf(newVariant);

    if (variantIndex != -1 && variantIndex < widget.product.imageUrls.length) {
      _carouselController.animateToPage(variantIndex);
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 350.0, // Increased height for better look
            flexibleSpace: FlexibleSpaceBar(
              background: ProductImageSlider(
                imageUrls: widget.product.imageUrls,
                controller: _carouselController, // Pass the controller
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.product.title, style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),

                  Text(
                    '\$${_selectedVariant.price.toStringAsFixed(2)}',
                    style: textTheme.headlineSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    _selectedVariant.quantity > 0 ? 'In Stock (${_selectedVariant.quantity} available)' : 'Out of Stock',
                    style: TextStyle(
                      color: _selectedVariant.quantity > 0 ? Colors.green.shade700 : Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),

                  if (widget.product.variants.length > 1)
                    VariantSelector(
                      product: widget.product,
                      selectedVariant: _selectedVariant,
                      onVariantSelected: _onVariantSelected,
                    ),
                  if (widget.product.variants.length > 1)
                    const Divider(height: 32, thickness: 1),

                  Text('Description', style: textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    widget.product.description,
                    style: textTheme.bodyMedium?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: _buildActionButtons(),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          )
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          // Wishlist Button
          OutlinedButton(
            onPressed: () {
              // TODO: Implement add to wishlist logic
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Wishlist (Not Implemented)')));
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(12),
              shape: const CircleBorder(),
            ),
            child: const Icon(Icons.favorite_border),
          ),
          const SizedBox(width: 16),
          // Add to Cart Button
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _selectedVariant.quantity > 0 ? () {
                // TODO: Implement add to cart logic
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Added to Cart (Not Implemented)')));
              } : null, // Disable if out of stock
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}