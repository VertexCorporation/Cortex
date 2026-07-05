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
    if (screen == 'chat' || finalData['type'] == 'background_chat') {
      _openChatFromNotification(finalData['conversation_id']?.toString());
    } else if (screen == 'news') {
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

  Future<void> _openChatFromNotification(String? conversationId) async {
    navigatorKey.currentState?.popUntil((route) => route.isFirst);

    for (int attempt = 0; attempt < 8; attempt++) {
      final context = navigatorKey.currentContext;
      final state = mainScreenKey?.currentState;
      if (context != null && state != null) {
        InboxViewModel? inbox;
        LocaleProvider? localeProvider;
        ModelService? modelService;
        try {
          // ignore: use_build_context_synchronously
          inbox = context.read<InboxViewModel>();
          // ignore: use_build_context_synchronously
          localeProvider = context.read<LocaleProvider>();
          // ignore: use_build_context_synchronously
          modelService = context.read<ModelService>();
        } catch (e) {
          debugPrint("[Extrovert] Providers not ready for chat tap: $e");
        }

        if (conversationId != null && conversationId.isNotEmpty) {
          ConversationManager? manager;
          if (inbox != null) {
            try {
              await inbox.refreshIfNeeded();
              manager = inbox.conversationManagers[conversationId];
            } catch (e) {
              debugPrint(
                  "[Extrovert] Inbox refresh failed for chat notification: $e");
            }
          }

          if (manager == null &&
              localeProvider != null &&
              modelService != null) {
            try {
              final langCode = localeProvider.locale.languageCode;
              manager = await ConversationManager.fromId(
                conversationId,
                langCode: langCode,
                modelService: modelService,
              );
            } catch (e) {
              debugPrint(
                  "[Extrovert] Conversation lookup failed for notification: $e");
            }
          }

          if (manager != null) {
            try {
              (state as dynamic).openConversation(manager);
              return;
            } catch (e) {
              debugPrint(
                  "[Extrovert] Could not open conversation from notification: $e");
            }
          }
        }

        try {
          (state as dynamic).startNewConversation(
            closeSidebar: true,
            restoreDefaultModel: false,
          );
        } catch (e) {
          debugPrint("[Extrovert] Chat notification fallback failed: $e");
        }
        return;
      }

      await Future.delayed(const Duration(milliseconds: 150));
    }
  }
}
