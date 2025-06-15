abstract class PaymentRepository {
  // Returns true on success, false on failure/cancellation.
  Future<bool> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  });
}