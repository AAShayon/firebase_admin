import '../entities/dashboard_stats_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import '../entities/sales_data_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStatsEntity> getDashboardStats();

  // --- UPDATED METHOD ---
  // The action is now creating a notification entity.
  Future<void> createPublicNotification(NotificationEntity notification);
  Stream<List<SalesDataEntity>> getRecentSales();
  Future<void> sendPromotionToTarget({
    required NotificationEntity notification,
    required String target, // 'all_users' or a specific userId
  });
}