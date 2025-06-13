// lib/app/features/admin/presentation/pages/order_management_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/enums.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../../../order/presentation/providers/order_notifier_provider.dart';
import '../../../order/presentation/providers/order_providers.dart';
import '../../../order/presentation/widgets/order_status_stepper.dart';


class OrderManagementPage extends ConsumerWidget {
  const OrderManagementPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Orders')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (orders) {
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ExpansionTile(
                  title: Text('Order #${order.id}'),
                  subtitle: Text('Status: ${order.status.toString().split('.').last}'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          OrderStatusStepper(currentStatus: order.status),
                          const SizedBox(height: 16),
                          ...order.items.map((item) => ListTile(
                            title: Text(item.productTitle),
                            subtitle: Text('${item.variantSize} - ${item.variantColorName}'),
                            trailing: Text('${item.quantity} x \$${item.price.toStringAsFixed(2)}'),
                          )),
                          const Divider(),
                          Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                          const SizedBox(height: 16),
                          if (order.status != OrderStatus.completed &&
                              order.status != OrderStatus.cancelled)
                            _buildStatusButtons(ref, order),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatusButtons(WidgetRef ref, OrderEntity order) {
    final nextStatus = _getNextStatus(order.status);

    return ElevatedButton(
      onPressed: () {
        ref.read(orderNotifierProvider.notifier).updateOrderStatus(
          orderId: order.id,
          newStatus: nextStatus,
          userId: order.userId,
        );
      },
      child: Text('Mark as ${nextStatus.toString().split('.').last}'),
    );
  }

  OrderStatus _getNextStatus(OrderStatus currentStatus) {
    switch (currentStatus) {
      case OrderStatus.pending:
        return OrderStatus.accepted;
      case OrderStatus.accepted:
        return OrderStatus.packaging;
      case OrderStatus.packaging:
        return OrderStatus.readyForDelivery;
      case OrderStatus.readyForDelivery:
        return OrderStatus.shipping;
      case OrderStatus.shipping:
        return OrderStatus.completed;
      case OrderStatus.completed:
      case OrderStatus.cancelled:
        return currentStatus;
    }
  }
}