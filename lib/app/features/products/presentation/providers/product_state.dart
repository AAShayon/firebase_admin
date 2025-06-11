import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../shared/domain/entities/product_entity.dart';


part 'product_state.freezed.dart';

// lib/app/features/products/presentation/providers/product_state.dart
@freezed
class ProductState with _$ProductState {
  const factory ProductState.initial() = _Initial;
  const factory ProductState.loading() = _Loading;
  const factory ProductState.loaded(List<ProductEntity> products) = _Loaded;
  const factory ProductState.error(String message) = _Error;
  const factory ProductState.added() = _Added;
  const factory ProductState.updated() = _Updated; // ADDED
  const factory ProductState.deleted() = _Deleted; // ADDED
}