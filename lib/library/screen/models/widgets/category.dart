// library/screen/models/widgets/category.dart

import 'package:cortex/app.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';
import '../../../backend/utils.dart';
import 'cards.dart';

/// A widget that displays a self-contained, pageable section of models for a specific category.
/// This widget now operates on a type-safe list of [ModelEntity].
class ModelCategorySection extends StatelessWidget {
  final String title;
  final List<ModelEntity> models;
  final Animation<double>? pulseAnimation;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final CompatibilityStatus Function(int? modelSizeInMB) getCompatibilityStatus;

  // Callbacks
  final void Function(ModelEntity model) onModelTapped;
  final Future<void> Function(String id, String title) onRemovePressed;
  final Future<void> Function(String id, bool isServerSide, {bool isCustomModel, String? modelPath}) onChatPressed;
  final Future<void> Function({required String id, required String? url, required String title}) onDownloadPressed;
  final void Function(String id) onCancelDownload;
  final void Function(String id) onResumeDownload;

  const ModelCategorySection({
    super.key,
    required this.title,
    required this.models,
    this.pulseAnimation,
    required this.downloadedStates,
    required this.downloadManagers,
    required this.getCompatibilityStatus,
    required this.onModelTapped,
    required this.onRemovePressed,
    required this.onChatPressed,
    required this.onDownloadPressed,
    required this.onCancelDownload,
    required this.onResumeDownload,
  });

  double _calculateHeight(double screenWidth) {
    final modelMaps = models.map((e) => e.toMap()).toList();
    return ModelsBackendUtils.calculateCategoryHeight(modelMaps, screenWidth);
  }

  List<Widget> _buildModelColumns(BuildContext context, double screenWidth) {
    final List<Widget> columns = [];
    const int modelsPerColumn = 3;
    final int totalModels = models.length;
    final int totalColumns = (totalModels / modelsPerColumn).ceil();

    for (int i = 0; i < totalColumns; i++) {
      final int startIndex = i * modelsPerColumn;
      final int endIndex = (startIndex + modelsPerColumn > totalModels)
          ? totalModels
          : startIndex + modelsPerColumn;

      final List<ModelEntity> columnModels = models.sublist(startIndex, endIndex);

      columns.add(
        Padding(
          padding: EdgeInsets.only(right: screenWidth * 0.01, left: screenWidth * 0.01),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: columnModels.map((model) {

              final isDownloaded = downloadedStates[model.id] ?? false;
              final manager = model.isServerSide ? null : downloadManagers[model.id];

              final compatibilityStatus =
              isDownloaded ? CompatibilityStatus.compatible : getCompatibilityStatus(model.size);

              return ModelTile(
                model: model,
                isLastInColumn: model == columnModels.last,
                isSeeAll: false,
                manager: manager,
                isDownloaded: isDownloaded,
                compatibilityStatus: compatibilityStatus,
                onTileTap: () => onModelTapped(model),
                onRemoveRequested: () async {
                  HapticFeedback.mediumImpact();
                  await onRemovePressed(model.id, model.displayTitle);
                },
                onChatPressed: () => onChatPressed(model.id, model.isServerSide, isCustomModel: model.isCustomModel, modelPath: null),
                onDownloadPressed: () => onDownloadPressed(id: model.id, url: model.url, title: model.displayTitle),
                onCancelDownload: () => onCancelDownload(model.id),
                onResumeDownload: () => onResumeDownload(model.id),
              );
            }).toList(),
          ),
        ),
      );
    }
    return columns;
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.02, bottom: screenWidth * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }
    final double screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPaddingRatio = 0.04;
    final double cardWidth = screenWidth - (screenWidth * horizontalPaddingRatio * 2);
    final double pageViewWidth = cardWidth + (screenWidth * horizontalPaddingRatio);
    final double viewportFraction = pageViewWidth / screenWidth;


    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * horizontalPaddingRatio),
          child: _buildHeader(screenWidth),
        ),
        SizedBox(
          height: _calculateHeight(screenWidth),
          child: PageView(
            clipBehavior: Clip.none,
            controller: PageController(viewportFraction: viewportFraction),
            children: _buildModelColumns(context, screenWidth),
          ),
        ),
      ],
    );

    if (pulseAnimation != null) {
      return AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) {
          const double maxExpansionInPixels = 7.0;
          final double originalContentWidth = screenWidth - 2 * (screenWidth * 0.04);
          final double maxDesiredWidth = originalContentWidth + maxExpansionInPixels;
          final double targetWidth = (maxDesiredWidth < screenWidth) ? maxDesiredWidth : screenWidth;
          final double maxTargetScale = (originalContentWidth > 0) ? targetWidth / originalContentWidth : 1.0;
          final double animationProgress = (pulseAnimation!.value - 1.0) / 0.10;
          final double finalAppliedScale = 1.0 + (animationProgress * (maxTargetScale - 1.0));
          final double headerApproxHeight = screenWidth * 0.08;
          final double contentOriginalHeight = _calculateHeight(screenWidth) + headerApproxHeight;
          final double extraHeight = (contentOriginalHeight * finalAppliedScale) - contentOriginalHeight;
          final double bottomSpacerHeight = extraHeight / 2.0;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Transform.scale(
                scale: finalAppliedScale,
                child: child,
              ),
              SizedBox(height: bottomSpacerHeight > 0 ? bottomSpacerHeight : 0),
            ],
          );
        },
        child: content,
      );
    }
    return content;
  }
}