part of 'service.dart';

/// Handles FCM messages that arrive when the app is terminated or in the background.
/// This must be a top-level function, not a class method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    // Ensure Firebase is initialized for this isolate.
    await Firebase.initializeApp();
    debugPrint("--- Background Message Handler triggered by FCM ---");
    // Payloads may contain user-specific fields; never log raw FCM data.
    if (message.notification == null) {
      await _showLocalizedNotification(message.data, background: true);
    }
    // Notification+data payloads are normally presented by the OS in background.
    await _reportNotificationReceipt(message.data);
  } catch (e, s) {
    debugPrint("FATAL: Error in firebaseMessagingBackgroundHandler: $e\n$s");
  }
}

/// This reports app-handled notifications, not guaranteed OS banner delivery.
Future<void> _reportNotificationReceipt(Map<String, dynamic> data) async {
  final id = data['vertex_notification_id'];
  if (id is! String || !RegExp(r'^[a-f0-9]{64}
/// It dynamically selects the correct channel based on the payload.
Future<void> _showLocalizedNotification(Map<String, dynamic> data,
    {bool background = false, RemoteNotification? original}) async {
  final notificationContent = await _buildLocalizedContent(data);
  final String title = (notificationContent['title']?.isNotEmpty == true
      ? notificationContent['title']
      : original?.title) ?? '';
  final String body = (notificationContent['body']?.isNotEmpty == true
      ? notificationContent['body']
      : original?.body) ?? '';
  if (title.isEmpty) {
    debugPrint('[Notification Displayer] No notification text available.');
    return;
  }

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

  final plugin = FlutterLocalNotificationsPlugin();
  if (background) {
    // Background handlers run in a separate isolate; plugin initialization
    // performed by the foreground service does not carry over.
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }
  await plugin.show(
    DateTime.now().millisecondsSinceEpoch.toSigned(31),
    title,
    body,
    platformDetails,
    payload: jsonEncode(data),
  );
}
).hasMatch(id)) return;
  if (FirebaseAuth.instance.currentUser == null) return;
  try {
    await FirebaseFunctions.instanceFor(region: 'europe-west1')
        .httpsCallable('recordNotificationReceipt')
        .call(<String, dynamic>{'taskId': id});
  } catch (_) {
    // Receipt telemetry must never prevent a notification from being shown.
    debugPrint('[Extrovert] Notification receipt unavailable.');
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
    DateTime.now().millisecondsSinceEpoch.toSigned(31),
    title,
    body,
    platformDetails,
    payload: jsonEncode(data),
  );
}
