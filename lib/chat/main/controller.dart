// lib/chat/controller.dart

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
import 'package:cortex/chat/services/load.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/recent.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../banner.dart';
import '../../initialization.dart';
import '../../l10n/app_localizations.dart';
import '../../language.dart';
import '../../models/backend/data/data.dart';
import '../../navigation.dart';
import '../../settings/settings.dart';
import '../../theme.dart';
import '../screen/selected/dynamic.dart';
import '../screen/unselected/news.dart';
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
  ChatSessionProvider? _sessionProvider;
  OfflineService? _offlineService;
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
  // A session flag to prevent a dismissed dynamic chat from reappearing on tab re-selection.
  static bool hasShownDynamicChatThisSession = false;
  // Last initialized base id, so explanatory.
  String? _lastInitializedBaseId;
  bool _wasChatActive = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize UI helpers that are owned by this controller.
    extensions = Extensions(vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);

    // Perform one-time setup that depends on the context.
    if (!_isInitialSetupComplete) {
      debugPrint("[Controller] didChangeDependencies: Performing one-time initial setup.");
      _isInitialSetupComplete = true;
      _currentLocale = newLocale;

      // Safely get provider references here
      _sessionProvider = context.read<ChatSessionProvider>();
      _offlineService = context.read<OfflineService>();

      // Heavy lifting is done after the first frame is built.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _performInitialAsyncSetup();
        }
      });
      return;
    }

    // If the language changes, trigger a full data reload.
    if (_currentLocale != newLocale) {
      debugPrint("[Controller] Language change detected. Forcing data reload.");
      _currentLocale = newLocale;

      // The state-changing calls are wrapped in a post-frame callback.
      // This schedules the execution of this code to run immediately AFTER the current
      // build cycle is complete, thus avoiding the "setState() called during build" error.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // We add a `mounted` check as a safety measure, since this code runs asynchronously.
        if (mounted) {
          // These calls can now safely call `notifyListeners()` because the build is finished.
          inactiveChatViewKey.currentState?.reloadAllModelsForLanguageChange();
          context.read<NewsService>().forceRefresh(context);
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
    final sessionProvider = context.read<ChatSessionProvider>();
    final conversationProvider = context.read<ConversationProvider>();
    final inputProvider = context.read<InputProvider>();
    final recentModelsManager = context.read<RecentModelsManager>();

    if (sessionProvider.isDynamicChat) {
      hasShownDynamicChatThisSession = true;
      debugPrint("[Controller] Exiting dynamic chat. Session flag set.");
    }

    appbarKey.currentState?.closeAnyOpenPanels();

    activeChatViewKey.currentState?.cancelAnyActiveEdit();

    activeChatViewKey.currentState?.clearControllers();
    inactiveChatViewKey.currentState?.clearControllers();

    unawaited(recentModelsManager.refresh());

    sessionProvider.resetSessionState();
    conversationProvider.clearConversation();
    inputProvider.resetInputState();

    widget.onModelSelectionChanged?.call(false);
  }


  Future<void> _performInitialAsyncSetup() async {
    // Wait for core services like Firebase to be ready.
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    final langCode = Localizations.localeOf(context).languageCode;

    // Load models and initialize recent models manager concurrently.
    await Future.wait([
      context.read<LoadService>().loadModels(languageCode: langCode),
      context.read<RecentModelsManager>().initialize(),
    ]);
    if (!mounted) return;

    // If the app was opened with a specific conversation ID, load it.
    if (widget.conversationID != null) {
      final currentLanguageCode = context.read<LocaleProvider>().locale.languageCode;
      await context.read<ReadService>().loadConversationById(
        widget.conversationID!,
        languageCode: currentLanguageCode,
      );
      return;
    }
  }

  @override
  void dispose() {
    debugPrint("[Controller] Disposing state...");
    WidgetsBinding.instance.removeObserver(this);

    // Use the cached provider instances instead of context.read() ---
    // This is now safe because _sessionProvider and _offlineService were set
    // earlier in the widget's lifecycle.
    if (_sessionProvider?.isChatActive == true && Utils.isLocalModel(_sessionProvider?.modelId)) {
      debugPrint("[Controller] Disposing: Unloading local model ${_sessionProvider?.modelId}.");
      _offlineService?.unloadModel();
    }

    // Dispose of UI helpers owned by this controller.
    extensions.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final sessionProvider = context.read<ChatSessionProvider>();

    // When the app is backgrounded, unload any active local models to save resources.
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      if (sessionProvider.isChatActive && Utils.isLocalModel(sessionProvider.modelId)) {
        debugPrint("[Controller] AppLifecycle: $state. Unloading local model.");
        context.read<OfflineService>().unloadModel();
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

    if (isStandardChatActive) {
      final currentBaseId = ModelData.getBaseIdFromFullId(sessionProvider.modelId!);
      if (currentBaseId != _lastInitializedBaseId) {
        debugPrint("[Controller] Model series changed from '$_lastInitializedBaseId' to '$currentBaseId'. Initializing extensions.");
        _lastInitializedBaseId = currentBaseId;
        final seriesData = ModelData.getPreciseModelData(currentBaseId);
        extensions.initialize(
          mainId: currentBaseId,
          ext: sessionProvider.modelId!,
          modelData: seriesData,
        );
      }
    } else if (_lastInitializedBaseId != null) {
      debugPrint("[Controller] Chat exited. Resetting last initialized model ID.");
      _lastInitializedBaseId = null;
    }

    if (isChatNowActive && !_wasChatActive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (mounted && activeChatViewKey.currentState != null) {
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
                onAccountTap: () async {
                  final isChatCurrentlyActive = sessionProvider.isChatActive;
                  if (extensions.isPanelVisible) extensions.closePanel();
                  await Future.delayed(const Duration(milliseconds: 300));
                  if (!mounted) return;
                  FocusScope.of(context).unfocus();
                  navigateToScreen(context, SettingsScreen(isFromActiveChat: isChatCurrentlyActive), direction: const Offset(1.0, 0.0));
                },
                onShowExtensionInfoRequest: () async {
                  if (mounted) {
                    if (MediaQuery.of(context).viewInsets.bottom > 0) {
                      FocusScope.of(context).unfocus();
                      await Future.delayed(const Duration(milliseconds: 200));
                    }
                    if (!mounted) return;
                    setState(() => _showExtensionInfoBanner = true);
                  }
                },
                onTitleTap: () {
                  final mode = sessionProvider.appBarMode;
                  if (mode == AppBarMode.modelSelected) {
                    if (!extensions.isPanelVisible) {
                      extensions.showExtensionPanel(
                        context: context,
                        extensionKey: _extensionKey,
                        modelTitle: sessionProvider.modelTitle ?? "",
                        updateModelId: (selectedEntryKey) async {
                          await context.read<SelectionService>().changeExtension(selectedEntryKey);
                          if (mounted) extensions.closePanel();
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
                        ? ActiveChatView(key: activeChatViewKey, onModelSelectionChanged: widget.onModelSelectionChanged, extensions: extensions)
                        : InactiveChatView(key: inactiveChatViewKey, onModelSelectionChanged: widget.onModelSelectionChanged),
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
              bannerService.startCooldown();
            },
          ),
        ],
      ],
    );
  }
}