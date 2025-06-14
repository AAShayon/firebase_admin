import 'package:flutter_riverpod/flutter_riverpod.dart';


// Dependency Injection and other providers
import '../../../../core/di/injector.dart';


// Domain Layer: Entities and Use Cases
import '../../domain/entities/notification_entity.dart';
import '../../domain/usecases/create_notification_use_case.dart';
import '../../domain/usecases/get_notifications_use_case.dart';
import '../../domain/usecases/get_public_notifications_use_case.dart';
import '../../domain/usecases/get_targeted_notifications_use_case.dart';
import '../../domain/usecases/get_user_private_notifications_use_case.dart';
import '../../domain/usecases/mark_as_read_use_case.dart';
import '../../domain/usecases/mark_notification_as_read_use_case.dart';

// Export the notifier provider for easy access from other files
export 'notification_notifier_provider.dart';


//==============================================================================
// USE CASE PROVIDERS
//==============================================================================

final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) => locator<GetNotificationsUseCase>());
final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) => locator<MarkAsReadUseCase>());
final createNotificationUseCaseProvider = Provider<CreateNotificationUseCase>((ref) => locator<CreateNotificationUseCase>());
final getPublicNotificationsUseCaseProvider = Provider<GetPublicNotificationsUseCase>((ref) => locator<GetPublicNotificationsUseCase>());
final getTargetedNotificationsUseCaseProvider = Provider<GetTargetedNotificationsUseCase>((ref) => locator<GetTargetedNotificationsUseCase>());


//==============================================================================
// ADMIN NOTIFICATION PROVIDERS
//==============================================================================

/// A real-time stream of ALL notifications from the '/notifications' collection.
final notificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  return ref.watch(getNotificationsUseCaseProvider)();
});

/// A derived state provider that calculates the number of unread notifications for the admin's badge.
final unreadNotificationCountProvider = Provider.autoDispose<int>((ref) {
  final notificationsAsync = ref.watch(notificationsStreamProvider);
  return notificationsAsync.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (e, s) => 0,
  );
});


//==============================================================================
// USER NOTIFICATION PROVIDERS (Final, Corrected Implementation)
//==============================================================================

/// --- THIS IS THE MISSING PROVIDER, NOW CORRECTLY DEFINED ---
/// This StateProvider holds the map of all items (orders or promos) the user has "seen".
/// Key: item ID (orderId or notificationId), Value: seen status or "read"
final seenItemsProvider = StateProvider<Map<String, String>>((ref) {
  // Initialize from local storage
  return appData.read<Map>('seen_items_map')?.cast<String, String>() ?? {};
});


/// A real-time stream of ONLY public/promotional notifications.
final publicNotificationsStreamProvider = StreamProvider.autoDispose<List<NotificationEntity>>((ref) {
  return ref.watch(getPublicNotificationsUseCaseProvider)();
});

/// A real-time stream for notifications targeted specifically at the user.
final targetedNotificationsStreamProvider = StreamProvider.autoDispose.family<List<NotificationEntity>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value([]);
  return ref.watch(getTargetedNotificationsUseCaseProvider)(userId);
});
final getUserPrivateNotificationsUseCaseProvider = Provider<GetUserPrivateNotificationsUseCase>((ref) {
  return locator<GetUserPrivateNotificationsUseCase>();
});

final markNotificationAsReadUseCaseProvider = Provider<MarkNotificationAsReadUseCase>((ref) {
  return locator<MarkNotificationAsReadUseCase>();
});

final userPrivateNotificationsStreamProvider = StreamProvider.autoDispose.family<List<NotificationEntity>, String>((ref, userId) {
  if (userId.isEmpty) return Stream.value([]);
  // This will use a new data source method
  return ref.watch(getUserPrivateNotificationsUseCaseProvider)(userId);
});

/// --- THIS IS THE NEW, MODERN, AND CORRECT COMBINED PROVIDER ---
/// It combines data from three different streams to calculate the final unread count for the user's badge.
final userUnreadNotificationCountProvider = Provider.autoDispose.family<int, String>((ref, userId) {
  final userNotifications = ref.watch(userPrivateNotificationsStreamProvider(userId));
  return userNotifications.when(
    data: (notifications) => notifications.where((n) => !n.isRead).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});


// This provider combines the public and targeted notification lists for the user's inbox page.
// It remains separate from the count provider for clarity.
final userCombinedNotificationsProvider = Provider.autoDispose.family<AsyncValue<List<NotificationEntity>>, String>((ref, userId) {
  if (userId.isEmpty) return const AsyncData([]);

  final publicAsync = ref.watch(publicNotificationsStreamProvider);
  final targetedAsync = ref.watch(targetedNotificationsStreamProvider(userId));

  if (publicAsync.isLoading || targetedAsync.isLoading) return const AsyncLoading();
  if (publicAsync.hasError) return AsyncError(publicAsync.error!, publicAsync.stackTrace!);
  if (targetedAsync.hasError) return AsyncError(targetedAsync.error!, targetedAsync.stackTrace!);

  final combinedMap = <String, NotificationEntity>{};
  for (var n in [...publicAsync.value ?? [], ...targetedAsync.value ?? []]) {
    combinedMap[n.id] = n;
  }

  final sortedList = combinedMap.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  return AsyncData(sortedList);
});