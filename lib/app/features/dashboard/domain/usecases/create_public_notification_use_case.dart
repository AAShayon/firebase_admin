import '../../../../features/notifications/domain/entities/notification_entity.dart';
import '../repositories/dashboard_repository.dart';

class CreatePublicNotificationUseCase {
  final DashboardRepository repository;
  CreatePublicNotificationUseCase(this.repository);

  Future<void> call(NotificationEntity notification) {
    return repository.createPublicNotification(notification);
  }
}