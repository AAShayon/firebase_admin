// lib/app/features/order/domain/repositories/order_repository.dart
import '../../../../core/helpers/enums.dart';
import '../entities/order_entity.dart';


abstract class OrderRepository {
  Future<String> createOrder(OrderEntity order,String namePrefix);
  Stream<List<OrderEntity>> getUserOrders(String userId);
  Stream<List<OrderEntity>> getAllOrders();
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus);
  Future<OrderEntity> getOrderById(String orderId);
  Stream<OrderEntity> watchOrderById(String orderId);
  Future<String?> getLastOrderId();
}