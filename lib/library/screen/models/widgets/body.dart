// lib/library/screen/models/widgets/body.dart

import 'package:cortex/app.dart';
import 'package:cortex/library/screen/models/widgets/category.dart';
import 'package:cortex/library/screen/models/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../error.dart';
import '../../../../fog.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';
import '../../../backend/search.dart';
import '../../../backend/system.dart';
import '../../../backend/utils.dart';
import '../skeleton.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../theme.dart';

// Constants for animations and layout, ensuring consistency.
const _kDefaultFadeDuration = Duration(milliseconds: 300);
const _kSearchTransitionDuration = Duration(milliseconds: 260);
const _kWarningPanelAnimDuration = Duration(milliseconds: 400);
const _kHorizontalPaddingRatio = 0.04;
const _kWarningPanelVisibleBottom = 16.0;
const _kWarningPanelHiddenBottom = -150.0;

/// A type definition for the download callback to keep the code clean.
typedef DownloadCallback = Future<bool> Function({
required String id,
required String? url,
required String title,
});

/// The main body component for the ModelsScreen.
class ModelsBody extends StatelessWidget {
  // State flags passed from the parent widget.
  final bool isLoading;
  final bool hasError;
  final bool showLocalizationWarning;
  final List<ModelEntity> allModels;

  // Data and controllers from providers.
  final SystemInfoData? systemInfo;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final ModelsSearchController searchController;

  // Animation object for visual feedback.
  final Animation<double> pulseAnimation;

  // Callbacks to interact with providers and parent widgets.
  final VoidCallback onRetry;
  final VoidCallback onDismissWarningPanel;
  final CompatibilityStatus Function(int?) getCompatibilityStatus;
  final Future<void> Function(String, String) onRemovePressed;
  final Future<void> Function(String, bool, {bool isCustomModel, String? modelPath}) onChatPressed;
  final DownloadCallback onDownloadPressed;
  final void Function(String) onCancelDownload;
  final void Function(String) onResumeDownload;
  final void Function(String id) openModelDetail;
  final ScrollController scrollController;

  const ModelsBody({
    super.key,
    required this.isLoading,
    required this.hasError,
    required this.showLocalizationWarning,
    required this.allModels,
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
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // We use an AnimatedBuilder to listen for changes in the search text.
    // This ensures that ONLY the parts of the UI that depend on the search state
    // are rebuilt, not the entire ModelsBody.
    return AnimatedBuilder(
      animation: searchController.textController,
      builder: (context, child) {
        final isSearching = searchController.textController.text.isNotEmpty;

        return Stack(
          children: [
            // A GestureDetector to dismiss the keyboard when tapping outside the text field.
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusScope.of(context).unfocus(),
              // The top-level AnimatedSwitcher handles fading between loading/error/content states.
              child: AnimatedSwitcher(
                duration: _kDefaultFadeDuration,
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: _buildContentSwitcher(context, isSearching),
              ),
            ),
            // The localization warning panel is a positioned overlay.
            _buildLocalizationWarningPanel(context, localizations),
          ],
        );
      },
    );
  }

  /// Builds the animated warning panel at the bottom of the screen.
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

  /// Determines whether to show the skeleton, error view, or the main content.
  Widget _buildContentSwitcher(BuildContext context, bool isSearching) {
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
    return _buildContentView(context, isSearching);
  }

  /// Builds the primary view, containing the search bar and the switchable content area.
  Widget _buildContentView(BuildContext context, bool isSearching) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height; // For ScrollFog

    return ScrollFog(
      scrollController: scrollController,
      fogColor: AppColors.background,
      topFogHeight: screenHeight * 0.02,
      showTop: true,    // Enable only the top fog.
      showBottom: false, // Disable the bottom fog.
      child: SingleChildScrollView(
        key: const ValueKey('content'),
        controller: scrollController, // Link the controller here.
        clipBehavior: Clip.none,
        child: Column(
          children: [
            searchController.buildSearchBar(screenWidth),
            AnimatedSize(
              duration: _kSearchTransitionDuration,
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: _kSearchTransitionDuration,
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: isSearching
                    ? Container(
                  key: const ValueKey('search-view'),
                  child: searchController.buildSearchBody(screenWidth),
                )
                    : Container(
                  key: const ValueKey('default-view'),
                  child: _buildDefaultModelList(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the default view with categorized lists of models.
  Widget _buildDefaultModelList(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Filter models into categories. This logic runs only when the widget rebuilds.
    final self = allModels.where((model) => model.category == 'self').toList();
    final serverSide = allModels.where((model) => model.isServerSide && model.category != 'self' && model.category != 'roleplay').toList();
    final local = allModels.where((model) => !model.isServerSide && model.category != 'self').toList();
    final role = allModels.where((model) => model.category == 'roleplay').toList();

    // A helper callback to reduce boilerplate in ModelCategorySection.
    void openModelDetailCallback(ModelEntity model) {
      openModelDetail(model.id);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenHeight * 0.01),

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
            padding: EdgeInsets.symmetric(horizontal: screenWidth * _kHorizontalPaddingRatio)
                .copyWith(top: screenWidth * 0.015, bottom: screenWidth * 0.015),
            child: Text(loc.systemInfo,
                style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenWidth * _kHorizontalPaddingRatio),
            child: SystemInfoChart(
                totalStorage: systemInfo!.totalStorage,
                usedStorage: systemInfo!.totalStorage - systemInfo!.freeStorage,
                totalMemory: systemInfo!.deviceMemory,
                usedMemory: systemInfo!.usedMemory),
          ),
        ],
        SizedBox(height: screenWidth * _kHorizontalPaddingRatio),
      ],
    );
  }
}