import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProductImageSlider extends StatelessWidget {
  final List<String> imageUrls;
  final CarouselSliderController controller;
  final Function(int, CarouselPageChangedReason) onPageChanged;
  final bool isWishlisted;
  final VoidCallback onWishlistPressed;

  const ProductImageSlider({
    super.key,
    required this.imageUrls,
    required this.controller,
    required this.onPageChanged,
    required this.isWishlisted,
    required this.onWishlistPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300.0,
      pinned: true,
      floating: false,
      actions: [
        IconButton(
          icon: Icon(
            isWishlisted ? Icons.favorite : Icons.favorite_border,
            color: isWishlisted ? Colors.pink : Colors.white,
          ),
          onPressed: onWishlistPressed,
          style: IconButton.styleFrom(backgroundColor: Colors.black.withOpacity(0.4)),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: imageUrls.isNotEmpty
            ? CarouselSlider(
          carouselController: controller,
          options: CarouselOptions(
            height: 350.0,
            viewportFraction: 1.0,
            onPageChanged: onPageChanged,
          ),
          items: imageUrls.map((url) => CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            placeholder: (c,u) => const Center(child: CircularProgressIndicator()),
            errorWidget: (c,u,e) => const Icon(Icons.error),
          )).toList(),
        )
            : Container(color: Colors.grey, child: const Center(child: Icon(Icons.image_not_supported))),
      ),
    );
  }
}