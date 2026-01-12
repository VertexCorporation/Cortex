// lib/chat/main/controller.dart

import 'dart:async';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/appbar.dart';
import 'package:cortex/chat/screen/view.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:cortex/extensions.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../banner.dart';
import '../initialization.dart';
import '../l10n/app_localizations.dart';
import '../library/backend/data/service.dart';
import '../navigation.dart';
import '../settings/controller.dart';
import '../theme.dart';
import 'services/dynamic.dart';
import 'widgets/news/service.dart';

class ChatController extends StatefulWidget {
  final String? conversationID;

  const ChatController({
    super.key,
    this.conversationID,
  });

  @override
  ChatControllerState createState() => ChatControllerState();
}

class ChatControllerState extends State<ChatController>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // --- Keys ---
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<AppbarState> appbarKey = GlobalKey<AppbarState>();
  final GlobalKey _extensionKey = GlobalKey();
  final GlobalKey<ChatViewState> chatViewKey = GlobalKey<ChatViewState>();
  final GlobalKey _exitButtonKey = GlobalKey();
  final GlobalKey _accountButtonKey = GlobalKey();
  final GlobalKey<FloatingInfoBannerState> _extensionBannerKey = GlobalKey<FloatingInfoBannerState>();

  // --- Providers ---
  late final ChatSessionProvider _sessionProvider;
  late final OfflineService _offlineService;
  late final ModelService _modelService;

  // --- State ---
  late final Extensions extensions;
  bool _showExtensionInfoBanner = false;
  Locale? _currentLocale;
  bool _isInitialSetupComplete = false;
  String? _lastInitializedBaseId;

  // Extension Info Logic
  static bool hasShownExtensionInfoThisSession = false;
  bool _extensionInfoPrefsLoaded = false;
  int _extensionInfoTotalShows = 0;
  bool _autoShowExtensionInfoScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    extensions = Extensions(vsync: this);

    _sessionProvider = context.read<ChatSessionProvider>();
    _offlineService = context.read<OfflineService>();
    _modelService = context.read<ModelService>();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLocale = Localizations.localeOf(context);

    if (!_isInitialSetupComplete) {
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
      _currentLocale = newLocale;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<NewsService>().loadNewsForLanguage(newLocale.languageCode);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (_sessionProvider.isChatActive) {
      final langCode = _sessionProvider.getLocale().languageCode;
      if (Utils.isLocalModel(_sessionProvider.modelId, langCode: langCode, modelService: _modelService)) {
        _offlineService.releaseModel();
      }
    }
    extensions.dispose();
    super.dispose();
  }

  /// Handles system back press events (called by MainScreen).
  bool handleSystemBackPress() {
    // 1. Close AppBar Panels
    if (appbarKey.currentState?.isAPanelShowing() ?? false) {
      appbarKey.currentState?.closeAnyOpenPanels();
      return false; // Handled
    }

    // 2. Dismiss Full-Screen Extension Info Banner
    if (_showExtensionInfoBanner) {
      _extensionBannerKey.currentState?.dismiss();
      return false; // Handled
    }

    // 3. Cancel Message Editing Mode
    if (context.read<InputProvider>().isEditingMode) {
      chatViewKey.currentState?.cancelAnyActiveEdit();
      return false; // Handled
    }

    return true; // Not handled, bubble up
  }

  Future<void> _performInitialAsyncSetup(String langCode) async {
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    final newsFuture = context.read<NewsService>().loadNewsForLanguage(langCode);
    await newsFuture;

    if (!mounted) return;

    if (widget.conversationID != null) {
      await context.read<ReadService>().loadConversationById(
        widget.conversationID!,
        languageCode: langCode,
      );
    } else if (!_sessionProvider.isChatActive) {
      await _sessionProvider.startDynamicConversation();
    }
  }

  void _focusTextField() {
    chatViewKey.currentState?.focusTextField();
  }

  void _scheduleAutoShowExtensionInfoIfNeeded() {
    if (_autoShowExtensionInfoScheduled || _showExtensionInfoBanner || hasShownExtensionInfoThisSession) return;

    _autoShowExtensionInfoScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _autoShowExtensionInfoScheduled = false;
      _tryAutoShowExtensionInfoBanner();
    });
  }

  Future<void> _tryAutoShowExtensionInfoBanner() async {
    if (!_extensionInfoPrefsLoaded) {
      final prefs = await SharedPreferences.getInstance();
      _extensionInfoTotalShows = prefs.getInt('extensionInfoTotalShows') ?? 0;
      _extensionInfoPrefsLoaded = true;
    }

    if (_extensionInfoTotalShows >= 2 || hasShownExtensionInfoThisSession || _showExtensionInfoBanner) return;

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

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final localizations = AppLocalizations.of(context)!;
    final bannerService = context.read<BannerService>();
    final modelService = context.read<ModelService>();

    // --- Extension Logic ---
    if (sessionProvider.isModelSelected && sessionProvider.modelId != null) {
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

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Appbar(
                  key: appbarKey,
                  // We map modelTitle to appTitle just to be safe, but Appbar uses 'Cortex' usually.
                  // Or you can pass sessionProvider.modelTitle ?? localizations.appTitle if you want dynamic title.
                  appTitle: localizations.appTitle,
                  extensionKey: _extensionKey,

                  // Cleaned up unused callbacks
                  exitButtonKey: _exitButtonKey,
                  accountButtonKey: _accountButtonKey,

                  // Updated Callbacks
                  onExit: () async {
                    _scaffoldKey.currentState?.openDrawer();
                  },
                  onAccountTap: () {
                    navigateToScreen(
                      SettingsScreen(isFromActiveChat: true),
                      direction: const Offset(1.0, 0.0),
                    );
                    if (extensions.isPanelVisible) extensions.closePanel();
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
                  onCreditsInfoTapped: bannerService.triggerBannerManually,

                  // CRITICAL FIX: onTitleTap Logic
                  onTitleTap: () {
                    if (sessionProvider.isModelSelected) {
                      // Standard Model Extensions Logic
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
                    } else if (sessionProvider.isDynamicChat) {
                      // Dynamic Chat Logic -> Requires Anchor Context from Appbar State
                      final anchorCtx = appbarKey.currentState?.titleContext;

                      if (anchorCtx != null) {
                        context.read<DynamicChatService>().showDynamicAssistantPanel(
                          context: context,
                          anchorContext: anchorCtx,
                        );
                      }
                    }
                  },
                ),

                // Active Chat View
                Expanded(
                  child: ChatView(
                    key: chatViewKey,
                    extensions: extensions,
                  ),
                ),
              ],
            ),
          ),

          // Full Screen Banner Overlay
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
                  _focusTextField();
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}