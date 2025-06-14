import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/create_notification_use_case.dart'; // <-- Add this
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/get_public_notifications_use_case.dart';
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
final getPublicNotificationsUseCaseProvider = Provider<GetPublicNotificationsUseCase>((ref) {
  return locator<GetPublicNotificationsUseCase>();
});

final publicNotificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  final getPublicNotifications = ref.watch(getPublicNotificationsUseCaseProvider);
  return getPublicNotifications();
});

final userUnreadNotificationCountProvider = Provider.autoDispose.family<int, String>((ref, userId) {
  // If userId is empty, no count.
  if (userId.isEmpty) return 0;

  final publicNotifications = ref.watch(publicNotificationsStreamProvider);
  // In the future, you could also watch the user's own order stream here and combine the counts.
  return publicNotifications.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length, // Note: public notifs dont have a read status yet
    loading: () => 0,
    error: (e, s) => 0,
  );
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