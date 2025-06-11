//
// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:firebase_admin/app/core/utils/sliver_app_bar.dart';
// import 'package:flutter/material.dart';
// import '../../../../core/utils/product_action_buttons.dart';
// import '../../../../core/utils/quantity_selector.dart';
// import '../../../shared/data/model/product_model.dart';
// import '../../../shared/domain/entities/product_entity.dart';
//
// import '../widgets/product_info_section.dart';
// import '../widgets/variant_selector.dart';
// import '../widgets/product_description_section.dart';
//
//
// class ProductDetailPage extends StatefulWidget {
//   final ProductEntity product;
//
//   const ProductDetailPage({super.key, required this.product});
//
//   @override
//   State<ProductDetailPage> createState() => _ProductDetailScreenState();
// }
//
// class _ProductDetailScreenState extends State<ProductDetailPage> {
//   late ProductVariantEntity _selectedVariant;
//   List<String> allImages = [];
//   List<ProductVariantEntity> variantsForSlider = [];
//   final CarouselSliderController _carouselController = CarouselSliderController();
//   bool _showQuantitySelector = false;
//   int _quantity = 1;
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Combine all images from all variants
//     for (var variant in widget.product.variants) {
//       allImages.addAll(variant.imageUrls);
//       variantsForSlider.add(variant);
//     }
//
//     // Default selected variant
//     _selectedVariant = widget.product.variants.isNotEmpty
//         ? widget.product.variants.first
//         : ProductVariantEntity(
//       size: 'N/A',
//       price: 0,
//       quantity: 0,
//       color: ProductColor.custom,
//       imageUrls: [],
//     );
//   }
//
//   void _onImageSlide(int index) {
//     final newVariant = variantsForSlider[index];
//     setState(() {
//       _selectedVariant = newVariant;
//       // Reset quantity selector when variant changes
//       _showQuantitySelector = false;
//       _quantity = 1;
//     });
//   }
//
//   void _onColorChipSelected(ProductVariantEntity newVariant) {
//     setState(() {
//       _selectedVariant = newVariant;
//       // Reset quantity selector when variant changes
//       _showQuantitySelector = false;
//       _quantity = 1;
//     });
//     allImages = newVariant.imageUrls;
//     _carouselController.animateToPage(0);
//   }
//
//   void _addToCart() {
//     setState(() {
//       _showQuantitySelector = true;
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Added to Cart (Not Implemented)')),
//     );
//   }
//
//   void _buyNow() {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Proceeding to Checkout')),
//     );
//   }
//
//   void _incrementQuantity() {
//     setState(() {
//       _quantity++;
//     });
//   }
//
//   void _decrementQuantity() {
//     setState(() {
//       if (_quantity > 1) {
//         _quantity--;
//       } else {
//         _showQuantitySelector = false;
//         _quantity = 1;
//       }
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           CustomSliverAppBar(
//             imageUrls: allImages,
//             controller: _carouselController,
//             onImageChanged: _onImageSlide,
//             onWishlistPressed: () {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(
//                   content: Text('Added to Wishlist (Not Implemented)'),
//                 ),
//               );
//             },
//           ),
//           SliverToBoxAdapter(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 if (_showQuantitySelector)
//                   Padding(
//                     padding: const EdgeInsets.only(top: 16.0),
//                     child: QuantitySelector(
//                       quantity: _quantity,
//                       onDecrement: _decrementQuantity,
//                       onIncrement: _incrementQuantity,
//                     ),
//                   ),
//                 ProductInfoSection(
//                   product: widget.product,
//                   selectedVariant: _selectedVariant,
//                 ),
//                 if (widget.product.variants.length > 1)
//                   VariantSelector(
//                     product: widget.product,
//                     selectedVariant: _selectedVariant,
//                     onVariantSelected: _onColorChipSelected,
//                   ),
//                 ProductDescriptionSection(
//                   description: widget.product.description,
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: ProductActionButtons(
//         isInStock: _selectedVariant.quantity > 0,
//         onAddToCart: _addToCart,
//         onBuyNow: _buyNow,
//         showQuantitySelector: _showQuantitySelector,
//         quantity: _quantity,
//         onDecrement: _decrementQuantity,
//         onIncrement: _incrementQuantity,
//       ),
//     );
//   }
// }
///
// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
//
// // Your App Specific Imports
// import '../../../../core/routes/app_router.dart';
// import '../../../../core/utils/product_action_buttons.dart';
// import '../../../../core/utils/quantity_selector.dart';
// import '../../../../core/utils/sliver_app_bar.dart';
// import '../../../auth/presentation/providers/auth_providers.dart';
// import '../../../cart/domain/entities/cart_item_entity.dart';
// import '../../../cart/presentation/providers/cart_notifier_provider.dart';
// import '../../../cart/presentation/widgets/mini_cart_summary.dart';
// import '../../../shared/data/model/product_model.dart'; // For Enums
// import '../../../shared/domain/entities/product_entity.dart';
//
// import '../widgets/product_description_section.dart';
// import '../widgets/product_info_section.dart';
// import '../widgets/variant_selector.dart';
//
// class ProductDetailPage extends ConsumerStatefulWidget {
//   final ProductEntity product;
//
//   const ProductDetailPage({super.key, required this.product});
//
//   @override
//   ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
// }
//
// class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
//   late ProductVariantEntity _selectedVariant;
//   List<String> allImages = [];
//   final CarouselSliderController _carouselController = CarouselSliderController();
//   int _quantity = 1;
//
//   // New state for controlling the bottom bar animation
//   bool _itemAddedToCart = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeVariantAndImages();
//   }
//
//   void _initializeVariantAndImages() {
//     if (widget.product.variants.isNotEmpty) {
//       _selectedVariant = widget.product.variants.first;
//       allImages = _selectedVariant.imageUrls;
//     } else {
//       // Handle products with no variants (should be rare)
//       _selectedVariant = ProductVariantEntity(
//         size: 'N/A', price: 0, quantity: 0, color: ProductColor.custom, imageUrls: [],
//       );
//       allImages = [];
//     }
//   }
//
//   void _onColorChipSelected(ProductVariantEntity newVariant) {
//     setState(() {
//       _selectedVariant = newVariant;
//       allImages = newVariant.imageUrls;
//       _quantity = 1;
//       // If user switches variant, let them add the new one to cart
//       _itemAddedToCart = false;
//     });
//     // Animate image slider to the first image of the new variant
//     _carouselController.animateToPage(0);
//   }
//
//   void _addToCart() {
//     final currentUser = ref.read(currentUserProvider);
//     if (currentUser == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please log in to add items to your cart')),
//       );
//       return;
//     }
//
//     final cartItem = CartItemEntity(
//       // The 'id' will be generated by the data source, so a placeholder is fine.
//       id: '${widget.product.id}_${_selectedVariant.size}_${_selectedVariant.color}',
//       userId: currentUser.id,
//       productId: widget.product.id,
//       productTitle: widget.product.title,
//       variantSize: _selectedVariant.size,
//       variantColorName: _selectedVariant.color.name,
//       variantPrice: _selectedVariant.price,
//       variantImageUrl: _selectedVariant.imageUrls.isNotEmpty ? _selectedVariant.imageUrls.first : null,
//       quantity: _quantity,
//     );
//
//     // Call the notifier to add the item to Firestore
//     ref.read(cartNotifierProvider.notifier).addToCart(cartItem);
//
//     setState(() {
//       _itemAddedToCart = true;
//     });
//   }
//
//   void _buyNow() {
//     // This logic can remain the same or be adapted for a direct checkout flow
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Proceeding to Checkout (Not Implemented)')),
//     );
//   }
//
//   void _incrementQuantity() => setState(() => _quantity++);
//   void _decrementQuantity() => setState(() => _quantity > 1 ? _quantity-- : null);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // REMOVED bottomNavigationBar
//       body: Stack(
//         children: [
//           CustomScrollView(
//             slivers: [
//               CustomSliverAppBar(
//                 imageUrls: allImages,
//                 controller: _carouselController,
//                 onImageChanged: (index) {}, // Can be empty if not needed
//                 onWishlistPressed: () { /* Wishlist logic */ },
//               ),
//               SliverToBoxAdapter(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     ProductInfoSection(
//                       product: widget.product,
//                       selectedVariant: _selectedVariant,
//                     ),
//                     if (widget.product.variants.length > 1)
//                       VariantSelector(
//                         product: widget.product,
//                         selectedVariant: _selectedVariant,
//                         onVariantSelected: _onColorChipSelected,
//                       ),
//                     QuantitySelector(
//                       quantity: _quantity,
//                       onDecrement: _decrementQuantity,
//                       onIncrement: _incrementQuantity,
//                     ),
//                     ProductDescriptionSection(
//                       description: widget.product.description,
//                     ),
//                     // Add padding to the bottom to avoid being covered by the action bar
//                     const SizedBox(height: 120),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           // Positioned Bottom Bar with Animation
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: AnimatedSwitcher(
//               duration: const Duration(milliseconds: 500),
//               transitionBuilder: (child, animation) {
//                 return SlideTransition(
//                   position: Tween<Offset>(
//                     begin: const Offset(0, 1),
//                     end: Offset.zero,
//                   ).animate(animation),
//                   child: child,
//                 );
//               },
//               child: _itemAddedToCart
//                   ? MiniCartSummary(
//                 key: const ValueKey('miniCart'),
//                 productName: widget.product.title,
//                 quantity: _quantity,
//                 total: _selectedVariant.price * _quantity,
//                 onTap: () => context.pushNamed(AppRoutes.cart), // Navigate to cart page
//               )
//                   : ProductActionButtons(
//                 key: const ValueKey('actionButtons'),
//                 isInStock: _selectedVariant.quantity > 0,
//                 onAddToCart: _addToCart,
//                 onBuyNow: _buyNow,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
///
// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:flutter/material.dart';
// import '../../../shared/data/model/product_model.dart';
// import '../../../shared/domain/entities/product_entity.dart';
//
//
// import '../../../../core/utils/product_image_slider.dart';
// import '../widgets/variant_selector.dart';
//
// class ProductDetailPage extends StatefulWidget {
//   final ProductEntity product;
//
//   const ProductDetailPage({super.key, required this.product});
//
//   @override
//   State<ProductDetailPage> createState() => _ProductDetailPageState();
// }
//
// class _ProductDetailPageState extends State<ProductDetailPage> {
//   late ProductVariantEntity _selectedVariant;
//   List<String> allImages = [];
//   List<ProductVariantEntity> variantsForSlider = [];
//   final CarouselSliderController _carouselController =
//       CarouselSliderController();
//
//   @override
//   void initState() {
//     super.initState();
//
//     // Combine all images from all variants
//     for (var variant in widget.product.variants) {
//       allImages.addAll(variant.imageUrls); // Collect all images
//       variantsForSlider.add(variant); // Store the corresponding variants
//     }
//
//     // Default selected variant (first variant)
//     if (widget.product.variants.isNotEmpty) {
//       _selectedVariant = widget.product.variants.first;
//     } else {
//       _selectedVariant = ProductVariantEntity(
//         size: 'N/A',
//         price: 0,
//         quantity: 0,
//         color: ProductColor.custom,
//         imageUrls: [],
//       );
//     }
//   }
//
//   // Update selected variant based on the image index
//   void _onImageSlide(int index) {
//     final newVariant =
//         variantsForSlider[index]; // Get the variant corresponding to the image
//     setState(() {
//       _selectedVariant = newVariant;
//     });
//   }
//
//   // Handle color chip tap and update the selected variant and image slider
//   void _onColorChipSelected(ProductVariantEntity newVariant) {
//     setState(() {
//       _selectedVariant = newVariant;
//     });
//
//     // Update the image list to reflect the images of the selected variant
//     allImages = newVariant.imageUrls;
//
//     // Optionally: Auto-slide to the first image of the selected variant
//     _carouselController.animateToPage(0);
//   }
//
//   void _logVariantDetails() {
//     print("Selected Variant Details:");
//     print("Title: ${_selectedVariant.color}");
//     print("ID: ${widget.product.id}");
//     print("Color: ${_selectedVariant.color}");
//     print("Size: ${_selectedVariant.size}");
//     print("Price: \$${_selectedVariant.price}");
//     print("Quantity Available: ${_selectedVariant.quantity}");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//
//     return Scaffold(
//       body: CustomScrollView(
//         slivers: [
//           SliverAppBar(
//             pinned: true,
//             expandedHeight: 350.0,
//             flexibleSpace: FlexibleSpaceBar(
//               background: ProductImageSlider(
//                 imageUrls: allImages,
//                 // Pass the updated list of images
//                 controller: _carouselController,
//                 onImageChanged: _onImageSlide,
//                 // Handle image change to update variant
//                 onPressed: () {
//                   _logVariantDetails();
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Added to Wishlist (Not Implemented)'),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.product.title,
//                     style: textTheme.headlineMedium?.copyWith(
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//
//                   Text(
//                     '\$${_selectedVariant.price.toStringAsFixed(2)}',
//                     style: textTheme.headlineSmall?.copyWith(
//                       color: Theme.of(context).colorScheme.primary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),
//
//                   Text(
//                     _selectedVariant.quantity > 0
//                         ? 'In Stock (${_selectedVariant.quantity} available)'
//                         : 'Out of Stock',
//                     style: TextStyle(
//                       color:
//                           _selectedVariant.quantity > 0
//                               ? Colors.green.shade700
//                               : Colors.red.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const Divider(height: 32, thickness: 1),
//
//                   if (widget.product.variants.length > 1)
//                     VariantSelector(
//                       product: widget.product,
//                       selectedVariant: _selectedVariant,
//                       onVariantSelected:
//                           _onColorChipSelected, // Pass the color chip selection handler
//                     ),
//                   const Divider(height: 32, thickness: 1),
//
//                   Text('Description', style: textTheme.titleLarge),
//                   const SizedBox(height: 8),
//                   Text(
//                     widget.product.description,
//                     style: textTheme.bodyMedium?.copyWith(height: 1.5),
//                   ),
//                   const SizedBox(height: 32),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildActionButtons(),
//     );
//   }
//
//   Widget _buildActionButtons() {
//     return Container(
//       padding: const EdgeInsets.all(
//         16,
//       ).copyWith(bottom: MediaQuery.of(context).padding.bottom + 8),
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 10,
//             offset: const Offset(0, -5),
//           ),
//         ],
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       child: Row(
//         children: [
//           // Add to Cart Button
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed:
//                   _selectedVariant.quantity > 0
//                       ? () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Added to Cart (Not Implemented)'),
//                           ),
//                         );
//                       }
//                       : null,
//               icon: const Icon(Icons.shopping_cart_outlined),
//               label: const Text('Add to Cart'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 16),
//           // Buy Now Button
//           Expanded(
//             child: ElevatedButton.icon(
//               onPressed:
//                   _selectedVariant.quantity > 0
//                       ? () {
//                         // You can replace this with actual Buy Now logic (e.g., navigate to checkout)
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Proceeding to Checkout'),
//                           ),
//                         );
//                       }
//                       : null,
//               icon: const Icon(Icons.shopping_bag_outlined),
//               label: const Text('Buy Now'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 textStyle: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                 ),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
///
import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_admin/app/core/utils/sliver_app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/product_action_buttons.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../shared/data/model/product_model.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_info_section.dart';
import '../widgets/variant_selector.dart';

// CONVERTED to ConsumerStatefulWidget
class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late ProductVariantEntity _selectedVariant;
  List<String> allImages = [];
  final CarouselSliderController _carouselController = CarouselSliderController();

  // State for the Add to Cart interaction
  bool _isCartActionInitiated = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeVariant();
  }

  void _initializeVariant() {
    // Default selected variant
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
      allImages = _selectedVariant.imageUrls;
    } else {
      // Fallback for a product with no variants (should not happen in a real app)
      _selectedVariant = ProductVariantEntity(
        size: 'N/A', price: 0, quantity: 0,
        color: ProductColor.custom, imageUrls: [],
      );
      allImages = [];
    }
  }

  // Resets the state when a new variant is selected
  void _resetCartState() {
    setState(() {
      _isCartActionInitiated = false;
      _quantity = 1;
    });
  }

  void _onImageSlide(int index) {
    // This logic might need adjustment based on how images map to variants.
    // Assuming 1 image per variant for simplicity here.
    if (index < widget.product.variants.length) {
      setState(() {
        _selectedVariant = widget.product.variants[index];
        _resetCartState();
      });
    }
  }

  void _onVariantSelected(ProductVariantEntity newVariant) {
    setState(() {
      _selectedVariant = newVariant;
      allImages = newVariant.imageUrls;
      if (allImages.isNotEmpty) {
        _carouselController.animateToPage(0);
      }
      _resetCartState();
    });
  }

  // --- CART LOGIC ---
  void _handleAddToCart() {
    if (_isCartActionInitiated) {
      // This is the "Update Cart" click
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        // Prompt user to log in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add items to your cart.')),
        );
        return;
      }

      // Create the CartItemEntity
      final cartItem = CartItemEntity(
        id: '', // The data source will generate this
        userId: currentUser.id,
        productId: widget.product.id,
        productTitle: widget.product.title,
        variantSize: _selectedVariant.size,
        variantColorName: _selectedVariant.color.name,
        variantPrice: _selectedVariant.price,
        variantImageUrl: _selectedVariant.imageUrls.isNotEmpty ? _selectedVariant.imageUrls.first : null,
        quantity: _quantity,
      );

      // Call the notifier to add to Firestore
      ref.read(cartNotifierProvider.notifier).addToCart(cartItem);

      // Show confirmation and optionally navigate
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity x ${widget.product.title} to cart!'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => context.pushNamed(AppRoutes.cart), // Assumes a 'cart' route
          ),
        ),
      );

    } else {
      // This is the first "Add to Cart" click
      setState(() {
        _isCartActionInitiated = true;
      });
    }
  }

  void _buyNow() {
    // Logic for immediate checkout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to Checkout...')),
    );
  }

  void _incrementQuantity() {
    if (_quantity < _selectedVariant.quantity) {
      setState(() { _quantity++; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum stock quantity reached (${_selectedVariant.quantity})')),
      );
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() { _quantity--; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            imageUrls: allImages,
            controller: _carouselController,
            onImageChanged: _onImageSlide,
            onWishlistPressed: () { /* Wishlist logic */ },
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProductInfoSection(
                  product: widget.product,
                  selectedVariant: _selectedVariant,
                ),
                if (widget.product.variants.length > 1)
                  VariantSelector(
                    product: widget.product,
                    selectedVariant: _selectedVariant,
                    onVariantSelected: _onVariantSelected,
                  ),
                ProductDescriptionSection(
                  description: widget.product.description,
                ),
                // --- ACTION BUTTONS MOVED HERE ---
                ProductActionButtons(
                  isInStock: _selectedVariant.quantity > 0,
                  onAddToCart: _handleAddToCart,
                  onBuyNow: _buyNow,
                  showQuantitySelector: _isCartActionInitiated,
                  quantity: _quantity,
                  onDecrement: _decrementQuantity,
                  onIncrement: _incrementQuantity,
                ),
              ],
            ),
          ),
        ],
      ),
      // REMOVED bottomNavigationBar
    );
  }
}