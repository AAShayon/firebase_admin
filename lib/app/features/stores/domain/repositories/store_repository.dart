// lib/features/stores/domain/repositories/store_repository.dart
import 'package:fpdart/fpdart.dart';
import '../../../../core/errors/failures.dart';
import '../entities/store_entity.dart';

abstract class StoreRepository {
  Future<Either<Failure, List<StoreEntity>>> getStores();
  Future<Either<Failure, String>> createStore(StoreEntity store);
  Future<Either<Failure, void>> linkProductToStore(String storeId, String productId);
}