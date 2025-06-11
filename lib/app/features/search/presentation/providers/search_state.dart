import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../shared/domain/entities/product_entity.dart';

part 'search_state.freezed.dart';

@freezed
class SearchState with _$SearchState {
  const factory SearchState.initial() = _Initial;
  const factory SearchState.loading() = _Loading;
  const factory SearchState.loaded(List<ProductEntity> products) = _Loaded;
  const factory SearchState.error(String message) = _Error;
}