import 'package:flutter/material.dart';

class ColorChip extends StatelessWidget {
  final String colorString;
  final bool isSelected;
  final VoidCallback onTap;

  const ColorChip({
    super.key,
    required this.colorString,
    required this.isSelected,
    required this.onTap,
  });

  // Helper function to convert a string name to a Color object
  Color _getColorFromString(String colorStr) {
    final lowerCaseColor = colorStr.toLowerCase();
    switch (lowerCaseColor) {
      case 'charcoal black':
      case 'black':
        return Colors.black;
      case 'heather grey':
        return Colors.grey.shade400;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'silver':
        return Colors.grey.shade300;
    // Add more color mappings as needed
      default:
        return Colors.grey; // Fallback color
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorFromString(colorString);
    final hasBorder = color == Colors.white;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(1, 2),
            )
          ],
        ),
        // Padding to make the border appear on the "outside"
        padding: const EdgeInsets.all(2.0),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: hasBorder ? Border.all(color: Colors.grey.shade400, width: 1) : null,
          ),
          child: isSelected
              ? Icon(
            Icons.check,
            color: color.computeLuminance() > 0.5 ? Colors.black : Colors.white,
            size: 20,
          )
              : null,
        ),
      ),
    );
  }
}