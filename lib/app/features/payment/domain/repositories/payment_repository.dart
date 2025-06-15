abstract class PaymentRepository {
  // Returns true on success, false on failure/cancellation.
  Future<String?> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  });
}