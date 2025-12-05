// lib/library/models/controller.dart

import 'dart:async';
import 'package:cortex/library/screen/models/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import 'widgets/search.dart';
import '../../providers/catalog.dart';
import '../../providers/local.dart';
import '../../../theme.dart';
import 'widgets/body.dart';
import 'widgets/appbar.dart';

const _kWarningPanelDelay = Duration(milliseconds: 700);

class LibraryScreen extends StatefulWidget {
  final bool showOfflineModelsPulse;
  const LibraryScreen({super.key, this.showOfflineModelsPulse = false});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<LibraryScreen> {

  ModelCatalogProvider? _catalogProvider;
  ModelLocalStateProvider? _localStateProvider;

  ModelsSearchController? _searchCtrl;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

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
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation =
        Tween<double>(begin: 1.0, end: 1.0).animate(_pulseController);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
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
          openModelDetail: (String id) =>
              _navigateAndHandleFocus(() =>
                  _catalogProvider!.openModelDetail(context, id)),
          removeModel: (id) async {
            final modelToRemove = _catalogProvider!.allModels.firstWhere((m) => m.id == id);
            await _catalogProvider!.removeModel(context, modelToRemove);
          },
          startChat: (id, _, {String? modelPath, isCustomModel = false}) =>
              _catalogProvider!.startChatWithModel(id),
          startDownload: ({required id, required url, required title}) =>
              _localStateProvider!.requestPermissionAndStartDownload(
                  context: context, id: id, url: url),
          cancelDownload: _localStateProvider!.cancelDownload,
          resumeDownload: _localStateProvider!.resumeDownload,
        );

        setState(() {
          _isInitialized = true;
        });

        if (widget.showOfflineModelsPulse) {
          _startPulseAnimation();
        }

        _checkAndScheduleLocalizationWarning();
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
        final DateTime lastShownDate = DateTime.fromMillisecondsSinceEpoch(lastShownTs);
        final Duration diff = now.difference(lastShownDate);
        if (diff.inDays >= 7) {
          shouldShow = true;
        }
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
      debugPrint("Warning scheduling error: $e");
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void _startPulseAnimation() {
    _pulseController.reset();
    _pulseAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.10), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.10, end: 1.0), weight: 50),
    ]).animate(
        CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.repeat();
    Timer(const Duration(seconds: 3), () {
      if(mounted) {
        _pulseController.stop();
        _pulseController.animateTo(0.0,
            duration: const Duration(milliseconds: 400), curve: Curves.easeOut);
      }
    });
  }

  void _onSearchFocusChanged() {
    if (_searchFocusNode.hasFocus && _showLocalizationWarning) {
      _dismissWarningPanel();
    }
  }

  Future<void> _navigateAndHandleFocus(Future<void> Function() pageBuilder) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await pageBuilder();
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusManager.instance.primaryFocus?.unfocus();
      });
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

  void _dismissWarningPanel() {
    if (mounted && _showLocalizationWarning) {
      setState(() {
        _showLocalizationWarning = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    if (!_isInitialized || _searchCtrl == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: ModelsAppBar(
          title: localizations.modelsTitle,
          createButtonText: localizations.create,
          onOpenCreateScreen: () {},
        ),
        body: const SkeletonScreen(),
      );
    }

    return Consumer2<ModelCatalogProvider, ModelLocalStateProvider>(
      builder: (context, catalog, localState, child) {
        final bool showLoadingSkeleton = catalog.isLoading;

        if (!showLoadingSkeleton) {
          _searchCtrl!.updateModels(catalog.allModels);
          _searchCtrl!.downloadManagers = Map.from(localState.downloadManagers);
          _searchCtrl!.downloadedFileStates = localState.downloadCompleted;
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ModelsAppBar(
            title: localizations.modelsTitle,
            createButtonText: localizations.create,
            onOpenCreateScreen: () => _navigateAndHandleFocus(() => catalog.openCreateScreen(context)),
          ),
          body: ModelsBody(
            scrollController: _scrollController,
            isLoading: showLoadingSkeleton,
            hasError: catalog.loadError,
            allModels: catalog.allModels,
            pulseAnimation: _pulseAnimation,
            onRetry: () => catalog.refreshCatalog(),
            systemInfo: localState.systemInfo,
            downloadedStates: localState.downloadCompleted,
            downloadManagers: Map.from(localState.downloadManagers),
            getCompatibilityStatus: localState.getCompatibilityStatus,
            searchController: _searchCtrl!,
            showLocalizationWarning: _showLocalizationWarning,
            onDismissWarningPanel: _dismissWarningPanel,
            onRemovePressed: (id, title) async {
              final modelToRemove = catalog.allModels.firstWhere((m) => m.id == id);
              await catalog.removeModel(context, modelToRemove);
            },
            onChatPressed: (id, _, {String? modelPath, isCustomModel = false}) =>
                catalog.startChatWithModel(id),
            onDownloadPressed: ({required id, required url, required title}) =>
                localState.requestPermissionAndStartDownload(context: context, id: id, url: url),
            onCancelDownload: localState.cancelDownload,
            onResumeDownload: localState.resumeDownload,
            openModelDetail: (id) => _navigateAndHandleFocus(() => catalog.openModelDetail(context, id)),
          ),
        );
      },
    );
  }
}