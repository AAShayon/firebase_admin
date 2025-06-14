import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_providers.dart';
import 'notification_state.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(const NotificationState.initial());

  Future<void> markAsRead(String notificationId, String adminId) async {
    try {
      await _ref.read(markAsReadUseCaseProvider).call(notificationId, adminId);
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }
  Future<void> markNotificationAsRead({
    required String notificationId,
    required String userId,
    required bool isAdmin,
  }) async {
    try {
      // Call the new, smarter use case with all required parameters.
      await _ref.read(markNotificationAsReadUseCaseProvider).call(
        notificationId: notificationId,
        userId: userId,
        isAdmin: isAdmin,
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      // Optionally set an error state
    }
  }
}