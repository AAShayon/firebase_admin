import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core and Feature imports
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/product_action_buttons.dart';
import '../../../../core/utils/product_image_slider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../checkout/presentation/providers/checkout_notifier_provider.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../../../wishlist/presentation/providers/wishlist_notifier_provider.dart';
import '../../../wishlist/presentation/providers/wishlist_providers.dart';

// Widget imports
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
  // --- STATE MANAGEMENT ---
  late ProductVariantEntity _selectedVariant;
  final List<String> _allImages = [];
  final List<ProductVariantEntity> _variantsForSlider = [];
  final CarouselSliderController _carouselController = CarouselSliderController();

  bool _isCartActionInitiated = false;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _initializeVariantsAndImages();
  }

  // --- LOGIC METHODS ---

  void _initializeVariantsAndImages() {
    if (widget.product.variants.isEmpty) {
      _selectedVariant = ProductVariantEntity.empty();
      return;
    }
    for (var variant in widget.product.variants) {
      for (var imageUrl in variant.imageUrls) {
        if (imageUrl.startsWith('http')) {
          _allImages.add(imageUrl);
          _variantsForSlider.add(variant);
        }
      }
    }
    _selectedVariant = widget.product.variants.first;
  }

  void _resetCartState() => setState(() {
    _isCartActionInitiated = false;
    _quantity = 1;
  });

  void _onImageSlide(int index, CarouselPageChangedReason reason) {
    if (index < _variantsForSlider.length) {
      final newVariant = _variantsForSlider[index];
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

    int imageIndex = _allImages.indexWhere((url) => newVariant.imageUrls.contains(url));
    if (imageIndex != -1) {
      _carouselController.animateToPage(imageIndex);
    }
  }

  void _handleAddToCart() {
    if (!_isCartActionInitiated) {
      setState(() => _isCartActionInitiated = true);
      return;
    }

    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to add items.')));
      return;
    }

    ref.read(cartNotifierProvider.notifier).addToCart(CartItemEntity(
      id: '', userId: currentUser.id, productId: widget.product.id,
      productTitle: widget.product.title,
      variantSize: _selectedVariant.size,
      variantColorName:describeEnum(_selectedVariant.color),
      variantPrice: _selectedVariant.price,
      variantImageUrl: _selectedVariant.imageUrls.isNotEmpty ? _selectedVariant.imageUrls.first : null,
      quantity: _quantity,
    ));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Added $_quantity x ${widget.product.title} to cart!'),
      action: SnackBarAction(label: 'VIEW CART', onPressed: () => context.pushNamed(AppRoutes.cart)),
    ));
  }

  void _buyNow() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) { /* ... handle guest ... */ return; }

    try {
      // --- PREPARE STATE BEFORE NAVIGATING ---

      // Invalidate to ensure a fresh state
      ref.invalidate(checkoutNotifierProvider);

      // Await profile to get address
      final profile = await ref.read(userProfileStreamProvider(currentUser.id).future);
      if (!mounted || profile.addresses.isEmpty) { /* ... handle no address ... */ return; }

      final defaultAddress = profile.addresses.firstWhere((a) => a.isDefault, orElse: () => profile.addresses.first);

      // Initialize the notifier with the "Buy Now" item
      ref.read(checkoutNotifierProvider.notifier).initializeForBuyNow(
        product: widget.product,
        variant: _selectedVariant,
        quantity: _isCartActionInitiated ? _quantity : 1,
        defaultAddress: defaultAddress,
      );

      // --- NAVIGATE LAST ---
      // Now that the state is ready, navigate to the checkout page.
      context.pushNamed(AppRoutes.checkout);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not prepare checkout: $e')));
      }
    }
  }

  void _incrementQuantity() {
    if (_quantity < _selectedVariant.quantity) {
      setState(() => _quantity++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Maximum stock quantity reached (${_selectedVariant.quantity})')));
    }
  }

  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() => _quantity--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final wishlistIdsAsync = ref.watch(wishlistIdsProvider(currentUser?.id ?? ''));
    final isInWishlist = wishlistIdsAsync.when(data: (ids) => ids.contains(widget.product.id), loading: () => false, error: (e, s) => false);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- WIDGET COMPOSITION IN ACTION ---
          ProductImageSlider(
            imageUrls: _allImages,
            controller: _carouselController,
            onPageChanged: _onImageSlide,
            isWishlisted: isInWishlist,
            onWishlistPressed: () {
              if (currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please log in to use the wishlist.')));
                return;
              }
              final notifier = ref.read(wishlistNotifierProvider.notifier);
              if (isInWishlist) {
                notifier.removeFromWishlist(currentUser.id, widget.product.id);
              } else {
                notifier.addToWishlist(currentUser.id, widget.product);
              }
            },
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductInfoSection(product: widget.product, selectedVariant: _selectedVariant),

                  if (widget.product.variants.length > 1)
                    VariantSelector(product: widget.product, selectedVariant: _selectedVariant, onVariantSelected: _onVariantSelected),

                  ProductDescriptionSection(description: widget.product.description),

                  ProductActionButtons(
                    isInStock: _selectedVariant.quantity > 0,
                    onAddToCart: _handleAddToCart,
                    onBuyNow: _buyNow,
                    showQuantitySelector: _isCartActionInitiated,
                    quantity: _quantity,
                    onDecrement: _decrementQuantity,
                    onIncrement: _incrementQuantity,
                  ),
                  const SizedBox(height: 40), // Spacing at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}