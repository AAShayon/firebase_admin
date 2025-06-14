import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<DocumentSnapshot>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> createNotification(Map<String, dynamic> notificationData);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Stream<List<DocumentSnapshot>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to the last 50 notifications for performance
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Future<void> markAsRead(String notificationId) {
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Future<void> createNotification(Map<String, dynamic> notificationData) {
    return _firestore.collection('notifications').add(notificationData);
  }
}