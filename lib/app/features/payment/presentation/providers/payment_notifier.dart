import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'payment_providers.dart';
import 'payment_state.dart';

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;
  PaymentNotifier(this._ref) : super(const PaymentState.initial());


  String _generateTransactionId() {
    return 'TRX-${DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '')}';
  }

  Future<bool> processPayment({required double amount}) async {
    state = const PaymentState.loading();
    try {
      final useCase = _ref.read(processSslCommerzPaymentUseCaseProvider);
      final transactionId = _generateTransactionId();

      final success = await useCase(amount: amount, transactionId: transactionId);

      if (success) {
        state = const PaymentState.success();
        return true;
      } else {
        state = const PaymentState.failure('Payment failed or was cancelled by the user.');
        return false;
      }
    } catch (e) {
      state = PaymentState.failure(e.toString());
      return false;
    }
  }
}