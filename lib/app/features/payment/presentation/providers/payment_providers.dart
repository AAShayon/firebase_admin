import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/usecases/process_sslcommerz_payment_use_case.dart';


// Use Case
final processSslCommerzPaymentUseCaseProvider = Provider<ProcessSslCommerzPaymentUseCase>(
      (ref) => locator<ProcessSslCommerzPaymentUseCase>(),
);
