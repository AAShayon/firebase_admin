import 'package:flutter/material.dart';
import '../../../../core/helpers/enums.dart'; // Make sure you have your OrderStatus enum here

/// A styled badge to visually represent the status of an order.
class OrderStatusBadge extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusBadge({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      // Use a helper method to get the appropriate icon
      avatar: Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status).withOpacity(0.8),
        size: 18,
      ),
      // Use a helper method to get the display text
      label: Text(
        _getStatusText(status),
        style: TextStyle(
          color: _getStatusColor(status).withOpacity(0.9),
          fontWeight: FontWeight.bold,
        ),
      ),
      // Use a helper method to get the background color
      backgroundColor: _getStatusColor(status).withOpacity(0.15),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(
          color: _getStatusColor(status).withOpacity(0.2),
        ),
      ),
    );
  }

  /// Returns a specific color based on the order status.
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.packaging:
        return Colors.cyan;
      case OrderStatus.readyForDelivery:
        return Colors.purple;
      case OrderStatus.shipping:
        return Colors.teal;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  /// Returns a display-friendly string for the order status.
  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.accepted:
        return 'Accepted';
      case OrderStatus.packaging:
        return 'Packaging';
      case OrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case OrderStatus.shipping:
        return 'Shipping';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }

  /// Returns a specific icon based on the order status.
  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.accepted:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.packaging:
        return Icons.inventory_2_outlined;
      case OrderStatus.readyForDelivery:
        return Icons.all_out_rounded;
      case OrderStatus.shipping:
        return Icons.local_shipping_outlined;
      case OrderStatus.completed:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}