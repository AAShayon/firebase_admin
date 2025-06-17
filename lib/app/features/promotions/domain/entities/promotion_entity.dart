enum DiscountType { percentage, fixedAmount }
enum PromotionScope { allProducts, specificProducts }

class PromotionEntity {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DiscountType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final String? couponCode;
  final int? usageLimit;
  final int timesUsed;

  // --- ADD THESE NEW PROPERTIES ---
  final PromotionScope scope;
  final List<String> productIds;

  PromotionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.couponCode,
    this.usageLimit,
    this.timesUsed = 0,
    // --- ADD TO CONSTRUCTOR ---
    required this.scope,
    required this.productIds,
  });

  bool get isActive {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  bool get isCouponAvailable {
    if (usageLimit == null || usageLimit == 0) return true; // Unlimited uses
    return timesUsed < usageLimit!;
  }
}
