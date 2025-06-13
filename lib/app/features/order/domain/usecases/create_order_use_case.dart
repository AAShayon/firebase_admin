// lib/app/features/order/domain/usecases/create_order_use_case.dart
import '../repositories/order_repository.dart';
import '../entities/order_entity.dart';

class CreateOrderUseCase {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  Future<String> call(OrderEntity order) async {
    return await repository.createOrder(order);
  }
}