enum NotificationType {
  newOrder,
  promotion,
  coupon,
  stockAlert,
  unknown,
}

class NotificationEntity {
  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic> data;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    this.isRead = false,
    this.type = NotificationType.unknown,
    this.data = const {},
  });
}