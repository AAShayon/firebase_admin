import 'package:flutter/material.dart';

import '../../domain/entities/cart_item_entity.dart';
import 'cart_item_card.dart';

class CartListView extends StatelessWidget {
  final List<CartItemEntity> items;
  final String userId;

  const CartListView({
    super.key,
    required this.items,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 180), // Prevent overlap with summary
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemCard(item: item, userId: userId);
      },
    );
  }
}