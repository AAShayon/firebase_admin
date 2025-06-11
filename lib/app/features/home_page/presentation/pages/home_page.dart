import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../cart/presentation/widgets/floating_basket_view.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../search/presentation/providers/search_notifier_provider.dart';
import '../../../search/presentation/widgets/product_search_bar.dart';
import '../../../search/presentation/widgets/search_results_list.dart';
import '../../../shared/domain/entities/product_entity.dart';


typedef RunAnimationCallback = void Function(GlobalKey, ProductEntity);


final homeAnimationProvider = StateProvider<RunAnimationCallback?>((ref) => null);


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

    // 3. Set the provider's value to our actual runAnimation function
    // This makes the function available to any widget that reads the provider.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeAnimationProvider.notifier).state = runAnimation;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void runAnimation(GlobalKey itemKey, ProductEntity product) {
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
      _addToCart(product);
      _overlayEntry?.remove();
      _overlayEntry = null;
      _animationController.reset();
    });
  }

  void _addToCart(ProductEntity product) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add items to your cart.')),
      );
      return;
    }

    final selectedVariant = product.variants.first;
    final cartItem = CartItemEntity(
      id: '',
      userId: currentUser.id,
      productId: product.id,
      productTitle: product.title,
      variantSize: selectedVariant.size,
      variantColorName: selectedVariant.color.name,
      variantPrice: selectedVariant.price,
      variantImageUrl: selectedVariant.imageUrls.isNotEmpty ? selectedVariant.imageUrls.first : null,
      quantity: 1,
    );
    ref.read(cartNotifierProvider.notifier).addToCart(cartItem);
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