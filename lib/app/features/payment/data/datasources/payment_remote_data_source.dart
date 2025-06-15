import 'dart:developer';
import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

abstract class PaymentRemoteDataSource {
  Future<String?> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  });
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  @override
  Future<String?> processSslCommerzPayment({
    required double amount,
    required String transactionId,
  }) async {
    try {
      Sslcommerz sslcommerz = Sslcommerz(
        initializer: SSLCommerzInitialization(
          store_id: "edigi677dec8fa96b7",
          store_passwd: "edigi677dec8fa96b7@ssl",
          total_amount: amount,
          tran_id: transactionId,
          currency: SSLCurrencyType.BDT,
          sdkType: SSLCSdkType.TESTBOX, //
          product_category: "E-Commerce",
          multi_card_name: "visa,master,bkash",
        ),
      );

      final response = await sslcommerz.payNow();

      if (response.status == 'VALID') {
        log("SSL commerze response ${response.toString()}");
        log('Payment completed, TRX ID: ${response.tranId}');
        log('Payment Date: ${response.tranDate}');
        log('Amount: ${response.amount}');
        log('Currency: ${response.tranId}');

        // Check for additional details like bank transaction ID if available
        if (response.bankTranId != null && response.bankTranId!.isNotEmpty) {
          log('Bank Transaction ID: ${response.bankTranId}');
        }
        // Payment completed successfully
        log('Payment completed, TRX ID: ${response.tranId}');
        log('Payment Date: ${response.tranDate}');
        return response.tranId;
      } else if (response.status == 'Closed') {
        log('Payment closed');
        return null;
      } else if (response.status == 'FAILED') {
        log('Payment failed');
        return null;
      }
      else{
        return null;
      }
    } catch (e) {
      log('Error during SSLCommerz payment: $e');
      return null;
    }
  }
}