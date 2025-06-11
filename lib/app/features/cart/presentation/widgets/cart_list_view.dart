import 'package:flutter/material.dart';
import '../../domain/entities/cart_item_entity.dart';
import 'cart_item_card.dart';

class CartListView extends StatelessWidget {
  final List<CartItemEntity> items;
  final String userId;
  final ScrollController? controller;

  const CartListView({
    super.key,
    required this.items,
    required this.userId,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: controller, // Use the controller for scrolling within the sheet
      padding: const EdgeInsets.only(bottom: 200), // Prevent overlap with summary
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return CartItemCard(item: item, userId: userId);
      },
    );
  }
}