import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Core and Feature imports
import '../../../../core/routes/app_router.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../checkout/presentation/providers/checkout_notifier_provider.dart';
import '../../../user_profile/presentation/providers/user_profile_providers.dart';
import '../providers/cart_notifier_provider.dart';
import '../providers/cart_providers.dart';
import '../providers/cart_state.dart';
import '../widgets/cart_header.dart';
import '../widgets/cart_list_view.dart';
import '../widgets/cart_summary.dart';
import '../widgets/empty_cart_view.dart';

class CartPage extends ConsumerWidget {
  final ScrollController? scrollController;
  final bool isFromLanding;

  const CartPage({super.key, this.scrollController, this.isFromLanding = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    // Listener for one-time actions like showing a snackbar
    ref.listen<CartState>(cartNotifierProvider, (_, state) {
      state.whenOrNull(
        success: (message) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 2))),
        error: (message) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red)),
      );
    });

    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _buildBody(context, ref, currentUser),
      ),
    );
  }

  // --- THIS IS THE NEW "PROCEED TO CHECKOUT" LOGIC ---
  Future<void> _proceedToCheckout(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final navigator = GoRouter.of(context);

    // 1. Get all necessary data first
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    final cartItems = ref.read(cartItemsStreamProvider(user.id)).value;
    if (cartItems == null || cartItems.isEmpty) {
      scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Your cart is empty.')));
      return;
    }

    try {
      // Show a loading dialog while we prepare the next screen's state
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const PopScope(
          canPop: false,
          child: Center(child: CircularProgressIndicator()),
        ),
      );

      // 2. Await the user's profile to get their addresses
      final profile = await ref.read(userProfileStreamProvider(user.id).future);

      // Guard against the widget being disposed during the async call
      if (!context.mounted) return;

      // Dismiss the loading indicator
      Navigator.of(context, rootNavigator: true).pop();

      if (profile.addresses.isEmpty) {
        scaffoldMessenger.showSnackBar(const SnackBar(content: Text('Please add a shipping address to your profile first.')));
        navigator.pushNamed(AppRoutes.addAddress);
        return;
      }

      final defaultAddress = profile.addresses.firstWhere((a) => a.isDefault, orElse: () => profile.addresses.first);

      // 3. PREPARE THE CHECKOUT STATE by calling the initializer
      ref.read(checkoutNotifierProvider.notifier).initializeFromCart(
        cartItems: cartItems,
        defaultAddress: defaultAddress,
      );

      // 4. NAVIGATE LAST, only after the state is ready.
      navigator.pushNamed(AppRoutes.checkout);

    } catch (e) {
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop(); // Dismiss loading indicator on error
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red));
      }
    }
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, UserEntity? user) {
    if (user == null) {
      return Column(
        children: [
          CartHeader(isFromLanding: isFromLanding),
          Expanded(
            child: Center(
              child: ref.watch(authNotifierProvider).maybeWhen(
                loading: () => const CircularProgressIndicator(),
                orElse: () => const Text('Please log in to view your cart.', style: TextStyle(fontSize: 16)),
              ),
            ),
          ),
        ],
      );
    }

    final cartStream = ref.watch(cartItemsStreamProvider(user.id));
    return cartStream.when(
      data: (items) {
        if (items.isEmpty) {
          return Column(
            children: [
              CartHeader(isFromLanding: isFromLanding),
              const Expanded(child: EmptyCartView()),
            ],
          );
        }

        return Stack(
          children: [
            // The main list of cart items
            Padding(
              padding: const EdgeInsets.only(top: 80.0, bottom: 150.0), // Adjust bottom padding
              child: CartListView(
                items: items,
                userId: user.id,
                controller: scrollController,
              ),
            ),
            // The summary and checkout button at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartSummary(
                items: items,
                // Pass the new checkout function to the button
                onCheckout: () => _proceedToCheckout(context, ref),
              ),
            ),
            // The header at the top
            Positioned(
              top: 20,
              left: 0,
              right: 0,
              child: CartHeader(
                isFromLanding: isFromLanding,
                onPressed: () => _showClearCartDialog(context, ref, user.id),
              ),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error loading cart: ${error.toString()}')),
    );
  }

  void _showClearCartDialog(BuildContext context, WidgetRef ref, String userId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text('Are you sure you want to remove all items from your cart?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Clear'),
            onPressed: () {
              ref.read(cartNotifierProvider.notifier).clearCart(userId);
              Navigator.of(ctx).pop();
            },
          ),
        ],
      ),
    );
  }
}