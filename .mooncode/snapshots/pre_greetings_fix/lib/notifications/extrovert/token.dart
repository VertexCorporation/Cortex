part of 'service.dart';

const List<int> _notificationPermissionPromptThresholds = <int>[5, 25, 50, 100];
const String _notificationPermissionMessageCountKey =
    'notification_permission_message_count';
const String _notificationPermissionAttemptedThresholdsKey =
    'notification_permission_attempted_thresholds';

extension ExtrovertTokenManager on ExtrovertNotificationService {
  /// Sets up Firebase Cloud Messaging, including permissions and message listeners.
  Future<void> _initializeFirebaseMessaging() async {
    if (kIsWeb) {
      debugPrint(
          "[Extrovert] Skipping Firebase Messaging init on Web to prevent permission prompts.");
      return;
    }

    try {
      final bool fcmAvailable = await _fcm.isSupported();
      if (!fcmAvailable) {
        debugPrint(
            "[Extrovert] FCM not supported on this device. Skipping FCM init.");
        return;
      }

      final settings = await _fcm.getNotificationSettings();
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint("[Extrovert] Notifications denied. Not requesting token.");
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final String? cachedToken = prefs.getString('fcm_token');

      String? token;
      int retryCount = 0;
      const int maxRetries = 3;

      while (retryCount < maxRetries) {
        try {
          token = await _fcm.getToken();
          if (token != null) break;
        } catch (e) {
          final String errorStr = e.toString();

          final bool isServiceNotAvailable =
              errorStr.contains("SERVICE_NOT_AVAILABLE") ||
                  errorStr.contains("java.io.IOException");
          final bool isTooManyRegistrations =
              errorStr.contains("TOO_MANY_REGISTRATIONS");

          if (isServiceNotAvailable || isTooManyRegistrations) {
            retryCount++;
            if (retryCount < maxRetries) {
              debugPrint(
                  "[Extrovert] FCM Token fetch failed ($errorStr). Retrying ($retryCount/$maxRetries) in ${retryCount * 2} seconds...");
              await Future.delayed(Duration(seconds: retryCount * 2));
            } else {
              debugPrint(
                  "[Extrovert] FCM Token fetch gave up after $maxRetries attempts. Using cached token if available.");
              token = cachedToken;
            }
          } else {
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

      if (cachedToken != token) {
        await prefs.setString('fcm_token', token);
        await _saveTokenToDatabase(token);
        debugPrint("[Extrovert] Token saved/updated successfully.");
      } else {
        debugPrint("[Extrovert] Token unchanged. No write needed.");
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        debugPrint("[Extrovert] Token refreshed: $newToken");
        await prefs.setString('fcm_token', newToken);
        await _saveTokenToDatabase(newToken);
      }, onError: (err) {
        debugPrint("[Extrovert] Token refresh stream error: $err");
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage msg) {
        debugPrint("[Extrovert] Foreground FCM received.");
        _showLocalizedNotification(msg.data);
      });

      final initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        Future.delayed(
          const Duration(seconds: 1),
          () => _handleTapLogic(initialMessage.data),
        );
      }
    } catch (e, s) {
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

  bool _hasNotificationPermission(NotificationSettings settings) {
    return settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional;
  }

  int? _nextPermissionPromptThreshold({
    required int messageCount,
    required Set<String> attemptedThresholds,
  }) {
    for (final threshold in _notificationPermissionPromptThresholds) {
      if (messageCount >= threshold &&
          !attemptedThresholds.contains(threshold.toString())) {
        return threshold;
      }
    }
    return null;
  }

  Future<void> recordSentMessageAndMaybeRequestPermission() async {
    if (kIsWeb || _isRequestingPermission) return;

    try {
      final bool fcmAvailable = await _fcm.isSupported();
      if (!fcmAvailable) return;

      final currentSettings = await _fcm.getNotificationSettings();
      final prefs = await SharedPreferences.getInstance();
      if (_hasNotificationPermission(currentSettings)) {
        if (!prefs.containsKey('fcm_token')) {
          await syncTokenAfterLogin();
        }
        return;
      }

      final messageCount =
          (prefs.getInt(_notificationPermissionMessageCountKey) ?? 0) + 1;
      await prefs.setInt(_notificationPermissionMessageCountKey, messageCount);

      final attemptedThresholds =
          (prefs.getStringList(_notificationPermissionAttemptedThresholdsKey) ??
                  const <String>[])
              .toSet();
      final threshold = _nextPermissionPromptThreshold(
        messageCount: messageCount,
        attemptedThresholds: attemptedThresholds,
      );
      if (threshold == null) return;

      attemptedThresholds.add(threshold.toString());
      final sortedThresholds = attemptedThresholds.toList()
        ..sort(
            (a, b) => (int.tryParse(a) ?? 0).compareTo(int.tryParse(b) ?? 0));
      await prefs.setStringList(
          _notificationPermissionAttemptedThresholdsKey, sortedThresholds);

      debugPrint(
          "[ExtrovertNotificationService] Requesting notification permission at message #$messageCount (threshold $threshold).");
      await requestPermission();
    } catch (e, s) {
      debugPrint(
          "[ExtrovertNotificationService] Error while evaluating notification permission prompt: $e");
      FirebaseCrashlytics.instance.recordError(
        e,
        s,
        reason: "Notification Permission Prompt Evaluation Failed",
        fatal: false,
      );
    }
  }

  /// Fetches the current FCM token and saves it to local storage and Firestore.
  Future<void> syncTokenAfterLogin() async {
    if (kIsWeb) return;
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
  Future<void> clearUserTokenOnSignOut() async {
    if (kIsWeb) return;

    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? localToken = prefs.getString('fcm_token');
      await prefs.remove('fcm_token');
      debugPrint(
          "[ExtrovertNotificationService] Local FCM token cleared on sign out.");

      String? tokenToRemove = localToken;

      if (tokenToRemove == null) {
        debugPrint(
            "[ExtrovertNotificationService] Local token not found. Fetching current token as a fallback.");
        try {
          tokenToRemove = await _fcm.getToken();
        } catch (e) {
          debugPrint(
              "[ExtrovertNotificationService] Ignored error while fetching token during sign-out: \$e");
        }
      }

      if (tokenToRemove != null) {
        if (user.isAnonymous) {
          debugPrint(
              "[ExtrovertNotificationService] User is anonymous. Skipping Firestore FCM token cleanup.");
        } else {
          final userRef = _db.collection('users').doc(user.uid);
          await userRef.update({
            'fcmTokens': FieldValue.arrayRemove([tokenToRemove])
          });
          debugPrint(
              "[ExtrovertNotificationService] FCM token removed from Firestore for user ${user.uid}.");
        }
      }
    } catch (e, s) {
      if (e is FirebaseException && e.code == 'permission-denied') {
        debugPrint(
            "[ExtrovertNotificationService] Permission denied removing token (likely anonymous or deleted). Ignoring.");
        return;
      }
      debugPrint(
          "[ExtrovertNotificationService] Error removing FCM token on sign-out: $e");
      FirebaseCrashlytics.instance
          .recordError(e, s, reason: "FCM Token Cleanup Failed");
    }
  }

  /// Saves or updates the user's FCM token in their Firestore document with retry logic.
  Future<void> _saveTokenToDatabase(String token) async {
    final user = _auth.currentUser;
    if (user == null) return;
    final userRef = _db.collection('users').doc(user.uid);
    
    int attempts = 0;
    const int maxAttempts = 5;
    while (attempts < maxAttempts) {
      try {
        await userRef.set({
          'fcmTokens': FieldValue.arrayUnion([token])
        }, SetOptions(merge: true));
        debugPrint(
            "[ExtrovertNotificationService] FCM Token successfully saved to Firestore on attempt ${attempts + 1}.");
        return;
      } catch (e, s) {
        attempts++;
        debugPrint(
            "[ExtrovertNotificationService] Attempt $attempts to save FCM token failed: $e");
        if (attempts >= maxAttempts) {
          debugPrint(
              "[ExtrovertNotificationService] CRITICAL: Failed to save FCM token to Firestore after $maxAttempts attempts.");
          FirebaseCrashlytics.instance.recordError(
            e,
            s,
            reason: "FCM Token Database Save Exhausted Retries",
          );
        } else {
          // Wait with exponential backoff: 500ms, 1000ms, 2000ms, 4000ms...
          await Future.delayed(Duration(milliseconds: 500 * (1 << (attempts - 1))));
        }
      }
    }
  }

  /// Displays the OS permission dialog for notifications.
  Future<void> requestPermission() async {
    if (kIsWeb) {
      debugPrint(
          "[ExtrovertNotificationService] Web platform does not support or require notification permissions at this time.");
      return;
    }

    if (_isRequestingPermission) {
      debugPrint(
          "[ExtrovertNotificationService] A permission request is already in progress. Ignoring new request.");
      return;
    }

    try {
      _isRequestingPermission = true;

      final settings = await _fcm.requestPermission(
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

      if (_hasNotificationPermission(settings)) {
        await syncTokenAfterLogin();
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
}
