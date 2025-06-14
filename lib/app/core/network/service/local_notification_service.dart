import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Call this once from your main() function to set up the service.
  static Future<void> initialize() async {
    // Initialization settings for Android.
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher'); // Uses your app's default icon

    // Initialization settings for iOS.
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      settings,
      // This callback handles when a notification is tapped while the app is open.
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null && response.payload!.isNotEmpty) {
          print('Notification payload: ${response.payload}');
          // Here you would add navigation logic. For example:
          // navigatorKey.currentState?.pushNamed('/orders/${response.payload}');
        }
      },
    );
  }

  // Call this method to show a notification.
  static Future<void> showNotification({
    required String title,
    required String body,
    String payload = '',
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'new_order_channel', // A unique ID for the channel
      'New Orders',        // The name of the channel
      channelDescription: 'Notifications for new orders placed in the app.',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.toUnsigned(31), // Unique ID
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }
}