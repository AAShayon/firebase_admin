import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';

// --- CORE & FEATURE IMPORTS ---
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../../../cart/presentation/widgets/floating_basket_view.dart';
import '../../../search/presentation/providers/search_notifier_provider.dart';
import '../../../search/presentation/widgets/product_search_bar.dart';
import '../../../search/presentation/widgets/search_results_list.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../providers/home_page_notifier_provider.dart';
import '../providers/home_page_providers.dart';
import '../widgets/home_content_view.dart';


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

    // Provide the animation function to the rest of the app via the provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(homeAnimationProvider.notifier).state = _initiateAddToCartAndAnimation;
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _overlayEntry?.remove();
    super.dispose();
  }

  /// The page is now only responsible for the VISUAL animation part.
  void _initiateAddToCartAndAnimation(GlobalKey itemKey, ProductEntity product, PromotionEntity? promotion) {
    // 1. Delegate the LOGICAL part (updating state, talking to cart) to the notifier.
    ref.read(homePageNotifierProvider.notifier).addToCart(product, promotion, context);

    // 2. Run the VISUAL animation.
    _runAnimation(itemKey, product);
  }

  /// This animation logic remains here as it is purely a View concern.
  /// It needs access to the TickerProvider (`this`) and the Overlay.
  void _runAnimation(GlobalKey itemKey, ProductEntity product) {
    if (!mounted || itemKey.currentContext == null || _basketKey.currentContext == null) return;

    final itemRenderBox = itemKey.currentContext!.findRenderObject() as RenderBox?;
    final basketRenderBox = _basketKey.currentContext!.findRenderObject() as RenderBox?;

    if (itemRenderBox == null || basketRenderBox == null || !itemRenderBox.hasSize || !basketRenderBox.hasSize) return;

    final itemPosition = itemRenderBox.localToGlobal(Offset.zero);
    final basketPosition = basketRenderBox.localToGlobal(Offset.zero);

    _overlayEntry?.remove();
    _overlayEntry = OverlayEntry(
      builder: (context) {
        final animation = CurvedAnimation(parent: _animationController, curve: Curves.easeInOutCubic);
        final tween = Tween<Offset>(begin: itemPosition, end: Offset(basketPosition.dx + 20, basketPosition.dy + 10)).animate(animation);
        final firstImageUrl = product.variants.isNotEmpty && product.variants.first.imageUrls.isNotEmpty ? product.variants.first.imageUrls.first : null;

        return AnimatedBuilder(
          animation: _animationController,
          builder: (_, child) => Positioned(
            left: tween.value.dx, top: tween.value.dy,
            child: Opacity(
              opacity: 1.0 - (_animationController.value * 0.5),
              child: Material(
                color: Colors.transparent,
                child: CircleAvatar(
                  radius: 15,
                  backgroundImage: (firstImageUrl != null && firstImageUrl.startsWith('http')) ? CachedNetworkImageProvider(firstImageUrl) : null,
                  child: (firstImageUrl == null || !firstImageUrl.startsWith('http')) ? const Icon(Icons.shopping_bag, size: 15, color: Colors.white) : null,
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

  /// This view logic for showing the cart is fine to keep here.
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

    // Listen to cart state to invalidate the cart items stream.
    ref.listen<CartState>(cartNotifierProvider, (previous, next) {
      next.maybeWhen(
        success: (_) {
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
                  initial: () => const HomeContentView(), // DELEGATE UI building
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
}