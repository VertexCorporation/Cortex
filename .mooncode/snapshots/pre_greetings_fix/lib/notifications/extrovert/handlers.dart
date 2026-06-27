part of 'service.dart';

/// Handles FCM messages that arrive when the app is terminated or in the background.
/// This must be a top-level function, not a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Ensure Firebase is initialized for this isolate.
    await Firebase.initializeApp();
    debugPrint("--- Background Message Handler triggered by FCM ---");
    debugPrint("FCM Data payload: ${message.data}");
    await _showLocalizedNotification(message.data);
  } catch (e, s) {
    debugPrint("FATAL: Error in firebaseMessagingBackgroundHandler: $e\n$s");
  }
}

/// Displays the notification using FlutterLocalNotifications.
/// It dynamically selects the correct channel based on the payload.
Future<void> _showLocalizedNotification(Map<String, dynamic> data) async {
  final notificationContent = await _buildLocalizedContent(data);
  if (notificationContent.isEmpty || notificationContent['title']!.isEmpty) {
    debugPrint(
        "[Notification Displayer] Could not build localized content. Aborting display.");
    return;
  }

  final String title = notificationContent['title']!;
  final String body = notificationContent['body']!;

  final String channelId = data['channel_id'] ?? 'cortex_notifications';
  final String channelName = data['channel_name'] ?? 'Cortex Updates';
  final String channelDescription = data['channel_desc'] ??
      'Notifications about news and updates from Cortex.';

  final BigTextStyleInformation bigTextStyleInformation =
  BigTextStyleInformation(
    body,
    htmlFormatBigText: false,
    contentTitle: title,
    htmlFormatContentTitle: false,
  );

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    channelId,
    channelName,
    channelDescription: channelDescription,
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: bigTextStyleInformation,
  );

  final NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ));

  await FlutterLocalNotificationsPlugin().show(
    DateTime
        .now()
        .millisecondsSinceEpoch
        .toSigned(31),
    title,
    body,
    platformDetails,
    payload: jsonEncode(data),
  );
}
