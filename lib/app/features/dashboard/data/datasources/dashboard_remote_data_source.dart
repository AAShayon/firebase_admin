import 'package:cloud_firestore/cloud_firestore.dart';
// You no longer need 'dart:convert' or 'http' here.

abstract class DashboardRemoteDataSource {
  Future<int> getTotalProductCount();
  Future<int> getTotalCustomerCount();
  Future<double> getTotalSales();
  Future<int> getLowStockCount();
  Stream<QuerySnapshot> getOrdersFromLast7Days();
  Future<void> sendNotificationToAllUsers({
    required Map<String, dynamic> notificationData,
  });
  Future<void> sendNotificationToUser({
    required String userId,
    required Map<String, dynamic> notificationData,
  });

  // --- UPDATED METHOD ---
  Future<void> createNotification(Map<String, dynamic> notificationData);
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final FirebaseFirestore _firestore;

  DashboardRemoteDataSourceImpl({required FirebaseFirestore firestore})
      : _firestore = firestore;

  @override
  Future<int> getTotalProductCount() async {
    final snapshot = await _firestore.collection('products').count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<int> getTotalCustomerCount() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count ?? 0;
  }

  @override
  Future<double> getTotalSales() async {
    final snapshot = await _firestore.collection('orders').get();
    if (snapshot.docs.isEmpty) return 0.0;

    double total = 0.0;
    for (var doc in snapshot.docs) {
      total += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }
    return total;
  }

  @override
  Future<int> getLowStockCount({int threshold = 10}) async {
    final snapshot = await _firestore.collection('products').where('stock', isLessThan: threshold).count().get();
    return snapshot.count ?? 0;
  }
  @override
  Future<void> createNotification(Map<String, dynamic> notificationData) {
    return _firestore.collection('notifications').add(notificationData);
  }
  @override
  Stream<QuerySnapshot> getOrdersFromLast7Days() {
    final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
    return _firestore
        .collection('orders')
        .where('orderDate', isGreaterThanOrEqualTo: sevenDaysAgo)
        .snapshots();
  }
  @override
  Future<void> sendNotificationToUser({
    required String userId,
    required Map<String, dynamic> notificationData,
  }) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notificationData);
  }

  @override
  Future<void> sendNotificationToAllUsers({
    required Map<String, dynamic> notificationData,
  }) async {
    // WARNING: This is inefficient for a large number of users.
    // A backend (Cloud Function) is the proper way to do this at scale.
    // But for your requirements, this client-side loop will work.
    final usersSnapshot = await _firestore.collection('users').where('isAdmin', isEqualTo: false).get();

    final WriteBatch batch = _firestore.batch();
    for (final userDoc in usersSnapshot.docs) {
      final notificationRef = userDoc.reference.collection('notifications').doc();
      batch.set(notificationRef, notificationData);
    }
    return batch.commit();
  }
}