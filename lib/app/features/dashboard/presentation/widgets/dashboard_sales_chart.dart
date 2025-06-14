import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../config/widgets/custom_card.dart';
import '../../domain/entities/sales_data_entity.dart';
import '../providers/dashboard_providers.dart';

class DashboardSalesChart extends ConsumerWidget {
  const DashboardSalesChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final salesDataAsync = ref.watch(recentSalesStreamProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('📊 Sales Overview (Last 7 Days)',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: salesDataAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return const Center(child: Text('No sales data in the last 7 days.'));
                }
                // We pass the data list to the chart builder
                return BarChart(_buildChartData(context, data));
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, s) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  BarChartData _buildChartData(BuildContext context, List<SalesDataEntity> salesData) {
    final maxSales = salesData.map((d) => d.sales).reduce((a, b) => a > b ? a : b);

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxSales <= 0 ? 100 : maxSales * 1.2,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final day = DateFormat('MMM d').format(salesData[groupIndex].date);
            return BarTooltipItem(
              '$day\n',
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              children: <TextSpan>[
                TextSpan(
                  text: NumberFormat.simpleCurrency(decimalDigits: 0).format(rod.toY),
                  style: const TextStyle(color: Colors.yellow, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            // Pass the data list to the titles helper
            getTitlesWidget: (value, meta) => _bottomTitles(value, meta, salesData),
          ),
        ),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      gridData: const FlGridData(show: false),
      borderData: FlBorderData(show: false),
      barGroups: salesData.asMap().entries.map((entry) {
        final index = entry.key;
        final data = entry.value;
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: data.sales,
              color: Theme.of(context).primaryColor,
              width: 16,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
            ),
          ],
        );
      }).toList(),
    );
  }

  // The helper now accepts the data list as a parameter
  Widget _bottomTitles(double value, TitleMeta meta, List<SalesDataEntity> salesData) {
    final style = TextStyle(color: Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 12);

    final int index = value.toInt();
    if (index < 0 || index >= salesData.length) {
      return Container();
    }

    final date = salesData[index].date;
    final dayText = DateFormat('E').format(date); // "Mon", "Tue"

    return SideTitleWidget(
      meta: meta, // Pass the required meta object
      space: 4,
      child: Text(dayText, style: style),
    );
  }
}