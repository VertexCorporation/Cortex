// lib/chat/services/send/notify.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// Handles background notification dispatch when asynchronous chat tasks complete.
class BackgroundNotifier {
  /// Gets the conversation title for the notification.
  static Future<String> getChatTitle(String convId) async {
    try {
      final db = await ChatStorageService.getConversationTitle(convId);
      return db ?? 'Chat';
    } catch (_) {
      return 'Chat';
    }
  }

  /// Sends a local push notification when a background chat finishes.
  static void sendCompletionNotification({
    required String convId,
    required String chatTitle,
    required AppLocalizations localizations,
  }) {
    try {
      final plugin = FlutterLocalNotificationsPlugin();

      final title = chatTitle;
      final body = localizations.backgroundChatNotificationTitle;

      const androidDetails = AndroidNotificationDetails(
        'background_chat',
        'Background Chats',
        channelDescription:
            'Notifications when background chats finish generating.',
        importance: Importance.high,
        priority: Priority.high,
      );

      const platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      plugin.show(
        DateTime.now().millisecondsSinceEpoch.toSigned(31),
        title,
        body,
        platformDetails,
        payload: jsonEncode({
          'type': 'background_chat',
          'screen': 'chat',
          'conversation_id': convId,
        }),
      );

      debugPrint(
          '[BackgroundNotifier] Background notification sent for: $chatTitle');
    } catch (e) {
      debugPrint(
          '[BackgroundNotifier] Failed to send background notification: $e');
    }
  }
}
