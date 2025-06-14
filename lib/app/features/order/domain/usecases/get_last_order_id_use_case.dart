import '../repositories/order_repository.dart';

class GetLastOrderIdUseCase {
  final OrderRepository repository;
  GetLastOrderIdUseCase(this.repository);

  Future<String?> call() {
    return repository.getLastOrderId();
  }
}