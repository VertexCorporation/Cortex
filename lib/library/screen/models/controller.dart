// lib/library/screen/models/controller.dart

import 'dart:async';
import 'package:cortex/library/screen/models/skeleton.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../l10n/app_localizations.dart';
import '../../../screen.dart';
import 'widgets/search.dart';
import '../../providers/catalog.dart';
import '../../providers/local.dart';
import '../../../theme.dart';
import 'package:cortex/app.dart';
import 'package:cortex/scaled_bottom_sheet.dart';
import 'widgets/body.dart';
import 'widgets/appbar.dart';
import '../../../server/user.dart';
import '../../../funds/funds.dart';
import '../../../navigation.dart';
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
      openModelDetail: (String id) =>
          _navigateAndHandleFocus(() =>
              _catalogProvider!.openModelDetail(context, id)),
      removeModel: (id) async {
        final modelToRemove = _catalogProvider!.allModels.firstWhere((m) =>
        m.id == id);
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
        _pulseController.animateTo(
            0.0, duration: const Duration(milliseconds: 300));
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
        final DateTime lastShownDate = DateTime.fromMillisecondsSinceEpoch(
            lastShownTs);
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
      if (model.isPremium) {
        final userProvider = context.read<UserProvider>();
        if (!userProvider.isSubscriptionActive) {
          HapticFeedback.lightImpact();
          navigateToScreen(const FundsScreen(), direction: const Offset(0.0, 1.0));
          return;
        }
      }

      if (model.variants != null && model.variants!.isNotEmpty) {
        final variants = model.variants!.values.toList();
        
        await showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (context) {
            final w = MediaQuery.of(context).size.width;
            return ScaledBottomSheet(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
                ),
                padding: EdgeInsets.symmetric(vertical: w * 0.06),
                child: SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: w * 0.1,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.tertiaryColor,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      SizedBox(height: w * 0.06),
                      Text(
                        model.displayTitle,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: w * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: w * 0.04),
                      Flexible(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height * 0.5,
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: variants.length,
                            separatorBuilder: (context, index) => Divider(
                              color: AppColors.secondaryColor,
                              height: 1,
                            ),
                            itemBuilder: (context, index) {
                              final variant = variants[index];
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: w * 0.06, vertical: 4),
                                title: Text(
                                  variant['title'] ?? variant['id'],
                                  style: TextStyle(
                                    color: AppColors.primaryColor.inverted,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  variant['id'],
                                  style: TextStyle(
                                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                                    fontSize: 12,
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.chevron_right_rounded,
                                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.3),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _catalogProvider!.startChatWithModel(variant['id']);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
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
      _navigateAndHandleFocus(() =>
          _catalogProvider!.openCreateScreen(context));
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
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: ModelsAppBar(
            title: localizations.modelsTitle,
            // UPDATED: Pass the controller so the title fades!
            scrollController: _scrollController,
            onOpenCreateScreen: () =>
                _navigateAndHandleFocus(() =>
                    catalog.openCreateScreen(context)),
          ),

          body: Builder(
            builder: (context) {
              final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
              return AnimatedPadding(
                padding: EdgeInsets.only(bottom: bottomInset),
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                child: ModelsBody(
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
                    final modelToRemove = catalog.allModels.firstWhere((m) =>
                    m.id == id);
                    await catalog.removeModel(context, modelToRemove);
                    // FIX: Prevent keyboard from popping up after model removal
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  onChatPressed: (id, _,
                      {String? modelPath, isCustomModel = false}) =>
                      _handleChatPress(id),
                  onDownloadPressed: ({required id, required url, required title}) =>
                      localState.requestPermissionAndStartDownload(
                          context: context, id: id, url: url),
                  onCancelDownload: localState.cancelDownload,
                  onResumeDownload: localState.resumeDownload,
                  openModelDetail: (id) =>
                      _navigateAndHandleFocus(() =>
                          catalog.openModelDetail(context, id)),
                  onTriggerAxon: _handleOverscrollStart,
                  onTriggerCreateScreen: _handleOverscrollEnd,
                ),
              );
            }
          ),
        );
      },
    );
  }
}