// This entity holds the aggregated data for our dashboard.
class DashboardStatsEntity {
  final int totalProducts;
  final int totalCustomers;
  final double totalSales;
  final int lowStockCount; // Number of products with stock < a threshold

  DashboardStatsEntity({
    required this.totalProducts,
    required this.totalCustomers,
    required this.totalSales,
    required this.lowStockCount,
  });
}