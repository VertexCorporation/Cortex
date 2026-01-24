// extrovert.dart
//
// Manages "extroverted" notifications: push notifications and local notifications
// that reach out to the user through the operating system, even when the
// app is in the background or closed.
// This service handles all communication with FCM, the system's notification tray,
// local notification scheduling, and permission requests.

import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:timezone/data/latest.dart' as data;
import '../l10n/app_localizations.dart';
import '../maintenance.dart';
import '../funds/funds.dart';

//======================================================================
// Top-Level Functions (Required for Background Isolate)
//======================================================================

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
    // It's crucial to catch errors here, otherwise the isolate might crash silently.
    debugPrint("FATAL: Error in firebaseMessagingBackgroundHandler: $e\n$s");
    // Optionally, you could log this to a remote service if Crashlytics isn't available
    // in this isolate context without extra setup.
  }
}

/// Builds the final notification content from a data payload.
/// This is a shared helper used by both background and foreground handlers
/// to ensure consistent, localized content.
Future<Map<String, String>> _buildLocalizedContent(
    Map<String, dynamic> data) async {
  final String? titleKey = data['notification_title_key'];
  final String? bodyKey = data['notification_body_key'];

  if (titleKey == null || bodyKey == null) {
    debugPrint(
        "[Content Builder] Title or body key is missing in the payload.");
    return {}; // Return an empty map to signify failure.
  }

  final prefs = await SharedPreferences.getInstance();
  final savedLocaleCode = prefs.getString('language_code');

  final locale = savedLocaleCode != null
      ? Locale(savedLocaleCode)
      : Locale(Platform.localeName
      .split('_')
      .first);

  debugPrint(
      "[Content Builder] Using '${locale
          .languageCode}' for notification language.");

  final l10n = await AppLocalizations.delegate.load(locale);

  String getLocalizedString(String key) {
    // This maps your camelCase keys to the generated AppLocalizations properties.
    // It correctly handles both parameterized and non-parameterized strings.
    switch (key) {
    // --- PARAMETERIZED STRINGS ---
      case 'notificationNewModelAddedBody':
        return l10n
            .notificationNewModelAddedBody(data['modelName'] ?? '[Model]');
      case 'notificationNewFeatureBody':
        return l10n
            .notificationNewFeatureBody(data['featureName'] ?? '[Feature]');
      case 'notificationWelcomeOfferBody':
        return l10n.notificationWelcomeOfferBody;
      case 'notificationUpsellFeatureTitle':
        return l10n
            .notificationUpsellFeatureTitle(data['targetTier'] ?? '[Plan]');
      case 'notificationUpsellFeatureBody':
        return l10n.notificationUpsellFeatureBody(
            data['currentTier'] ?? '[Current Plan]',
            data['targetTier'] ?? '[New Plan]',
            data['featureName'] ?? '[Feature]');

    // --- NON-PARAMETERIZED STRINGS (unchanged from your original code) ---
      case 'notificationComebackTitle':
        return l10n.notificationComebackTitle;
      case 'notificationComebackBody':
        return l10n.notificationComebackBody;
      case 'notificationLongTimeNoSeeTitle':
        return l10n.notificationLongTimeNoSeeTitle;
      case 'notificationLongTimeNoSeeBody':
        return l10n.notificationLongTimeNoSeeBody;
      case 'notificationHowAreYouTitle':
        return l10n.notificationHowAreYouTitle;
      case 'notificationHowAreYouBody':
        return l10n.notificationHowAreYouBody;
      case 'notificationNewYearTitle':
        return l10n.notificationNewYearTitle;
      case 'notificationNewYearBody':
        return l10n.notificationNewYearBody;
      case 'notificationValentinesDayTitle':
        return l10n.notificationValentinesDayTitle;
      case 'notificationValentinesDayBody':
        return l10n.notificationValentinesDayBody;
      case 'notificationAtaturkRemembranceTitle':
        return l10n.notificationAtaturkRemembranceTitle;
      case 'notificationAtaturkRemembranceBody':
        return l10n.notificationAtaturkRemembranceBody;
      case 'notificationMothersDayTitle':
        return l10n.notificationMothersDayTitle;
      case 'notificationMothersDayBody':
        return l10n.notificationMothersDayBody;
      case 'notificationFathersDayTitle':
        return l10n.notificationFathersDayTitle;
      case 'notificationFathersDayBody':
        return l10n.notificationFathersDayBody;
      case 'notificationHomeworkHelperTitle':
        return l10n.notificationHomeworkHelperTitle;
      case 'notificationHomeworkHelperBody':
        return l10n.notificationHomeworkHelperBody;
      case 'notificationTrollAnimeTitle':
        return l10n.notificationTrollAnimeTitle;
      case 'notificationTrollAnimeBody':
        return l10n.notificationTrollAnimeBody;
      case 'notificationTrollAiRebellionTitle':
        return l10n.notificationTrollAiRebellionTitle;
      case 'notificationTrollAiRebellionBody':
        return l10n.notificationTrollAiRebellionBody;
      case 'notificationNewModelAddedTitle':
        return l10n.notificationNewModelAddedTitle;
      case 'notificationAppUpdateTitle':
        return l10n.notificationAppUpdateTitle;
      case 'notificationAppUpdateBody':
        return l10n.notificationAppUpdateBody;
      case 'notificationNewFeatureTitle':
        return l10n.notificationNewFeatureTitle;
      case 'notificationWelcomeOfferTitle':
        return l10n.notificationWelcomeOfferTitle;
      case 'notificationSocialMediaTitle':
        return l10n.notificationSocialMediaTitle;
      case 'notificationSocialMediaBody':
        return l10n.notificationSocialMediaBody;
      case 'notificationRandomFactTitle':
        return l10n.notificationRandomFactTitle;
      case 'notificationRandomFactBody':
        return l10n.notificationRandomFactBody;
      case 'notificationGoodMorningTitle':
        return l10n.notificationGoodMorningTitle;
      case 'notificationGoodMorningBody':
        return l10n.notificationGoodMorningBody;
      case 'notificationGoodNightTitle':
        return l10n.notificationGoodNightTitle;
      case 'notificationGoodNightBody':
        return l10n.notificationGoodNightBody;
      case 'notificationOfflineReadyTitle':
        return l10n.notificationOfflineReadyTitle;
      case 'notificationOfflineReadyBody':
        return l10n.notificationOfflineReadyBody;
      case 'notificationRateAppTitle':
        return l10n.notificationRateAppTitle;
      case 'notificationRateAppBody':
        return l10n.notificationRateAppBody;
      case 'notificationReferralTitle':
        return l10n.notificationReferralTitle;
      case 'notificationReferralBody':
        return l10n.notificationReferralBody;
      case 'notificationCookingTitle':
        return l10n.notificationCookingTitle;
      case 'notificationCookingBody':
        return l10n.notificationCookingBody;
      case 'notificationExistentialTitle':
        return l10n.notificationExistentialTitle;
      case 'notificationExistentialBody':
        return l10n.notificationExistentialBody;
      case 'notificationCustomModelTitle':
        return l10n.notificationCustomModelTitle;
      case 'notificationCustomModelBody':
        return l10n.notificationCustomModelBody;
      case 'notificationDynamicChatTitle':
        return l10n.notificationDynamicChatTitle;
      case 'notificationDynamicChatBody':
        return l10n.notificationDynamicChatBody;
      case 'notificationPirateTitle':
        return l10n.notificationPirateTitle;
      case 'notificationPirateBody':
        return l10n.notificationPirateBody;
      case 'notificationFortuneCookieTitle':
        return l10n.notificationFortuneCookieTitle;
      case 'notificationFortuneCookieBody':
        return l10n.notificationFortuneCookieBody;
      case 'notificationSingularityTitle':
        return l10n.notificationSingularityTitle;
      case 'notificationSingularityBody':
        return l10n.notificationSingularityBody;
      case 'notificationHackerJokeTitle':
        return l10n.notificationHackerJokeTitle;
      case 'notificationHackerJokeBody':
        return l10n.notificationHackerJokeBody;
      case 'notificationDetectiveCaseTitle':
        return l10n.notificationDetectiveCaseTitle;
      case 'notificationDetectiveCaseBody':
        return l10n.notificationDetectiveCaseBody;
      case 'notificationOriginStoryTitle':
        return l10n.notificationOriginStoryTitle;
      case 'notificationOriginStoryBody':
        return l10n.notificationOriginStoryBody;
      case 'notificationOpenSourceTitle':
        return l10n.notificationOpenSourceTitle;
      case 'notificationOpenSourceBody':
        return l10n.notificationOpenSourceBody;
      case 'notificationRejectionStoryTitle':
        return l10n.notificationRejectionStoryTitle;
      case 'notificationRejectionStoryBody':
        return l10n.notificationRejectionStoryBody;
      case 'notificationGGUFSupportTitle':
        return l10n.notificationGGUFSupportTitle;
      case 'notificationGGUFSupportBody':
        return l10n.notificationGGUFSupportBody;
      case 'notificationThemeCustomizationTitle':
        return l10n.notificationThemeCustomizationTitle;
      case 'notificationThemeCustomizationBody':
        return l10n.notificationThemeCustomizationBody;
      case 'notificationShowerThoughtTitle':
        return l10n.notificationShowerThoughtTitle;
      case 'notificationShowerThoughtBody':
        return l10n.notificationShowerThoughtBody;
      case 'notificationLowBatteryTitle':
        return l10n.notificationLowBatteryTitle;
      case 'notificationLowBatteryBody':
        return l10n.notificationLowBatteryBody;
      default:
        return '';
    }
  }

  String localizedTitle = getLocalizedString(titleKey);
  String localizedBody = getLocalizedString(bodyKey);

  return {'title': localizedTitle, 'body': localizedBody};
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

  // Dynamically determine the channel ID from the payload, with a fallback.
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
        .toSigned(31), // Unique ID
    title,
    body,
    platformDetails,
    payload: jsonEncode(data), // Pass the original data for tap handling
  );
}

//======================================================================
// The Main Push Notification Service Class
//======================================================================

class ExtrovertNotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  // Define Android Notification Channels
  late final AndroidNotificationChannel _fcmChannel;
  late final AndroidNotificationChannel _engagementChannel;
  late final AndroidNotificationChannel _greetingsChannel;

  bool _isInitialized = false;
  bool _isRequestingPermission = false;

  ExtrovertNotificationService({required this.navigatorKey});

  /// Initializes the entire notification system. This method is self-contained
  /// and can be called early in the app lifecycle without needing a BuildContext.
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      data.initializeTimeZones();

      try {
        final _ = timezone.local;
      } catch (e) {
        debugPrint(
            "[ExtrovertNotificationService] Timezone local not set. Defaulting to UTC to prevent crash.");
        timezone.setLocalLocation(timezone.getLocation('UTC'));
      }
    } catch (e) {
      debugPrint(
          "[ExtrovertNotificationService] Error initializing timezones: $e");
    }

    // Load localization data safely.
    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString('language_code');
    final locale = savedLocaleCode != null
        ? Locale(savedLocaleCode)
        : Locale(Platform.localeName
        .split('_')
        .first);
    final l10n = await AppLocalizations.delegate.load(locale);

    // Initialize channels with localized names.
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
    debugPrint("[ExtrovertNotificationService] Initialization complete.");
  }

  /// Sets up Flutter Local Notifications, including channels and tap handlers.
  Future<void> _initializeLocalNotifications() async {
    // Create Android notification channels upfront.
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_fcmChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_engagementChannel);
    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_greetingsChannel);

    const AndroidInitializationSettings initSettingsAndroid =
    AndroidInitializationSettings('ic_notification');
    const DarwinInitializationSettings initSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    final InitializationSettings initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );
  }

  /// Sets up Firebase Cloud Messaging, including permissions and message listeners.
  Future<void> _initializeFirebaseMessaging() async {
    try {
      //
      // --- SAFETY 1: Is the device supports Google Play Services?  ---
      //
      final bool fcmAvailable = await _fcm.isSupported();
      if (!fcmAvailable) {
        debugPrint(
            "[Extrovert] FCM not supported on this device. Skipping FCM init.");
        return;
      }

      //
      // --- SAFETY 2: Do we have permission? ---
      //
      final settings = await _fcm.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("[Extrovert] Notifications denied. Not requesting token.");
        return;
      }

      //
      // --- SAFETY 3: Take Token Process (With Retry Strategy) ---
      //
      final prefs = await SharedPreferences.getInstance();
      final String? cachedToken = prefs.getString('fcm_token');

      String? token;
      int retryCount = 0;
      const int maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          token = await _fcm.getToken();
          if (token != null) break; // Success!
        } catch (e) {
          final String errorStr = e.toString();

          // Check for specific recoverable errors
          final bool isServiceNotAvailable =
              errorStr.contains("SERVICE_NOT_AVAILABLE") ||
                  errorStr.contains("java.io.IOException");
          final bool isTooManyRegistrations =
          errorStr.contains("TOO_MANY_REGISTRATIONS");

          if (isServiceNotAvailable || isTooManyRegistrations) {
            retryCount++;
            if (retryCount < maxRetries) {
              debugPrint(
                  "[Extrovert] FCM Token fetch failed ($errorStr). Retrying ($retryCount/$maxRetries) in ${retryCount *
                      2} seconds...");
              await Future.delayed(Duration(
                  seconds: retryCount * 2)); // Exponential backoff: 2s, 4s, 6s
            } else {
              debugPrint(
                  "[Extrovert] FCM Token fetch gave up after $maxRetries attempts. Using cached token if available.");
              token = cachedToken; // Fallback to cache
            }
          } else {
            // If it's a different error (e.g. invalid config), don't retry, just log.
            debugPrint(
                "[Extrovert] Unrecoverable error fetching FCM token: $e");
            break;
          }
        }
      }

      if (token == null) {
        debugPrint(
            "[Extrovert] Could not obtain an FCM token (Network issue or Service Unavailable). Skipping setup this session.");
        return;
      }

      //
      // --- ONLY IF TOKEN CHANGED ---
      //
      if (cachedToken != token) {
        await prefs.setString('fcm_token', token);
        await _saveTokenToDatabase(token);
        debugPrint("[Extrovert] Token saved/updated successfully.");
      } else {
        debugPrint("[Extrovert] Token unchanged. No write needed.");
      }

      //
      // --- Token Refresh Listener ---
      //
      _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint("[Extrovert] Token refreshed: $newToken");
        await prefs.setString('fcm_token', newToken);
        await _saveTokenToDatabase(newToken);
      }, onError: (err) {
        debugPrint("[Extrovert] Token refresh stream error: $err");
      });

      //
      // --- Foreground Message Listener ---
      //
      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
        debugPrint("[Extrovert] Foreground FCM received.");
        _showLocalizedNotification(msg.data);
      });

      //
      // --- Message Tapped When App Killed ---
      //
      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(
          const Duration(seconds: 1),
              () => _handleTapLogic(initialMessage.data),
        );
      }
    } catch (e, s) {
      // Final safety net.
      // We verify if it is the known "SERVICE_NOT_AVAILABLE" to avoid spamming Crashlytics
      if (e.toString().contains("SERVICE_NOT_AVAILABLE")) {
        debugPrint(
            "[Extrovert] FCM Service Not Available (Ignored in Crashlytics): $e");
      } else {
        debugPrint("[Extrovert] UNEXPECTED ERROR during FCM init: $e");
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: "FCM Initialization Failed (Fatal)");
      }
    }
  }

  /// Displays the OS permission dialog for notifications.
  /// This method is now protected against concurrent calls.
  Future<void> requestPermission() async {
    if (_isRequestingPermission) {
      debugPrint(
          "[ExtrovertNotificationService] A permission request is already in progress. Ignoring new request.");
      return;
    }

    try {
      _isRequestingPermission = true;

      await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (Platform.isIOS) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e, s) {
      if (e is! FirebaseException || e.code != 'failed-precondition') {
        debugPrint(
            "[ExtrovertNotificationService] Error requesting notification permission: $e");
        FirebaseCrashlytics.instance
            .recordError(e, s, reason: "FCM Permission Request Failed");
      } else {
        debugPrint(
            "[ExtrovertNotificationService] Handled a known 'failed-precondition' error during permission request.");
      }
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// Handles app lifecycle changes to schedule or cancel notifications.
  void handleAppLifecycleStateChange(AppLifecycleState state) async {
    if (!_isInitialized) {
      debugPrint(
          "[ExtrovertNotificationService] App lifecycle changed, but service not initialized. Skipping.");
      return;
    }

    const int lowBatteryNotificationId = 3;

    if (state == AppLifecycleState.resumed) {
      await _localNotifications.cancel(lowBatteryNotificationId);
      debugPrint(
          "[ExtrovertNotificationService] App resumed. Canceled any pending low-battery notification (ID: $lowBatteryNotificationId).");

      if (_auth.currentUser != null) {
        final pendingRequests =
        await _localNotifications.pendingNotificationRequests();
        final engagementRequests = pendingRequests
            .where((p) => p.id != lowBatteryNotificationId)
            .toList();
        if (engagementRequests.isEmpty) {
          debugPrint(
              "[ExtrovertNotificationService] No pending engagement notifications. Scheduling a recovery notification.");
          await _scheduleNextEngagementNotification();
        }
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      if (_auth.currentUser != null) {
        debugPrint(
            "[ExtrovertNotificationService] App paused/detached. Checking conditions to schedule notifications.");
        try {
          final batteryLevel = await Battery().batteryLevel;
          if (batteryLevel < 20) {
            final prefs = await SharedPreferences.getInstance();
            final lastSentTime =
                prefs.getInt('lowBatteryNotificationSentTime') ?? 0;
            final now = DateTime
                .now()
                .millisecondsSinceEpoch;
            if (now - lastSentTime > const Duration(hours: 12).inMilliseconds) {
              if (Random().nextDouble() < 0.1) {
                await _scheduleLowBatteryNotification();
                await prefs.setInt('lowBatteryNotificationSentTime', now);
                return; // Prioritize low battery notification
              }
            }
          }
        } catch (e) {
          debugPrint(
              "[ExtrovertNotificationService] Could not check battery level: $e");
        }
        _scheduleNextEngagementNotification();
      }
    }
  }

  /// Schedules a low battery notification.
  Future<void> _scheduleLowBatteryNotification() async {
    const int lowBatteryNotificationId = 3;
    final dataPayload = {
      'notification_title_key': 'notificationLowBatteryTitle',
      'notification_body_key': 'notificationLowBatteryBody',
    };
    final content = await _buildLocalizedContent(dataPayload);
    if (content.isNotEmpty) {
      final scheduledTime = DateTime.now().add(const Duration(minutes: 5));
      await _zonedScheduleNotification(
        lowBatteryNotificationId,
        content,
        scheduledTime,
        dataPayload,
        _engagementChannel,
      );
    }
  }

  /// Fetches the current FCM token and saves it to local storage and Firestore.
  /// This should be called after a successful login or registration to ensure
  /// the token is immediately associated with the user account.
  Future<void> syncTokenAfterLogin() async {
    if (!_isInitialized) {
      debugPrint(
          "[ExtrovertNotificationService] syncTokenAfterLogin called before initialization. Initializing now.");
      await initialize();
    }

    if (_auth.currentUser == null) {
      debugPrint(
          "[ExtrovertNotificationService] syncTokenAfterLogin called but no user is logged in. Aborting.");
      return;
    }

    try {
      final String? token = await _fcm.getToken();
      if (token == null) {
        debugPrint(
            "[ExtrovertNotificationService] Failed to get FCM token during syncAfterLogin.");
        return;
      }

      debugPrint(
          "[ExtrovertNotificationService] Token fetched on login/register: $token");

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('fcm_token', token);
      await _saveTokenToDatabase(token);
    } catch (e) {
      debugPrint(
          "[ExtrovertNotificationService] Error during syncTokenAfterLogin: $e");
    }
  }

  /// Removes the device's FCM token from Firestore and local storage on sign-out.
  /// This is more robust as it includes a fallback to get the current token if
  /// it's not found in local storage.
  Future<void> clearUserTokenOnSignOut() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? localToken = prefs.getString('fcm_token');
      await prefs.remove('fcm_token');
      debugPrint(
          "[ExtrovertNotificationService] Local FCM token cleared on sign out.");

      String? tokenToRemove = localToken;

      // Fallback: If the token wasn't in local storage for some reason,
      // get the current token directly from FCM to ensure it's removed from the backend.
      if (tokenToRemove == null) {
        debugPrint(
            "[ExtrovertNotificationService] Local token not found. Fetching current token as a fallback.");
        tokenToRemove = await _fcm.getToken();
      }

      if (tokenToRemove != null) {
        final userRef = _db.collection('users').doc(user.uid);
        await userRef.update({
          'fcmTokens': FieldValue.arrayRemove([tokenToRemove])
        });
        debugPrint(
            "[ExtrovertNotificationService] FCM token removed from Firestore for user ${user
                .uid}.");
      }
    } catch (e, s) {
      debugPrint(
          "[ExtrovertNotificationService] Error removing FCM token on sign-out: $e");
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: "FCM Token Cleanup Failed");
    }
  }

  /// Records the timestamp of the app being opened for scheduling logic.
  Future<void> recordAppOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime
        .now()
        .millisecondsSinceEpoch;
    if (prefs.getInt('firstAppOpenTime') == null) {
      await prefs.setInt('firstAppOpenTime', now);
    }
    await prefs.setInt('lastAppOpenTime', now);
    debugPrint(
        "[ExtrovertNotificationService] App open recorded at ${DateTime
            .now()}.");
  }

  /// The main scheduler for engagement notifications with richer content pools.
  Future<void> _scheduleNextEngagementNotification() async {
    if (!_isInitialized) return;
    if (await checkMaintenanceMode()) {
      debugPrint(
          "[ExtrovertNotificationService] Maintenance mode active. Deferring notification scheduling.");
      await SharedPreferences.getInstance()
          .then((p) => p.setBool('pendingNotificationDueToMaintenance', true));
      return;
    }
    try {
      const int engagementNotificationId = 2;
      await _localNotifications.cancel(engagementNotificationId);

      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now(); // DateTime

      final firstOpenTime = prefs.getInt('firstAppOpenTime');
      final lastOpenTime =
          prefs.getInt('lastAppOpenTime') ?? now.millisecondsSinceEpoch;
      final lastScheduledTime = prefs.getInt('lastSmartScheduleTime') ?? 0;

      if (now.millisecondsSinceEpoch - lastScheduledTime <
          const Duration(hours: 24).inMilliseconds) {
        debugPrint(
            "[ExtrovertNotificationService] Smart notification scheduled recently. Skipping.");
        return;
      }

      final welcomeNotificationSent =
          prefs.getBool('welcomeNotificationSent') ?? false;
      if (firstOpenTime != null && !welcomeNotificationSent) {
        final firstOpenDate =
        DateTime.fromMillisecondsSinceEpoch(firstOpenTime);
        if (now
            .difference(firstOpenDate)
            .inHours < 48) {
          final scheduledDateTime = now.add(const Duration(hours: 1));
          await _scheduleWelcomeNotification(scheduledDateTime);
          return;
        }
      }

      final daysSinceLastOpen = now
          .difference(DateTime.fromMillisecondsSinceEpoch(lastOpenTime))
          .inDays;
      Duration scheduleDelay;
      if (daysSinceLastOpen <= 2) {
        scheduleDelay = Duration(hours: 48 + Random().nextInt(12));
      } else if (daysSinceLastOpen <= 6) {
        scheduleDelay = Duration(hours: 36 + Random().nextInt(12));
      } else if (daysSinceLastOpen <= 14) {
        scheduleDelay = Duration(hours: 24 + Random().nextInt(12));
      } else {
        scheduleDelay = Duration(hours: 12 + Random().nextInt(12));
      }

      final scheduledDateTime = now.add(scheduleDelay);
      Map<String, String> selectedNotification;

      if (now.hour >= 20) {
        selectedNotification = {
          'title': 'notificationGoodMorningTitle',
          'body': 'notificationGoodMorningBody'
        };
        final tomorrow = now.add(const Duration(days: 1));
        final finalScheduleTime =
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9);
        await _scheduleFinalNotification(engagementNotificationId,
            selectedNotification, finalScheduleTime, _greetingsChannel);
      } else if (now.hour < 18) {
        selectedNotification = {
          'title': 'notificationGoodNightTitle',
          'body': 'notificationGoodNightBody'
        };
        final finalScheduleTime = DateTime(now.year, now.month, now.day, 22);
        await _scheduleFinalNotification(engagementNotificationId,
            selectedNotification, finalScheduleTime, _greetingsChannel);
      } else {
        if (daysSinceLastOpen > 14) {
          const comebackPool = [
            {
              'title': 'notificationComebackTitle',
              'body': 'notificationComebackBody'
            },
            {
              'title': 'notificationLongTimeNoSeeTitle',
              'body': 'notificationLongTimeNoSeeBody'
            }
          ];
          selectedNotification =
          comebackPool[Random().nextInt(comebackPool.length)];
        } else {
          const generalPool = [
            {
              'title': 'notificationHowAreYouTitle',
              'body': 'notificationHowAreYouBody'
            },
            {
              'title': 'notificationRandomFactTitle',
              'body': 'notificationRandomFactBody'
            },
            {
              'title': 'notificationShowerThoughtTitle',
              'body': 'notificationShowerThoughtBody'
            },
            {
              'title': 'notificationFortuneCookieTitle',
              'body': 'notificationFortuneCookieBody'
            },
            {
              'title': 'notificationHackerJokeTitle',
              'body': 'notificationHackerJokeBody'
            },
            {
              'title': 'notificationExistentialTitle',
              'body': 'notificationExistentialBody'
            }
          ];
          selectedNotification =
          generalPool[Random().nextInt(generalPool.length)];
        }
        await _scheduleFinalNotification(engagementNotificationId,
            selectedNotification, scheduledDateTime, _engagementChannel);
      }
    } catch (e, s) {
      debugPrint(
          "[ExtrovertNotificationService] Error during smart scheduling: $e");
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: "SmartSchedulingFailed");
    }
  }

  /// Schedules the notification that was deferred due to maintenance.
  /// This version intelligently determines *which* notification to schedule
  /// instead of just re-running the main scheduler.
  Future<void> schedulePendingNotification() async {
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('pendingNotificationDueToMaintenance') ?? false)) {
      return;
    }

    debugPrint(
        "[ExtrovertNotificationService] Maintenance is over. Intelligently scheduling deferred notification.");

    final welcomeNotificationSent =
        prefs.getBool('welcomeNotificationSent') ?? false;

    if (!welcomeNotificationSent) {
      debugPrint(
          "[ExtrovertNotificationService] The pending notification was a 'Welcome' notification. Scheduling it now.");
      final scheduledTime = DateTime.now().add(const Duration(minutes: 5));
      await _scheduleWelcomeNotification(scheduledTime);
    } else {
      debugPrint(
          "[ExtrovertNotificationService] Scheduling a general engagement notification after maintenance.");
      const generalPool = [
        {
          'title': 'notificationHowAreYouTitle',
          'body': 'notificationHowAreYouBody'
        },
        {
          'title': 'notificationLongTimeNoSeeTitle',
          'body': 'notificationLongTimeNoSeeBody'
        },
      ];
      final selectedNotification =
      generalPool[Random().nextInt(generalPool.length)];
      final scheduledTime = DateTime.now().add(const Duration(minutes: 5));
      await _scheduleFinalNotification(
          2, selectedNotification, scheduledTime, _engagementChannel);
    }

    await prefs.setBool('pendingNotificationDueToMaintenance', false);
  }

  /// Schedules the special welcome discount notification.
  Future<void> _scheduleWelcomeNotification(DateTime scheduledTime) async {
    const int welcomeNotificationId = 1;
    final welcomeNotification = {
      'title': 'notificationWelcomeOfferTitle',
      'body': 'notificationWelcomeOfferBody',
      'screen': 'funds'
    };

    await _scheduleFinalNotification(
      welcomeNotificationId,
      welcomeNotification,
      scheduledTime,
      _engagementChannel,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('welcomeNotificationSent', true);
    debugPrint(
        "[ExtrovertNotificationService] Welcome discount notification scheduled with ID 1 for $scheduledTime.");
  }

  /// Helper to build and schedule a notification, centralizing the logic.
  Future<void> _scheduleFinalNotification(int id,
      Map<String, String> notificationKeys,
      DateTime scheduledTime,
      AndroidNotificationChannel channel) async {
    final dataPayload = {
      'notification_title_key': notificationKeys['title']!,
      'notification_body_key': notificationKeys['body']!,
      'channel_id': channel.id,
      'channel_name': channel.name,
      'channel_desc': channel.description,
    };
    final content = await _buildLocalizedContent(dataPayload);
    if (content.isNotEmpty) {
      await _zonedScheduleNotification(
          id, content, scheduledTime, dataPayload, channel);
    }
  }

  /// Performs the actual zoned scheduling with FlutterLocalNotifications.
  Future<void> _zonedScheduleNotification(int id,
      Map<String, String> content,
      DateTime scheduledDateTime,
      Map<String, dynamic> payload,
      AndroidNotificationChannel channel,) async {
    timezone.TZDateTime timezoneScheduled;
    try {
      timezoneScheduled =
          timezone.TZDateTime.from(scheduledDateTime, timezone.local);
    } catch (e) {
      debugPrint(
          "[Extrovert] Timezone conversion failed. Re-initializing fallback.");
      try {
        data.initializeTimeZones();
        timezone.setLocalLocation(timezone.getLocation('UTC'));
        timezoneScheduled =
            timezone.TZDateTime.from(scheduledDateTime, timezone.local);
      } catch (innerE) {
        debugPrint(
            "[Extrovert] CRITICAL: Timezone fatal error. Cannot schedule notification.");
        return;
      }
    }
    // ----------------------------

    final platformChannelSpecifics = NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: Priority.high,
        styleInformation: BigTextStyleInformation(
          content['body']!,
          htmlFormatBigText: false,
          contentTitle: content['title'],
          htmlFormatContentTitle: false,
        ),
      ),
      iOS: const DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.zonedSchedule(
      id,
      content['title'],
      content['body'],
      timezoneScheduled,
      platformChannelSpecifics,
      payload: jsonEncode(payload),
      androidScheduleMode: AndroidScheduleMode.inexact,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        'lastSmartScheduleTime', DateTime
        .now()
        .millisecondsSinceEpoch);
    debugPrint(
        "[ExtrovertNotificationService] Scheduled '${payload['notification_title_key']}' for ${timezoneScheduled
            .toString()}.");
  }

  /// Saves or updates the user's FCM token in their Firestore document.
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userRef = _db.collection('users').doc(user.uid);
    try {
      await userRef.set({
        'fcmTokens': FieldValue.arrayUnion([token])
      }, SetOptions(merge: true));
      debugPrint(
          "[ExtrovertNotificationService] FCM Token successfully saved to Firestore.");
    } catch (e) {
      debugPrint(
          "[ExtrovertNotificationService] CRITICAL: Error saving FCM token to Firestore: $e");
    }
  }

  /// Callback for when any local notification is tapped.
  void _onNotificationTapped(NotificationResponse response) {
    debugPrint('[ExtrovertNotificationService] Local notification tapped!');
    if (response.payload != null && response.payload!.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _handleTapLogic(data);
      } catch (e) {
        debugPrint(
            '[ExtrovertNotificationService] Error decoding notification payload: $e');
      }
    }
  }

  /// Centralized logic for handling a tap from any notification source.
  void _handleTapLogic(Map<String, dynamic> data) {
    debugPrint(
        "[ExtrovertNotificationService] Handling notification tap. Data: $data");

    Map<String, dynamic> finalData = Map.from(data);
    if (data['dataPayloadJson'] is String) {
      try {
        final decodedPayload = jsonDecode(data['dataPayloadJson']);
        if (decodedPayload is Map<String, dynamic>) {
          finalData.addAll(decodedPayload);
        }
      } catch (e) {
        debugPrint(
            "[ExtrovertNotificationService] Could not decode dataPayloadJson: $e");
      }
    }

    final screen = finalData['screen'];
    if (screen == 'news') {
      final slug = finalData['slug'];
      debugPrint("TODO: Navigate to news article with slug: $slug");
      // Example: navigatorKey.currentState?.push(MaterialPageRoute(builder: (_) => NewsDetailScreen(slug: slug)));
    } else if (screen == 'funds' ||
        finalData['notification_title_key'] ==
            'notificationWelcomeOfferTitle') {
      debugPrint("[Extrovert] Navigating to FundsScreen (Special Offer)");
      navigatorKey.currentState
          ?.push(MaterialPageRoute(builder: (_) => const FundsScreen()));
    } else if (finalData['notification_title_key'] ==
        'notificationRateAppTitle') {
      debugPrint("TODO: Open the app store for rating.");
      // Example: InAppReview.instance.openStoreListing();
    } else {
      debugPrint(
          "No specific navigation action for this notification. Defaulting to home screen.");
    }
  }
}
