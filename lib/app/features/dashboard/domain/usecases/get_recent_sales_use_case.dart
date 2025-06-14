import '../entities/sales_data_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentSalesUseCase {
  final DashboardRepository repository;
  GetRecentSalesUseCase(this.repository);

  Stream<List<SalesDataEntity>> call() => repository.getRecentSales();
}