import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/dashboard_notifier_provider.dart';
import '../widgets/dashboard_notification_section.dart';
import '../widgets/dashboard_sales_chart.dart';
import '../widgets/dashboard_stats_section.dart';
import '../widgets/dashboard_top_customers.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardNotifier = ref.read(dashboardNotifierProvider.notifier);

    // Set up a listener for one-time events like snackbars
    ref.listen(dashboardNotifierProvider, (previous, next) {
      next.maybeWhen(
        notificationSent: (message) =>
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.green)),
        error: (message) =>
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $message'), backgroundColor: Colors.red)),
        orElse: () {},
      );
    });

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => dashboardNotifier.getStats(),
        child: const SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real-time stats cards
              DashboardStatsSection(),
              SizedBox(height: 24),

              // Real-time sales chart
              DashboardSalesChart(),
              SizedBox(height: 24),

              // Top customers list (with real users, placeholder metrics)
              DashboardTopCustomers(),
              SizedBox(height: 24),

              // Fully functional notification section
              DashboardNotificationSection(),
            ],
          ),
        ),
      ),
    );
  }
}