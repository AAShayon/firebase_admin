import 'package:cloud_firestore/cloud_firestore.dart';

abstract class NotificationRemoteDataSource {
  Future<void> createNotification(Map<String, dynamic> notificationData);
  Stream<List<DocumentSnapshot>> getNotifications();
  Stream<List<DocumentSnapshot>> getPublicNotifications();
  Stream<List<DocumentSnapshot>> getTargetedNotifications(String userId);
  Future<void> markAsRead(String notificationId, String adminId);
  Stream<List<DocumentSnapshot>> getUserPrivateNotifications(String userId);
  Future<void> markAdminNotificationAsRead(String notificationId, String adminId);

  // This one targets the private /users/{id}/notifications subcollection
  Future<void> markUserNotificationAsRead(String notificationId, String userId);
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final FirebaseFirestore _firestore;

  NotificationRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<void> createNotification(Map<String, dynamic> notificationData) {
    return _firestore.collection('notifications').add(notificationData);
  }
  @override
  Future<void> markAdminNotificationAsRead(String notificationId, String adminId) {
    // Only admins can mark global notifications as read
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // --- NEW IMPLEMENTATION for User ---
  @override
  Future<void> markUserNotificationAsRead(String notificationId, String userId) {
    // A user marks their own private notification as read
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  @override
  Stream<List<DocumentSnapshot>> getNotifications() {
    return _firestore
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }
  @override
  Stream<List<DocumentSnapshot>> getUserPrivateNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Stream<List<DocumentSnapshot>> getPublicNotifications() {
    return _firestore
        .collection('notifications')
        .where('type', whereIn: ['promotion', 'coupon', 'stock_alert'])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Stream<List<DocumentSnapshot>> getTargetedNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('data.target', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) => snapshot.docs);
  }

  @override
  Future<void> markAsRead(String notificationId, String adminId) {
    return _firestore
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}