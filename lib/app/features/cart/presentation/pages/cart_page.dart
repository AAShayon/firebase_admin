// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../auth/domain/entities/user_entity.dart';
// import '../../../auth/presentation/providers/auth_providers.dart';
// import '../providers/cart_notifier_provider.dart';
// import '../providers/cart_providers.dart';
// import '../providers/cart_state.dart';
// import '../widgets/cart_list_view.dart';
// import '../widgets/cart_summary.dart';
// import '../widgets/empty_cart_view.dart';
//
// class CartPage extends ConsumerWidget {
//   const CartPage({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // CORRECTED: Watch the new currentUserProvider
//     final currentUser = ref.watch(currentUserProvider);
//
//     // Listen for state changes from the CartNotifier to show SnackBars for feedback.
//     ref.listen<CartState>(cartNotifierProvider, (_, state) {
//       state.whenOrNull(
//         success: (message) => ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(SnackBar(content: Text(message))),
//         error: (message) => ScaffoldMessenger.of(context)
//           ..hideCurrentSnackBar()
//           ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red)),
//       );
//     });
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('My Cart'),
//         centerTitle: true,
//         actions: [
//           // Clear cart button logic is now much simpler
//           if (currentUser != null)
//             Consumer(builder: (context, ref, _) {
//               final cartItems = ref.watch(cartItemsStreamProvider(currentUser.id));
//               return cartItems.maybeWhen(
//                 data: (items) => items.isNotEmpty
//                     ? IconButton(
//                   icon: const Icon(Icons.delete_sweep_outlined),
//                   tooltip: 'Clear Cart',
//                   onPressed: () => _showClearCartDialog(context, ref, currentUser.id),
//                 )
//                     : const SizedBox.shrink(),
//                 orElse: () => const SizedBox.shrink(),
//               );
//             }),
//         ],
//       ),
//       // The main body now checks the currentUser state
//       body: _buildBody(context, ref, currentUser),
//     );
//   }
//
//   // Helper method to build the body based on auth state
//   Widget _buildBody(BuildContext context, WidgetRef ref, UserEntity? user) {
//     if (user == null) {
//       // User is not logged in or auth state is loading
//       return const Center(child: Text('Please log in to see your cart.'));
//     }
//
//     // User is logged in, so we can watch their cart stream
//     final cartStream = ref.watch(cartItemsStreamProvider(user.id));
//
//     return cartStream.when(
//       data: (items) {
//         if (items.isEmpty) {
//           return const EmptyCartView();
//         }
//         return Stack(
//           children: [
//             CartListView(items: items, userId: user.id),
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: CartSummary(items: items),
//             ),
//           ],
//         );
//       },
//       loading: () => const Center(child: CircularProgressIndicator()),
//       error: (error, stack) => Center(child: Text('Error loading cart: ${error.toString()}')),
//     );
//   }
//
//   // Helper method for the confirmation dialog
//   void _showClearCartDialog(BuildContext context, WidgetRef ref, String userId) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         title: const Text('Clear Cart?'),
//         content: const Text('Are you sure you want to remove all items from your cart?'),
//         actions: [
//           TextButton(
//             child: const Text('Cancel'),
//             onPressed: () => Navigator.of(ctx).pop(),
//           ),
//           TextButton(
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Clear'),
//             onPressed: () {
//               ref.read(cartNotifierProvider.notifier).clearCart(userId);
//               Navigator.of(ctx).pop();
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../providers/cart_notifier_provider.dart';
import '../providers/cart_providers.dart';
import '../providers/cart_state.dart';
import '../widgets/cart_header.dart'; // Import the new header
import '../widgets/cart_list_view.dart';
import '../widgets/cart_summary.dart';
import '../widgets/empty_cart_view.dart';

class CartPage extends ConsumerWidget {
  final bool isFromLanding;
  const CartPage({super.key,this.isFromLanding=true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    ref.listen<CartState>(cartNotifierProvider, (_, state) {
      state.whenOrNull(
        success: (message) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message))),
        error: (message) => ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red)),
      );
    });

    return Scaffold(
      // REMOVED the appBar property
      // Use SafeArea to avoid content overlapping with the status bar
      body: SafeArea(
        child: _buildBody(context, ref, currentUser),
      ),
    );
  }

  // Helper method to build the body
  Widget _buildBody(BuildContext context, WidgetRef ref, UserEntity? user) {
    if (user == null) {
      // Handle logged out or loading state
      final authState = ref.watch(authNotifierProvider);
      return authState.maybeWhen(
          loading: () => const Center(child: CircularProgressIndicator()),
          orElse: () => Column(
            children: [
               CartHeader(isFromLanding: isFromLanding,),
              const Expanded(
                child: Center(
                  child: Text(
                    'Please log in to view your cart.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ));
    }

    // User is logged in, so we can watch their cart stream
    final cartStream = ref.watch(cartItemsStreamProvider(user.id));

    return cartStream.when(
      data: (items) {
        if (items.isEmpty) {
          // Show header and empty view
          return Column(
            children: [
              CartHeader(isFromLanding: isFromLanding,),
              const Expanded(child: EmptyCartView()),
            ],
          );
        }

        // This is the main view with items
        return Stack(
          children: [
            // The main content list, with padding at the top for the header
            Padding(
              padding: const EdgeInsets.only(top: 60.0), // Space for the header
              child: CartListView(items: items, userId: user.id),
            ),

            // The sticky cart summary at the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartSummary(items: items),
            ),

            // The custom header at the top
             Positioned(
              top: 0,
              left: 0,
              right: 0,
              child:  CartHeader(isFromLanding: isFromLanding,),
            ),

            // --- CLEAR CART BUTTON MOVED HERE ---
            // Positioned at the top right of the screen
            Positioned(
              top: 12,
              right: 12,
              child: Consumer(builder: (context, ref, _) {
                // We don't need to re-watch the stream here as it's already watched above.
                // We can just use the 'items' variable.
                return items.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
                  tooltip: 'Clear Cart',
                  onPressed: () => _showClearCartDialog(context, ref, user.id),
                )
                    : const SizedBox.shrink();
              }),
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading cart: ${error.toString()}')),
    );
  }

  // Helper method for the confirmation dialog (no changes needed)
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