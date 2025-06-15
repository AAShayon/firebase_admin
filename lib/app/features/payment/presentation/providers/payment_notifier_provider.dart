import 'package:firebase_admin/app/features/payment/presentation/providers/payment_notifier.dart';
import 'package:firebase_admin/app/features/payment/presentation/providers/payment_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final paymentNotifierProvider = StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
      (ref) => PaymentNotifier(ref),
);