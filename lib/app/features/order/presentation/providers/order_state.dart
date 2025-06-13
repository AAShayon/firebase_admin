// lib/app/features/order/presentation/providers/order_state.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:firebase_admin/app/features/order/domain/entities/order_entity.dart';

part 'order_state.freezed.dart';


@freezed
class OrderState with _$OrderState {
  const factory OrderState.initial() = _Initial;

  const factory OrderState.loading() = _Loading;

  const factory OrderState.success(String message) = _Success;

  const factory OrderState.loaded(List<OrderItemEntity> items) = _Loaded;

  const factory OrderState.error(String message) = _Error;
}