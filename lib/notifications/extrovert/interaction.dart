part of 'service.dart';

extension ExtrovertInteraction on ExtrovertNotificationService {
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
