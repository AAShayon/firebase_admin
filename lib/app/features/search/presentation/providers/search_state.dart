import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/domain/entities/product_entity.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  // Add query to the loaded state
  const factory SearchState.loaded({
    required String query,
    required List<ProductEntity> products,
  }) = _Loaded;
  const factory SearchState.error(String message) = _Error;
}