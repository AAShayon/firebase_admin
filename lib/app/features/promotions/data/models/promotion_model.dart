import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/promotion_entity.dart';

class PromotionModel extends PromotionEntity {
  PromotionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    required super.discountType,
    required super.discountValue,
    required super.startDate,
    required super.endDate,
    super.couponCode,
    super.usageLimit,
    super.timesUsed,
    required super.scope,
    required super.productIds,
    required super.target,
    required super.targetUserIds,
  });

  factory PromotionModel.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PromotionModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      discountType:
          (data['discountType'] == 'percentage')
              ? DiscountType.percentage
              : DiscountType.fixedAmount,
      discountValue: (data['discountValue'] as num?)?.toDouble() ?? 0.0,
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      couponCode: data['couponCode'],
      usageLimit: data['usageLimit'],
      timesUsed: data['timesUsed'] ?? 0,
      scope: _stringToScope(data['scope']),
      productIds: List<String>.from(data['productIds'] ?? []),
      target: (data['target'] == 'specificUsers') ? PromotionTarget.specificUsers : PromotionTarget.all,
      targetUserIds: List<String>.from(data['targetUserIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'discountType': describeEnum(discountType),
      'discountValue': discountValue,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'couponCode': couponCode,
      'usageLimit': usageLimit,
      'timesUsed': timesUsed,
      'scope': describeEnum(scope),
      'productIds': productIds,
      'target': describeEnum(target),
      'targetUserIds': targetUserIds,
    };
  }

  static PromotionScope _stringToScope(String? scope) {
    return scope == 'specificProducts'
        ? PromotionScope.specificProducts
        : PromotionScope.allProducts;
  }
}
