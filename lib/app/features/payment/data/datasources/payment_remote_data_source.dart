import 'dart:developer';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

abstract class PaymentRemoteDataSource {
  Future<bool> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  @override
  Future<bool> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  }) async {
    try {
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          store_id: "edigi677dec8fa96b7", // Using your requested sandbox ID
          store_passwd: "edigi677dec8fa96b7@ssl", // Matching sandbox password
          ipn_url: "your_ipn_listener_url", // Optional: for server-to-server confirmation
          total_amount: amount,
          tran_id: transactionId, // The unique ID we generate
          currency: SSLCurrencyType.BDT,
          sdkType: SSLCSdkType.TESTBOX, // Use TESTBOX for sandbox
          product_category: "E-Commerce",
          multi_card_name: "visa,master,bkash",
        ),
      );

      final response = await sslcommerz.payNow();

      if (response != null && response.status?.toLowerCase() == 'valid') {
        log("SSLCommerz Payment Successful: ${response.toJson()}");
        return true;
      } else {
        log("SSLCommerz Payment Failed or Closed: ${response?.status} - ${response?.bankTranId}");
        return false;
      }
    } catch (e) {
      log('Error during SSLCommerz payment: $e');
      return false;
    }
  }
}