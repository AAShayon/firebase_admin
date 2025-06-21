import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

// --- CORE & FEATURE IMPORTS ---
import '../../../../core/routes/app_router.dart';
import '../../../../core/utils/price_calculator.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../cart/presentation/pages/cart_page.dart';
import '../../../cart/presentation/providers/cart_notifier_provider.dart';
import '../../../cart/presentation/providers/cart_providers.dart';
import '../../../cart/presentation/providers/cart_state.dart';
import '../../../cart/presentation/widgets/floating_basket_view.dart';
import '../../../products/presentation/providers/product_providers.dart';
import '../../../products/presentation/widgets/product_grid.dart';
import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../promotions/presentation/providers/promotion_providers.dart';
import '../../../promotions/presentation/widgets/promotion_banner_card.dart';
import '../../../promotions/presentation/widgets/promotional_products_section.dart';
import '../../../search/presentation/providers/search_notifier_provider.dart';
import '../../../search/presentation/widgets/product_search_bar.dart';
import '../../../search/presentation/widgets/search_results_list.dart';
import '../../../shared/domain/entities/product_entity.dart';
import '../widgets/category_pills.dart';

// --- PAGE-SPECIFIC PROVIDERS ---
typedef RunAnimationCallback = void Function(GlobalKey, ProductEntity,PromotionEntity?);
final homeAnimationProvider = StateProvider<RunAnimationCallback?>((ref) => null);
final addingToCartProvider = StateProvider<String?>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> with SingleTickerProviderStateMixin {
  // --- STATE AND CONTROLLERS ---
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

  // --- LOGIC METHODS ---

  void _initiateAddToCartAndAnimation(GlobalKey itemKey, ProductEntity product,PromotionEntity? promotion) {
    _addToCart(product,promotion);
    _runAnimation(itemKey, product);
  }

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

  Future<void> _addToCart(ProductEntity product,PromotionEntity? promotion) async {
    if (!mounted) return;
    ref.read(addingToCartProvider.notifier).state = product.id;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final currentUser = ref.read(currentUserProvider);

    if (currentUser == null) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Please log in to add items to your cart.')));
      ref.read(addingToCartProvider.notifier).state = null;
      return;
    }

    try {
      final selectedVariant = product.variants.firstWhere((v) => v.quantity > 0, orElse: () => product.variants.first);
      final finalPrice = calculateFinalPrice(
        product: product,
        variant: selectedVariant,
        promotion: promotion,
      );

      final cartItem = CartItemEntity(
        id: '', userId: currentUser.id, productId: product.id,
        productTitle: product.title,
        variantSize: selectedVariant.size,
        variantColorName: describeEnum(selectedVariant.color),
        variantPrice: finalPrice,
        variantImageUrl: selectedVariant.imageUrls.isNotEmpty ? selectedVariant.imageUrls.first : null,
        quantity: 1,
      );
      await ref.read(cartNotifierProvider.notifier).addToCart(cartItem);
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(
          content: Text('${product.title} added to cart!'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ));
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Failed to add item: ${e.toString()}'), backgroundColor: Colors.red));
      }
    } finally {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted && ref.read(addingToCartProvider) == product.id) {
        ref.read(addingToCartProvider.notifier).state = null;
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
                  initial: () => _buildMainContent(),
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

  Widget _buildMainContent() {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(productsStreamProvider);
        ref.invalidate(activePromotionsStreamProvider);
      },
      child: CustomScrollView(
        slivers: [

          _buildPromoBannerSliver(),

          _buildPromoProductsSliver(),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: CategoryPills(),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text("For You", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
          ),
          _buildProductGridSliver(),
        ],
      ),
    );
  }

  Widget _buildPromoBannerSliver() {
    final activePromosAsync = ref.watch(activePromotionsStreamProvider);
    return SliverToBoxAdapter(
      child: activePromosAsync.when(
        data: (promos) => promos.isEmpty
            ? const SizedBox.shrink()
            : Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: PromotionBannerCard(
            promotion: promos.first,
            onViewAll: () => context.pushNamed(AppRoutes.promotionDetail, extra: promos.first),
          ),
        ),
        loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
        error: (e, s) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildPromoProductsSliver() {
    final activePromosAsync = ref.watch(activePromotionsStreamProvider);
    final productsState = ref.watch(productsStreamProvider);
    return SliverToBoxAdapter(
      child: activePromosAsync.when(
        data: (promos) {
          if (promos.isEmpty || promos.first.scope != PromotionScope.specificProducts) {
            return const SizedBox.shrink();
          }
          final bannerPromo = promos.first;
          return productsState.when(
            data: (allProducts) {
              final promoProducts = allProducts.where((p) => bannerPromo.productIds.contains(p.id)).toList();
              if (promoProducts.isEmpty) return const SizedBox.shrink();
              return PromotionalProductsSection(promotion: bannerPromo, products: promoProducts);
            },
            loading: () => const SizedBox.shrink(),
            error: (e,s) => const SizedBox.shrink(),
          );
        },
        loading: () => const SizedBox(height: 280, child: Center(child: CircularProgressIndicator())),
        error: (e,s) => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildProductGridSliver() {
    final productsState = ref.watch(productsStreamProvider);

    // Get the list of active promotions.
    final activePromos = ref.watch(activePromotionsStreamProvider).valueOrNull;

    // --- THIS IS THE FIX ---
    // Use the `firstWhereOrNull` extension method. It safely returns null if no match is found.
    final PromotionEntity? activePromo = activePromos?.firstWhereOrNull((p) => p.isActive);

    return productsState.when(
      data: (products) {
        if (products.isEmpty) {
          return const SliverFillRemaining(child: Center(child: Text('No products found.')));
        }
        // Pass the potentially null promotion to the grid.
        return ProductGrid(products: products, promotion: activePromo);
      },
      loading: () => const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      error: (e, _) => SliverFillRemaining(child: Center(child: Text('Failed to load products: $e'))),
    );
  }
}