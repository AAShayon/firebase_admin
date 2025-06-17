import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // for describeEnum
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- FEATURE IMPORTS ---
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../../../cart/presentation/widgets/floating_basket_view.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../search/presentation/providers/search_notifier_provider.dart';
import '../../../search/presentation/widgets/product_search_bar.dart';
import '../../../search/presentation/widgets/search_results_list.dart';
import '../../../shared/domain/entities/product_entity.dart';

// --- PROVIDERS FOR THIS PAGE ---
typedef RunAnimationCallback = void Function(GlobalKey, ProductEntity);
final homeAnimationProvider = StateProvider<RunAnimationCallback?>((ref) => null);
final addingToCartProvider = StateProvider<String?>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  final GlobalKey _basketKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeAnimationProvider.notifier).state = _initiateAddToCartAndAnimation;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  void _initiateAddToCartAndAnimation(GlobalKey itemKey, ProductEntity product) {
    _addToCart(product);
    _runAnimation(itemKey, product);
  }

  void _runAnimation(GlobalKey itemKey, ProductEntity product) {
    if (itemKey.currentContext == null || _basketKey.currentContext == null) return;
    final itemRenderBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final basketRenderBox = _basketKey.currentContext!.findRenderObject() as RenderBox;
    if (!itemRenderBox.hasSize || !basketRenderBox.hasSize) return;

    final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    final basketPosition = basketRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
        final tween = Tween<Offset>(begin: itemPosition, end: Offset(basketPosition.dx + 20, basketPosition.dy + 10)).animate(animation);

        String? imageUrl;
        if(product.variants.isNotEmpty && product.variants.first.imageUrls.isNotEmpty) {
          imageUrl = product.variants.first.imageUrls.first;
        }

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) => Positioned(
            left: tween.value.dx,
            top: tween.value.dy,
            child: Opacity(
              opacity: 1.0 - (_animationController.value * 0.5),
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: (imageUrl != null && imageUrl.startsWith('http')) ? CachedNetworkImageProvider(imageUrl) : null,
                  child: (imageUrl == null || !imageUrl.startsWith('http')) ? const Icon(Icons.image, size: 15) : null,
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().whenComplete(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.reset();
    });
  }

  Future<void> _addToCart(ProductEntity product) async {
    if (!mounted) return;

    // --- Immediately disable the button for this product ---
    ref.read(addingToCartProvider.notifier).state = product.id;

    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Please log in to add items to your cart.')));
      ref.read(addingToCartProvider.notifier).state = null; // Re-enable on failure
      return;
    }

    try {
      final selectedVariant = product.variants.firstWhere((v) => v.quantity > 0, orElse: () => product.variants.first);

      final cartItem = CartItemEntity(
        id: '', userId: currentUser.id, productId: product.id,
        productTitle: product.title,
        variantSize: selectedVariant.size,
        variantColorName: describeEnum(selectedVariant.color), // Use describeEnum
        variantPrice: selectedVariant.price,
        variantImageUrl: selectedVariant.imageUrls.isNotEmpty ? selectedVariant.imageUrls.first : null,
        quantity: 1,
      );

      await ref.read(cartNotifierProvider.notifier).addToCart(cartItem);

      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('${product.title} added to cart!'),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Failed to add item: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      // --- Re-enable the button after a delay ---
      await Future.delayed(const Duration(milliseconds: 700)); // Should match animation duration
      if (mounted) {
        if (ref.read(addingToCartProvider) == product.id) {
          ref.read(addingToCartProvider.notifier).state = null;
        }
      }
    }
  }

  void _onViewBasket() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8, minChildSize: 0.4, maxChildSize: 0.95,
        builder: (_, controller) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: CartPage(scrollController: controller),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchNotifierProvider);
    ref.listen<CartState>(cartNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (message) {
          final currentUser = ref.read(currentUserProvider);
          if (currentUser != null) {
            ref.invalidate(cartItemsStreamProvider(currentUser.id));
          }
        },
        orElse: () {},
      );
    });

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              const ProductSearchBar(),
              Expanded(
                child: searchState.when(
                  initial: () => _buildMainProductGrid(),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (_, products) => SearchResultsList(products: products),
                  error: (message) => Center(child: Text('Search failed: $message')),
                ),
              ),
            ],
          ),
          FloatingBasketView(
            basketKey: _basketKey,
            onViewBasket: _onViewBasket,
          ),
        ],
      ),
    );
  }

  Widget _buildMainProductGrid() {
    final productsState = ref.watch(productsStreamProvider);
    return productsState.when(
      data: (products) => products.isEmpty
          ? const Center(child: Text('No products found.'))
          : ProductGrid(products: products),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Failed to load products: $e')),
    );
  }
}