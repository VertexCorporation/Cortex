// lib/chat/main/controller.dart

//
// This file defines the ChatController widget, which acts as the main orchestrator
// for the chat interface. It does not build the detailed UI itself but decides
// which view to display—either the active chat view or the model selection view—based
// on the application's state. It manages the top-level Scaffold, AppBar, and handles
// high-level lifecycle events and navigation logic.

import 'dart:async';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/appbar.dart';
import 'package:cortex/chat/screen/appbar/chat.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/recent.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../banner.dart';
import '../../initialization.dart';
import '../../l10n/app_localizations.dart';
import '../../library/backend/data/service.dart';
import '../../navigation.dart';
import '../../settings/controller.dart';
import '../../theme.dart';
import '../messages/options/manager.dart';
import '../screen/selected/dynamic.dart';
import '../screen/unselected/widgets/news/service.dart';
import 'active.dart';
import 'inactive.dart';

/// The ChatController widget is the main stateful widget for the chat screen,
/// acting as the primary controller.
class ChatController extends StatefulWidget {
  final String? conversationID;
  final void Function(bool isSelected)? onModelSelectionChanged;
  final Future<void> Function()? onExitRequest;

  const ChatController({
    super.key,
    this.conversationID,
    this.onModelSelectionChanged,
    this.onExitRequest,
  });

  @override
  ChatControllerState createState() => ChatControllerState();
}

/// The state for the ChatController. It manages high-level UI state and logic,
/// delegating the actual view building to child widgets (`ActiveChatView`, `InactiveChatView`).
class ChatControllerState extends State<ChatController>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // --- Keys for high-level components and child communication ---

  // Manages the state of the custom AppBar.
  final GlobalKey<AppbarState> appbarKey = GlobalKey<AppbarState>();
  // Used to anchor the extension panel to the AppBar title.
  final GlobalKey _extensionKey = GlobalKey();
  // Used to provide a stable key for the chat title widget within the AppBar.
  final GlobalKey<ChatTitleState> chatTitleKey = GlobalKey<ChatTitleState>();
  // Allows the controller to call methods on the InactiveChatView's state.
  final GlobalKey<InactiveChatViewState> inactiveChatViewKey =
  GlobalKey<InactiveChatViewState>();
  // Allows the controller to call methods on the ActiveChatView's state.
  final GlobalKey<ActiveChatViewState> activeChatViewKey =
  GlobalKey<ActiveChatViewState>();
  // Key for the exit/back button in the AppBar.
  final GlobalKey _exitButtonKey = GlobalKey();
  // Key for the user account avatar/button in the AppBar.
  final GlobalKey _accountButtonKey = GlobalKey();
  // Member variables to hold provider instances safely.
  late final ChatSessionProvider _sessionProvider;
  late final OfflineService _offlineService;
  late final ModelService _modelService;

  // --- UI and Animation State ---

  // Manages the UI helper for model extensions (e.g., different versions of a model).
  late final Extensions extensions;
  // Controls the visibility of the full-screen overlay for the extension info banner.
  bool _showExtensionInfoBanner = false;
  // Key to control the dismissal of the extension info banner.
  final GlobalKey<FloatingInfoBannerState> _extensionBannerKey =
  GlobalKey<FloatingInfoBannerState>();

  // --- Lifecycle and Initialization State ---

  // Tracks the current locale to detect language changes.
  Locale? _currentLocale;
  // Ensures one-time asynchronous setup runs only once.
  bool _isInitialSetupComplete = false;

  static bool hasShownDynamicChatThisSession = false;

  static bool hasShownExtensionInfoThisSession = false;

  String? _lastInitializedBaseId;
  bool _wasChatActive = false;

  bool _extensionInfoPrefsLoaded = false;
  int _extensionInfoTotalShows = 0;
  bool _autoShowExtensionInfoScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    extensions = Extensions(vsync: this);

    // --- Get all provider instances here, ONCE. ---
    _sessionProvider = context.read<ChatSessionProvider>();
    _offlineService = context.read<OfflineService>();
    _modelService = context.read<ModelService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);

    if (!_isInitialSetupComplete) {
      debugPrint("[Controller] didChangeDependencies: Performing one-time initial setup.");
      _isInitialSetupComplete = true;
      _currentLocale = newLocale;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performInitialAsyncSetup(newLocale.languageCode);
        }
      });
      return;
    }

    if (_currentLocale != newLocale) {
      debugPrint("[Controller] Language change detected for language: '${newLocale.languageCode}'.");
      _currentLocale = newLocale;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NewsService>().loadNewsForLanguage(newLocale.languageCode);
        }
      });
    }
  }

  /// Public method for parent widgets (e.g., MainScreen) to programmatically
  /// focus the chat input field. It delegates the call to the ActiveChatView.
  void focusTextField() {
    activeChatViewKey.currentState?.focusTextField();
  }

  /// Public method for external services to notify that a local model has loaded.
  /// This can be used to update UI elements in the ActiveChatView.
  void onOfflineModelLoaded() {
    debugPrint("[Controller] onOfflineModelLoaded triggered.");
    // This is a placeholder. If needed, it can delegate to ActiveChatView:
    // activeChatViewKey.currentState?.onOfflineModelLoaded();
  }

  /// Called by MainScreen when the chat tab is re-selected. It ensures a previously
  /// exited dynamic chat doesn't reappear, improving user experience.
  void onReactivated() {
    final sessionProvider = context.read<ChatSessionProvider>();
    debugPrint("[Controller] Reactivated. Dynamic chat session flag: $hasShownDynamicChatThisSession");

    if (hasShownDynamicChatThisSession && sessionProvider.isDynamicChat) {
      debugPrint("[Controller] Dynamic chat was shown this session. Forcing exit.");
      handleExit();
    }
  }


  /// Handles the logic for exiting any active chat. It orchestrates a full state
  /// reset across all relevant providers and notifies the parent widget.
  Future<void> handleExit() async {
    // --- Get all providers and langCode at the beginning ---
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();
    final inputProvider = context.read<InputProvider>();
    final recentModelsManager = context.read<RecentModelsManager>();
    // Get the langCode from the context, as it's available here.
    final langCode = Localizations.localeOf(context).languageCode;

    if (sessionProvider.isDynamicChat) {
      hasShownDynamicChatThisSession = true;
      debugPrint("[Controller] Exiting dynamic chat. Session flag set.");
    }

    dismissCurrentMessageOptions();
    appbarKey.currentState?.closeAnyOpenPanels();

    activeChatViewKey.currentState?.cancelAnyActiveEdit();

    activeChatViewKey.currentState?.clearControllers();
    inactiveChatViewKey.currentState?.clearControllers();

    unawaited(recentModelsManager.refresh(langCode: langCode));

    sessionProvider.resetSessionState();
    conversationProvider.clearConversation();
    inputProvider.resetInputState();

    widget.onModelSelectionChanged?.call(false);
  }

  void _scheduleAutoShowExtensionInfoIfNeeded() {
    if (_autoShowExtensionInfoScheduled ||
        _showExtensionInfoBanner ||
        hasShownExtensionInfoThisSession) {
      return;
    }

    _autoShowExtensionInfoScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoShowExtensionInfoScheduled = false;
      unawaited(_tryAutoShowExtensionInfoBanner());
    });
  }

  Future<void> _tryAutoShowExtensionInfoBanner() async {
    if (!_extensionInfoPrefsLoaded) {
      final prefs = await SharedPreferences.getInstance();
      _extensionInfoTotalShows = prefs.getInt('extensionInfoTotalShows') ?? 0;
      _extensionInfoPrefsLoaded = true;
    }

    if (_extensionInfoTotalShows >= 2) return;
    if (hasShownExtensionInfoThisSession) return;
    if (_showExtensionInfoBanner) return;

    hasShownExtensionInfoThisSession = true;

    if (!mounted) return;

    FocusScope.of(context).unfocus();
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    setState(() => _showExtensionInfoBanner = true);

    _extensionInfoTotalShows++;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('extensionInfoTotalShows', _extensionInfoTotalShows);
  }


  Future<void> _performInitialAsyncSetup(String langCode) async {
    // Wait for core services...
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    // We still need to load news and initialize recent models.
    final newsFuture = context.read<NewsService>().loadNewsForLanguage(langCode);
    final recentFuture = context.read<RecentModelsManager>().initialize(langCode: langCode);
    await Future.wait([newsFuture, recentFuture]);

    if (!mounted) return;

    // Conversation loading logic remains the same.
    if (widget.conversationID != null) {
      await context.read<ReadService>().loadConversationById(
        widget.conversationID!,
        languageCode: langCode,
      );
      return;
    }
  }

  @override
  void dispose() {
    debugPrint("[Controller] Disposing state...");
    WidgetsBinding.instance.removeObserver(this);

    // --- Use the securely stored provider instances ---
    if (_sessionProvider.isChatActive) {
      final langCode = _sessionProvider.getLocale().languageCode;

      if (Utils.isLocalModel(_sessionProvider.modelId, langCode: langCode, modelService: _modelService)) {
        debugPrint("[Controller] Disposing: Unloading local model ${_sessionProvider.modelId}.");

        _offlineService.releaseModel();
      }
    }

    extensions.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // For consistency and absolute safety, use the stored instances here as well.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final langCode = _sessionProvider.getLocale().languageCode;
      if (_sessionProvider.isChatActive && Utils.isLocalModel(_sessionProvider.modelId, langCode: langCode, modelService: _modelService)) {
        debugPrint("[Controller] AppLifecycle: $state. Unloading local model.");
        _offlineService.releaseModel();
      }
    }
  }

  /// Handles system back press events. It prioritizes closing UI panels
  /// before allowing the default back navigation to occur.
  bool handleSystemBackPress() {
    // If the AppBar has an open panel (e.g., extensions), close it first.
    if (appbarKey.currentState?.isAPanelShowing() ?? false) {
      appbarKey.currentState?.closeAnyOpenPanels();
      return false; // Event handled.
    }

    // If the full-screen extension info banner is showing, dismiss it.
    if (_showExtensionInfoBanner) {
      _extensionBannerKey.currentState?.dismiss();
      return false; // Event handled.
    }

    return true; // No panels open, allow default behavior.
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final localizations = AppLocalizations.of(context)!;
    final bannerService = context.read<BannerService>();
    final bool isStandardChatActive = sessionProvider.isModelSelected && sessionProvider.modelId != null;
    final bool isChatNowActive = sessionProvider.isChatActive;
    final modelService = context.read<ModelService>();

    if (isStandardChatActive) {
      final langCode = Localizations.localeOf(context).languageCode;

      final currentBaseId = modelService.getBaseIdFromFullId(
        sessionProvider.modelId!,
        langCode: langCode,
      );

      if (currentBaseId != _lastInitializedBaseId) {
        _lastInitializedBaseId = currentBaseId;
        final seriesEntity = modelService.getPreciseModelData(
          currentBaseId,
          langCode: langCode,
        );

        extensions.initialize(
          mainId: currentBaseId,
          ext: sessionProvider.modelId!,
          model: seriesEntity,
        );

        if ((seriesEntity.extensions ?? {}).isNotEmpty) {
          _scheduleAutoShowExtensionInfoIfNeeded();
        }
      }
    } else if (_lastInitializedBaseId != null) {
      _lastInitializedBaseId = null;
    }

    if (isChatNowActive && !_wasChatActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (!mounted) return;

          if (_showExtensionInfoBanner || _autoShowExtensionInfoScheduled) {
            return;
          }

          if (activeChatViewKey.currentState != null) {
            activeChatViewKey.currentState?.focusTextField();
          }
        });
      });
    }

    _wasChatActive = isChatNowActive;

    return Stack(
      children: [
        // LAYER 1: Main Content.
        SafeArea(
          bottom: false,
          child: Column(
            children: [
              Appbar(
                key: appbarKey,
                modelTitle: sessionProvider.modelTitle,
                modelImagePath: sessionProvider.modelImagePath,
                extensionKey: _extensionKey,
                onExit: () async {
                  if (sessionProvider.isChatActive) {
                    await widget.onExitRequest?.call();
                  } else if (sessionProvider.appBarMode == AppBarMode.inSelection) {
                    inactiveChatViewKey.currentState?.showSelectionView();
                  }
                },
                onAccountTap: () {
                  navigateToScreen(
                    SettingsScreen(isFromActiveChat: _sessionProvider.isChatActive),
                    direction: const Offset(1.0, 0.0),
                  );

                  if (extensions.isPanelVisible) {
                    extensions.closePanel();
                  }
                  FocusScope.of(context).unfocus();
                },
                onShowExtensionInfoRequest: () async {
                  if (mounted) {
                    if (MediaQuery.of(context).viewInsets.bottom > 0) {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 200));
                    }
                    if (!mounted) return;
                    setState(() => _showExtensionInfoBanner = true);
                    hasShownExtensionInfoThisSession = true;
                  }
                },
                onTitleTap: () {
                  final mode = sessionProvider.appBarMode;
                  if (mode == AppBarMode.modelSelected) {
                    if (!extensions.isPanelVisible) {
                      FocusScope.of(context).unfocus();

                      extensions.showExtensionPanel(
                        context: context,
                        extensionKey: _extensionKey,
                        modelTitle: sessionProvider.modelTitle ?? "",
                        updateModelId: (selectedEntryKey) async {
                          await context.read<SelectionService>().changeExtension(selectedEntryKey);
                        },
                        modelService: modelService,

                        onPanelClosed: () {
                          if (mounted) setState(() {});
                        },
                      );
                    } else {
                      extensions.closePanel();
                    }
                  } else if (mode == AppBarMode.dynamicChat) {
                    context.read<DynamicChatService>().showDynamicAssistantPanel(context: context, chatTitleKey: chatTitleKey);
                  }
                },
                appTitle: localizations.appTitle,
                extensions: extensions,
                onCreditsInfoTapped: bannerService.triggerBannerManually,
                chatTitleKey: chatTitleKey,
                exitButtonKey: _exitButtonKey,
                accountButtonKey: _accountButtonKey,
              ),
              // 2. Messages or Model Selection.
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: sessionProvider.isChatActive ? AppColors.background : null,
                    gradient: !sessionProvider.isChatActive
                        ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColors.background, AppColors.background.withValues(alpha: 0.0)],
                      stops: const [0.18, 0.28],
                    )
                        : null,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: sessionProvider.isChatActive
                        ? SizedBox(
                      key: const ValueKey('active_chat_view'),
                      child: ActiveChatView(
                          key: activeChatViewKey,
                          onModelSelectionChanged: widget.onModelSelectionChanged,
                          extensions: extensions),
                    )
                        : SizedBox(
                      key: const ValueKey('inactive_chat_view'),
                      child: InactiveChatView(
                          key: inactiveChatViewKey,
                          onModelSelectionChanged: widget.onModelSelectionChanged),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // LAYER 2: Overlay banner.
        if (_showExtensionInfoBanner) ...[
          GestureDetector(
            onTap: () => _extensionBannerKey.currentState?.dismiss(),
            child: Container(color: Colors.black.withValues(alpha: 0.6)),
          ),
          FloatingInfoBanner(
            key: _extensionBannerKey,
            bannerType: BannerType.extensionInfo,
            anchorKey: _extensionKey,
            onDismissed: () {
              if (mounted) {
                setState(() => _showExtensionInfoBanner = false);
                focusTextField();
              }
            },
          ),
        ],
      ],
    );
  }
}