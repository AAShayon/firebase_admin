// lib/app/features/order/data/repositories/order_repository_impl.dart
import '../../../../core/helpers/enums.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';
import '../models/order_model.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl({required this.remoteDataSource});

  OrderModel _toModel(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      userId: entity.userId,
      items: entity.items.map((item) => OrderItem(
        productId: item.productId,
        productTitle: item.productTitle,
        variantSize: item.variantSize,
        variantColorName: item.variantColorName,
        price: item.price,
        quantity: item.quantity,
        imageUrl: item.imageUrl,
      )).toList(),
      totalAmount: entity.totalAmount,
      orderDate: entity.orderDate,
      status: entity.status,
      shippingAddress: entity.shippingAddress,
      billingAddress: entity.billingAddress,
      paymentMethod: entity.paymentMethod,
      transactionId: entity.transactionId,
    );
  }

  OrderEntity _toEntity(OrderModel model) {
    return OrderEntity(
      id: model.id,
      userId: model.userId,
      items: model.items.map((item) => OrderItemEntity(
        productId: item.productId,
        productTitle: item.productTitle,
        variantSize: item.variantSize,
        variantColorName: item.variantColorName,
        price: item.price,
        quantity: item.quantity,
        imageUrl: item.imageUrl,
      )).toList(),
      totalAmount: model.totalAmount,
      orderDate: model.orderDate,
      status: model.status,
      shippingAddress: model.shippingAddress,
      billingAddress: model.billingAddress,
      paymentMethod: model.paymentMethod,
      transactionId: model.transactionId,
    );
  }

  @override
  Future<String> createOrder(OrderEntity order) async {
    final model = _toModel(order);
    return await remoteDataSource.createOrder(model);
  }

  @override
  Stream<List<OrderEntity>> getUserOrders(String userId) {
    return remoteDataSource.getUserOrders(userId).map((orders) {
      return orders.map((order) => _toEntity(order)).toList();
    });
  }

  @override
  Stream<List<OrderEntity>> getAllOrders() {
    return remoteDataSource.getAllOrders().map((orders) {
      return orders.map((order) => _toEntity(order)).toList();
    });
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    await remoteDataSource.updateOrderStatus(orderId, newStatus);
  }
}