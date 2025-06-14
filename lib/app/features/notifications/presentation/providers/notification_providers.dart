import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/create_notification_use_case.dart'; // <-- Add this
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/mark_as_read_use_case.dart';

// Export the notifier provider for easy access
export 'notification_notifier_provider.dart';

// Use Cases
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  return locator<GetNotificationsUseCase>();
});

final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  return locator<MarkAsReadUseCase>();
});

// The new use case provider
final createNotificationUseCaseProvider = Provider<CreateNotificationUseCase>((ref) {
  return locator<CreateNotificationUseCase>();
});

// Real-time stream of notifications
final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final getNotifications = ref.watch(getNotificationsUseCaseProvider);
  return getNotifications();
});

// Derived state for the number of unread notifications (for badges)
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (e, s) => 0,
  );
});