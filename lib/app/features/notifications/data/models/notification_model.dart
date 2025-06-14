import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.createdAt,
    required super.isRead,
    required super.type,
    required super.data,
  });

  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      createdAt: (json['createdAt'] as Timestamp).toDate(),
      isRead: json['isRead'] ?? false,
      type: _stringToNotificationType(json['type']),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  static NotificationType _stringToNotificationType(String? type) {
    switch (type) {
      case 'new_order':
        return NotificationType.newOrder;
      case 'stock_alert':
        return NotificationType.stockAlert;
      default:
        return NotificationType.unknown;
    }
  }
}