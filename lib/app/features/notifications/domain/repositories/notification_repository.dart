import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Stream<List<NotificationEntity>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> createNotification(NotificationEntity notification);
  Stream<List<NotificationEntity>> getPublicNotifications();
}