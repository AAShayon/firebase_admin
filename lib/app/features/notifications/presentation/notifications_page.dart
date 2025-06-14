import 'package:firebase_admin/app/features/notifications/presentation/providers/notification_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/routes/app_router.dart';



class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. WATCH the stream provider to get the list of notifications.
    //    This will automatically rebuild the UI when data changes in Firestore.
    final notificationsAsync = ref.watch(notificationsStreamProvider);

    return Scaffold(
      // The AppBar is likely managed by your LandingPage, so we comment it out here.
      // If this is a standalone page, you can add an AppBar.
      // appBar: AppBar(
      //   title: const Text('Notifications'),
      // ),
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
          return ListView.separated(
            itemCount: notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = notifications[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: notification.isRead
                      ? Colors.grey.shade300
                      : Theme.of(context).primaryColor,
                  child: Icon(
                    Icons.receipt_long, // Icon for an order
                    color: notification.isRead ? Colors.grey[600] : Colors.white,
                  ),
                ),
                title: Text(
                  notification.title,
                  style: TextStyle(
                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                    color: notification.isRead ? Colors.grey[600] : Colors.black87,
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
                onTap: () {
                  // 2. READ the notifier to TRIGGER an action.
                  //    Use `ref.read` in callbacks like `onTap`.
                  if (!notification.isRead) {
                    ref
                        .read(notificationNotifierProvider.notifier)
                        .markAsRead(notification.id);
                  }

                  // 3. Optional: Navigate to the order details page.
                  final orderId = notification.data['orderId'] as String?;
                  if (orderId != null) {

                    context.pushNamed(AppRoutes.orderDetails, pathParameters: {'orderId': orderId});
                  }
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }
}