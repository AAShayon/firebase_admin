import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/widgets/stats_card.dart';
import '../providers/dashboard_notifier_provider.dart';

class DashboardStatsSection extends ConsumerWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardState = ref.watch(dashboardNotifierProvider);

    return dashboardState.maybeWhen(
      statsLoaded: (stats) {
        final currencyFormat = NumberFormat.simpleCurrency(locale: 'en_US', decimalDigits: 0);
        return LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            if (isMobile) {
              // On mobile, use a scrollable row.
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _buildCards(stats, currencyFormat),
                ),
              );
            } else {
              // On desktop/tablet, use a grid.
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: constraints.maxWidth < 1024 ? 2 : 4,
                childAspectRatio: 1.5,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _buildCards(stats, currencyFormat),
              );
            }
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (message) => Center(child: Text('Error: $message')),
      orElse: () => const Center(child: Text('Could not load stats.')),
    );
  }

  List<Widget> _buildCards(dynamic stats, NumberFormat currencyFormat) {
    return [
      StatsCard(emoji: '📦', title: 'Total Products', value: stats.totalProducts.toString()),
      StatsCard(emoji: '💰', title: 'Total Sales', value: currencyFormat.format(stats.totalSales), color: Colors.green),
      StatsCard(emoji: '👥', title: 'Total Customers', value: stats.totalCustomers.toString()),
      StatsCard(emoji: '📉', title: 'Low Stock', value: stats.lowStockCount.toString(), color: Colors.red),
    ];
  }
}