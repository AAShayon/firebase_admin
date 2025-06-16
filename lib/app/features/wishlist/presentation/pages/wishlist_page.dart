import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

import '../providers/wishlist_providers.dart';
import '../widgets/wishlist_item_card.dart'; // We'll create a dedicated card for this page

class WishlistPage extends ConsumerWidget {
  const WishlistPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider)?.id;
    if (userId == null) {
      return Scaffold(
        body: const Center(child: Text('Please log in to see your wishlist.')),
      );
    }

    // --- THIS IS THE FIX ---
    // Watch the correct provider: wishlistItemsProvider
    final wishlistItemsAsync = ref.watch(wishlistItemsProvider(userId));

    return Scaffold(
      appBar: AppBar(title: const Text('My Wishlist')),
      body: wishlistItemsAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your wishlist is empty.', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 8),
                  Text('Tap the heart on products to save them here.', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          // Using a ListView is better for this page than a GridView
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return WishlistItemCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading wishlist: $e')),
      ),
    );
  }
}