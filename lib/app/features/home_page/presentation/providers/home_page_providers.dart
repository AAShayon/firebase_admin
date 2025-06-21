import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../promotions/domain/entities/promotion_entity.dart';
import '../../../shared/domain/entities/product_entity.dart';
import 'home_page_notifier_provider.dart';




// The animation callback provider remains
typedef RunAnimationCallback = void Function(GlobalKey, ProductEntity, PromotionEntity?);
final homeAnimationProvider = StateProvider<RunAnimationCallback?>((ref) => null);

// We can now use the notifier's state instead of this separate provider
final addingToCartProvider = Provider<String?>((ref) {
  return ref.watch(homePageNotifierProvider).cartProductId;
});