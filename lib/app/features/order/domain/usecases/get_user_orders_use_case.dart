// lib/app/features/order/domain/usecases/get_user_orders_use_case.dart
import '../repositories/order_repository.dart';
import '../entities/order_entity.dart';

class GetUserOrdersUseCase {
  final OrderRepository repository;

  GetUserOrdersUseCase(this.repository);

  Stream<List<OrderEntity>> call(String userId) {
    return repository.getUserOrders(userId);
  }
}