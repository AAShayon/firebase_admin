import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cart_notifier.dart';
import 'cart_state.dart';

final cartNotifierProvider = StateNotifierProvider<CartNotifier, CartState>(
      (ref) => CartNotifier(ref),
);