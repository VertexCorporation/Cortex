part of 'service.dart';

extension ExtrovertScheduler on ExtrovertNotificationService {
  /// Handles app lifecycle changes to schedule or cancel notifications.
  void handleAppLifecycleStateChange(AppLifecycleState state) async {
    if (kIsWeb) return;

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
      final now = DateTime.now();

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
            .inHours < 47) {
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
  Future<void> schedulePendingNotification() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('pendingNotificationDueToMaintenance') ?? false)) {
      return;
    }

    debugPrint(
        "[ExtrovertNotificationService] Maintenance is over. Intelligently scheduling deferred notification.");

    final now = DateTime.now();
    final welcomeNotificationSent =
        prefs.getBool('welcomeNotificationSent') ?? false;

    if (!welcomeNotificationSent) {
      debugPrint(
          "[ExtrovertNotificationService] The pending notification was a 'Welcome' notification. Scheduling it now.");
      final scheduledTime = now.add(const Duration(minutes: 5));
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
      final scheduledTime = now.add(const Duration(minutes: 5));
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
}
