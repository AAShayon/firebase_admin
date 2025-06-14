// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:intl/intl.dart';
// import '../../../../config/widgets/custom_card.dart';
// import '../../domain/entities/order_entity.dart';
// import '../providers/order_providers.dart';
// import '../widgets/order_status_badge.dart';
//
// class OrderDetailsPage extends ConsumerWidget {
//   final String orderId;
//   const OrderDetailsPage({super.key, required this.orderId});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     // Use the specific provider to fetch details for this orderId
//     final orderDetailsAsync = ref.watch(orderDetailsProvider(orderId));
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order #$orderId'),
//       ),
//       body: orderDetailsAsync.when(
//         data: (order) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 _buildStatusSection(context, order),
//                 const SizedBox(height: 24),
//                 _buildSectionTitle(context, 'Order Summary'),
//                 _buildSummaryCard(order),
//                 const SizedBox(height: 24),
//                 _buildSectionTitle(context, 'Items (${order.items.length})'),
//                 _buildItemsList(order),
//                 const SizedBox(height: 24),
//                 _buildSectionTitle(context, 'Shipping Information'),
//                 _buildAddressCard('Shipping Address', order.shippingAddress),
//                 const SizedBox(height: 16),
//                 _buildAddressCard('Billing Address', order.billingAddress),
//                 const SizedBox(height: 24),
//               ],
//             ),
//           );
//         },
//         loading: () => const Center(child: CircularProgressIndicator()),
//         error: (e, s) => Center(
//           child: Text('Error loading order details: $e'),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSectionTitle(BuildContext context, String title) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8.0),
//       child: Text(
//         title,
//         style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
//       ),
//     );
//   }
//
//   Widget _buildStatusSection(BuildContext context, OrderEntity order) {
//     return CustomCard(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 'Order Placed:',
//                 style: Theme.of(context).textTheme.bodySmall,
//               ),
//               Text(
//                 DateFormat('MMMM d, yyyy \'at\' h:mm a').format(order.orderDate),
//                 style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
//               ),
//             ],
//           ),
//           OrderStatusBadge(status: order.status),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryCard(OrderEntity order) {
//     return CustomCard(
//       child: Column(
//         children: [
//           _buildSummaryRow('Payment Method:', order.paymentMethod.toString()),
//           _buildSummaryRow('Subtotal:', '\$${(order.totalAmount).toStringAsFixed(2)}'),
//           // You can add discount and delivery fee here if they are part of your OrderEntity
//           const Divider(height: 20),
//           _buildSummaryRow('Grand Total:', '\$${order.totalAmount.toStringAsFixed(2)}', isTotal: true),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
//           Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildItemsList(OrderEntity order) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: order.items.length,
//       separatorBuilder: (_, __) => const Divider(),
//       itemBuilder: (context, index) {
//         final item = order.items[index];
//         return ListTile(
//           leading: item.imageUrl != null
//               ? ClipRRect(
//             borderRadius: BorderRadius.circular(8),
//             child: Image.network(
//               item.imageUrl!,
//               width: 50,
//               height: 50,
//               fit: BoxFit.cover,
//             ),
//           )
//               : const Icon(Icons.shopping_bag),
//           title: Text(item.productTitle),
//           subtitle: Text('Qty: ${item.quantity}'),
//           trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
//           contentPadding: EdgeInsets.zero,
//         );
//       },
//     );
//   }
//
//   Widget _buildAddressCard(String title, String? address) {
//     return CustomCard(
//       child: SizedBox(
//         width: double.infinity,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
//             const SizedBox(height: 8),
//             Text(address ?? 'Not provided'),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/widgets/custom_card.dart';
import '../../../../core/helpers/enums.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_notifier_provider.dart';
import '../providers/order_providers.dart';
import '../providers/order_state.dart';
import '../widgets/order_status_badge.dart';
import '../widgets/order_status_stepper.dart'; // <-- IMPORT YOUR STEPPER

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderDetailsAsync = ref.watch(orderDetailsProvider(orderId));
    final currentUser = ref.watch(currentUserProvider);
    final bool isAdmin = currentUser?.isAdmin ?? false;

    ref.listen<OrderState>(orderNotifierProvider, (_, state) {
      state.maybeWhen(
        success: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: Colors.green),
          );
          ref.invalidate(orderDetailsProvider(orderId));
        },
        error: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red),
          );
        },
        orElse: () {},
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #${orderId.substring(0, 12)}...'),
      ),
      body: orderDetailsAsync.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(context, order),

                // --- ADMIN-ONLY SECTION ---
                if (isAdmin) ...[
                  const SizedBox(height: 24),
                  _buildAdminStatusUpdater(context, ref, order),
                ],

                // --- BEAUTIFUL STEPPER FOR ALL USERS ---
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Order Progress'),
                CustomCard(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: OrderStatusStepper(currentStatus: order.status),
                ),
                // --- END STEPPER SECTION ---

                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Items (${order.items.length})'),
                _buildItemsList(order),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Shipping Information'),
                _buildAddressCard('Shipping Address', order.shippingAddress),
                const SizedBox(height: 16),
                _buildAddressCard('Billing Address', order.billingAddress),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Order Summary'),
                _buildSummaryCard(context,order),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error loading order details: $e')),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, OrderEntity order) {
    return CustomCard(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Order Placed:',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              Text(
                DateFormat('MMMM d, yyyy \'at\' h:mm a').format(order.orderDate),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Expanded(child: OrderStatusBadge(status: order.status)),
        ],
      ),
    );
  }

  Widget _buildAdminStatusUpdater(BuildContext context, WidgetRef ref, OrderEntity order) {
    final orderState = ref.watch(orderNotifierProvider);
    final bool isLoading = orderState.maybeWhen(
      loading: () => true,
      orElse: () => false,
    );

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Admin: Update Status',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<OrderStatus>(
            value: order.status,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            items: OrderStatus.values
                .where((s) => s != OrderStatus.unknown && s != OrderStatus.cancelled)
                .map((status) => DropdownMenuItem(
              value: status,
              child: Text(status.toString().split('.').last.replaceAllMapped(
                  RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}'
              ).trim().toUpperCase()),
            ))
                .toList(),
            onChanged: isLoading ? null : (newStatus) {
              if (newStatus != null && newStatus != order.status) {
                // This call is now correct, without the userId.
                ref.read(orderNotifierProvider.notifier).updateOrderStatus(  orderId: order.id, newStatus:newStatus,);
              }
            },
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 12.0),
              child: Center(child: LinearProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context,OrderEntity order) {
    // This widget doesn't need to be in a CustomCard since its content is just rows.
    // Let's wrap it in one for consistency.
    return CustomCard(
      child: Column(
        children: [
          _buildSummaryRow(context,'Payment Method:', order.paymentMethod.toString().toUpperCase()),
          _buildSummaryRow(context,'Subtotal:', '\$${(order.totalAmount).toStringAsFixed(2)}'),
          const Divider(height: 20),
          _buildSummaryRow(context,'Grand Total:', '\$${order.totalAmount.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context,String label, String value, {bool isTotal = false}) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: textTheme.bodyLarge),
          Text(value, style: textTheme.bodyLarge?.copyWith(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildItemsList(OrderEntity order) {
    return CustomCard(
      padding: EdgeInsets.zero, // The ListTiles have their own padding
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: order.items.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = order.items[index];
          return ListTile(
            leading: item.imageUrl != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover),
            )
                : const CircleAvatar(child: Icon(Icons.shopping_bag)),
            title: Text(item.productTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Qty: ${item.quantity} @ \$${item.price.toStringAsFixed(2)}'),
            trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }

  Widget _buildAddressCard(String title, String? address) {
    return CustomCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(address?.replaceAll(', ,', ',') ?? 'Not provided', style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
          ],
        ),
      ),
    );
  }
}