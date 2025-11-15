// lib/library/models/controller.dart

import 'dart:async';
import 'package:cortex/library/screen/models/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../l10n/app_localizations.dart';
import '../../backend/search.dart';
import '../../providers/catalog.dart';
import '../../providers/local.dart';
import '../../../theme.dart';
import 'widgets/body.dart';
import 'widgets/appbar.dart';

const _kWarningPanelDelay = Duration(milliseconds: 700);

/// The main UI widget for the Library Screen.
///
/// It consumes the globally-provided `ModelCatalogProvider` and `ModelLocalStateProvider`
/// to build its view. It is responsible for its own UI-specific state, such as
/// animations and focus nodes, but does not manage the provider lifecycle.
class LibraryScreen extends StatefulWidget {
  final bool showOfflineModelsPulse;
  const LibraryScreen({super.key, this.showOfflineModelsPulse = false});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<LibraryScreen> {
  // Providers are now read from context, not created here.
  ModelCatalogProvider? _catalogProvider;
  ModelLocalStateProvider? _localStateProvider;

  // UI-specific state and controllers are owned by this widget.
  ModelsSearchController? _searchCtrl;
  late final FocusNode _searchFocusNode;
  late final ScrollController _scrollController;
  late final AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _showLocalizationWarning = false;
  static bool _hasWarningBeenShownThisSession = false;
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

    // This is the correct lifecycle method for one-time setup.
    // Using addPostFrameCallback ensures that the context is fully available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isInitialized) {
        _catalogProvider = context.read<ModelCatalogProvider>();
        _localStateProvider = context.read<ModelLocalStateProvider>();
        _localStateProvider!.initialize(context: context);

        _searchCtrl = ModelsSearchController(
          context: context,
          focusNode: _searchFocusNode,
          // Initial data is passed here. Updates will be handled via watch/consumer.
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

        if (!_hasWarningBeenShownThisSession) {
          Future.delayed(_kWarningPanelDelay, () {
            if (mounted) {
              setState(() => _showLocalizationWarning = true);
              _hasWarningBeenShownThisSession = true;
            }
          });
        }
      }
    });
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
    _pulseController.dispose(); // Dispose the animation controller.
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

    // ModelCatalogProvider or ModelLocalStateProvider notifies its listeners.
    // The main LibraryScreen widget itself no longer rebuilds unnecessarily.
    return Consumer2<ModelCatalogProvider, ModelLocalStateProvider>(
      builder: (context, catalog, localState, child) {
        final bool showLoadingSkeleton = catalog.isLoading;

        // Update the search controller with the latest data from providers.
        // This is safe to do inside the builder.
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
            // Pass the function reference directly from the provider.
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