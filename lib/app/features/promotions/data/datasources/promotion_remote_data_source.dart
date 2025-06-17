import 'package:cloud_firestore/cloud_firestore.dart';

abstract class PromotionRemoteDataSource {
  Future<void> createPromotion(Map<String, dynamic> data);
  Future<void> updatePromotion(String id, Map<String, dynamic> data);
  Future<void> deletePromotion(String id);
  Stream<QuerySnapshot> getAllPromotions();
  Stream<QuerySnapshot> getActivePromotions();
  Future<QuerySnapshot> getPromotionByCode(String code);
  Future<DocumentSnapshot> getUserRedemption(String promoId, String userId);
  Future<void> redeemCoupon(String promoId, String userId);
}

class PromotionRemoteDataSourceImpl implements PromotionRemoteDataSource {
  final FirebaseFirestore _firestore;
  PromotionRemoteDataSourceImpl({required FirebaseFirestore firestore}) : _firestore = firestore;

  @override
  Future<void> createPromotion(Map<String, dynamic> data) => _firestore.collection('promotions').add(data);
  @override
  Future<void> updatePromotion(String id, Map<String, dynamic> data) => _firestore.collection('promotions').doc(id).update(data);
  @override
  Future<void> deletePromotion(String id) => _firestore.collection('promotions').doc(id).delete();
  @override
  Stream<QuerySnapshot> getAllPromotions() => _firestore.collection('promotions').orderBy('endDate', descending: true).snapshots();
  @override
  Stream<QuerySnapshot> getActivePromotions() => _firestore.collection('promotions').where('endDate', isGreaterThan: Timestamp.now()).snapshots();
  @override
  Future<QuerySnapshot> getPromotionByCode(String code) => _firestore.collection('promotions').where('couponCode', isEqualTo: code.toUpperCase()).limit(1).get();
  @override
  Future<DocumentSnapshot> getUserRedemption(String promoId, String userId) => _firestore.collection('promotions').doc(promoId).collection('redemptions').doc(userId).get();

  @override
  Future<void> redeemCoupon(String promotionId, String userId) {
    final promoRef = _firestore.collection('promotions').doc(promotionId);
    final redemptionRef = promoRef.collection('redemptions').doc(userId);

    return _firestore.runTransaction((transaction) async {
      transaction.update(promoRef, {'timesUsed': FieldValue.increment(1)});
      transaction.set(redemptionRef, {'redeemedAt': FieldValue.serverTimestamp()});
    });
  }
}