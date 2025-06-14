import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderByIdUseCase {
  final OrderRepository repository;
  GetOrderByIdUseCase(this.repository);

  Future<OrderEntity> call(String orderId) {
    return repository.getOrderById(orderId);
  }
}