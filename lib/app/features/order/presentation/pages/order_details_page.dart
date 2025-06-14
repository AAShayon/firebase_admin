import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../config/widgets/custom_card.dart';
import '../../domain/entities/order_entity.dart';
import '../providers/order_providers.dart';
import '../widgets/order_status_badge.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;
  const OrderDetailsPage({super.key, required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use the specific provider to fetch details for this orderId
    final orderDetailsAsync = ref.watch(orderDetailsProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text('Order #$orderId'),
      ),
      body: orderDetailsAsync.when(
        data: (order) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusSection(context, order),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Order Summary'),
                _buildSummaryCard(order),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Items (${order.items.length})'),
                _buildItemsList(order),
                const SizedBox(height: 24),
                _buildSectionTitle(context, 'Shipping Information'),
                _buildAddressCard('Shipping Address', order.shippingAddress),
                const SizedBox(height: 16),
                _buildAddressCard('Billing Address', order.billingAddress),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(
          child: Text('Error loading order details: $e'),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
          OrderStatusBadge(status: order.status),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(OrderEntity order) {
    return CustomCard(
      child: Column(
        children: [
          _buildSummaryRow('Payment Method:', order.paymentMethod.toString()),
          _buildSummaryRow('Subtotal:', '\$${(order.totalAmount).toStringAsFixed(2)}'),
          // You can add discount and delivery fee here if they are part of your OrderEntity
          const Divider(height: 20),
          _buildSummaryRow('Grand Total:', '\$${order.totalAmount.toStringAsFixed(2)}', isTotal: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildItemsList(OrderEntity order) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: order.items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final item = order.items[index];
        return ListTile(
          leading: item.imageUrl != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              item.imageUrl!,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
            ),
          )
              : const Icon(Icons.shopping_bag),
          title: Text(item.productTitle),
          subtitle: Text('Qty: ${item.quantity}'),
          trailing: Text('\$${(item.price * item.quantity).toStringAsFixed(2)}'),
          contentPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Widget _buildAddressCard(String title, String? address) {
    return CustomCard(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(address ?? 'Not provided'),
          ],
        ),
      ),
    );
  }
}