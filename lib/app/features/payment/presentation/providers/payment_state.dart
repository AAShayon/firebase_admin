import 'package:freezed_annotation/freezed_annotation.dart';
part 'payment_state.freezed.dart';

@freezed
class PaymentState with _$PaymentState {
  const factory PaymentState.initial() = _Initial;
  const factory PaymentState.loading() = _Loading;
  const factory PaymentState.success(String transactionId) = _Success;
  const factory PaymentState.failure(String message) = _Failure;
}