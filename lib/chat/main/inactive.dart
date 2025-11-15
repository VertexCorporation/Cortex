// lib/chat/main/inactive.dart
//
// This file defines the InactiveChatView widget. It is responsible for rendering the UI
// when no chat is active. This includes the model selection screen, displaying recent
// models, news, and handling model search and filtering logic. It owns the state
// and behavior specific to the model discovery and selection process.

import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/unselected/controller.dart';
import 'package:cortex/chat/services/recent.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../banner.dart';
import '../../error.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../library/backend/data/entity.dart';
import '../../library/providers/catalog.dart';
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
  final GlobalKey<SelectionControllerState> selectionControllerKey =
  GlobalKey<SelectionControllerState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      widget.onModelSelectionChanged?.call(false);
      context.read<BannerService>().checkAndTriggerBanner();

      final sessionProvider = context.read<ChatSessionProvider>();
      if (sessionProvider.appBarMode == AppBarMode.inSelection) {
        selectionControllerKey.currentState?.showExploreView();
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
    selectionControllerKey.currentState?.showWelcomeView();
  }

  /// Public method to programmatically switch to the "all models" grid.
  /// This is called by the parent MainScreen when restoring the view state after a chat exit.
  void showAllModelsView() {
    selectionControllerKey.currentState?.showExploreView();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // We watch ChatSessionProvider for the actual list of models (which it gets from ModelService).
    final sessionProvider = context.watch<ChatSessionProvider>();
    final catalogProvider = context.watch<ModelCatalogProvider>();

    final conversationProvider = context.watch<ConversationProvider>();
    final recentModelsManager = context.watch<RecentModelsManager>();
    final bannerService = context.watch<BannerService>();
    final userProvider = context.watch<UserProvider>();

    // The error view now gets its state from the catalog.
    if (catalogProvider.loadError) {
      return ErrorView(
        key: const ValueKey('chat_error'),
        title: localizations.errorLoadingTitle,
        message: localizations.errorLoadingMessage,
        buttonText: localizations.retry,
        onRetry: () => catalogProvider.retryLoad(),
      );
    }

    return Stack(
      children: [
        // --- This builder now listens for a List<ModelEntity> ---
        ValueListenableBuilder<List<ModelEntity>>(
          valueListenable: recentModelsManager.recentModelsNotifier,
          builder: (context, recentModelsValue, child) {
            final bool isLimitExceeded =
                sessionProvider.chatLimitManager?.isLimitExceeded(
                  conversationProvider.messages,
                ) ??
                    false;

            return SelectionController(
              key: selectionControllerKey, // The key is now attached here
              isLoading: catalogProvider.isLoading,
              allModels: sessionProvider.allModels,
              recentModels: recentModelsValue,
              conversationLimitReached: isLimitExceeded,
              searchController: searchController,
              onSelectModel: (model, ctx) {
                context.read<SelectionService>().selectModel(model, context: ctx);
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