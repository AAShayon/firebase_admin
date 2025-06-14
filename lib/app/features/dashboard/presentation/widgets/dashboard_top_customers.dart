import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/widgets/custom_card.dart';
import '../../../order/presentation/providers/order_providers.dart'; // <-- IMPORT
import '../../../user_profile/presentation/providers/user_profile_providers.dart';

class DashboardTopCustomers extends ConsumerWidget {
  const DashboardTopCustomers({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allUsersAsync = ref.watch(allUsersProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('🧑‍💼 Recent Customers',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          allUsersAsync.when(
            data: (customers) {
              if (customers.isEmpty) return const Center(child: Text('No customers yet.'));
              return SizedBox(
                width: double.infinity,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Orders')),
                  ],
                  // Take the first 5 customers for display
                  rows: customers.take(5).map((customer) {
                    return DataRow(cells: [
                      DataCell(Text(customer.displayName ?? 'N/A')),
                      DataCell(Text(customer.email ?? 'N/A')),
                      // This cell is now a Consumer to watch the specific order count
                      DataCell(
                        Consumer(
                          builder: (context, cellRef, _) {
                            final orderCountAsync = cellRef.watch(userOrderCountProvider(customer.id));
                            return orderCountAsync.when(
                              data: (count) => Text(count.toString()),
                              loading: () => const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                              error: (_, __) => const Text('?'),
                            );
                          },
                        ),
                      ),
                    ]);
                  }).toList(),
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Error: $e')),
          )
        ],
      ),
    );
  }
}