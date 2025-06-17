// import 'package:carousel_slider/carousel_controller.dart';
// import 'package:firebase_admin/app/core/utils/product_image_slider.dart';
// import 'package:flutter/material.dart';
//
//
// class CustomSliverAppBar extends StatelessWidget {
//   final List<String> imageUrls;
//   final CarouselSliderController controller;
//   final Function(int) onImageChanged;
//   final VoidCallback onWishlistPressed;
//   final bool isWishlisted;
//
//   const CustomSliverAppBar({
//     super.key,
//     required this.imageUrls,
//     required this.controller,
//     required this.onImageChanged,
//     required this.onWishlistPressed,
//     required this.isWishlisted,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SliverAppBar(
//       pinned: true,
//       expandedHeight: 350.0,
//       flexibleSpace: FlexibleSpaceBar(
//         background: ProductImageSlider(
//           imageUrls: imageUrls,
//           controller: controller,
//           onImageChanged: onImageChanged,
//           onPressed: onWishlistPressed,
//           isWishlisted: isWishlisted,
//         ),
//       ),
//     );
//   }
// }