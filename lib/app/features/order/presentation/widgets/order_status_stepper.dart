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
    // --- GRACEFUL HANDLING OF SPECIAL STATES ---
    // If the order is cancelled, show a special message instead of the stepper.
    if (currentStatus == OrderStatus.cancelled) {
      return const Center(
        child: ListTile(
          leading: Icon(Icons.cancel, color: Colors.red, size: 32),
          title: Text('Order Cancelled', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
          subtitle: Text('This order has been cancelled and will not proceed.'),
        ),
      );
    }
    // If the status is unknown, show a clear message instead of crashing.
    if (currentStatus == OrderStatus.unknown) {
      return const Center(
        child: ListTile(
          leading: Icon(Icons.help_outline, color: Colors.grey),
          title: Text('Status Unknown', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          subtitle: Text('The order status could not be determined.'),
        ),
      );
    }
    // --- END OF GRACEFUL HANDLING ---

    // Filter out the statuses we don't want to show in the linear stepper.
    final stepperStatuses = OrderStatus.values
        .where((s) => s != OrderStatus.unknown && s != OrderStatus.cancelled)
        .toList();

    int activeStep = stepperStatuses.indexOf(currentStatus);
    // If the current status somehow isn't in our list, default to the first step to prevent a crash.
    if (activeStep == -1) {
      activeStep = 0;
    }

    return Stepper(
      physics: const ClampingScrollPhysics(), // Prevents nested scroll errors
      type: StepperType.vertical,
      currentStep: activeStep,
      // Hide the default "Continue" and "Cancel" buttons
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: stepperStatuses.map((status) {
        return Step(
          // --- THESE CALLS ARE NOW SAFE ---
          // They will never be called with `unknown` or `cancelled`.
          title: Text(_getStatusTitle(status)),
          subtitle: Text(_getStatusSubtitle(status)),
          content: const SizedBox.shrink(),
          isActive: activeStep >= stepperStatuses.indexOf(status),
          state: _getStepState(activeStep, stepperStatuses.indexOf(status)),
        );
      }).toList(),
    );
  }

  StepState _getStepState(int currentStepIndex, int stepIndex) {
    if (currentStepIndex > stepIndex) {
      return StepState.complete;
    } else if (currentStepIndex == stepIndex) {
      return StepState.indexed;
    } else {
      return StepState.disabled;
    }
  }

  // This helper is now safe because we filter the list before calling it.
  String _getStatusTitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Pending Confirmation';
      case OrderStatus.accepted: return 'Order Accepted';
      case OrderStatus.packaging: return 'Packaging';
      case OrderStatus.readyForDelivery: return 'Ready for Delivery';
      case OrderStatus.shipping: return 'Shipping';
      case OrderStatus.completed: return 'Completed';
    // No `cancelled` or `unknown` cases are needed here.
      default: return '';
    }
  }

  // This helper is also now safe.
  String _getStatusSubtitle(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return 'Waiting for confirmation';
      case OrderStatus.accepted: return 'Your order has been confirmed';
      case OrderStatus.packaging: return 'We are preparing your items';
      case OrderStatus.readyForDelivery: return 'Your package is ready to be shipped';
      case OrderStatus.shipping: return 'Your order is on the way';
      case OrderStatus.completed: return 'Successfully delivered';
    // No `cancelled` or `unknown` cases are needed here.
      default: return '';
    }
  }
}