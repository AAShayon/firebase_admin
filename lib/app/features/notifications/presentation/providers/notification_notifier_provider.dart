import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'notification_notifier.dart';
import 'notification_state.dart';

final notificationNotifierProvider =
StateNotifierProvider.autoDispose<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});