import '../../domain/repositories/payment_repository.dart';
import '../datasources/payment_remote_data_source.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  PaymentRepositoryImpl({required this.remoteDataSource});

  @override
  Future<bool> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  }) {
    return remoteDataSource.processSslCommerzPayment(amount: amount, transactionId: transactionId);
  }
}