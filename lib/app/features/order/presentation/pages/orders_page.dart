import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../config/widgets/loading_screen.dart';
import '../../../../core/helpers/enums.dart';
import '../../../../core/routes/app_router.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';



class OrderPage extends ConsumerWidget {
  const OrderPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // FIX 1: Handle null user case first to prevent crashes
    final currentUser = ref.watch(currentUserProvider);
    if (currentUser == null) {
      // Show a loading screen or a login prompt if the user is not available yet
      return Scaffold(
        appBar: AppBar(title: const Text('My Orders')),
        body: const Center(child: Text('Please log in to see your orders.')),
      );
    }

    // FIX 2: Correctly check the boolean 'isAdmin' flag. No need to compare to a string.
    // This is now safe because we've confirmed currentUser is not null.
    final bool isAdmin = currentUser.isAdmin;

    // FIX 3: Corrected the stream provider call with the missing parenthesis
    final ordersStream = isAdmin
        ? ref.watch(allOrdersStreamProvider)
        : ref.watch(userOrdersStreamProvider(currentUser.id)); // <-- Fixed parenthesis

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdmin ? 'All Orders' : 'My Orders'),
      ),
      body: ordersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'No orders found.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderListItem(order: order);
            },
          );
        },
        loading: () => const Center(child: CustomLoadingScreen()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Failed to load orders: $error',
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrderListItem extends StatelessWidget {
  final OrderEntity order;

  const _OrderListItem({required this.order});

  @override
  Widget build(BuildContext context) {
    // Using try-catch for date parsing in case of bad data
    String formattedDate;
    try {
      formattedDate = DateFormat.yMMMd().add_jm().format(order.orderDate);
    } catch (e) {
      formattedDate = 'Invalid date';
    }

    final statusColor = _getStatusColor(order.status);

    return GestureDetector(
      onTap: (){
        context.pushNamed(AppRoutes.orderDetails, pathParameters: {'orderId': order.id});
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Order #${order.id}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '\$${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Date: $formattedDate',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Text('Status: '),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      order.status.name.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
      case OrderStatus.packaging:
      case OrderStatus.readyForDelivery:
        return Colors.blue;
      case OrderStatus.shipping:
        return Colors.purple;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.cancelled:
        return Colors.red;
      }
  }
}