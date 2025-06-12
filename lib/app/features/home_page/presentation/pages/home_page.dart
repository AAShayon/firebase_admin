import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

typedef RunAnimationCallback = void Function(GlobalKey, ProductEntity);

final homeAnimationProvider = StateProvider<RunAnimationCallback?>((ref) => null);

final addingToCartProvider = StateProvider<String?>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with SingleTickerProviderStateMixin {
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
      // <<< CHANGE 1: The function passed to the provider is now our new handler
      ref.read(homeAnimationProvider.notifier).state = _initiateAddToCartAndAnimation;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // <<< CHANGE 2: THIS IS THE NEW HANDLER FUNCTION. It replaces the old `runAnimation` as the main entry point.
  /// This function handles the entire process: it immediately starts the
  /// cart logic and then conditionally triggers the visual animation.
  void _initiateAddToCartAndAnimation(GlobalKey itemKey, ProductEntity product) {
    // Step 1: Immediately start the core logic. This is the most important part.
    // This ensures the item is added regardless of whether the animation can run.
    _addToCart(product);

    // Step 2: Attempt to run the animation.
    // The check for the basket's context is now inside _runAnimation.
    _runAnimation(itemKey, product);
  }


  // <<< CHANGE 3: The animation function is now purely visual.
  // It no longer contains any business logic.
  void _runAnimation(GlobalKey itemKey, ProductEntity product) {
    // This guard clause is now perfect. If the basket isn't visible,
    // we just exit, but the _addToCart logic has already been fired.
    if (itemKey.currentContext == null || _basketKey.currentContext == null) return;

    final itemRenderBox = itemKey.currentContext!.findRenderObject() as RenderBox;
    final basketRenderBox = _basketKey.currentContext!.findRenderObject() as RenderBox;
    final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    final basketPosition = basketRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
        final tween = Tween<Offset>(
          begin: itemPosition,
          end: Offset(basketPosition.dx + 20, basketPosition.dy + 10),
        ).animate(animation);

        return AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Positioned(
              left: tween.value.dx,
              top: tween.value.dy,
              child: Opacity(
                opacity: 1.0 - _animationController.value,
                child: Material(
                  color: Colors.transparent,
                  child: CircleAvatar(
                    radius: 15,
                    backgroundImage: NetworkImage(product.variants.first.imageUrls.first),
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().whenComplete(() {
      // <<< CHANGE 4: The _addToCart call is REMOVED from here.
      // It's already been called.
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.reset();
    });
  }

  // This function is now perfect as-is.
  Future<void> _addToCart(ProductEntity product) async {
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    ref.read(addingToCartProvider.notifier).state = product.id;

    try {
      final selectedVariant = product.variants.first;
      final cartItem = CartItemEntity(
        id: '',
        userId: currentUser.id,
        productId: product.id,
        productTitle: product.title,
        variantSize: selectedVariant.size,
        variantColorName: selectedVariant.color.name,
        variantPrice: selectedVariant.price,
        variantImageUrl: selectedVariant.imageUrls.isNotEmpty
            ? selectedVariant.imageUrls.first
            : null,
        quantity: 1,
      );

      await ref.read(cartNotifierProvider.notifier).addToCart(cartItem);

      if(!mounted) return;

      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${product.title} added to cart!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 1),
        ),
      );


    } catch (e) {
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Failed to add item: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ref.read(addingToCartProvider.notifier).state = null;
        }
      });
    }
  }

  void _onViewBasket() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.4,
        maxChildSize: 0.95,
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
    // The invalidate logic here is not strictly necessary anymore because
    // _addToCart now directly calls the notifier, but it's good practice
    // to keep it as a fallback or for other cart actions.
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