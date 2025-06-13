import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'checkout_notifier.dart';
import 'checkout_state.dart';

final checkoutNotifierProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref);
});