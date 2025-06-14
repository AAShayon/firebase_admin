import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationRemoteDataSource {
  Stream<List<DocumentSnapshot>> getNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> createNotification(Map<String, dynamic> notificationData);
  Stream<List<DocumentSnapshot>> getPublicNotifications();
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
  @override
  Stream<List<DocumentSnapshot>> getPublicNotifications() {
    // Fetches notifications marked with a 'promotion' type.
    return _firestore
        .collection('notifications')
        .where('type', isEqualTo: 'promotion') // Assuming you set this from the dashboard
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
}