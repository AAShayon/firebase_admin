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
import '../../../wishlist/presentation/providers/wishlist_notifier_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';
import '../widgets/product_description_section.dart';
import '../widgets/product_info_section.dart';
import '../widgets/variant_selector.dart';

class ProductDetailPage extends ConsumerStatefulWidget {
  final ProductEntity product;

  const ProductDetailPage({super.key, required this.product});

  @override
  ConsumerState<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends ConsumerState<ProductDetailPage> {
  late ProductVariantEntity _selectedVariant;
  List<String> allImages = [];
  List<ProductVariantEntity> variantsForSlider = [];
  final CarouselSliderController _carouselController = CarouselSliderController();

  bool _isCartActionInitiated = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeVariant();
  }

  void _initializeVariant() {
    // Combine all images from all variants and map them to their variants
    for (var variant in widget.product.variants) {
      allImages.addAll(variant.imageUrls);
      // For each image, add the corresponding variant to variantsForSlider
      for (var _ in variant.imageUrls) {
        variantsForSlider.add(variant);
      }
    }

    // Default selected variant
    if (widget.product.variants.isNotEmpty) {
      _selectedVariant = widget.product.variants.first;
    } else {
      _selectedVariant = ProductVariantEntity(
        size: 'N/A', price: 0, quantity: 0,
        color: ProductColor.custom, imageUrls: [],
      );
    }
  }

  void _resetCartState() {
    setState(() {
      _isCartActionInitiated = false;
      _quantity = 1;
    });
  }

  void _onImageSlide(int index) {
    if (index < variantsForSlider.length) {
      final newVariant = variantsForSlider[index];
      if (newVariant != _selectedVariant) {
        setState(() {
          _selectedVariant = newVariant;
          _resetCartState();
        });
      }
    }
  }

  void _onVariantSelected(ProductVariantEntity newVariant) {
    setState(() {
      _selectedVariant = newVariant;
      _resetCartState();
    });

    // Find the first occurrence of this variant's images in the allImages list
    final variantIndex = widget.product.variants.indexOf(newVariant);
    if (variantIndex != -1) {
      int startIndex = 0;
      for (int i = 0; i < variantIndex; i++) {
        startIndex += widget.product.variants[i].imageUrls.length;
      }
      if (startIndex < allImages.length) {
        _carouselController.animateToPage(startIndex);
      }
    }
  }

  void _handleAddToCart() {
    if (_isCartActionInitiated) {
      final currentUser = ref.read(currentUserProvider);
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to add items to your cart.')),
        );
        return;
      }

      final cartItem = CartItemEntity(
        id: '',
        userId: currentUser.id,
        productId: widget.product.id,
        productTitle: widget.product.title,
        variantSize: _selectedVariant.size,
        variantColorName: _selectedVariant.color.name,
        variantPrice: _selectedVariant.price,
        variantImageUrl: _selectedVariant.imageUrls.isNotEmpty
            ? _selectedVariant.imageUrls.first
            : null,
        quantity: _quantity,
      );

      ref.read(cartNotifierProvider.notifier).addToCart(cartItem);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added $_quantity x ${widget.product.title} to cart!'),
          action: SnackBarAction(
            label: 'VIEW CART',
            onPressed: () => context.pushNamed(AppRoutes.cart),
          ),
        ),
      );
    } else {
      setState(() {
        _isCartActionInitiated = true;
      });
    }
  }

  void _buyNow() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proceeding to Checkout...')),
    );
  }

  void _incrementQuantity() {
    if (_quantity < _selectedVariant.quantity) {
      setState(() { _quantity++; });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum stock quantity reached (${_selectedVariant.quantity})'),
          ));
      }
      }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() { _quantity--; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final wishlistIdsAsync = ref.watch(wishlistIdsProvider(currentUser?.id ?? ''));
    final isInWishlist = wishlistIdsAsync.when(
      data: (ids) => ids.contains(widget.product.id),
      loading: () => false,
      error: (e, s) => false,
    );
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomSliverAppBar(
            imageUrls: allImages,
            controller: _carouselController,
            onImageChanged: _onImageSlide,
            isWishlisted: isInWishlist,
            onWishlistPressed: () {
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please log in to use the wishlist.'))
                );
                return;
              }

              final notifier = ref.read(wishlistNotifierProvider.notifier);
              if (isInWishlist) {
                notifier.removeFromWishlist(currentUser.id, widget.product.id);
              } else {
                notifier.addToWishlist(currentUser.id, widget.product);
              }
            },
            // wishlistButtonColor: {/* chnage according to is that wishlist or not */},
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
    );
  }
}