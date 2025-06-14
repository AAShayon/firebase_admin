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

  // This factory is now simple and correct. It only parses the document.
  factory NotificationModel.fromSnapshot(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Body',
      createdAt: (json['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isRead: json['isRead'] ?? false,
      type: _stringToNotificationType(json['type']),
      data: json['data'] as Map<String, dynamic>? ?? {},
    );
  }

  static NotificationType _stringToNotificationType(String? type) {
    switch (type) {
      case 'newOrder': return NotificationType.newOrder;
      case 'promotion': return NotificationType.promotion;
      case 'coupon': return NotificationType.coupon;
      case 'stock_alert': return NotificationType.stockAlert;
      default: return NotificationType.unknown;
    }
  }
}