// lib/features/stores/domain/usecases/get_stores_usecase.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';
import '../repositories/store_repository.dart';


class GetStoresUseCase {
  final StoreRepository repository;

  GetStoresUseCase(this.repository);

  Future<List<StoreEntity>> call() async {
    return (await repository.getStores()).fold(
          (failure) => throw failure,
          (stores) => stores,
    );
  }
}