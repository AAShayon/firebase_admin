import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
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

  const CartPage({super.key, this.scrollController,this.isFromLanding=true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

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

    // We use a Container to give the bottom sheet a background color.
    return Scaffold(
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: _buildBody(context, ref, currentUser),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, UserEntity? user) {
    if (user == null) {
      return Column(
        children: [
           CartHeader(isFromLanding: isFromLanding,),
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
          return  Column(
            children: [
              CartHeader(isFromLanding: isFromLanding,),
              Expanded(child: EmptyCartView()),
            ],
          );
        }

        return Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 60.0),
              child: CartListView(
                items: items,
                userId: user.id,
                controller: scrollController,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CartSummary(items: items),
            ),
             Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: CartHeader(isFromLanding: isFromLanding,onPressed: () => _showClearCartDialog(context, ref, user.id),),
            ),
            // Positioned(
            //   top: 2,
            //   right: 12,
            //   child: IconButton(
            //     icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            //     tooltip: 'Clear Cart',
            //     onPressed: () => _showClearCartDialog(context, ref, user.id),
            //   ),
            // ),
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