import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'promotion_notifier.dart';
import 'promotion_state.dart';

final promotionNotifierProvider =
StateNotifierProvider.autoDispose<PromotionNotifier, PromotionState>((ref) {
  return PromotionNotifier(ref);
});