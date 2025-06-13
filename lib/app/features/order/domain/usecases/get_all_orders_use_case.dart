// lib/app/features/order/domain/usecases/get_all_orders_use_case.dart
import '../repositories/order_repository.dart';
import '../entities/order_entity.dart';

class GetAllOrdersUseCase {
  final OrderRepository repository;

  GetAllOrdersUseCase(this.repository);

  Stream<List<OrderEntity>> call() {
    return repository.getAllOrders();
  }
}