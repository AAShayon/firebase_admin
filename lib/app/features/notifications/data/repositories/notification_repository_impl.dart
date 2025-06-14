import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/notification_model.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Stream<List<NotificationEntity>> getNotifications() {
    return remoteDataSource.getNotifications().map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return remoteDataSource.markAsRead(notificationId);
  }

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    final data = {
      'title': notification.title,
      'body': notification.body,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
      'type': 'new_order', // Example
      'data': notification.data,
    };
    await remoteDataSource.createNotification(data);
  }
  @override
  Stream<List<NotificationEntity>> getPublicNotifications() {
    return remoteDataSource.getPublicNotifications().map((snapshots) {
      return snapshots.map((doc) => NotificationModel.fromSnapshot(doc)).toList();
    });
  }
}