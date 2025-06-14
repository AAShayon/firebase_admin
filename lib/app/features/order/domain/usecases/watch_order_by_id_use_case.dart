import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class WatchOrderByIdUseCase {
  final OrderRepository repository;
  WatchOrderByIdUseCase(this.repository);

  Stream<OrderEntity> call(String orderId) {
    return repository.watchOrderById(orderId);
  }
}