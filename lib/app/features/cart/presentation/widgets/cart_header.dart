import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartHeader extends StatelessWidget {
  final bool isFromLanding;
  const CartHeader({super.key, required this.isFromLanding});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
      child: Row(
        children: [
          // Back Button
        isFromLanding?  IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ):SizedBox.shrink(),
          // Title
          const Expanded(
            child: Text(
              'My Cart',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Spacer to keep title centered
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}