import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

// A dedicated use case for creating a notification. This is clean and testable.
class CreateNotificationUseCase {
  final NotificationRepository repository;
  CreateNotificationUseCase(this.repository);

  Future<void> call(NotificationEntity notification) {
    return repository.createNotification(notification);
  }
}