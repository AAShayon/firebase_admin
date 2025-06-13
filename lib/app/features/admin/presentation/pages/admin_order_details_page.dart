// This is a conceptual widget
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/helpers/enums.dart';

class AdminOrderDetailsPage extends ConsumerWidget {
  final String orderId;
  const AdminOrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // You would use a provider to get the specific order details
    // final orderAsync = ref.watch(orderDetailsProvider(orderId));

    // ... when order data is loaded
    // final OrderEntity order = orderAsync.value!;

    return Scaffold(
        appBar: AppBar(title: Text('Order #${orderId.substring(0, 6)}')),
        body: Column(
          children: [
            // ... Display order details ...

            Text("Update Status:", style: Theme.of(context).textTheme.titleLarge),
            DropdownButton<OrderStatus>(
              // value: order.status,
              value: OrderStatus.pending, // Placeholder
              items: OrderStatus.values.map((status) => DropdownMenuItem(
                value: status,
                child: Text(status.name.toUpperCase()),
              )).toList(),
              onChanged: (newStatus) {
                if (newStatus != null) {
                  // Call your notifier/use case to update the status
                  // ref.read(orderNotifierProvider.notifier).updateStatus(orderId, newStatus);
                  print("Updating status to ${newStatus.name}");
                }
              },
            )
          ],
        )
    );
  }
}