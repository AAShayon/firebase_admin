import 'package:flutter/material.dart';

import '../../../../config/widgets/responsive_scaffold.dart';
import '../../../../config/widgets/stats_card.dart';


class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveScaffold(
      title: 'eCommerce Admin',
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards
              _buildStatsSection(context),
              const SizedBox(height: 24),

              // Sales Chart
              _buildSalesChartSection(),
              const SizedBox(height: 24),

              // Top Customers
              _buildTopCustomersSection(),
              const SizedBox(height: 24),

              // Push Notification
              _buildNotificationSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final isTablet = constraints.maxWidth < 1024;

        if (isMobile) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: constraints.maxWidth,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    _buildStatCard('📦', 'Total Products', '125'),
                    const SizedBox(width: 12),
                    _buildStatCard('💰', 'Total Sales', '\$12,500'),
                    const SizedBox(width: 12),
                    _buildStatCard('👥', 'Total Customers', '85'),
                    const SizedBox(width: 12),
                    _buildStatCard('📉', 'Low Stock', '7', color: Colors.red),
                  ],
                ),
              ),
            ),
          );
        }else {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isTablet ? 2 : 4,
            childAspectRatio: isTablet ? 1.2 : 1.5, // Adjusted aspect ratio
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            padding: const EdgeInsets.all(8),
            children: [
              _buildStatCard('📦', 'Total Products', '125'),
              _buildStatCard('💰', 'Total Sales', '\$12,500', color: Colors.green),
              _buildStatCard('👥', 'Total Customers', '85'),
              _buildStatCard('📉', 'Low Stock', '7', color: Colors.red),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard(String emoji, String title, String value, {Color? color}) {
    return StatsCard(
      emoji: emoji,
      title: title,
      value: value,
      color: color,
    );
  }

  Widget _buildSalesChartSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('📊 Sales Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text('Chart Placeholder',
                    style: TextStyle(color: Colors.grey)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopCustomersSection() {
    final customers = [
      {'name': 'John Doe', 'orders': 25, 'revenue': 1200.00},
      {'name': 'Jane Smith', 'orders': 22, 'revenue': 1050.00},
      {'name': 'Robert Johnson', 'orders': 18, 'revenue': 950.00},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🧑‍💼 Top Customers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Orders')),
                  DataColumn(label: Text('Revenue')),
                ],
                rows: customers
                    .map((customer) => DataRow(cells: [
                  DataCell(Text(customer['name'].toString())),
                  DataCell(Text(customer['orders'].toString())),
                  DataCell(Text('\$${customer['revenue']}')),
                ]))
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('🔔 Push Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Summer Sale',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Message',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                hintText: 'e.g., Get 30% off on all items today!',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Send to',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              value: 'all',
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Customers')),
                DropdownMenuItem(value: 'active', child: Text('Active Customers')),
                DropdownMenuItem(
                    value: 'high', child: Text('High Spenders')),
              ],
              onChanged: (value) {},
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Send Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}