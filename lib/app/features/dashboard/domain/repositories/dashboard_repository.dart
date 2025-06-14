import '../entities/dashboard_stats_entity.dart';
import '../../../notifications/domain/entities/notification_entity.dart';

abstract class DashboardRepository {
  Future<DashboardStatsEntity> getDashboardStats();

  // --- UPDATED METHOD ---
  // The action is now creating a notification entity.
  Future<void> createPublicNotification(NotificationEntity notification);
}