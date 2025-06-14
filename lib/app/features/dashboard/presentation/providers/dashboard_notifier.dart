import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifications/domain/entities/notification_entity.dart';
import 'dashboard_providers.dart';
import 'dashboard_state.dart';

class DashboardNotifier extends StateNotifier<DashboardState> {
  final Ref _ref;
  final TextEditingController notificationTitleController = TextEditingController();
  final TextEditingController notificationBodyController = TextEditingController();

  DashboardNotifier(this._ref) : super(const DashboardState.initial()) {
    getStats(); // Load stats when the notifier is created
  }

  Future<void> getStats() async {
    state = const DashboardState.loading();
    try {
      final stats = await _ref.read(getDashboardStatsUseCaseProvider).call();
      state = DashboardState.statsLoaded(stats);
    } catch (e) {
      state = DashboardState.error(e.toString());
    }
  }

  Future<void> sendNotification({required String target}) async {
    final title = notificationTitleController.text.trim();
    final body = notificationBodyController.text.trim();

    if (title.isEmpty || body.isEmpty) {
      state = const DashboardState.error('Title and message cannot be empty.');
      return;
    }

    state = const DashboardState.loading();

    try {
      final notification = NotificationEntity(
        id: '',
        title: title,
        body: body,
        createdAt: DateTime.now(),
        type: NotificationType.promotion, // A new type
        // The 'data' payload now specifies the target
        data: {'target': target},
      );

      await _ref.read(createPublicNotificationUseCaseProvider).call(notification);

      notificationTitleController.clear();
      notificationBodyController.clear();
      state = const DashboardState.notificationSent('Notification published successfully!');

    } catch (e) {
      state = DashboardState.error(e.toString());
    } finally {
      getStats(); // Revert to stats loaded state
    }
  }

  @override
  void dispose() {
    notificationTitleController.dispose();
    notificationBodyController.dispose();
    super.dispose();
  }
}