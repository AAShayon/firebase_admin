// lib/app/features/order/domain/usecases/update_order_status_use_case.dart
import '../../../../core/helpers/enums.dart';
import '../repositories/order_repository.dart';

class UpdateOrderStatusUseCase {
  final OrderRepository repository;

  UpdateOrderStatusUseCase(this.repository);

  Future<void> call(String orderId, OrderStatus newStatus) async {
    await repository.updateOrderStatus(orderId, newStatus);
  }
}