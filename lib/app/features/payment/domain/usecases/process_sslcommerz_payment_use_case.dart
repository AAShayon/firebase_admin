import '../repositories/payment_repository.dart';

class ProcessSslCommerzPaymentUseCase {
  final PaymentRepository repository;
  ProcessSslCommerzPaymentUseCase(this.repository);

  Future<bool> call({required double amount, required String transactionId}) {
    return repository.processSslCommerzPayment(amount: amount, transactionId: transactionId);
  }
}