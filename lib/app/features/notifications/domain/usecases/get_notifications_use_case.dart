import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;
  GetNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call() {
    return repository.getNotifications();
  }
}