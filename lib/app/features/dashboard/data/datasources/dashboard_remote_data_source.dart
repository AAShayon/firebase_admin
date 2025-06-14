import 'package:cloud_firestore/cloud_firestore.dart';
// You no longer need 'dart:convert' or 'http' here.

abstract class DashboardRemoteDataSource {
  Future<int> getTotalProductCount();
  Future<int> getTotalCustomerCount();
  Future<double> getTotalSales();
  Future<int> getLowStockCount();

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
}