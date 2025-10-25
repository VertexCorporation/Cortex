// lib/screens/library/library.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../../backend/search.dart';
import '../../providers/main.dart';
import 'body.dart';
import 'widgets/appbar.dart';

const _kWarningPanelDelay = Duration(milliseconds: 700);

class LibraryScreen extends StatelessWidget {
  final bool showOfflineModelsPulse;

  const LibraryScreen({super.key, this.showOfflineModelsPulse = false});

  @override
  Widget build(BuildContext context) {
    return _LibraryScreenWithTicker(
      showOfflineModelsPulse: showOfflineModelsPulse,
    );
  }
}

class _LibraryScreenWithTicker extends StatefulWidget {
  final bool showOfflineModelsPulse;
  const _LibraryScreenWithTicker({required this.showOfflineModelsPulse});

  @override
  State<_LibraryScreenWithTicker> createState() => __LibraryScreenWithTickerState();
}

class __LibraryScreenWithTickerState extends State<_LibraryScreenWithTicker> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ModelsViewModel(this),
      child: LibraryScreenView(
        showOfflineModelsPulse: widget.showOfflineModelsPulse,
      ),
    );
  }
}

class LibraryScreenView extends StatefulWidget {
  final bool showOfflineModelsPulse;
  const LibraryScreenView({super.key, required this.showOfflineModelsPulse});

  @override
  State<LibraryScreenView> createState() => _LibraryScreenViewState();
}

class _LibraryScreenViewState extends State<LibraryScreenView>
    with AutomaticKeepAliveClientMixin<LibraryScreenView> {

  late final ModelsViewModel _viewModel;
  late final ModelsSearchController _searchCtrl;
  bool _showLocalizationWarning = false;
  static bool _hasWarningBeenShownThisSession = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<ModelsViewModel>(context, listen: false);
    _viewModel.initialize(context, showOfflineModelsPulse: widget.showOfflineModelsPulse);

    // --- REFACTORED: All callbacks now correctly handle ModelEntity from the ViewModel ---
    _searchCtrl = ModelsSearchController(
      context: context,
      allModels: _viewModel.allModels, // This is now List<ModelEntity>
      downloadManagers: _viewModel.downloadManagers,
      getCompatibilityStatus: _viewModel.getCompatibilityStatus,
      openModelDetail: (args) => _viewModel.openModelDetail(context, args.id),
      removeModel: (id) async {
        try {
          // REFACTORED: Use safe property access on the ModelEntity list.
          final model = _viewModel.allModels.firstWhere((m) => m.id == id);
          await _viewModel.handleRemoveFromList(context, id, model.displayTitle);
        } catch (e) {
          // Fallback if the model is not found in the list for some reason.
          await _viewModel.handleRemoveFromList(context, id, id);
        }
      },
      startChat: (id, isServerSide, {bool isCustomModel = false, String? modelPath}) =>
          _viewModel.startChatWithModel(context, id),
      startDownload: ({required id, required url, required title}) =>
          _viewModel.requestPermissionAndStartDownload(context: context, id: id, url: url, title: title),
      cancelDownload: _viewModel.cancelDownload,
      resumeDownload: _viewModel.resumeDownload,
      downloadedFileStates: _viewModel.downloadCompleted,
    );

    if (!_hasWarningBeenShownThisSession) {
      Future.delayed(_kWarningPanelDelay, () {
        if (mounted) {
          setState(() => _showLocalizationWarning = true);
          _hasWarningBeenShownThisSession = true;
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel.onLanguageChanged(context);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _dismissWarningPanel() {
    if (mounted && _showLocalizationWarning) {
      setState(() { _showLocalizationWarning = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final localizations = AppLocalizations.of(context)!;

    return Consumer<ModelsViewModel>(
      builder: (context, viewModel, child) {
        // --- This now correctly passes List<ModelEntity> to the controller ---
        _searchCtrl.updateModels(viewModel.allModels);
        _searchCtrl.downloadedFileStates = viewModel.downloadCompleted;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: ModelsAppBar(
            title: localizations.modelsTitle,
            createButtonText: localizations.create,
            onOpenCreateScreen: () => viewModel.openCreateScreen(context),
          ),
          body: ModelsBody(
            isLoading: viewModel.isLoading,
            hasError: viewModel.loadError,
            showLocalizationWarning: _showLocalizationWarning,
            // --- This now correctly passes List<ModelEntity> to the body ---
            allModels: viewModel.allModels,
            systemInfo: viewModel.systemInfo,
            downloadedStates: viewModel.downloadCompleted,
            downloadManagers: viewModel.downloadManagers,
            searchController: _searchCtrl,
            pulseAnimation: viewModel.pulseAnimation,
            onRetry: () => viewModel.retryLoad(context),
            onDismissWarningPanel: _dismissWarningPanel,
            getCompatibilityStatus: viewModel.getCompatibilityStatus,
            onRemovePressed: (id, title) => viewModel.handleRemoveFromList(context, id, title),
            onChatPressed: (id, isServerSide, {bool isCustomModel = false, String? modelPath}) =>
                viewModel.startChatWithModel(context, id),
            onDownloadPressed: ({required id, required url, required title}) =>
                viewModel.requestPermissionAndStartDownload(context: context, id: id, url: url, title: title),
            onCancelDownload: viewModel.cancelDownload,
            onResumeDownload: viewModel.resumeDownload,
            openModelDetail: (args) => viewModel.openModelDetail(context, args.id),
          ),
        );
      },
    );
  }
}