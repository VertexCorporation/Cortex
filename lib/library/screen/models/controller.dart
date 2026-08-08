// lib/library/screen/models/controller.dart

import 'dart:async';
import 'package:cortex/library/screen/models/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../screen.dart';
import 'widgets/search.dart';
import '../../providers/catalog.dart';
import '../../providers/local.dart';
import '../../../theme.dart';
import 'widgets/body.dart';
import 'widgets/appbar.dart';
import '../../../server/user.dart';
import '../../../funds/funds.dart';
import '../../../navigation.dart';
import '../../../library/backend/data/entity.dart';
import '../../../library/backend/download/download.dart';
import '../../../library/backend/system.dart';
import 'package:flutter/services.dart';

const _kWarningPanelDelay = Duration(milliseconds: 700);

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen>
    with
        TickerProviderStateMixin,
        AutomaticKeepAliveClientMixin<LibraryScreen> {
  ModelCatalogProvider? _catalogProvider;
  ModelLocalStateProvider? _localStateProvider;

  ModelsSearchController? _searchCtrl;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  bool _showLocalizationWarning = false;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
    _searchFocusNode.addListener(_onSearchFocusChanged);
    _scrollController = ScrollController();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _initializeData();
      }
    });
  }

  void _initializeData() {
    _catalogProvider = context.read<ModelCatalogProvider>();
    _localStateProvider = context.read<ModelLocalStateProvider>();
    _localStateProvider!.initialize(context: context);

    _searchCtrl = ModelsSearchController(
      context: context,
      focusNode: _searchFocusNode,
      allModels: _catalogProvider!.allModels,
      downloadManagers: Map.from(_localStateProvider!.downloadManagers),
      downloadedFileStates: _localStateProvider!.downloadCompleted,
      getCompatibilityStatus: _localStateProvider!.getCompatibilityStatus,
      openModelDetail: (String id) => _navigateAndHandleFocus(
          () => _catalogProvider!.openModelDetail(context, id)),
      removeModel: (id) async {
        final modelToRemove =
            _catalogProvider!.allModels.firstWhere((m) => m.id == id);
        await _catalogProvider!.removeModel(context, modelToRemove);
        // FIX: Prevent keyboard from popping up after model removal
        FocusManager.instance.primaryFocus?.unfocus();
      },
      startChat: (id, _, {String? modelPath, isCustomModel = false}) =>
          _handleChatPress(id),
      startDownload: ({required id, required url, required title}) =>
          _localStateProvider!.requestPermissionAndStartDownload(
              context: context, id: id, url: url),
      cancelDownload: _localStateProvider!.cancelDownload,
      resumeDownload: _localStateProvider!.resumeDownload,
    );

    setState(() {
      _isInitialized = true;
    });

    _checkAndScheduleLocalizationWarning();
  }

  void triggerPulseAnimation() {
    debugPrint("[LibraryScreen] Pulse Animation Triggered Imperatively.");

    if (!mounted) return;

    _pulseController.stop();
    _pulseController.reset();
    _pulseController.repeat(reverse: true);

    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        _pulseController.stop();
        _pulseController.animateTo(0.0,
            duration: const Duration(milliseconds: 300));
      }
    });
  }

  Future<void> _checkAndScheduleLocalizationWarning() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      const String key = 'last_localization_warning_ts';
      final int? lastShownTs = prefs.getInt(key);
      final DateTime now = DateTime.now();
      bool shouldShow = false;
      if (lastShownTs == null) {
        shouldShow = true;
      } else {
        final DateTime lastShownDate =
            DateTime.fromMillisecondsSinceEpoch(lastShownTs);
        final Duration diff = now.difference(lastShownDate);
        if (diff.inDays >= 7) shouldShow = true;
      }
      if (shouldShow) {
        Future.delayed(_kWarningPanelDelay, () async {
          if (mounted) {
            setState(() => _showLocalizationWarning = true);
            await prefs.setInt(key, now.millisecondsSinceEpoch);
          }
        });
      }
    } catch (e) {
      debugPrint("Warning error: $e");
    }
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _showLocalizationWarning) {
      _dismissWarningPanel();
    }
  }

  Future<void> _navigateAndHandleFocus(
      Future<void> Function() pageBuilder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await pageBuilder();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManager.instance.primaryFocus?.unfocus();
      });
    }
  }

  void _dismissWarningPanel() {
    if (mounted && _showLocalizationWarning) {
      setState(() => _showLocalizationWarning = false);
    }
  }

  Future<void> _handleChatPress(String id) async {
    try {
      final model = _catalogProvider!.allModels.firstWhere((m) => m.id == id);
      final isOnlineOrRP = model.isServerSide || model.category == 'roleplay';
      if (model.isPremium || isOnlineOrRP) {
        final userProvider = context.read<UserProvider>();
        if (!userProvider.isSubscriptionActive) {
          HapticFeedback.lightImpact();
          navigateToScreen(const FundsScreen(),
              direction: const Offset(0.0, 1.0));
          return;
        }
      }

      if (model.variants != null && model.variants!.isNotEmpty) {
        if (model.type == 'offline') {
          final downloadStates =
              context.read<ModelLocalStateProvider>().downloadCompleted;
          String? downloadedId;
          for (final entry in model.variants!.entries) {
            if (downloadStates[entry.key] == true) {
              downloadedId = entry.key;
              break;
            }
          }
          if (downloadedId != null) {
            await _catalogProvider!.startChatWithModel(downloadedId);
            return;
          }
        }
        final variants = model.variants!.values.toList();
        await _catalogProvider!.startChatWithModel(variants.first['id']);
        return;
      }
    } catch (_) {}
    await _catalogProvider!.startChatWithModel(id);
  }

  void _handleOverscrollStart() {
    final mainScreen = context.findAncestorStateOfType<MainScreenState>();
    if (mainScreen != null) {
      mainScreen.toggleAxon();
    }
  }

  void _handleOverscrollEnd() {
    if (_catalogProvider != null) {
      _navigateAndHandleFocus(
          () => _catalogProvider!.openCreateScreen(context));
    }
  }

  @override
  void dispose() {
    _searchCtrl?.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChanged);
    _searchFocusNode.dispose();
    _scrollController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    if (!_isInitialized || _searchCtrl == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        // UPDATED: Ensure body extends behind AppBar for transparency
        extendBodyBehindAppBar: true,
        appBar: ModelsAppBar(
          title: localizations.modelsTitle,
          onOpenCreateScreen: () {},
          // UPDATED: Pass null scroll controller here or use a dummy if needed for loading state,
          // but usually null is fine for static title.
        ),
        body: const SkeletonScreen(),
      );
    }

    return Selector2<ModelCatalogProvider, ModelLocalStateProvider, _CatalogState>(
      selector: (_, catalog, local) => _CatalogState(
        isLoading: catalog.isLoading,
        hasError: catalog.loadError,
        models: catalog.allModels,
        downloadedStates: local.downloadCompleted,
        downloadManagers: local.downloadManagers, // Do not copy, pass reference
        downloadUpdateVersion: local.downloadUpdateVersion,
        systemInfo: local.systemInfo,
      ),
      builder: (context, state, _) {
        if (!state.isLoading) {
          _searchCtrl!.updateModels(state.models);
          _searchCtrl!.downloadManagers = state.downloadManagers;
          _searchCtrl!.downloadedFileStates = state.downloadedStates;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: ModelsAppBar(
            title: localizations.modelsTitle,
            scrollController: _scrollController,
            onOpenCreateScreen: () => _navigateAndHandleFocus(
                () => _catalogProvider!.openCreateScreen(context)),
          ),
          body: Builder(builder: (context) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            return AnimatedPadding(
              padding: EdgeInsets.only(bottom: bottomInset),
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              child: ModelsBody(
                scrollController: _scrollController,
                isLoading: state.isLoading,
                hasError: state.hasError,
                allModels: state.models,
                pulseAnimation: _pulseAnimation,
                onRetry: () => _catalogProvider!.refreshCatalog(),
                systemInfo: state.systemInfo,
                downloadedStates: state.downloadedStates,
                downloadManagers: state.downloadManagers,
                getCompatibilityStatus: _localStateProvider!.getCompatibilityStatus,
                searchController: _searchCtrl!,
                showLocalizationWarning: _showLocalizationWarning,
                onDismissWarningPanel: _dismissWarningPanel,
                onRemovePressed: (id, title) async {
                  final modelToRemove =
                      _catalogProvider!.allModels.firstWhere((m) => m.id == id);
                  await _catalogProvider!.removeModel(context, modelToRemove);
                  FocusManager.instance.primaryFocus?.unfocus();
                },
                onChatPressed: (id, _, {String? modelPath, isCustomModel = false}) =>
                    _handleChatPress(id),
                onDownloadPressed: ({required id, required url, required title}) =>
                    _localStateProvider!.requestPermissionAndStartDownload(
                        context: context, id: id, url: url),
                onCancelDownload: _localStateProvider!.cancelDownload,
                onResumeDownload: _localStateProvider!.resumeDownload,
                openModelDetail: (id) => _navigateAndHandleFocus(
                    () => _catalogProvider!.openModelDetail(context, id)),
                onTriggerAxon: _handleOverscrollStart,
                onTriggerCreateScreen: _handleOverscrollEnd,
              ),
            );
          }),
        );
      },
    );
  }
}

class _CatalogState {
  final bool isLoading;
  final bool hasError;
  final List<ModelEntity> models;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final int downloadUpdateVersion;
  final SystemInfoData? systemInfo;

  const _CatalogState({
    required this.isLoading,
    required this.hasError,
    required this.models,
    required this.downloadedStates,
    required this.downloadManagers,
    required this.downloadUpdateVersion,
    this.systemInfo,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _CatalogState &&
          isLoading == other.isLoading &&
          hasError == other.hasError &&
          models.length == other.models.length &&
          mapEquals(downloadedStates, other.downloadedStates) &&
          downloadUpdateVersion == other.downloadUpdateVersion;

  @override
  int get hashCode => Object.hash(
        isLoading,
        hasError,
        models.length,
        Object.hashAll(downloadedStates.keys),
        downloadUpdateVersion,
      );
}
