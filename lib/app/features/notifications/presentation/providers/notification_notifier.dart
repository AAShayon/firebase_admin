import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_providers.dart';
import 'notification_state.dart';

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationNotifier(this._ref) : super(const NotificationState.initial());

  Future<void> markAsRead(String notificationId) async {
    // We don't need a loading state for this quick action.
    try {
      await _ref.read(markAsReadUseCaseProvider).call(notificationId);
      // The UI will rebuild automatically from the stream, so no success state needed.
    } catch (e) {
      // We could set an error state, but it's unlikely to fail.
      print('Error marking notification as read: $e');
    }
  }
}