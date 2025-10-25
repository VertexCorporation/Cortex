// file: lib/widgets/model_category_section.dart

import 'package:cortex/app.dart';
import 'package:cortex/models/backend/data/data.dart';
import 'package:cortex/models/backend/download.dart';
import 'package:cortex/models/backend/utils.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../backend/data/info.dart';
import 'cards.dart';

/// A widget that displays a self-contained, pageable section of models for a specific category.
///
/// This widget encapsulates the header, the horizontal PageView of model columns,
/// and the optional pulsing animation for featured sections. It delegates all user
/// interactions upwards via callback functions.
class ModelCategorySection extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> models;
  final Animation<double>? pulseAnimation;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final CompatibilityStatus Function(int? modelSizeInMB) getCompatibilityStatus;

  // Callbacks for user interactions
  final void Function(Map<String, dynamic> modelData) onModelTapped;
  final Future<void> Function(String id, String title) onRemovePressed;
  final Future<void> Function(String id, bool isServerSide, {bool isCustomModel, String? modelPath}) onChatPressed; // <-- DÜZELTİLDİ
  final Future<void> Function({required String id, required String? url, required String title}) onDownloadPressed; // <-- DÜZELTİLDİ
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

  /// Calculates the required height for the PageView based on the number of models
  /// and the screen width. This logic is derived from the original `_calculateCategoryHeight`.
  double _calculateHeight(double screenWidth) {
    return Utils.calculateCategoryHeight(models, screenWidth);
  }

  /// Builds the list of columns for the PageView. Each column contains up to 3 models.
  /// This logic is derived from the original `_buildModelColumns`.
  List<Widget> _buildModelColumns(BuildContext context, double screenWidth) {
    final List<Widget> columns = [];
    const int modelsPerColumn = 3;
    final int totalModels = models.length;
    final int totalColumns = (totalModels / modelsPerColumn).ceil();
    final double cardWidth = screenWidth - 2 * (screenWidth * 0.04);
    final String langCode = Localizations.localeOf(context).languageCode;

    for (int i = 0; i < totalColumns; i++) {
      final int startIndex = i * modelsPerColumn;
      final int endIndex = (startIndex + modelsPerColumn > totalModels)
          ? totalModels
          : startIndex + modelsPerColumn;
      final List<Map<String, dynamic>> columnModels = models.sublist(startIndex, endIndex);

      columns.add(
        SizedBox(
          width: cardWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: columnModels.map((model) {
              final String id = model['id'] as String;
              final String producer = model['producer'] as String;
              final String imagePath = ModelData.getModelImagePath(model);
              final bool isServerSide = model['type'] != 'offline';
              final String? modelPath = model['path'] as String?;
              final String? url = model['url'] as String?;
              final int? size = model['size'] as int?;
              final int? ram = model['ram'] as int?;
              final bool isCustomModel = id.startsWith('self_') || id.startsWith('local_');

              final String title = ModelData.getLocalizedText(model, 'title', langCode);
              final String summary = ModelData.getLocalizedText(model, 'summary', langCode);

              final bool isDownloaded = downloadedStates[id] ?? false;
              final DownloadManager? manager = isServerSide ? null : downloadManagers[id];

              final CompatibilityStatus compatibilityStatus =
              isDownloaded ? CompatibilityStatus.compatible : getCompatibilityStatus(size);

              return ModelTile(
                id: id,
                title: title,
                description: summary,
                imagePath: imagePath,
                producer: producer,
                url: url,
                size: size?.toString(),
                requirements: ram?.toString(),
                modelPath: modelPath,
                isServerSide: isServerSide,
                isCustomModel: isCustomModel,
                isLastInColumn: model == columnModels.last,
                isSeeAll: false,
                manager: manager,
                isDownloaded: isDownloaded,
                compatibilityStatus: compatibilityStatus,
                onTileTap: () => onModelTapped(model),
                onRemoveRequested: () async {
                  HapticFeedback.mediumImpact();
                  await onRemovePressed(id, title);
                },
                onChatPressed: () => onChatPressed(id, isServerSide, isCustomModel: isCustomModel, modelPath: modelPath),
                onDownloadPressed: () => onDownloadPressed(id: id, url: url, title: title),
                onCancelDownload: () => onCancelDownload(id),
                onResumeDownload: () => onResumeDownload(id),
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
    // If the list of models is empty, render nothing.
    if (models.isEmpty) {
      return const SizedBox.shrink();
    }

    final double screenWidth = MediaQuery.of(context).size.width;

    // The core content of the widget.
    final Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(screenWidth),
        SizedBox(
          height: _calculateHeight(screenWidth),
          child: PageView(
            clipBehavior: Clip.none, // Allows shadows from cards to be visible
            controller: PageController(viewportFraction: 1.0),
            children: _buildModelColumns(context, screenWidth),
          ),
        ),
      ],
    );

    // If a pulse animation is provided, wrap the content in an AnimatedBuilder.
    if (pulseAnimation != null) {
      return AnimatedBuilder(
        animation: pulseAnimation!,
        builder: (context, child) {
          // --- DYNAMIC SCALE CALCULATION LOGIC (Preserved from original code) ---
          const double maxExpansionInPixels = 7.0;
          final double originalContentWidth = screenWidth - 2 * (screenWidth * 0.04);
          final double maxDesiredWidth = originalContentWidth + maxExpansionInPixels;
          final double targetWidth = (maxDesiredWidth < screenWidth) ? maxDesiredWidth : screenWidth;
          final double maxTargetScale = (originalContentWidth > 0) ? targetWidth / originalContentWidth : 1.0;

          // Map the animation value (e.g., 1.0 to 1.1) to our new dynamic range.
          final double animationProgress = (pulseAnimation!.value - 1.0) / 0.10;
          final double finalAppliedScale = 1.0 + (animationProgress * (maxTargetScale - 1.0));

          // Calculate the extra vertical space needed to prevent overlap during scaling.
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
              // Add a spacer to push down subsequent content during the animation's peak.
              SizedBox(height: bottomSpacerHeight > 0 ? bottomSpacerHeight : 0),
            ],
          );
        },
        child: content,
      );
    }

    // If no animation, just return the content directly.
    return content;
  }
}