// lib/analytics/analytics_service.dart
//
// Central analytics service for screen tracking, event logging, and user properties.
// Wraps Firebase Analytics to provide a unified interface across the app.

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized analytics service providing screen tracking, event logging,
/// and user property management through Firebase Analytics.
class AnalyticsService {
  // Singleton pattern
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  /// Get the navigator observer for automatic route tracking.
  /// Filters out the root '/' route since it's always shown and not useful for analysis.
  FirebaseAnalyticsObserver get observer => FirebaseAnalyticsObserver(
        analytics: _analytics,
        nameExtractor: (settings) {
          // Filter out root route - it's always shown on app start
          if (settings.name == '/') return null;
          return settings.name;
        },
      );

  // ============================================================
  // SCREEN TRACKING (Views by Page title and screen class)
  // ============================================================

  /// Log a screen view event with the given [screenName].
  /// [screenClass] is optional and defaults to the screen name.
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
      debugPrint('[Analytics] Screen: $screenName');
    } catch (e) {
      debugPrint('[Analytics] Error logging screen view: $e');
    }
  }

  // Convenience methods for each screen
  Future<void> logOnboardingScreen() =>
      logScreenView(screenName: 'OnboardingScreen');

  Future<void> logLoginScreen() => logScreenView(screenName: 'LoginScreen');

  Future<void> logRegisterScreen() =>
      logScreenView(screenName: 'RegisterScreen');

  Future<void> logVerificationScreen() =>
      logScreenView(screenName: 'VerificationScreen');

  Future<void> logChatScreen() => logScreenView(screenName: 'ChatScreen');

  Future<void> logLibraryScreen() => logScreenView(screenName: 'LibraryScreen');

  Future<void> logNewsScreen() => logScreenView(screenName: 'NewsScreen');

  Future<void> logSettingsScreen() =>
      logScreenView(screenName: 'SettingsScreen');

  Future<void> logFundsScreen() => logScreenView(screenName: 'FundsScreen');

  Future<void> logModelDetailScreen(String modelId) => logScreenView(
        screenName: 'ModelDetailScreen',
        screenClass: 'ModelDetailScreen_$modelId',
      );

  Future<void> logCreateModelScreen() =>
      logScreenView(screenName: 'CreateModelScreen');

  Future<void> logWebViewScreen(String title) => logScreenView(
        screenName: 'WebViewScreen',
        screenClass: 'WebView_$title',
      );

  Future<void> logMaintenanceScreen() =>
      logScreenView(screenName: 'MaintenanceScreen');

  Future<void> logUpdateScreen() =>
      logScreenView(screenName: 'UpdateRequiredScreen');

  // ============================================================
  // EVENT TRACKING (Event count by Event name)
  // ============================================================

  /// Generic event logger
  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    try {
      await _analytics.logEvent(name: name, parameters: parameters);
      debugPrint('[Analytics] Event: $name ${parameters ?? ''}');
    } catch (e) {
      debugPrint('[Analytics] Error logging event: $e');
    }
  }

  // --- App Lifecycle Events ---

  Future<void> logAppOpen({
    required String version,
    required String platform,
  }) =>
      logEvent(
        name: 'app_open',
        parameters: {'version': version, 'platform': platform},
      );

  Future<void> logOnboardingComplete() => logEvent(name: 'onboarding_complete');

  Future<void> logOnboardingStep(int step) => logEvent(
        name: 'onboarding_step',
        parameters: {'step': step},
      );

  // --- Authentication Events ---

  Future<void> logLoginSuccess(String method) => logEvent(
        name: 'login_success',
        parameters: {'method': method},
      );

  Future<void> logLoginFailure(String method, String error) => logEvent(
        name: 'login_failure',
        parameters: {'method': method, 'error': error},
      );

  Future<void> logRegisterSuccess(String method) => logEvent(
        name: 'register_success',
        parameters: {'method': method},
      );

  Future<void> logRegisterFailure(String method, String error) => logEvent(
        name: 'register_failure',
        parameters: {'method': method, 'error': error},
      );

  Future<void> logLogout() => logEvent(name: 'logout');

  // --- Navigation & UI Events ---

  Future<void> logSidebarOpened() => logEvent(name: 'sidebar_opened');

  Future<void> logSidebarClosed() => logEvent(name: 'sidebar_closed');

  Future<void> logTabSwitched(String tabName) => logEvent(
        name: 'tab_switched',
        parameters: {'tab': tabName},
      );

  // --- Chat Events ---

  Future<void> logConversationStarted({required bool isNew}) => logEvent(
        name: 'conversation_started',
        parameters: {'is_new': isNew ? 1 : 0},
      );

  Future<void> logMessageSent({
    required String modelType,
    required bool hasAttachments,
  }) =>
      logEvent(
        name: 'message_sent',
        parameters: {
          'model_type': modelType,
          'has_attachments': hasAttachments ? 1 : 0,
        },
      );

  Future<void> logMessageRegenerated() => logEvent(name: 'message_regenerated');

  Future<void> logResponseStopped() => logEvent(name: 'response_stopped');

  Future<void> logMessageEdited() => logEvent(name: 'message_edited');

  Future<void> logMessageCopied() => logEvent(name: 'message_copied');

  Future<void> logConversationDeleted() =>
      logEvent(name: 'conversation_deleted');

  Future<void> logConversationRenamed() =>
      logEvent(name: 'conversation_renamed');

  // --- Model Events ---

  Future<void> logModelSelected({
    required String modelId,
    required String modelType,
  }) =>
      logEvent(
        name: 'model_selected',
        parameters: {'model_id': modelId, 'model_type': modelType},
      );

  Future<void> logModelDownloadStarted(String modelId) => logEvent(
        name: 'model_download_started',
        parameters: {'model_id': modelId},
      );

  Future<void> logModelDownloadCompleted({
    required String modelId,
    required int durationSeconds,
  }) =>
      logEvent(
        name: 'model_download_completed',
        parameters: {
          'model_id': modelId,
          'duration_sec': durationSeconds,
        },
      );

  Future<void> logModelDownloadFailed({
    required String modelId,
    required String error,
  }) =>
      logEvent(
        name: 'model_download_failed',
        parameters: {'model_id': modelId, 'error': error},
      );

  Future<void> logModelDeleted(String modelId) => logEvent(
        name: 'model_deleted',
        parameters: {'model_id': modelId},
      );

  Future<void> logModelCreated() => logEvent(name: 'model_created');

  // --- Feature Usage Events ---

  Future<void> logVoiceInputStarted() => logEvent(name: 'voice_input_started');

  Future<void> logVoiceInputCompleted() =>
      logEvent(name: 'voice_input_completed');

  Future<void> logAttachmentAdded(String type) => logEvent(
        name: 'attachment_added',
        parameters: {'type': type},
      );

  Future<void> logTTSUsed() => logEvent(name: 'tts_used');

  Future<void> logSearchUsed(String context) => logEvent(
        name: 'search_used',
        parameters: {'context': context},
      );

  // --- Purchase Events (Critical for Key Events) ---

  Future<void> logPurchaseInitiated({
    required String productId,
    required String productType,
  }) =>
      logEvent(
        name: 'purchase_initiated',
        parameters: {
          'product_id': productId,
          'product_type': productType,
        },
      );

  Future<void> logPurchaseSuccess({
    required String productId,
    required String productType,
    required double value,
    required String currency,
  }) async {
    // Use Firebase's built-in purchase event for proper tracking
    await _analytics.logPurchase(
      currency: currency,
      value: value,
      items: [
        AnalyticsEventItem(
          itemId: productId,
          itemName: productId,
          itemCategory: productType,
        ),
      ],
    );
    // Also log custom event for easier filtering
    await logEvent(
      name: 'purchase_success',
      parameters: {
        'product_id': productId,
        'product_type': productType,
        'value': value,
        'currency': currency,
      },
    );
  }

  Future<void> logPurchaseFailure({
    required String productId,
    required String productType,
    required String error,
  }) =>
      logEvent(
        name: 'purchase_failure',
        parameters: {
          'product_id': productId,
          'product_type': productType,
          'error': error,
        },
      );

  Future<void> logPurchaseCancelled({
    required String productId,
    required String productType,
  }) =>
      logEvent(
        name: 'purchase_cancelled',
        parameters: {
          'product_id': productId,
          'product_type': productType,
        },
      );

  Future<void> logSubscriptionRenewed({
    required String productId,
    required double value,
    required String currency,
  }) =>
      logEvent(
        name: 'subscription_renewed',
        parameters: {
          'product_id': productId,
          'value': value,
          'currency': currency,
        },
      );

  // --- Settings Events ---

  Future<void> logThemeChanged(String theme) => logEvent(
        name: 'theme_changed',
        parameters: {'theme': theme},
      );

  Future<void> logLanguageChanged(String languageCode) => logEvent(
        name: 'language_changed',
        parameters: {'language': languageCode},
      );

  // --- Error Events ---

  Future<void> logError({
    required String errorType,
    required String errorMessage,
    String? screen,
  }) =>
      logEvent(
        name: 'app_error',
        parameters: {
          'error_type': errorType,
          'error_message': errorMessage,
          if (screen != null) 'screen': screen,
        },
      );

  // ============================================================
  // USER PROPERTIES
  // ============================================================

  Future<void> setUserProperties({
    String? appVersion,
    String? platform,
    String? deviceType,
    String? userTier,
    String? accountType,
    String? languagePreference,
    String? themePreference,
  }) async {
    try {
      if (appVersion != null) {
        await _analytics.setUserProperty(
            name: 'app_version', value: appVersion);
      }
      if (platform != null) {
        await _analytics.setUserProperty(name: 'platform', value: platform);
      }
      if (deviceType != null) {
        await _analytics.setUserProperty(
            name: 'device_type', value: deviceType);
      }
      if (userTier != null) {
        await _analytics.setUserProperty(name: 'user_tier', value: userTier);
      }
      if (accountType != null) {
        await _analytics.setUserProperty(
            name: 'account_type', value: accountType);
      }
      if (languagePreference != null) {
        await _analytics.setUserProperty(
            name: 'language_pref', value: languagePreference);
      }
      if (themePreference != null) {
        await _analytics.setUserProperty(
            name: 'theme_pref', value: themePreference);
      }
      debugPrint('[Analytics] User properties updated');
    } catch (e) {
      debugPrint('[Analytics] Error setting user properties: $e');
    }
  }

  /// Set the Firebase user ID for cross-device tracking
  Future<void> setUserId(String? userId) async {
    try {
      await _analytics.setUserId(id: userId);
      debugPrint('[Analytics] User ID set: ${userId != null}');
    } catch (e) {
      debugPrint('[Analytics] Error setting user ID: $e');
    }
  }

  /// Clear analytics data on logout
  Future<void> resetAnalyticsData() async {
    try {
      await _analytics.resetAnalyticsData();
      debugPrint('[Analytics] Analytics data reset');
    } catch (e) {
      debugPrint('[Analytics] Error resetting analytics: $e');
    }
  }
}
