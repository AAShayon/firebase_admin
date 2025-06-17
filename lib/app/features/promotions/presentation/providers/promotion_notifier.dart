import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/promotion_entity.dart';
import 'promotion_providers.dart';
import 'promotion_state.dart';

class PromotionNotifier extends StateNotifier<PromotionState> {
  final Ref _ref;
  PromotionNotifier(this._ref) : super(const PromotionState.initial());

  Future<void> createPromotion(PromotionEntity promotion) async {
    state = const PromotionState.loading();
    try {
      await _ref.read(createPromotionUseCaseProvider).call(promotion);
      state = const PromotionState.success('Promotion created successfully!');
    } catch (e) {
      state = PromotionState.error(e.toString());
    }
  }

  Future<void> updatePromotion(PromotionEntity promotion) async {
    state = const PromotionState.loading();
    try {
      await _ref.read(updatePromotionUseCaseProvider).call(promotion);
      state = const PromotionState.success('Promotion updated successfully!');
    } catch (e) {
      state = PromotionState.error(e.toString());
    }
  }

  Future<void> deletePromotion(String promotionId) async {
    state = const PromotionState.loading();
    try {
      await _ref.read(deletePromotionUseCaseProvider).call(promotionId);
      state = const PromotionState.success('Promotion deleted.');
    } catch (e) {
      state = PromotionState.error(e.toString());
    }
  }
}