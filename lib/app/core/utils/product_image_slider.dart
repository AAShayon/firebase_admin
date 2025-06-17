import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

// In ProductImageSlider widget
class ProductImageSlider extends StatefulWidget {
  final List<String> imageUrls;
  final CarouselSliderController? controller;
  final ValueChanged<int> onImageChanged;
  final VoidCallback? onPressed;
  final bool isWishlisted;


  const ProductImageSlider({
    super.key,
    this.controller,
    required this.imageUrls,
    required this.onImageChanged,
    this.onPressed,
    required this.isWishlisted,
  });

  @override
  State<ProductImageSlider> createState() => _ProductImageSliderState();
}

class _ProductImageSliderState extends State<ProductImageSlider> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 12,
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
          ),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          carouselController: widget.controller,
          options: CarouselOptions(
            aspectRatio: 16 / 12,
            viewportFraction: 1.0,
            enableInfiniteScroll: widget.imageUrls.length > 1,
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
              widget.onImageChanged(index);  // Call the callback when image is changed
            },
          ),
          items: widget.imageUrls.map((url) {
            return Builder(
              builder: (BuildContext context) {
                return CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (context, url) => Container(color: Colors.grey[200]),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                );
              },
            );
          }).toList(),
        ),
        if (widget.imageUrls.length > 1)
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.imageUrls.length, (index) {
                return Container(
                  width: 8.0,
                  height: 8.0,
                  margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black)
                        .withOpacity(_currentIndex == index ? 0.9 : 0.4),
                  ),
                );
              }),
            ),
          ),
        Positioned(bottom: 10,right: 10,child:    OutlinedButton(
          onPressed: widget.onPressed,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(7),
            shape: const CircleBorder(),
          ),
          child:  Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: widget.isWishlisted ? Colors.pink.shade300 : Theme.of(context).colorScheme.secondary.withOpacity(0.8),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: Icon(
             widget.isWishlisted ? Icons.favorite : Icons.favorite_border,
              color: Colors.white,
              size: 22,
            ),
          ),
        ),)
      ],
    );
  }
}
