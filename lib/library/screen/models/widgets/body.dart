// lib/screens/models/widgets/models_body.dart

import 'package:cortex/app.dart';
import 'package:cortex/library/screen/models/widgets/category.dart';
import 'package:cortex/library/screen/models/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../errorview.dart';
import '../../backend/data/data.dart';
import '../../backend/data/entity.dart';
import '../../backend/download/download.dart';
import '../../backend/search.dart';
import '../../backend/system.dart';
import '../../backend/utils.dart';
import '../skeleton.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../theme.dart';
import '../args.dart';

// Constants (kept from your code)
const _kDefaultFadeDuration = Duration(milliseconds: 300);
const _kSearchFadeDuration = Duration(milliseconds: 260);
const _kWarningPanelAnimDuration = Duration(milliseconds: 400);
const _kHorizontalPaddingRatio = 0.04;
const _kWarningPanelVisibleBottom = 16.0;
const _kWarningPanelHiddenBottom = -150.0;

typedef DownloadCallback = Future<bool> Function({
required String id,
required String? url,
required String title,
});

/// The main body component for the ModelsScreen.
class ModelsBody extends StatelessWidget {
  // State flags
  final bool isLoading;
  final bool hasError;
  final bool showLocalizationWarning;

  // --- REFACTORED: Data now uses ModelEntity ---
  final List<ModelEntity> allModels;

  final SystemInfoData? systemInfo;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final ModelsSearchController searchController;

  // Animation
  final Animation<double> pulseAnimation;

  // Callbacks
  final VoidCallback onRetry;
  final VoidCallback onDismissWarningPanel;
  final CompatibilityStatus Function(int?) getCompatibilityStatus;
  final Future<void> Function(String, String) onRemovePressed;
  final Future<void> Function(String, bool, {bool isCustomModel, String? modelPath}) onChatPressed;
  final DownloadCallback onDownloadPressed;
  final void Function(String) onCancelDownload;
  final void Function(String) onResumeDownload;
  final void Function(ModelDetailArgs args) openModelDetail;

  const ModelsBody({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.showLocalizationWarning,
    required this.allModels, // Expects List<ModelEntity>
    this.systemInfo,
    required this.downloadedStates,
    required this.downloadManagers,
    required this.searchController,
    required this.pulseAnimation,
    required this.onRetry,
    required this.onDismissWarningPanel,
    required this.getCompatibilityStatus,
    required this.onRemovePressed,
    required this.onChatPressed,
    required this.onDownloadPressed,
    required this.onCancelDownload,
    required this.onResumeDownload,
    required this.openModelDetail,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: AnimatedSwitcher(
            duration: _kDefaultFadeDuration,
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: _buildContentSwitcher(context),
          ),
        ),
        _buildLocalizationWarningPanel(context, localizations),
      ],
    );
  }

  Widget _buildLocalizationWarningPanel(BuildContext context, AppLocalizations localizations) {
    final double bottomPosition = showLocalizationWarning ? _kWarningPanelVisibleBottom : _kWarningPanelHiddenBottom;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: _kWarningPanelAnimDuration,
      curve: Curves.easeOutCubic,
      bottom: bottomPosition,
      left: screenWidth * _kHorizontalPaddingRatio,
      right: screenWidth * _kHorizontalPaddingRatio,
      child: GestureDetector(
        onTap: onDismissWarningPanel,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/warning.svg',
                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.aiTranslationWarning,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSwitcher(BuildContext context) {
    if (isLoading) {
      return const SkeletonScreen(key: ValueKey('skeleton'));
    }
    if (hasError) {
      final localizations = AppLocalizations.of(context)!;
      return ErrorView(
        key: const ValueKey('error'),
        title: localizations.errorLoadingTitle,
        message: localizations.errorLoadingMessage,
        buttonText: localizations.retry,
        onRetry: onRetry,
      );
    }
    return _buildContentView(context);
  }

  Widget _buildContentView(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSearchActive = searchController.textController.text.trim().isNotEmpty;

    return CustomScrollView(
      key: const ValueKey('content'),
      slivers: [
        SliverToBoxAdapter(child: searchController.buildSearchBar(screenWidth)),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: _kSearchFadeDuration,
            child: KeyedSubtree(
              key: ValueKey(isSearchActive ? 'search' : 'default'),
              child: isSearchActive
                  ? searchController.buildSearchBody(screenWidth)
                  : _buildDefaultModelList(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultModelList(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // --- REFACTORED: Filtering on List<ModelEntity> ---
    final self = allModels.where((model) => model.category == 'self').toList();
    final serverSide = allModels.where((model) => model.isServerSide && model.category != 'self').toList();
    final local = allModels.where((model) => !model.isServerSide && model.category != 'self').toList();
    final role = allModels.where((model) => model.category == 'roleplay' && model.category != 'self').toList();

    // --- REFACTORED: Callback now accepts a ModelEntity and is much cleaner ---
    void openModelDetailCallback(ModelEntity model) {
      final args = ModelDetailArgs(
        id: model.id,
        description: model.displayDescription,
        imagePath: ModelData.getModelImagePath(model),
        size: model.size,
        ram: model.ram,
        producer: model.producer,
        isServerSide: model.isServerSide,
        isDownloaded: downloadedStates[model.id] ?? false,
        isDownloading: downloadManagers[model.id]?.isDownloading ?? false,
        compatibilityStatus: getCompatibilityStatus(model.size),
        url: model.url,
        isFullyLocalized: model.isFullyLocalized,
        isCustomModel: model.isCustomModel,
        modelPath: null, // This should be handled by the ViewModel if needed.
      );

      openModelDetail(args);
    }

    return Padding(
      key: const ValueKey('defaultView'),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * _kHorizontalPaddingRatio)
          .copyWith(bottom: screenWidth * _kHorizontalPaddingRatio),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.01),
          // Pass the typed lists and the new typed callback to ModelCategorySection
          ModelCategorySection(
            title: loc.localModels,
            models: local,
            pulseAnimation: pulseAnimation,
            downloadedStates: downloadedStates,
            downloadManagers: downloadManagers,
            getCompatibilityStatus: getCompatibilityStatus,
            onModelTapped: openModelDetailCallback,
            onRemovePressed: onRemovePressed,
            onChatPressed: onChatPressed,
            onDownloadPressed: onDownloadPressed,
            onCancelDownload: onCancelDownload,
            onResumeDownload: onResumeDownload,
          ),
          ModelCategorySection(
            title: loc.serverSideModels,
            models: serverSide,
            downloadedStates: downloadedStates,
            downloadManagers: downloadManagers,
            getCompatibilityStatus: getCompatibilityStatus,
            onModelTapped: openModelDetailCallback,
            onRemovePressed: onRemovePressed,
            onChatPressed: onChatPressed,
            onDownloadPressed: onDownloadPressed,
            onCancelDownload: onCancelDownload,
            onResumeDownload: onResumeDownload,
          ),
          ModelCategorySection(
            title: loc.roleModels,
            models: role,
            downloadedStates: downloadedStates,
            downloadManagers: downloadManagers,
            getCompatibilityStatus: getCompatibilityStatus,
            onModelTapped: openModelDetailCallback,
            onRemovePressed: onRemovePressed,
            onChatPressed: onChatPressed,
            onDownloadPressed: onDownloadPressed,
            onCancelDownload: onCancelDownload,
            onResumeDownload: onResumeDownload,
          ),
          ModelCategorySection(
            title: loc.myModels,
            models: self,
            downloadedStates: downloadedStates,
            downloadManagers: downloadManagers,
            getCompatibilityStatus: getCompatibilityStatus,
            onModelTapped: openModelDetailCallback,
            onRemovePressed: onRemovePressed,
            onChatPressed: onChatPressed,
            onDownloadPressed: onDownloadPressed,
            onCancelDownload: onCancelDownload,
            onResumeDownload: onResumeDownload,
          ),
          if (systemInfo != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
              child: Text(loc.systemInfo,
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold)),
            ),
            SystemInfoChart(
                totalStorage: systemInfo!.totalStorage,
                usedStorage: systemInfo!.totalStorage - systemInfo!.freeStorage,
                totalMemory: systemInfo!.deviceMemory,
                usedMemory: systemInfo!.usedMemory),
          ],
        ],
      ),
    );
  }
}