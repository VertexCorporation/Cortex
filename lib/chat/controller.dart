// lib/chat/main/controller.dart

import 'dart:async';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/appbar.dart';
import 'package:cortex/chat/screen/view.dart';
import 'package:cortex/chat/services/offline.dart';
import 'package:cortex/chat/services/read.dart';
import 'package:cortex/chat/services/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../initialization.dart';
import '../library/backend/data/service.dart';
import '../news/service.dart';
import '../theme.dart';

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

  final GlobalKey<ChatViewState> chatViewKey = GlobalKey<ChatViewState>();

  // --- Providers ---
  late final ChatSessionProvider _sessionProvider;
  late final OfflineService _offlineService;
  late final ModelService _modelService;

  // --- State ---
  Locale? _currentLocale;
  bool _isInitialSetupComplete = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

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
          context
              .read<NewsService>()
              .loadNewsForLanguage(newLocale.languageCode);
        }
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // --- FIX: Removed isChatActive check ---
    // We assume if modelId is not null, we might need to release resources.
    // Or we check if model is local directly.
    final langCode = _sessionProvider.getLocale().languageCode;
    final currentModelId = _sessionProvider.modelId;

    if (currentModelId != null &&
        Utils.isLocalModel(currentModelId,
            langCode: langCode, modelService: _modelService)) {
      _offlineService.releaseModel();
    }

    super.dispose();
  }

  /// Handles system back press events (called by MainScreen).
  bool handleSystemBackPress() {
    // 1. Cancel Message Editing Mode if active
    if (context.read<InputProvider>().isEditingMode) {
      chatViewKey.currentState?.cancelAnyActiveEdit();
      return false; // Handled
    }

    return true; // Not handled, bubble up (Exit app or Go back)
  }

  Future<void> _performInitialAsyncSetup(String langCode) async {
    await context.read<AppInitializer>().onCoreServicesReady;
    if (!mounted) return;

    final newsFuture =
        context.read<NewsService>().loadNewsForLanguage(langCode);
    await newsFuture;

    if (!mounted) return;

    if (widget.conversationID != null) {
      // Ensure input state (editing mode etc.) is reset when loading a chat
      // This keeps the Global Draft intact.
      context.read<InputProvider>().resetInputState();

      await context.read<ReadService>().loadConversationById(
            widget.conversationID!,
            languageCode: langCode,
          );
    } else {
      // Logic for new chat
      context.read<InputProvider>().resetInputState();
      await _sessionProvider.initializeDefaultSession();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,
      appBar: Appbar(key: appbarKey),
      body: ChatView(
        key: chatViewKey,
      ),
    );
  }
}
