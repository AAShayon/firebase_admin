import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FcmService {
  static const String _serverKey = 'PASTE_YOUR_FCM_SERVER_KEY_HERE';

  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Sends a "New Order" notification to all registered admins.
  static Future<void> sendNewOrderNotificationToAdmins({
    required String orderId,
    required String customerName,
    required double totalAmount,
  }) async {
    try {
      // 1. Get all admin documents from the 'admins' collection.
      final adminsSnapshot = await _firestore.collection('admins').get();
      if (adminsSnapshot.docs.isEmpty) {
        print('FCM: No admin users found.');
        return;
      }

      List<String> allAdminTokens = [];

      // 2. Fetch all tokens for each admin.
      for (final adminDoc in adminsSnapshot.docs) {
        final tokensSnapshot = await adminDoc.reference.collection('tokens').get();
        for (final tokenDoc in tokensSnapshot.docs) {
          allAdminTokens.add(tokenDoc.id);
        }
      }

      if (allAdminTokens.isEmpty) {
        print('FCM: No admin device tokens found.');
        return;
      }

      // 3. Construct the FCM payload.
      final body = {
        "registration_ids": allAdminTokens, // Use for sending to a list of tokens
        "notification": {
          "title": "🎉 New Order Received!",
          "body": "From: $customerName - Amount: \$${totalAmount.toStringAsFixed(2)}",
          "sound": "default",
        },
        // 'data' payload is for handling notifications when the app is in the background/terminated.
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK",
          "type": "NEW_ORDER",
          "orderId": orderId,
        },
      };

      // 4. Send the HTTP POST request to the FCM endpoint.
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$_serverKey',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        print('FCM: Admin notifications sent successfully.');
      } else {
        print('FCM: Failed to send notifications. Status: ${response.statusCode}');
        print('FCM Response body: ${response.body}');
      }
    } catch (e) {
      print('FCM: Error sending message to admins: $e');
    }
  }
}