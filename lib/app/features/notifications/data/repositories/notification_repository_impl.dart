import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    final data = {
      'title': notification.title,
      'body': notification.body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': notification.type.toString().split('.').last,
      'data': notification.data,
    };
    await remoteDataSource.createNotification(data);
  }

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications().map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Stream<List<NotificationEntity>> getPublicNotifications() {
    return remoteDataSource.getPublicNotifications().map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Stream<List<NotificationEntity>> getTargetedNotifications(String userId) {
    return remoteDataSource.getTargetedNotifications(userId).map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> markAsRead(String notificationId, String adminId) {
    return remoteDataSource.markAsRead(notificationId, adminId);
  }
  @override
  Stream<List<NotificationEntity>> getUserPrivateNotifications(String userId) {
    return remoteDataSource.getUserPrivateNotifications(userId).map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }
  @override
  Future<void> markAdminNotificationAsRead(String notificationId, String adminId) {
    return remoteDataSource.markAdminNotificationAsRead(notificationId, adminId);
  }

  // --- NEW IMPLEMENTATION for User ---
  @override
  Future<void> markUserNotificationAsRead(String notificationId, String userId) {
    return remoteDataSource.markUserNotificationAsRead(notificationId, userId);
  }
}