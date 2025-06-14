import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetPublicNotificationsUseCase {
  final NotificationRepository repository;
  GetPublicNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call() {
    return repository.getPublicNotifications();
  }
}