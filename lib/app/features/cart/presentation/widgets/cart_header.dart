import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CartHeader extends StatelessWidget {
  final bool isFromLanding;
  final VoidCallback? onPressed;
  const CartHeader({super.key,required this.isFromLanding,this.onPressed});

  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding:  EdgeInsets.only(top: 20),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.sp,
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isFromLanding?  IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ):SizedBox.shrink(),
             Center(
               child: Text(
                 'My Cart',
                 style: TextStyle(
                   fontSize: 20,
                   fontWeight: FontWeight.bold,
                 ),
               ),
             ),
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
              tooltip: 'Clear Cart',
              onPressed: onPressed,
            ),
          ],
        ),
      );
  }
}