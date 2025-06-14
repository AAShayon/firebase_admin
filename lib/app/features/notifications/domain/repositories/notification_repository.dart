import '../entities/notification_entity.dart';


abstract class NotificationRepository {
  Future<void> createNotification(NotificationEntity notification);
  Stream<List<NotificationEntity>> getNotifications(); // For Admins
  Stream<List<NotificationEntity>> getPublicNotifications(); // For Users
  Stream<List<NotificationEntity>> getTargetedNotifications(String userId); // For Users
  Future<void> markAsRead(String notificationId, String adminId);
  Stream<List<NotificationEntity>> getUserPrivateNotifications(String userId);
  Future<void> markAdminNotificationAsRead(String notificationId, String adminId);
  Future<void> markUserNotificationAsRead(String notificationId, String userId);
}