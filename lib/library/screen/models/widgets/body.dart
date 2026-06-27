// lib/library/screen/models/widgets/body.dart

import 'package:cortex/app.dart';
import 'package:cortex/library/screen/models/widgets/category.dart';
import 'package:cortex/library/screen/models/widgets/chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../../error.dart';
import '../../../../fog.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';
import 'search.dart';
import '../../../backend/system.dart';
import '../../../backend/utils.dart';
import '../skeleton.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../theme.dart';

// Constants for animations and layout
const _kDefaultFadeDuration = Duration(milliseconds: 300);
const _kSearchTransitionDuration = Duration(milliseconds: 260);
const _kWarningPanelAnimDuration = Duration(milliseconds: 400);
const _kWarningPanelVisibleBottom = 16.0;
const _kWarningPanelHiddenBottom = -150.0;

typedef DownloadCallback = Future<bool> Function({
  required String id,
  required String? url,
  required String title,
});

class ModelsBody extends StatelessWidget {
  final bool isLoading;
  final bool hasError;
  final bool showLocalizationWarning;
  final List<ModelEntity> allModels;

  final SystemInfoData? systemInfo;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final ModelsSearchController searchController;

  final Animation<double> pulseAnimation;

  final VoidCallback onRetry;
  final VoidCallback onDismissWarningPanel;
  final CompatibilityStatus Function(int?) getCompatibilityStatus;
  final Future<void> Function(String, String) onRemovePressed;
  final Future<void> Function(String, bool,
      {bool isCustomModel, String? modelPath}) onChatPressed;
  final DownloadCallback onDownloadPressed;
  final void Function(String) onCancelDownload;
  final void Function(String) onResumeDownload;
  final void Function(String id) openModelDetail;
  final ScrollController scrollController;
  final VoidCallback onTriggerAxon;
  final VoidCallback onTriggerCreateScreen;

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
    required this.onTriggerAxon,
    required this.onTriggerCreateScreen,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return AnimatedBuilder(
      animation: searchController.textController,
      builder: (context, child) {
        final isSearching = searchController.textController.text.isNotEmpty;

        return Stack(
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                HapticFeedback.lightImpact();
                FocusScope.of(context).unfocus();
              },
              child: AnimatedSwitcher(
                duration: _kDefaultFadeDuration,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _buildContentSwitcher(context, isSearching),
              ),
            ),
            _buildLocalizationWarningPanel(context, localizations),
          ],
        );
      },
    );
  }

  Widget _buildLocalizationWarningPanel(
      BuildContext context, AppLocalizations localizations) {
    final double bottomPosition = showLocalizationWarning
        ? _kWarningPanelVisibleBottom
        : _kWarningPanelHiddenBottom;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    // --- DYNAMIC WIDTH FOR TABLET ---
    // Tablet: 5% margin (90% width). Phone: 4% margin (92% width).
    final double horizontalMargin =
        isTablet ? screenWidth * 0.05 : screenWidth * 0.04;

    return AnimatedPositioned(
      duration: _kWarningPanelAnimDuration,
      curve: Curves.easeOutCubic,
      bottom: bottomPosition,
      left: horizontalMargin,
      right: horizontalMargin,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onDismissWarningPanel();
        },
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            // Taller padding on tablet for touch targets
            padding: EdgeInsets.symmetric(
                vertical: isTablet ? 16 : 12, horizontal: isTablet ? 20 : 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                  width: isTablet ? 28 : 24,
                  height: isTablet ? 28 : 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations.aiTranslationWarning,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: isTablet ? 16 : 14,
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

  Widget _buildContentView(BuildContext context, bool isSearching) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;
    final double safeTopPadding = topPadding;

    return ScrollFog(
      scrollController: scrollController,
      topFogHeight: screenHeight * 0.02,
      showTop: true,
      showBottom: false,
      child: SingleChildScrollView(
        key: const ValueKey('content'),
        controller: scrollController,
        clipBehavior: Clip.none,

        padding: EdgeInsets.only(
          top: safeTopPadding,
        ),
        // -------------------------

        child: Column(
          children: [
            // Search Bar handles its own internal responsiveness
            searchController.buildSearchBar(screenWidth),

            AnimatedSize(
              duration: _kSearchTransitionDuration,
              curve: Curves.easeInOut,
              child: AnimatedSwitcher(
                duration: _kSearchTransitionDuration,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: isSearching
                    ? Container(
                        key: const ValueKey('search-view'),
                        // Search Body also handles its own internal responsiveness
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

  Widget _buildDefaultModelList(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final bool isTablet = screenWidth >= 600;

    final self = allModels.where((model) => model.category == 'self').toList();
    final local = allModels
        .where((model) =>
            !model.isServerSide &&
            model.category != 'self' &&
            model.category != 'roleplay')
        .toList();
    final role =
        allModels.where((model) => model.category == 'roleplay').toList();
    final serverSide = allModels
        .where((model) =>
            model.isServerSide &&
            model.category != 'self' &&
            model.category != 'roleplay')
        .toList();

    void openModelDetailCallback(ModelEntity model) {
      openModelDetail(model.id);
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: isTablet ? 800 : double.infinity),
        child: Column(
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
              onOverscrollStart: onTriggerAxon,
              onOverscrollEnd: onTriggerCreateScreen,
            ),
            ModelCategorySection(
              title: loc.onlineModels,
              models: serverSide,
              subCategories: const ['categoryAll', 'categoryVideo', 'categoryPhoto'],
              downloadedStates: downloadedStates,
              downloadManagers: downloadManagers,
              getCompatibilityStatus: getCompatibilityStatus,
              onModelTapped: openModelDetailCallback,
              onRemovePressed: onRemovePressed,
              onChatPressed: onChatPressed,
              onDownloadPressed: onDownloadPressed,
              onCancelDownload: onCancelDownload,
              onResumeDownload: onResumeDownload,
              onOverscrollStart: onTriggerAxon,
              onOverscrollEnd: onTriggerCreateScreen,
            ),
            ModelCategorySection(
              title: loc.roleModels,
              models: role,
              subCategories: const ['categoryAll', 'categoryMasculine', 'categoryFeminine', 'categoryInanimate'],
              downloadedStates: downloadedStates,
              downloadManagers: downloadManagers,
              getCompatibilityStatus: getCompatibilityStatus,
              onModelTapped: openModelDetailCallback,
              onRemovePressed: onRemovePressed,
              onChatPressed: onChatPressed,
              onDownloadPressed: onDownloadPressed,
              onCancelDownload: onCancelDownload,
              onResumeDownload: onResumeDownload,
              onOverscrollStart: onTriggerAxon,
              onOverscrollEnd: onTriggerCreateScreen,
            ),
            ModelCategorySection(
              title: loc.myModels,
              models: self,
              subCategories: const ['categoryAll'],
              downloadedStates: downloadedStates,
              downloadManagers: downloadManagers,
              getCompatibilityStatus: getCompatibilityStatus,
              onModelTapped: openModelDetailCallback,
              onRemovePressed: onRemovePressed,
              onChatPressed: onChatPressed,
              onDownloadPressed: onDownloadPressed,
              onCancelDownload: onCancelDownload,
              onResumeDownload: onResumeDownload,
              onOverscrollStart: onTriggerAxon,
              onOverscrollEnd: onTriggerCreateScreen,
            ),
            if (systemInfo != null) ...[
              // --- SYSTEM INFO HEADER ---
              Padding(
                padding: EdgeInsets.symmetric(
                        horizontal:
                            isTablet ? screenWidth * 0.02 : screenWidth * 0.04)
                    .copyWith(
                        top: isTablet ? 24.0 : screenWidth * 0.02,
                        bottom: isTablet ? 16.0 : screenWidth * 0.01),
                child: Text(
                  loc.systemInfo,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: isTablet ? 36.0 : screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // --- SYSTEM INFO CHART ---
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? screenWidth * 0.1 : screenWidth * 0.04,
                ),
                child: SystemInfoChart(
                    totalStorage: systemInfo!.totalStorage,
                    usedStorage:
                        systemInfo!.totalStorage - systemInfo!.freeStorage,
                    totalMemory: systemInfo!.deviceMemory,
                    usedMemory: systemInfo!.usedMemory),
              ),
            ],
            SizedBox(height: isTablet ? 40.0 : screenWidth * 0.04),
          ],
        ),
      ),
    );
  }
}
