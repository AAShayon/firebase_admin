import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/cart_item_entity.dart';


part 'cart_state.freezed.dart';

@freezed
class CartState with _$CartState {
  /// The initial state before any action has been taken.
  const factory CartState.initial() = _Initial;

  /// State when an operation (add, update, remove, etc.) is in progress.
  const factory CartState.loading() = _Loading;

  /// State when the cart items have been successfully loaded.
  /// This is used by the StreamProvider, not typically set by the Notifier.
  const factory CartState.loaded(List<CartItemEntity> items) = _Loaded;

  /// State representing the successful completion of an action (e.g., item added).
  /// The message can be shown in a SnackBar.
  const factory CartState.success(String message) = _Success;

  /// State when an operation has failed.
  const factory CartState.error(String message) = _Error;
}