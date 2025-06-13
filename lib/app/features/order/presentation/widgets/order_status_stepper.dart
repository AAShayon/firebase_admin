// lib/app/features/order/presentation/widgets/order_status_stepper.dart
import 'package:flutter/material.dart';
import '../../../../core/helpers/enums.dart';

class OrderStatusStepper extends StatelessWidget {
  final OrderStatus currentStatus;

  const OrderStatusStepper({
    super.key,
    required this.currentStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Stepper(
      currentStep: currentStatus.index,
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: OrderStatus.values.map((status) {
        return Step(
          title: Text(_getStatusTitle(status)),
          subtitle: Text(_getStatusSubtitle(status)),
          content: const SizedBox.shrink(),
          isActive: currentStatus.index >= status.index,
          state: _getStepState(currentStatus, status),
        );
      }).toList(),
    );
  }

  String _getStatusTitle(OrderStatus status) {
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
    }
  }

  String _getStatusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Waiting for admin confirmation';
      case OrderStatus.accepted:
        return 'Order has been accepted';
      case OrderStatus.packaging:
        return 'Preparing your items';
      case OrderStatus.readyForDelivery:
        return 'Ready to be shipped';
      case OrderStatus.shipping:
        return 'On the way to you';
      case OrderStatus.completed:
        return 'Successfully delivered';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }

  StepState _getStepState(OrderStatus currentStatus, OrderStatus stepStatus) {
    if (currentStatus.index > stepStatus.index) {
      return StepState.complete;
    } else if (currentStatus.index == stepStatus.index) {
      return StepState.indexed;
    } else {
      return StepState.disabled;
    }
  }
}