// lib/app/features/order/presentation/providers/order_notifier_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'order_notifier.dart';
import 'order_state.dart';

final orderNotifierProvider = StateNotifierProvider<OrderNotifier, OrderState>((ref) => OrderNotifier(ref));