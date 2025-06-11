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

  Color _getColorFromString(String colorStr) {
    // Normalize the string to lower case for case-insensitive matching.
    final lowerCaseColor = colorStr.toLowerCase();

    switch (lowerCaseColor) {
    // Blacks & Dark Greys
      case 'black':
      case 'charcoal':
      case 'graphite':
      case 'space gray':
      case 'dark grey':
      case 'black/red': // Use first color
        return Colors.black87;

    // Whites & Off-Whites
      case 'white':
      case 'ivory':
      case 'champagne':
      case 'cream':
        return Colors.white;

    // Greys & Silvers
      case 'grey':
      case 'heather grey':
      case 'grey stripe':
      case 'grey/yellow': // Use first color
        return Colors.grey;
      case 'silver':
      case 'satin nickel':
      case 'brushed metal':
        return Colors.grey.shade400;

    // Blues
      case 'blue':
      case 'light blue':
      case 'navy':
      case 'navy stripe':
      case 'navy blue':
      case 'blue/gold': // Use first color
      case 'blue/white check': // Use first color
        return Colors.blue.shade700;

    // Greens
      case 'green':
      case 'olive green':
      case 'camo': // Representative color
      case 'olive/black': // Use first color
        return Colors.green.shade800;
      case 'teal':
        return Colors.teal;

    // Reds
      case 'red':
      case 'empire red':
      case 'red/black check': // Use first color
        return Colors.red.shade700;

    // Browns & Tans
      case 'khaki':
      case 'walnut':
      case 'leopard print': // Representative color
      case 'silver/brown': // Use second, more distinct color
        return Colors.brown.shade600;

    // Oranges
      case 'orange':
        return Colors.orange;
      case 'terracotta':
        return Colors.deepOrange.shade300;

    // Pinks
      case 'pink':
      case 'dusty rose':
      case 'rose gold':
        return Colors.pink.shade200;

    // Yellows
      case 'yellow':
        return Colors.yellow.shade600;

    // Special Cases
      case 'multi-color':
        return Colors.purple; // Use a distinct color to represent variety

    // Fallback for any unhandled colors
      default:
        return Colors.grey.shade500;
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