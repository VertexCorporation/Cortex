// lib/chat/view.dart

import 'package:cortex/chat/screen/widgets/bottom/bottom.dart';
import 'package:cortex/chat/screen/widgets/bottom/input/panels/briefing.dart';
import 'package:cortex/chat/screen/widgets/list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// --- Internal Imports ---
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/edit.dart';
import 'package:cortex/chat/services/regenerate.dart';
import 'package:cortex/chat/services/scroll.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/credits.dart';
import '../../theme.dart';
import '../messages/skeleton.dart';
import 'default/view.dart';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  ChatViewState createState() => ChatViewState();
}

class ChatViewState extends State<ChatView>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // --- Core Controllers ---
  final ScrollController scrollController = ScrollController();
  final GlobalKey _bottomPanelKey = GlobalKey();

  // --- Animations ---
  late AnimationController editPanelController;
  late Animation<Offset> slideAnimation;

  // --- Services ---
  late final EditService editService;
  late final ScrollService _scrollService;
  late final OfflineService _offlineService;

  // --- UI Notifiers ---
  final ValueNotifier<bool> showScrollDownButtonNotifier = ValueNotifier<bool>(
      false);
  final ValueNotifier<double> bottomPanelHeightNotifier = ValueNotifier<double>(
      0.0);
  final ValueNotifier<double> briefingVisibleHeightNotifier = ValueNotifier<
      double>(0.0);

  // Constants
  static const double _briefingBottomOffset = 8.0;

  // --- Flags ---
  final bool _showInappropriateContentWarning = false;
  bool _showPhotoModelWarning = false;
  String? _lastActiveOfflineModelId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scrollService = context.read<ScrollService>();
    _offlineService = context.read<OfflineService>();
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();

    _scrollService.setController(scrollController);
    _scrollService.attachListener(
      notifier: showScrollDownButtonNotifier,
      messageCountProvider: () => conversationProvider.messages.length,
    );

    editPanelController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
        CurvedAnimation(parent: editPanelController, curve: Curves.easeOut));

    editService = EditService(
      inputProvider: context.read<InputProvider>(),
      conversationProvider: context.read<ConversationProvider>(),
      regenerateService: context.read<RegenerateService>(),
      scrollService: context.read<ScrollService>(),
      controller: TextEditingController(),
      focusNode: FocusNode(),
      panelController: editPanelController,
    );

    _handleModelChange(sessionProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _updateBottomPanelHeight();
        _scrollService.jumpToBottom();
      }
    });
  }

  void _handleModelChange(ChatSessionProvider session) {
    final modelService = context.read<ModelService>();
    final langCode = session
        .getLocale()
        .languageCode;
    final newModelId = session.modelId;
    final newModelPath = session.modelPath;

    if (_lastActiveOfflineModelId == newModelId) return;

    if (_lastActiveOfflineModelId != null &&
        _lastActiveOfflineModelId != newModelId) {
      _offlineService.releaseModel();
    }

    final isNewModelOffline = newModelId != null &&
        !Utils.isServerSideModel(
            newModelId, langCode: langCode, modelService: modelService);

    if (isNewModelOffline && newModelPath != null && newModelPath.isNotEmpty) {
      _offlineService.cacheModel(newModelPath);
      _lastActiveOfflineModelId = newModelId;
    } else {
      _lastActiveOfflineModelId = null;
    }
  }

  void _updateBottomPanelHeight() {
    final RenderBox? box = _bottomPanelKey.currentContext
        ?.findRenderObject() as RenderBox?;
    if (box != null) {
      final newHeight = box.size.height;
      if (bottomPanelHeightNotifier.value != newHeight) {
        bottomPanelHeightNotifier.value = newHeight;
      }
    }
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollService.updateButtonVisibility();
      _updateBottomPanelHeight();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    scrollController.dispose();
    editPanelController.dispose();
    _scrollService.detachListener();
    super.dispose();
  }

  void focusTextField() {}

  void cancelAnyActiveEdit() {
    if (mounted && context
        .read<InputProvider>()
        .isEditingMode) {
      editService.cancelEditingMode();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final bottomSafe = mediaQuery.padding.bottom;
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0.0;
    context.watch<ThemeProvider>();

    return Stack(
      children: [
        // LAYER 1: Main Content
        Column(
          children: [
            // Chat Body
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (Widget child,
                    Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: conversationProvider.isLoadingMessages
                    ? const MessageListSkeleton(key: ValueKey('skeleton'))
                    : conversationProvider.messages.isEmpty
                    ? Container(
                  key: const ValueKey('empty'),
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: screenHeight * 0.1),
                  child: const ChatEmptyState(),
                )
                    : ChatMessageList(
                  key: const ValueKey('list'),
                  scrollController: scrollController,
                  editService: editService,
                ),
              ),
            ),

            // Bottom Panel
            SafeArea(
              top: false,
              bottom: true,
              child: NotificationListener<SizeChangedLayoutNotification>(
                onNotification: (notification) {
                  WidgetsBinding.instance.addPostFrameCallback((_) =>
                      _updateBottomPanelHeight());
                  return true;
                },
                child: Container(
                  key: _bottomPanelKey,
                  child: ChatInputPanel(
                    editService: editService,
                    scrollService: _scrollService,
                    editPanelController: editPanelController,
                    slideAnimation: slideAnimation,
                  ),
                ),
              ),
            ),
          ],
        ),

        // LAYER 2: Briefing Overlay (Keep functionality)
        AnimatedBuilder(
          animation: bottomPanelHeightNotifier,
          builder: (context, _) {
            final basePanelHeight = bottomPanelHeightNotifier.value;
            const horizontalPadding = 16.0;
            final bool shouldBeVisible = sessionProvider.isChatActive;

            return Positioned(
              left: horizontalPadding,
              right: horizontalPadding,
              bottom: basePanelHeight + bottomSafe + _briefingBottomOffset,
              child: BriefingOverlay(
                isVisible: shouldBeVisible,
                availableCredits: context
                    .watch<CreditsManager>()
                    .totalCreditsNotifier
                    .value,
                photoSelected: context
                    .watch<InputProvider>()
                    .selectedPhoto != null,
                isOfflineModel: _isOfflineCurrentModel(context),
                modelMissing: _isModelMissing(context),
                limitReached: _isLimitExceeded(context),
                isStorageSufficient: context
                    .watch<ChatSessionProvider>()
                    .isStorageSufficient,
                showDisclaimer: context
                    .watch<ChatSessionProvider>()
                    .showDisclaimer,
                isPremiumModel: context
                    .watch<ChatSessionProvider>()
                    .isCurrentModelPremium,
                isSubscribed: context
                    .watch<ChatSessionProvider>()
                    .isUserSubscribed,
                premiumTrialUses: context
                    .watch<ChatSessionProvider>()
                    .premiumTrialUses,
                inappropriate: _showInappropriateContentWarning,
                showPhotoWarning: _showPhotoModelWarning,
                onDisclaimerDismissed: () {
                  if (mounted) {
                    context.read<ChatSessionProvider>().dismissDisclaimer();
                    setState(() => _showPhotoModelWarning = false);
                  }
                },
                onVisibleHeightChanged: (h) {
                  if (briefingVisibleHeightNotifier.value != h) {
                    briefingVisibleHeightNotifier.value = h;
                  }
                },
                isDynamicChat: sessionProvider.isDynamicChat,
              ),
            );
          },
        ),

        // LAYER 3: Scroll Down Button
        AnimatedBuilder(
          animation: Listenable.merge([
            showScrollDownButtonNotifier,
            bottomPanelHeightNotifier,
            briefingVisibleHeightNotifier,
          ]),
          builder: (context, child) {
            final bool showButton = showScrollDownButtonNotifier.value;
            final double basePanel = bottomPanelHeightNotifier.value;
            final double briefingH = briefingVisibleHeightNotifier.value;
            final double combinedPanelHeight = basePanel + briefingH +
                _briefingBottomOffset;

            return _scrollService.buildScrollDownButton(
              screenWidth: screenWidth,
              screenHeight: screenHeight,
              bottomPanelHeight: combinedPanelHeight,
              showScrollDownButton: showButton,
              safeAreaBottomPadding: bottomSafe,
              isKeyboardOpen: isKeyboardOpen,
              keyboardHeight: keyboardHeight,
            );
          },
        ),
      ],
    );
  }

  // Helpers
  bool _isLimitExceeded(BuildContext context) {
    return context
        .read<ChatSessionProvider>()
        .chatLimitManager
        ?.isLimitExceeded(
        context
            .read<ConversationProvider>()
            .messages) ?? false;
  }

  bool _isOfflineCurrentModel(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
    return !Utils.isServerSideModel(
      session.modelId,
      langCode: langCode,
      modelService: context.read<ModelService>(),
    );
  }

  bool _isModelMissing(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final isOffline = _isOfflineCurrentModel(context);
    final isDownloaded = context
        .read<ModelLocalStateProvider>()
        .downloadCompleted[session.modelId] ?? false;
    return !session.isDynamicChat && isOffline && !isDownloaded;
  }
}