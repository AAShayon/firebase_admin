// lib/features/dashboard/data/repositories/dashboard_repository_impl.dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../orders/data/models/order_model.dart';
import '../../../products/data/models/product_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore;

  DashboardRepository(this._firestore);

  Future<int?> getTotalProducts() async {
    final snapshot = await _firestore.collection('products').count().get();
    return snapshot.count;
  }

  Future<double> getTotalSales() async {
    final snapshot = await _firestore.collection('orders')
        .where('status', isEqualTo: 'completed')
        .get();

    return snapshot.docs.fold(0.0, (sum, doc) {
      return sum + (doc.data()['total'] ?? 0).toDouble();
    });
  }

  Future<int?> getTotalCustomers() async {
    final snapshot = await _firestore.collection('users').count().get();
    return snapshot.count;
  }

  Future<List<ProductModel>> getLowStockProducts() async {
    final snapshot = await _firestore.collection('products')
        .where('stock', isLessThan: 10)
        .get();

    return snapshot.docs.map(ProductModel.fromFirestore).toList();
  }

  Future<List<OrderModel>> getRecentOrders() async {
    final snapshot = await _firestore.collection('orders')
        .orderBy('date', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map(OrderModel.fromFirestore).toList();
  }
}