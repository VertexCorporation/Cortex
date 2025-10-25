// notifications.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/initialization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'l10n/app_localizations.dart';

//======================================================================
// Top-Level Background Handler (Entry Point for FCM)
// This must be a top-level function (not a class method) to handle
// notifications that arrive when the app is terminated.
//======================================================================
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint("--- Background Message Handler triggered by FCM ---");
    debugPrint("FCM Data payload: ${message.data}");
    await _showLocalizedNotification(message.data);
  } catch (e, s) {
    debugPrint("FATAL: Error in firebaseMessagingBackgroundHandler: $e\n$s");
  }
}

//======================================================================
// Centralized Content Building Helper (DRY Principle)
// This single, reusable function builds the final notification content
// from a data payload. It is called by both FCM handlers and the
// client-side scheduler to avoid code duplication.
//======================================================================
Future<Map<String, String>> _buildLocalizedContent(Map<String, dynamic> data) async {
  final String? titleKey = data['notification_title_key'];
  final String? bodyKey = data['notification_body_key'];

  if (titleKey == null || bodyKey == null) {
    debugPrint("[Content Builder] Title or body key is missing in the payload.");
    return {}; // Return an empty map to signify failure.
  }

  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('language_code');

  final locale = savedLocaleCode != null
      ? Locale(savedLocaleCode)
      : Locale(Platform.localeName.split('_').first);

  debugPrint("[Content Builder] Using '${locale.languageCode}' for notification language.");

  final l10n = await AppLocalizations.delegate.load(locale);

  String getLocalizedString(String key) {
    // This maps your camelCase keys to the generated AppLocalizations properties.
    // It correctly handles both parameterized and non-parameterized strings.
    switch (key) {
    // --- PARAMETERIZED STRINGS ---
      case 'notificationNewModelAddedBody':
        return l10n.notificationNewModelAddedBody(data['modelName'] ?? '[Model]');
      case 'notificationNewFeatureBody':
        return l10n.notificationNewFeatureBody(data['featureName'] ?? '[Feature]');
      case 'notificationSubscriptionOfferBody':
        return l10n.notificationSubscriptionOfferBody(data['discountRate'] ?? '0');
      case 'notificationUpsellFeatureTitle':
        return l10n.notificationUpsellFeatureTitle(data['targetTier'] ?? '[Plan]');
      case 'notificationUpsellFeatureBody':
        return l10n.notificationUpsellFeatureBody(
            data['currentTier'] ?? '[Current Plan]',
            data['targetTier'] ?? '[New Plan]',
            data['featureName'] ?? '[Feature]'
        );

    // --- NON-PARAMETERIZED STRINGS (unchanged from your original code) ---
      case 'notificationComebackTitle': return l10n.notificationComebackTitle;
      case 'notificationComebackBody': return l10n.notificationComebackBody;
      case 'notificationLongTimeNoSeeTitle': return l10n.notificationLongTimeNoSeeTitle;
      case 'notificationLongTimeNoSeeBody': return l10n.notificationLongTimeNoSeeBody;
      case 'notificationHowAreYouTitle': return l10n.notificationHowAreYouTitle;
      case 'notificationHowAreYouBody': return l10n.notificationHowAreYouBody;
      case 'notificationNewYearTitle': return l10n.notificationNewYearTitle;
      case 'notificationNewYearBody': return l10n.notificationNewYearBody;
      case 'notificationValentinesDayTitle': return l10n.notificationValentinesDayTitle;
      case 'notificationValentinesDayBody': return l10n.notificationValentinesDayBody;
      case 'notificationAtaturkRemembranceTitle': return l10n.notificationAtaturkRemembranceTitle;
      case 'notificationAtaturkRemembranceBody': return l10n.notificationAtaturkRemembranceBody;
      case 'notificationMothersDayTitle': return l10n.notificationMothersDayTitle;
      case 'notificationMothersDayBody': return l10n.notificationMothersDayBody;
      case 'notificationFathersDayTitle': return l10n.notificationFathersDayTitle;
      case 'notificationFathersDayBody': return l10n.notificationFathersDayBody;
      case 'notificationHomeworkHelperTitle': return l10n.notificationHomeworkHelperTitle;
      case 'notificationHomeworkHelperBody': return l10n.notificationHomeworkHelperBody;
      case 'notificationTrollAnimeTitle': return l10n.notificationTrollAnimeTitle;
      case 'notificationTrollAnimeBody': return l10n.notificationTrollAnimeBody;
      case 'notificationTrollAiRebellionTitle': return l10n.notificationTrollAiRebellionTitle;
      case 'notificationTrollAiRebellionBody': return l10n.notificationTrollAiRebellionBody;
      case 'notificationNewModelAddedTitle': return l10n.notificationNewModelAddedTitle;
      case 'notificationAppUpdateTitle': return l10n.notificationAppUpdateTitle;
      case 'notificationAppUpdateBody': return l10n.notificationAppUpdateBody;
      case 'notificationNewFeatureTitle': return l10n.notificationNewFeatureTitle;
      case 'notificationSubscriptionOfferTitle': return l10n.notificationSubscriptionOfferTitle;
      case 'notificationSocialMediaTitle': return l10n.notificationSocialMediaTitle;
      case 'notificationSocialMediaBody': return l10n.notificationSocialMediaBody;
      case 'notificationRandomFactTitle': return l10n.notificationRandomFactTitle;
      case 'notificationRandomFactBody': return l10n.notificationRandomFactBody;
      case 'notificationGoodMorningTitle': return l10n.notificationGoodMorningTitle;
      case 'notificationGoodMorningBody': return l10n.notificationGoodMorningBody;
      case 'notificationGoodNightTitle': return l10n.notificationGoodNightTitle;
      case 'notificationGoodNightBody': return l10n.notificationGoodNightBody;
      case 'notificationOfflineReadyTitle': return l10n.notificationOfflineReadyTitle;
      case 'notificationOfflineReadyBody': return l10n.notificationOfflineReadyBody;
      case 'notificationRateAppTitle': return l10n.notificationRateAppTitle;
      case 'notificationRateAppBody': return l10n.notificationRateAppBody;
      case 'notificationReferralTitle': return l10n.notificationReferralTitle;
      case 'notificationReferralBody': return l10n.notificationReferralBody;
      case 'notificationCookingTitle': return l10n.notificationCookingTitle;
      case 'notificationCookingBody': return l10n.notificationCookingBody;
      case 'notificationExistentialTitle': return l10n.notificationExistentialTitle;
      case 'notificationExistentialBody': return l10n.notificationExistentialBody;
      case 'notificationCustomModelTitle': return l10n.notificationCustomModelTitle;
      case 'notificationCustomModelBody': return l10n.notificationCustomModelBody;
      case 'notificationDynamicChatTitle': return l10n.notificationDynamicChatTitle;
      case 'notificationDynamicChatBody': return l10n.notificationDynamicChatBody;
      case 'notificationPirateTitle': return l10n.notificationPirateTitle;
      case 'notificationPirateBody': return l10n.notificationPirateBody;
      case 'notificationFortuneCookieTitle': return l10n.notificationFortuneCookieTitle;
      case 'notificationFortuneCookieBody': return l10n.notificationFortuneCookieBody;
      case 'notificationSingularityTitle': return l10n.notificationSingularityTitle;
      case 'notificationSingularityBody': return l10n.notificationSingularityBody;
      case 'notificationHackerJokeTitle': return l10n.notificationHackerJokeTitle;
      case 'notificationHackerJokeBody': return l10n.notificationHackerJokeBody;
      case 'notificationDetectiveCaseTitle': return l10n.notificationDetectiveCaseTitle;
      case 'notificationDetectiveCaseBody': return l10n.notificationDetectiveCaseBody;
      case 'notificationOriginStoryTitle': return l10n.notificationOriginStoryTitle;
      case 'notificationOriginStoryBody': return l10n.notificationOriginStoryBody;
      case 'notificationOpenSourceTitle': return l10n.notificationOpenSourceTitle;
      case 'notificationOpenSourceBody': return l10n.notificationOpenSourceBody;
      case 'notificationRejectionStoryTitle': return l10n.notificationRejectionStoryTitle;
      case 'notificationRejectionStoryBody': return l10n.notificationRejectionStoryBody;
      case 'notificationGGUFSupportTitle': return l10n.notificationGGUFSupportTitle;
      case 'notificationGGUFSupportBody': return l10n.notificationGGUFSupportBody;
      case 'notificationThemeCustomizationTitle': return l10n.notificationThemeCustomizationTitle;
      case 'notificationThemeCustomizationBody': return l10n.notificationThemeCustomizationBody;
      case 'notificationShowerThoughtTitle': return l10n.notificationShowerThoughtTitle;
      case 'notificationShowerThoughtBody': return l10n.notificationShowerThoughtBody;
      case 'notificationLowBatteryTitle': return l10n.notificationLowBatteryTitle;
      case 'notificationLowBatteryBody': return l10n.notificationLowBatteryBody;
      default: return '';
    }
  }

  String localizedTitle = getLocalizedString(titleKey);
  String localizedBody = getLocalizedString(bodyKey);

  return {'title': localizedTitle, 'body': localizedBody};
}

//======================================================================
// Simplified Notification Display Function
// This function takes the final, translated content and displays it.
//======================================================================
Future<void> _showLocalizedNotification(Map<String, dynamic> data) async {
  final notificationContent = await _buildLocalizedContent(data);
  if (notificationContent.isEmpty || notificationContent['title']!.isEmpty) {
    debugPrint("[Notification Displayer] Could not build localized content. Aborting display.");
    return;
  }

  final String title = notificationContent['title']!;
  final String body = notificationContent['body']!;

  final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
    body,
    htmlFormatBigText: false,
    contentTitle: title,
    htmlFormatContentTitle: false,
    htmlFormatSummaryText: false,
  );

  final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'cortex_notifications',
    'Cortex Updates',
    channelDescription: 'Notifications about news and updates from Cortex.',
    importance: Importance.max,
    priority: Priority.high,
    styleInformation: bigTextStyleInformation,
  );

  final NotificationDetails platformDetails = NotificationDetails(android: androidDetails);

  await FlutterLocalNotificationsPlugin().show(
    DateTime.now().millisecondsSinceEpoch.toSigned(31), // Unique ID
    title,
    body,
    platformDetails,
    payload: jsonEncode(data), // Pass the original data for tap handling
  );
}

//======================================================================
// The Main Notification Service Class
//======================================================================
class NotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  // Define Android Notification Channels for better user control (Android 8.0+)
  late final AndroidNotificationChannel _fcmChannel;
  late final AndroidNotificationChannel _engagementChannel;
  late final AndroidNotificationChannel _greetingsChannel;

  bool _isInitialized = false;

  NotificationService({required this.navigatorKey});

  /// Initializes the entire notification system with localized channel names.
  Future<void> initialize(AppLocalizations l10n) async {
    _fcmChannel = AndroidNotificationChannel(
      'cortex_notifications',
      l10n.channelFcmName,
      description: l10n.channelFcmDescription,
      importance: Importance.max,
    );
    _engagementChannel = AndroidNotificationChannel(
      'engagement',
      l10n.channelEngagementName,
      description: l10n.channelEngagementDescription,
      importance: Importance.defaultImportance,
    );
    _greetingsChannel = AndroidNotificationChannel(
      'greetings',
      l10n.channelGreetingsName,
      description: l10n.channelGreetingsDescription,
      importance: Importance.defaultImportance,
    );

    await _initializeLocalNotifications();
    await _initializeFirebaseMessaging();

    _isInitialized = true;
    debugPrint("[NotificationService] Initialization complete.");
  }

  /// Sets up Flutter Local Notifications, including channels and tap handlers.
  Future<void> _initializeLocalNotifications() async {
    // Create Android notification channels upfront.
    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_fcmChannel);
    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_engagementChannel);
    await _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_greetingsChannel);

    const AndroidInitializationSettings initSettingsAndroid = AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings initSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(
      initSettings,
      // This is the new, recommended way to handle notification taps.
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Sets up Firebase Cloud Messaging, including permissions and message listeners.
  Future<void> _initializeFirebaseMessaging() async {
    await _fcm.requestPermission();

    final token = await _fcm.getToken();
    if (token != null) _saveTokenToDatabase(token);
    _fcm.onTokenRefresh.listen(_saveTokenToDatabase);

    // Listener for foreground FCM messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('[NotificationService] Received a foreground message!');
      _showLocalizedNotification(message.data);
    });

    // Listener for when the app is opened from a background notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('[NotificationService] App opened from background via notification!');
      _handleTapLogic(message.data);
    });

    // Handles the case where the app is opened from a terminated state
    final initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('[NotificationService] App opened from terminated state!');
      Future.delayed(const Duration(seconds: 1), () => _handleTapLogic(initialMessage.data));
    }
  }

  /// To be called from your main app widget when the app lifecycle changes.
  void handleAppLifecycleStateChange(AppLifecycleState state) async {
    if (!_isInitialized) {
      debugPrint("[NotificationService] App lifecycle changed, but service not initialized. Skipping.");
      return;
    }

    const int lowBatteryNotificationId = 3;

    // SCENARIO 1: The user is returning to the app.
    if (state == AppLifecycleState.resumed) {
      await _localNotifications.cancel(lowBatteryNotificationId);
      debugPrint("[NotificationService] App resumed. Canceled any pending low-battery notification (ID: $lowBatteryNotificationId).");

      if (_auth.currentUser != null) {
        final pendingRequests = await _localNotifications.pendingNotificationRequests();

        final engagementRequests = pendingRequests.where((p) => p.id != lowBatteryNotificationId).toList();

        if (engagementRequests.isEmpty) {
          debugPrint("[NotificationService] No pending engagement notifications found. This might be due to a force-close. Scheduling a recovery notification.");
          await _scheduleNextEngagementNotification();
        } else {
          debugPrint("[NotificationService] Found ${engagementRequests.length} pending notification(s). No recovery schedule needed.");
        }
      }
    }
    // SCENARIO 2: The user is leaving the app.
    else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (_auth.currentUser != null) {
        debugPrint("[NotificationService] App paused/detached. Checking conditions to schedule notifications.");

        try {
          final batteryLevel = await Battery().batteryLevel;
          debugPrint("[NotificationService] Current battery level: $batteryLevel%");
          if (batteryLevel < 20) {
            final prefs = await SharedPreferences.getInstance();
            final lastSentTime = prefs.getInt('lowBatteryNotificationSentTime') ?? 0;
            final now = DateTime.now().millisecondsSinceEpoch;
            if (now - lastSentTime > const Duration(hours: 12).inMilliseconds) {
              if (Random().nextDouble() < 0.1) {
                final dataPayload = {
                  'notification_title_key': 'notificationLowBatteryTitle',
                  'notification_body_key': 'notificationLowBatteryBody',
                };
                final content = await _buildLocalizedContent(dataPayload);
                if (content.isNotEmpty) {
                  final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
                  await _zonedScheduleNotification(
                    lowBatteryNotificationId,
                    content,
                    scheduledTime,
                    dataPayload,
                    _engagementChannel,
                  );
                  await prefs.setInt('lowBatteryNotificationSentTime', now);
                  return;
                }
              }
            }
          }
        } catch (e) {
          debugPrint("[NotificationService] CRITICAL: Could not check battery level: $e");
        }

        _scheduleNextEngagementNotification();
      }
    }
  }

  /// Removes the current device's FCM token from the logged-out user's document.
  /// This must be called BEFORE the actual signOut() operation.
  Future<void> clearUserTokenOnSignOut() async {
    final user = _auth.currentUser;
    if (user == null) return; // Should not happen if called before sign out, but a good safeguard.

    try {
      final token = await _fcm.getToken();
      if (token == null) {
        debugPrint("[NotificationService] No FCM token found for this device. Skipping cleanup.");
        return;
      }

      final userRef = _db.collection('users').doc(user.uid);
      await userRef.update({
        'fcmTokens': FieldValue.arrayRemove([token])
      });

      debugPrint("[NotificationService] FCM token successfully removed for user ${user.uid} on sign-out.");
    } catch (e) {
      debugPrint("[NotificationService] CRITICAL: Error removing FCM token on sign-out: $e");
      // We don't re-throw the error, because the user should be able to sign out
      // even if the token cleanup fails.
    }
  }

  /// It records the app open timestamp, which is crucial for the dynamic
  /// scheduling logic.
  Future<void> recordAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;

    // Record the first open time if it doesn't exist.
    if (prefs.getInt('firstAppOpenTime') == null) {
      debugPrint("[NotificationService] First app open detected. Recording timestamp.");
      await prefs.setInt('firstAppOpenTime', now);
    }

    // Always update the last app open time.
    await prefs.setInt('lastAppOpenTime', now);
    debugPrint("[NotificationService] App open recorded at ${DateTime.now()}.");
  }

  /// The main scheduler that now uses a smart, dynamic logic for ALL
  /// engagement notifications, including greetings.
  Future<void> _scheduleNextEngagementNotification() async {
    if (!_isInitialized) return;
    // Check for maintenance mode BEFORE doing anything else.
    if (await checkMaintenanceMode()) {
      debugPrint("[NotificationService] App is under maintenance. Deferring notification scheduling.");
      // Flag that we owe the user a notification.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('pendingNotificationDueToMaintenance', true);
      return; // Stop execution here.
    }
    try {

      const int engagementNotificationId = 2;
      await _localNotifications.cancel(engagementNotificationId);

      final prefs = await SharedPreferences.getInstance();
      final now = tz.TZDateTime.now(tz.local);

      final firstOpenTime = prefs.getInt('firstAppOpenTime');
      final lastOpenTime = prefs.getInt('lastAppOpenTime') ?? now.millisecondsSinceEpoch;
      final lastScheduledTime = prefs.getInt('lastSmartScheduleTime') ?? 0;

      // Cooldown: Don't schedule if one was already scheduled in the last 24 hours.
      if (now.millisecondsSinceEpoch - lastScheduledTime < const Duration(hours: 24).inMilliseconds) {
        debugPrint("[NotificationService] Smart notification was scheduled very recently. Skipping.");
        return;
      }

      // 1. First Day Welcome Notification Logic
      final welcomeNotificationSent = prefs.getBool('welcomeNotificationSent') ?? false;
      if (firstOpenTime != null && !welcomeNotificationSent) {
        final firstOpenDate = DateTime.fromMillisecondsSinceEpoch(firstOpenTime);
        if (now.difference(firstOpenDate).inHours < 24) {

          final scheduledDateTime = now.add(const Duration(hours: 1));
          await _scheduleWelcomeNotification(scheduledDateTime);

          return;
        }
      }

      // 2. Dynamic Scheduling Logic based on User Activity
      final daysSinceLastOpen = now.difference(DateTime.fromMillisecondsSinceEpoch(lastOpenTime)).inDays;
      Duration scheduleDelay;

      if (daysSinceLastOpen <= 2) { // Highly Active
        scheduleDelay = Duration(days: 1 + Random().nextInt(2)); // Schedule in 1-2 days
      } else if (daysSinceLastOpen <= 6) { // Normally Active
        scheduleDelay = Duration(days: 2 + Random().nextInt(3)); // Schedule in 2-4 days
      } else if (daysSinceLastOpen <= 14) { // Less Active
        scheduleDelay = Duration(days: 4 + Random().nextInt(3)); // Schedule in 4-6 days
      } else { // Inactive User
        scheduleDelay = const Duration(days: 1); // Schedule for tomorrow to win them back
      }

      final scheduledDateTime = now.add(scheduleDelay);
      Map<String, String>? selectedNotification;

      // 3. Smart Notification Selection (including Greetings)
      if (now.hour >= 20) { // After 8 PM, schedule a "Good Morning" for tomorrow
        selectedNotification = {'title': 'notificationGoodMorningTitle', 'body': 'notificationGoodMorningBody'};
        final tomorrow = now.add(const Duration(days: 1));
        final finalScheduleTime = tz.TZDateTime(tz.local, tomorrow.year, tomorrow.month, tomorrow.day, 9); // 9 AM tomorrow
        await _scheduleFinalNotification(engagementNotificationId, selectedNotification, finalScheduleTime);

      } else if (now.hour < 18) { // Before 6 PM, schedule a "Good Night" for tonight
        selectedNotification = {'title': 'notificationGoodNightTitle', 'body': 'notificationGoodNightBody'};
        final finalScheduleTime = tz.TZDateTime(tz.local, now.year, now.month, now.day, 22); // 10 PM tonight
        await _scheduleFinalNotification(engagementNotificationId, selectedNotification, finalScheduleTime);

      } else { // Otherwise, schedule a general notification based on activity
        if (daysSinceLastOpen > 14) { // Inactive user gets a specific comeback message
          const comebackPool = <Map<String, String>>[
            {'title': 'notificationComebackTitle', 'body': 'notificationComebackBody'},
            {'title': 'notificationLongTimeNoSeeTitle', 'body': 'notificationLongTimeNoSeeBody'},
          ];
          selectedNotification = comebackPool[Random().nextInt(comebackPool.length)];
        } else { // Active users get a general fun message
          const generalPool = <Map<String, String>>[
            {'title': 'notificationHowAreYouTitle', 'body': 'notificationHowAreYouBody'},
            {'title': 'notificationRandomFactTitle', 'body': 'notificationRandomFactBody'},
            {'title': 'notificationShowerThoughtTitle', 'body': 'notificationShowerThoughtBody'},
            {'title': 'notificationFortuneCookieTitle', 'body': 'notificationFortuneCookieBody'},
          ];
          selectedNotification = generalPool[Random().nextInt(generalPool.length)];
        }
        await _scheduleFinalNotification(engagementNotificationId, selectedNotification, scheduledDateTime);
      }

    } catch (e) {
      debugPrint("[NotificationService] CRITICAL Error during unified smart scheduling: $e");
    }
  }

  /// Schedules the notification that was deferred due to maintenance.
  /// This should be called by AppInitializer when the app is confirmed to be out of maintenance.
  Future<void> schedulePendingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final bool isPending = prefs.getBool('pendingNotificationDueToMaintenance') ?? false;

    if (isPending) {
      debugPrint("[NotificationService] Maintenance is over. Checking which notification to schedule.");

      final welcomeNotificationSent = prefs.getBool('welcomeNotificationSent') ?? false;

      if (!welcomeNotificationSent) {
        debugPrint("[NotificationService] Welcome notification was pending due to maintenance. Scheduling it now.");

        final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
        await _scheduleWelcomeNotification(scheduledTime);

      } else {
        debugPrint("[NotificationService] Scheduling a general engagement notification after maintenance.");
        const generalPool = <Map<String, String>>[
          {'title': 'notificationHowAreYouTitle', 'body': 'notificationHowAreYouBody'},
          {'title': 'notificationLongTimeNoSeeTitle', 'body': 'notificationLongTimeNoSeeBody'},
        ];
        final selectedNotification = generalPool[Random().nextInt(generalPool.length)];

        final scheduledTime = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 5));
        await _scheduleFinalNotification(2, selectedNotification, scheduledTime);
      }

      await prefs.setBool('pendingNotificationDueToMaintenance', false);
    }
  }

  /// Schedules the special, randomized welcome notification for the first day.
  /// This is centralized to be called from multiple places without code duplication.
  Future<void> _scheduleWelcomeNotification(tz.TZDateTime scheduledTime) async {
    const int welcomeNotificationId = 1;
    const welcomeNotificationPool = <Map<String, String>>[
      {'title': 'notificationDynamicChatTitle', 'body': 'notificationDynamicChatBody'},
      {'title': 'notificationPirateTitle', 'body': 'notificationPirateBody'},
      {'title': 'notificationFortuneCookieTitle', 'body': 'notificationFortuneCookieBody'},
      {'title': 'notificationSingularityTitle', 'body': 'notificationSingularityBody'},
      {'title': 'notificationHackerJokeTitle', 'body': 'notificationHackerJokeBody'},
      {'title': 'notificationDetectiveCaseTitle', 'body': 'notificationDetectiveCaseBody'},
      {'title': 'notificationOriginStoryTitle', 'body': 'notificationOriginStoryBody'},
      {'title': 'notificationOpenSourceTitle', 'body': 'notificationOpenSourceBody'},
      {'title': 'notificationRejectionStoryTitle', 'body': 'notificationRejectionStoryBody'},
      {'title': 'notificationHomeworkHelperTitle', 'body': 'notificationHomeworkHelperBody'},
      {'title': 'notificationTrollAnimeTitle', 'body': 'notificationTrollAnimeBody'},
      {'title': 'notificationTrollAiRebellionTitle', 'body': 'notificationTrollAiRebellionBody'},
      {'title': 'notificationRandomFactTitle', 'body': 'notificationRandomFactBody'},
    ];

    final selectedNotification = welcomeNotificationPool[Random().nextInt(welcomeNotificationPool.length)];

    final dataPayload = {
      'notification_title_key': selectedNotification['title']!,
      'notification_body_key': selectedNotification['body']!,
    };

    final content = await _buildLocalizedContent(dataPayload);
    if (content.isEmpty) return;

    await _zonedScheduleNotification(
      welcomeNotificationId,
      content,
      scheduledTime,
      dataPayload,
      _engagementChannel,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeNotificationSent', true);
    debugPrint("[NotificationService] Centralized welcome notification scheduled with UNIQUE ID 1 for $scheduledTime.");
  }

  /// A helper function to build and schedule the final notification.
  /// This avoids code duplication within the main scheduler's logic.
  Future<void> _scheduleFinalNotification(int id, Map<String, String> notificationKeys, tz.TZDateTime scheduledTime) async {
    final dataPayload = {
      'notification_title_key': notificationKeys['title']!,
      'notification_body_key': notificationKeys['body']!,
    };
    final content = await _buildLocalizedContent(dataPayload);
    if (content.isNotEmpty) {
      final channelToUse = (notificationKeys['title'] == 'notificationGoodMorningTitle' ||
          notificationKeys['title'] == 'notificationGoodNightTitle')
          ? _greetingsChannel
          : _engagementChannel;

      await _zonedScheduleNotification(id, content, scheduledTime, dataPayload, channelToUse);
    }
  }

  /// A helper function to reduce code duplication in zoned scheduling.
  Future<void> _zonedScheduleNotification(
      int id,
      Map<String, String> content,
      tz.TZDateTime scheduledDateTime,
      Map<String, dynamic> payload,
      AndroidNotificationChannel channel,
      ) async {

    final BigTextStyleInformation bigTextStyleInformation = BigTextStyleInformation(
      content['body']!,
      htmlFormatBigText: false,
      contentTitle: content['title'],
      htmlFormatContentTitle: false,
      htmlFormatSummaryText: false,
    );

    final platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        styleInformation: bigTextStyleInformation,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.zonedSchedule(
      id,
      content['title'],
      content['body'],
      scheduledDateTime,
      platformChannelSpecifics,
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastSmartScheduleTime', DateTime.now().millisecondsSinceEpoch);
    debugPrint("[NotificationService] Smartly scheduled '${payload['notification_title_key']}' on channel '${channel.name}' for ${scheduledDateTime.toString()}.");
  }

  /// Saves or updates the user's FCM token in their Firestore document.
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint("[NotificationService] User not logged in. Skipping token save.");
      return;
    }
    final userRef = _db.collection('users').doc(user.uid);
    try {
      await userRef.set({
        'fcmTokens': FieldValue.arrayUnion([token])
      }, SetOptions(merge: true));
      debugPrint("[NotificationService] FCM Token successfully saved to Firestore.");
    } catch (e) {
      debugPrint("[NotificationService] CRITICAL: Error saving FCM token to Firestore: $e");
    }
  }

  /// Callback for when any local notification is tapped.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[NotificationService] Local notification tapped!');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleTapLogic(data);
      } catch (e) {
        debugPrint('[NotificationService] Error decoding notification payload: $e');
      }
    } else {
      debugPrint('[NotificationService] Notification tapped, but no payload was found.');
    }
  }

  /// CENTRALIZED logic for handling a tap from ANY notification source.
  void _handleTapLogic(Map<String, dynamic> data) {
    debugPrint("[NotificationService] Handling notification tap. Data: $data");
    // Example navigation logic based on the data payload.
    final screen = data['screen'];
    if (screen == 'news') {
      final slug = data['slug'];
      debugPrint("TODO: Navigate to news article with slug: $slug");
      // Example: navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => NewsDetailScreen(slug: slug)));
    } else if (data['notification_title_key'] == 'notificationRateAppTitle') {
      debugPrint("TODO: Open the app store for rating.");
      // Example: InAppReview.instance.openStoreListing();
    } else {
      debugPrint("No specific navigation action for this notification. Defaulting to home screen.");
    }
  }

  //======================================================================
  // Original In-App Overlay Notification Code (Unchanged)
  // This section handles the custom, animated in-app notifications.
  //======================================================================
  void showNotification({
    required String message,
    bool? isSuccess,
    double bottomOffset = 0.1,
    double fontSize = 0.038,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 1),
    VoidCallback? onTap,
  }) {
    _showOverlayNotification(
      message: message,
      backgroundColor: isSuccess != null ? (isSuccess ? Colors.green : Colors.red) : const Color(0xFF222222),
      icon: isSuccess != null ? (isSuccess ? Icons.check_circle : Icons.error) : null,
      textColor: Colors.white,
      bottomOffset: bottomOffset,
      fontSizeProportion: fontSize,
      duration: duration,
      oneLine: oneLine,
      onTap: onTap,
    );
  }

  void _showOverlayNotification({
    required String message,
    required Color backgroundColor,
    IconData? icon,
    required Color textColor,
    required double bottomOffset,
    required double fontSizeProportion,
    bool oneLine = false,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    final overlay = navigatorKey.currentState?.overlay;
    if (overlay == null) {
      debugPrint("[NotificationService] Overlay not found. Cannot display custom notification.");
      return;
    }

    final GlobalKey<_AnimatedNotificationState> notificationKey = GlobalKey();
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) {
        final media = MediaQuery.of(context);
        final kbInset = media.viewInsets.bottom;
        final baseBot = bottomOffset * media.size.height;
        final bottom = kbInset + baseBot;
        final actualFontSize = fontSizeProportion * media.size.width;

        Widget notificationWidget = _AnimatedNotification(
          key: notificationKey,
          message: message,
          backgroundColor: backgroundColor,
          icon: icon,
          textColor: textColor,
          duration: duration,
          fontSize: actualFontSize,
          oneLine: oneLine,
          onRemove: () => overlayEntry.remove(),
          onTap: () {
            notificationKey.currentState?.dismiss();
            onTap?.call();
          },
        );

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => notificationKey.currentState?.dismiss(),
                child: Container(),
              ),
            ),
            Positioned(
              bottom: bottom,
              left: 0,
              right: 0,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: media.size.width * 0.95),
                  child: notificationWidget,
                ),
              ),
            ),
          ],
        );
      },
    );

    overlay.insert(overlayEntry);
  }
}

//======================================================================
// Original Animated Notification Widget (Unchanged)
//======================================================================
class _AnimatedNotification extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final IconData? icon;
  final Color textColor;
  final Duration duration;
  final double fontSize;
  final bool oneLine;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  const _AnimatedNotification({
    super.key,
    required this.message,
    required this.backgroundColor,
    this.icon,
    required this.textColor,
    required this.duration,
    required this.fontSize,
    required this.oneLine,
    required this.onRemove,
    required this.onTap,
  });

  @override
  _AnimatedNotificationState createState() => _AnimatedNotificationState();
}

class _AnimatedNotificationState extends State<_AnimatedNotification> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  double get maxWidth => MediaQuery.of(context).size.width * 0.9;
  double get minFontSize => widget.fontSize * 0.7;

  double calculateFontSize(String text, double initialFontSize, double maxWidth, IconData? icon) {
    double fontSize = initialFontSize;
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: TextStyle(fontSize: fontSize)),
      maxLines: widget.oneLine ? 1 : null,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    double iconWidth = icon != null ? fontSize + 8.0 : 0.0;
    double totalWidth = textPainter.size.width + iconWidth + 32.0;

    while (widget.oneLine && totalWidth > maxWidth && fontSize > minFontSize) {
      fontSize -= 1.0;
      textPainter.text = TextSpan(text: text, style: TextStyle(fontSize: fontSize));
      textPainter.layout();
      totalWidth = textPainter.size.width + iconWidth + 32.0;
    }
    return fontSize;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _controller.forward();
    Future.delayed(widget.duration, _startExitAnimation);
  }

  void dismiss() {
    if (mounted) {
      _startExitAnimation();
    }
  }

  void _startExitAnimation() {
    if (mounted) {
      _controller.reverse().then((_) {
        if (mounted) {
          widget.onRemove();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final double verticalPadding = screenHeight * 0.015;
    final double horizontalPadding = screenWidth * 0.04;
    final double iconSpacing = screenWidth * 0.02;
    double adjustedFontSize = calculateFontSize(widget.message, widget.fontSize, maxWidth, widget.icon);
    double iconSize = widget.icon != null ? adjustedFontSize : 0.0;

    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: EdgeInsets.symmetric(
                vertical: verticalPadding,
                horizontal: horizontalPadding,
              ),
              decoration: BoxDecoration(
                color: widget.backgroundColor,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, color: widget.textColor, size: iconSize),
                    SizedBox(width: iconSpacing),
                  ],
                  Flexible(
                    child: Text(
                      widget.message,
                      style: TextStyle(color: widget.textColor, fontSize: adjustedFontSize),
                      maxLines: widget.oneLine ? 1 : null,
                      overflow: widget.oneLine ? TextOverflow.ellipsis : TextOverflow.visible,
                      textAlign: widget.icon != null ? TextAlign.start : TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}