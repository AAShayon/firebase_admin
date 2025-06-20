// lib/core/utils/price_calculator.dart
import '../../features/promotions/domain/entities/promotion_entity.dart';
import '../../features/shared/domain/entities/product_entity.dart';

/// Calculates the final price of a product variant considering a potential promotion.
///
/// [product]: The parent product, needed to check if it's part of a specific promotion.
/// [variant]: The specific variant whose price is being calculated.
/// [promotion]: An optional active promotion to apply.
///
/// Returns the discounted price if the promotion is valid and applies to the product,
/// otherwise returns the original variant price.
double calculateFinalPrice({
  required ProductEntity product,
  required ProductVariantEntity variant,
  PromotionEntity? promotion,
}) {
  final originalPrice = variant.price;

  if (promotion == null || !promotion.isActive) {
    return originalPrice;
  }

  bool isPromotionApplicable = false;
  // Check if the promotion applies to this specific product
  if (promotion.scope == PromotionScope.allProducts || promotion.productIds.contains(product.id)) {
    isPromotionApplicable = true;
  }

  if (!isPromotionApplicable) {
    return originalPrice;
  }

  // Calculate the discounted price
  double discountedPrice;
  if (promotion.discountType == DiscountType.fixedAmount) {
    discountedPrice = originalPrice - promotion.discountValue;
  } else { // Percentage
    discountedPrice = originalPrice * (1 - (promotion.discountValue / 100));
  }

  // Ensure the price doesn't go below zero
  return discountedPrice < 0 ? 0.0 : discountedPrice;
}