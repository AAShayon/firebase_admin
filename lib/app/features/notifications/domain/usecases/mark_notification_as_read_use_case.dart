import '../repositories/notification_repository.dart';

class MarkNotificationAsReadUseCase {
  final NotificationRepository repository;
  MarkNotificationAsReadUseCase(this.repository);

  Future<void> call({
    required String notificationId,
    required String userId,
    required bool isAdmin,
  }) {
    if (isAdmin) {
      return repository.markAdminNotificationAsRead(notificationId, userId);
    } else {
      return repository.markUserNotificationAsRead(notificationId, userId);
    }
  }
}