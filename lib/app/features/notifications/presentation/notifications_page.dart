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

    // --- ROLE-BASED DATA FETCHING ---
    // Watch the appropriate stream based on the user's role.
    // Admins see all notifications, users see public/promotional ones.
    final notificationsAsync = ref.watch(
        isAdmin ? notificationsStreamProvider : publicNotificationsStreamProvider
    );

    return Scaffold(
      // The AppBar is managed by LandingPage.
      body: notificationsAsync.when(
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'You have no notifications.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              // Invalidate the correct provider to refresh the data
              ref.invalidate(isAdmin ? notificationsStreamProvider : publicNotificationsStreamProvider);
            },
            child: ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notification = notifications[index];

                // Determine the icon and if the item is tappable
                final IconData iconData;
                bool isTappable = false;
                if (notification.type == NotificationType.newOrder) {
                  iconData = Icons.receipt_long;
                  isTappable = isAdmin; // Only admins can tap order notifications
                } else {
                  iconData = Icons.campaign; // Icon for promotions
                  isTappable = false; // Promotions are not tappable for now
                }

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: notification.isRead && isAdmin // Only admins see read status
                        ? Colors.grey.shade300
                        : Theme.of(context).primaryColor,
                    child: Icon(
                      iconData,
                      color: notification.isRead && isAdmin ? Colors.grey[600] : Colors.white,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: !notification.isRead && isAdmin ? FontWeight.bold : FontWeight.normal,
                      color: !notification.isRead && isAdmin ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(notification.body),
                      const SizedBox(height: 4),
                      Text(
                        timeago.format(notification.createdAt),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: isTappable ? () {
                    if (isAdmin && !notification.isRead) {
                      ref.read(notificationNotifierProvider.notifier).markAsRead(notification.id);
                    }
                    final orderId = notification.data['orderId'] as String?;
                    if (orderId != null) {
                      context.pushNamed(AppRoutes.orderDetails, pathParameters: {'orderId': orderId});
                    }
                  } : null,
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}