import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/routes/app_router.dart';
import '../../auth/presentation/providers/auth_providers.dart';
import '../domain/entities/notification_entity.dart';
import 'providers/notification_notifier_provider.dart';
import 'providers/notification_providers.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final bool isAdmin = currentUser?.isAdmin ?? false;
    final userId = currentUser?.id ?? '';

    // Watch the appropriate stream based on the user's role.
    // This is the core of the separation.
    final notificationsAsync = ref.watch(
        isAdmin ? notificationsStreamProvider : userPrivateNotificationsStreamProvider(userId)
    );

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(isAdmin ? notificationsStreamProvider : userPrivateNotificationsStreamProvider(userId));
        },
        child: notificationsAsync.when(
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(
                child: Text('You have no notifications.', style: TextStyle(fontSize: 16, color: Colors.grey)),
              );
            }
            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                final IconData iconData;
                switch (notification.type) {
                  case NotificationType.newOrder:
                    iconData = Icons.receipt_long;
                    break;
                  case NotificationType.promotion:
                  default:
                    iconData = Icons.campaign;
                    break;
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead ? Colors.grey.shade300 : Theme.of(context).primaryColor,
                    child: Icon(iconData, color: notification.isRead ? Colors.grey.shade700 : Colors.white),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: !notification.isRead ? FontWeight.bold : FontWeight.normal,
                      color: !notification.isRead ? Theme.of(context).textTheme.bodyLarge?.color : Colors.grey.shade600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body, maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () => _handleNotificationTap(context, ref, notification),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text('Error loading notifications: $e')),
        ),
      ),
    );
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref, NotificationEntity notification) {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    if (!notification.isRead) {
      // --- THIS CALL IS NOW CORRECT ---
      ref.read(notificationNotifierProvider.notifier).markNotificationAsRead(
        notificationId: notification.id,
        userId: currentUser.id,
        isAdmin: currentUser.isAdmin,
      );
    }

    // Navigation logic
    if (notification.type == NotificationType.newOrder && currentUser.isAdmin) {
      final orderId = notification.data['orderId'] as String?;
      if (orderId != null) {
        context.pushNamed(AppRoutes.orderDetails, pathParameters: {'orderId': orderId});
      }
    } else if (notification.type != NotificationType.newOrder) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(notification.title),
          content: Text(notification.body),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
        ),
      );
    }
  }
}