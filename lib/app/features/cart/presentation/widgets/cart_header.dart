// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
//
// class CartHeader extends StatelessWidget {
//   final bool isFromLanding;
//   const CartHeader({super.key, required this.isFromLanding});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
//       child: Row(
//         children: [
//           // Back Button
//         isFromLanding?  IconButton(
//             icon: const Icon(Icons.arrow_back),
//             onPressed: () => context.pop(),
//           ):SizedBox.shrink(),
//           // Title
//           const Expanded(
//             child: Text(
//               'My Cart',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           // Spacer to keep title centered
//           const SizedBox(width: 48),
//         ],
//       ),
//     );
//   }
// }
///

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
        padding:  EdgeInsets.only(top: 15),
        child: Row(
          // crossAxisAlignment: CrossAxisAlignment.sp,
          // mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            isFromLanding?  IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ):SizedBox.shrink(),

            // isFromLanding?    Container(
            //   width: 40,
            //   height: 5,
            //   margin: const EdgeInsets.symmetric(vertical: 10),
            //   decoration: BoxDecoration(
            //     color: Colors.grey[300],
            //     borderRadius: BorderRadius.circular(12),
            //   ),
            // ):SizedBox.shrink(),
            // The rest of the header
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