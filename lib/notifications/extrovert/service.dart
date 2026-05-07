import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:battery_plus/battery_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as timezone;
import 'package:timezone/data/latest.dart' as data;

import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/maintenance.dart';
import 'package:cortex/funds/funds.dart';

part 'localization.dart';
part 'handlers.dart';
part 'scheduler.dart';
part 'token.dart';
part 'interaction.dart';

class ExtrovertNotificationService {
  final GlobalKey<NavigatorState> navigatorKey;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  late AndroidNotificationChannel _fcmChannel;
  late AndroidNotificationChannel _engagementChannel;
  late AndroidNotificationChannel _greetingsChannel;

  bool _isInitialized = false;
  Future<void>? _initFuture;
  bool _isRequestingPermission = false;

  ExtrovertNotificationService({required this.navigatorKey});

  /// Initializes the entire notification system. This method is self-contained
  /// and can be called early in the app lifecycle without needing a BuildContext.
  Future<void> initialize() async {
    if (_isInitialized) return;
    if (_initFuture != null) {
      await _initFuture;
      return;
    }

    _initFuture = _performInitialization();
    try {
      await _initFuture;
      _isInitialized = true;
    } finally {
      _initFuture = null;
    }
  }

  Future<void> _performInitialization() async {
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

    final prefs = await SharedPreferences.getInstance();
    final savedLocaleCode = prefs.getString('language_code');
    final locale = savedLocaleCode != null
        ? Locale(savedLocaleCode)
        : Locale(Platform.localeName
        .split('_')
        .first);
    final l10n = await AppLocalizations.delegate.load(locale);

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

    debugPrint("[ExtrovertNotificationService] Initialization complete.");
  }

  /// Sets up Flutter Local Notifications, including channels and tap handlers.
  Future<void> _initializeLocalNotifications() async {
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
}
