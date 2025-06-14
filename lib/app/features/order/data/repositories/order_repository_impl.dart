import '../../../../core/helpers/enums.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  // The _toModel and _toEntity helpers are no longer needed
  // because OrderModel is a direct subclass of OrderEntity.

  @override
  Future<String> createOrder(OrderEntity order) async {
    // We can cast the OrderEntity to an OrderModel because we know
    // that the object coming from the Notifier was created as an OrderEntity,
    // which our model can represent. A more robust way is to create a new model.
    final orderModel = OrderModel(
      id: order.id,
      userId: order.userId,
      items: order.items,
      totalAmount: order.totalAmount,
      orderDate: order.orderDate,
      status: order.status,
      shippingAddress: order.shippingAddress,
      billingAddress: order.billingAddress,
      paymentMethod: order.paymentMethod,
      transactionId: order.transactionId,
    );
    return await remoteDataSource.createOrder(orderModel);
  }

  @override
  Stream<List<OrderEntity>> getUserOrders(String userId) {
    // The remote data source now returns a Stream<List<OrderModel>>.
    // Since OrderModel extends OrderEntity, the list is already compatible.
    // No mapping is needed.
    return remoteDataSource.getUserOrders(userId);
  }

  @override
  Stream<List<OrderEntity>> getAllOrders() {
    // Same as above, the list is already compatible.
    return remoteDataSource.getAllOrders();
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    // This method doesn't deal with models, so it's already correct.
    await remoteDataSource.updateOrderStatus(orderId, newStatus);
  }

  @override
  Future<OrderEntity> getOrderById(String orderId) async {
    final doc = await remoteDataSource.getOrderById(orderId);
    if (!doc.exists) {
      throw Exception('Order with ID $orderId not found.');
    }
    // The fromSnapshot factory returns an OrderModel, which is a valid OrderEntity.
    // No extra conversion is needed.
    return OrderModel.fromSnapshot(doc);
  }
}