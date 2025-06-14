import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
import '../../domain/entities/sales_data_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_data_source.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;

  DashboardRepositoryImpl({required this.remoteDataSource});

  @override
  Future<DashboardStatsEntity> getDashboardStats() async {
    // We fetch all stats in parallel for better performance.
    final results = await Future.wait([
      remoteDataSource.getTotalProductCount(),
      remoteDataSource.getTotalCustomerCount(),
      remoteDataSource.getTotalSales(),
      remoteDataSource.getLowStockCount(),
    ]);

    return DashboardStatsEntity(
      totalProducts: results[0] as int,
      totalCustomers: results[1] as int,
      totalSales: results[2] as double,
      lowStockCount: results[3] as int,
    );
  }

  // --- UPDATED METHOD IMPLEMENTATION ---
  @override
  Future<void> createPublicNotification(NotificationEntity notification) async {
    // We convert our domain entity into a plain map to be sent to the data source.
    final data = {
      'title': notification.title,
      'body': notification.body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false, // Public notifications might not need a read status
      'type': 'promotion', // A new type to distinguish it from order notifications
      'data': notification.data, // e.g., {'topic': 'all_users'}
    };
    return remoteDataSource.createNotification(data);
  }
  @override
  Stream<List<SalesDataEntity>> getRecentSales() {
    return remoteDataSource.getOrdersFromLast7Days().map((snapshot) {
      if (snapshot.docs.isEmpty) return [];

      // Group orders by the day they were created
      final groupedByDay = groupBy(
        snapshot.docs,
            (doc) {
          final date = (doc.data() as Map<String, dynamic>)['orderDate']?.toDate() ?? DateTime.now();
          return DateTime(date.year, date.month, date.day);
        },
      );

      // Aggregate sales for each day
      return groupedByDay.entries.map((entry) {
        final totalSales = entry.value.fold<double>(0.0, (sum, doc) {
          return sum + ((doc.data() as Map<String, dynamic>)['totalAmount'] as num? ?? 0.0);
        });
        return SalesDataEntity(date: entry.key, sales: totalSales);
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date)); // Sort by date
    });
  }
}