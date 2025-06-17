import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/injector.dart';
import '../../domain/entities/promotion_entity.dart';
import '../../domain/usecases/create_promotion_use_case.dart';
import '../../domain/usecases/delete_promotion_use_case.dart';
import '../../domain/usecases/get_active_promotions_use_case.dart';
import '../../domain/usecases/get_all_promotions_use_case.dart';
import '../../domain/usecases/redeem_coupon_use_case.dart';
import '../../domain/usecases/update_promotion_use_case.dart';
import '../../domain/usecases/validate_coupon_use_case.dart';


// --- USE CASE PROVIDERS ---
final createPromotionUseCaseProvider = Provider<CreatePromotionUseCase>((ref) => locator<CreatePromotionUseCase>());
final updatePromotionUseCaseProvider = Provider<UpdatePromotionUseCase>((ref) => locator<UpdatePromotionUseCase>());
final deletePromotionUseCaseProvider = Provider<DeletePromotionUseCase>((ref) => locator<DeletePromotionUseCase>());
final getAllPromotionsUseCaseProvider = Provider<GetAllPromotionsUseCase>((ref) => locator<GetAllPromotionsUseCase>());
final getActivePromotionsUseCaseProvider = Provider<GetActivePromotionsUseCase>((ref) => locator<GetActivePromotionsUseCase>());
final validateCouponUseCaseProvider = Provider<ValidateCouponUseCase>((ref) => locator<ValidateCouponUseCase>());
final redeemCouponUseCaseProvider = Provider<RedeemCouponUseCase>((ref) => locator<RedeemCouponUseCase>());


// --- UI DATA PROVIDERS ---

// Stream provider for admins to see all promotions
final allPromotionsStreamProvider = StreamProvider.autoDispose<List<PromotionEntity>>((ref) {
  return ref.watch(getAllPromotionsUseCaseProvider)();
});

// Stream provider for users to see only active promotions
final activePromotionsStreamProvider = StreamProvider.autoDispose<List<PromotionEntity>>((ref) {
  return ref.watch(getActivePromotionsUseCaseProvider)();
});