import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

class GetUserPrivateNotificationsUseCase {
  final NotificationRepository repository;
  GetUserPrivateNotificationsUseCase(this.repository);

  Stream<List<NotificationEntity>> call(String userId) {
    return repository.getUserPrivateNotifications(userId);
  }
}