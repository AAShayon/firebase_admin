import 'package:flutter/material.dart';

/// A reusable card widget with a consistent shadow, border radius, and padding.
class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        // Use the app's default card theme color unless overridden
        color: color ?? Theme.of(context).cardColor,
        // A subtle shadow for a modern look
        elevation: 1,
        // Consistent margin for spacing between cards
        margin: margin ?? const EdgeInsets.symmetric(vertical: 4.0),
        shape: RoundedRectangleBorder(
          // Softly rounded corners
          borderRadius: BorderRadius.circular(12.0),
          // Optional: add a subtle border
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
        // Ensures the content inside is clipped to the rounded corners
        clipBehavior: Clip.antiAlias,
        child: Padding(
          // Default padding that can be overridden
          padding: padding ?? const EdgeInsets.all(16.0),
          child: child,
        ),
      ),
    );
  }
}