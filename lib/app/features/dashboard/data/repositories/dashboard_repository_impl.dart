import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../../domain/entities/dashboard_stats_entity.dart';
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
}