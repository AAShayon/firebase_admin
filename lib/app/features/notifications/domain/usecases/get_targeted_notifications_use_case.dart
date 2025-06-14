import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetTargetedNotificationsUseCase {
  final NotificationRepository repository;
  GetTargetedNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call(String userId) {
    return repository.getTargetedNotifications(userId);
  }
}