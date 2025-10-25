// lib/chat/widgets/inactive.dart
//
// This file defines the InactiveChatView widget. It is responsible for rendering the UI
// when no chat is active. This includes the model selection screen, displaying recent
// models, news, and handling model search and filtering logic. It owns the state
// and behavior specific to the model discovery and selection process.

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/unselected/screen/screen.dart';
import 'package:cortex/chat/services/load.dart';
import 'package:cortex/chat/services/recent.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../banner.dart';
import '../../errorview.dart';
import '../../initialization.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../../models/backend/data/info.dart';
import '../../server/user.dart';

/// A stateful widget that displays the UI for the model selection screen.
class InactiveChatView extends StatefulWidget {
  final void Function(bool isSelected)? onModelSelectionChanged;

  const InactiveChatView({
    super.key,
    required this.onModelSelectionChanged,
  });

  @override
  InactiveChatViewState createState() => InactiveChatViewState();
}

/// The state for InactiveChatView. Manages UI state such as the search controller
/// and orchestrates data loading and presentation for the SelectionScreen.
class InactiveChatViewState extends State<InactiveChatView> {
  // --- UI Controllers and Keys ---

  // Controller for the model search input field.
  final TextEditingController searchController = TextEditingController();
  // Key to access the state of the child SelectionScreen widget.
  final GlobalKey<SelectionScreenState> selectionScreenKey =
  GlobalKey<SelectionScreenState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onModelSelectionChanged?.call(false);

      context.read<BannerService>().checkAndTriggerBanner();

      final sessionProvider = context.read<ChatSessionProvider>();
      if (sessionProvider.appBarMode == AppBarMode.inSelection) {
        selectionScreenKey.currentState?.showAllModelsView();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  /// Public method to clear controllers owned by this view.
  /// Called by the parent controller during a full exit.
  void clearControllers() {
    searchController.clear();
  }

  /// Public method to programmatically switch the view back to the main selection
  /// page from the "all models" grid.
  void showSelectionView() {
    selectionScreenKey.currentState?.showSelectionView();
  }

  /// Public method to programmatically switch to the "all models" grid.
  /// This is called by the parent MainScreen when restoring the view state after a chat exit.
  void showAllModelsView() {
    selectionScreenKey.currentState?.showAllModelsView();
  }

  /// A central function to trigger a reload of all model data.
  /// This is called by the parent controller when a language change is detected.
  Future<void> reloadAllModelsForLanguageChange() async {
    if (!mounted) return;
    debugPrint("[InactiveView] Triggering model reload...");

    // Ensure core services are ready before attempting to load data.
    final appInitializer = context.read<AppInitializer>();
    await appInitializer.onCoreServicesReady;
    if (!mounted) return;

    // Delegate the actual loading logic to the LoadService.
    await context
        .read<LoadService>()
        .loadModels(languageCode: Localizations.localeOf(context).languageCode);

    debugPrint("[InactiveView] Model reload command sent to LoadService.");
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final recentModelsManager = context.watch<RecentModelsManager>();
    final bannerService = context.watch<BannerService>();
    final userProvider = context.watch<UserProvider>();

    if (sessionProvider.modelsLoadError) {
      return ErrorView(
        key: const ValueKey('chat_error'),
        title: localizations.errorLoadingTitle,
        message: localizations.errorLoadingMessage,
        buttonText: localizations.retry,
        onRetry: reloadAllModelsForLanguageChange,
      );
    }

    // The entire view is wrapped in a Stack to overlay the banner.
    return Stack(
      children: [
        // Original content (SelectionScreen) is the first child of the Stack.
        ValueListenableBuilder<List<ModelInfo>>(
          valueListenable: recentModelsManager.recentModelsNotifier,
          builder: (context, recentModelsValue, child) {
            final bool isLimitExceeded =
                sessionProvider.chatLimitManager?.isLimitExceeded(
                  conversationProvider.messages,
                ) ??
                    false;

            return SelectionScreen(
              key: selectionScreenKey,
              isLoading: sessionProvider.areModelsLoading,
              allModels: sessionProvider.allModels,
              recentModels: recentModelsValue,
              conversationLimitReached: isLimitExceeded,
              searchController: searchController,
              onReloadModels: reloadAllModelsForLanguageChange,
              onSelectModel: (model, ctx) {
                context.read<SelectionService>().selectModel(model, context: ctx);
              },
              onScrollToBottom: () {
                context.read<ScrollService>().scrollToBottom();
              },
              localizations: localizations,
              userData: userProvider.userData,
              onViewModeChanged: (isShowingAllModels) {
                context.read<ChatSessionProvider>().setAppBarMode(
                    isShowingAllModels
                        ? AppBarMode.inSelection
                        : AppBarMode.notSelected);
              },
            );
          },
        ),

        // A ValueListenableBuilder is added to show the banner conditionally.
        ValueListenableBuilder<bool>(
          valueListenable: bannerService.showInviteBannerNotifier,
          builder: (context, showBanner, child) {
            if (showBanner) {
              return FloatingInfoBanner(
                bannerType: BannerType.inviteCredits,
                onTap: () async {
                  await bannerService.generateAndShareInviteLink(context);
                },
                onDismissed: bannerService.startCooldown,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}