import 'package:cortex/l10n/app_localizations.dart';
// lib/library/screen/models/widgets/category.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:cortex/fog.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';
import '../../../backend/utils.dart';
import 'package:cortex/library/utils.dart';
import 'package:cortex/axon/inbox/panel/view.dart';
import 'package:cortex/axon/inbox/panel/buttons.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'cards.dart';

class ModelCategorySection extends StatefulWidget {
  final String title;
  final List<ModelEntity> models;
  final Animation<double>? pulseAnimation;
  final Map<String, bool> downloadedStates;
  final Map<String, DownloadManager> downloadManagers;
  final List<String>? subCategories;
  final CompatibilityStatus Function(int? modelSizeInMB) getCompatibilityStatus;

  // Actions
  final void Function(ModelEntity model) onModelTapped;
  final Future<void> Function(String id, String title) onRemovePressed;
  final Future<void> Function(String id, bool isServerSide,
      {bool isCustomModel, String? modelPath}) onChatPressed;
  final Future<void> Function(
      {required String id,
      required String? url,
      required String title}) onDownloadPressed;
  final void Function(String id) onCancelDownload;
  final void Function(String id) onResumeDownload;

  // Edge Gestures
  final VoidCallback? onOverscrollStart;
  final VoidCallback? onOverscrollEnd;

  const ModelCategorySection({
    super.key,
    required this.title,
    required this.models,
    this.pulseAnimation,
    required this.downloadedStates,
    required this.downloadManagers,
    this.subCategories,
    required this.getCompatibilityStatus,
    required this.onModelTapped,
    required this.onRemovePressed,
    required this.onChatPressed,
    required this.onDownloadPressed,
    required this.onCancelDownload,
    required this.onResumeDownload,
    this.onOverscrollStart,
    this.onOverscrollEnd,
  });

  @override
  State<ModelCategorySection> createState() => _ModelCategorySectionState();
}

class _ModelCategorySectionState extends State<ModelCategorySection> {
  late final PageController _pageController;

  // Debounce
  bool _canTriggerEdgeAction = true;

  // Category state
  String _selectedCategory = 'categoryAll';
  bool _isMenuOpen = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.98);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _triggerEdgeAction(VoidCallback action) {
    if (_canTriggerEdgeAction) {
      HapticFeedback.lightImpact();

      // Navigasyon hatasını önlemek için post frame callback
      WidgetsBinding.instance.addPostFrameCallback((_) {
        action();
      });

      setState(() => _canTriggerEdgeAction = false);

      Timer(const Duration(seconds: 1), () {
        if (mounted) setState(() => _canTriggerEdgeAction = true);
      });
    }
  }

  double _calculateHeight(double screenWidth) {
    final modelMaps = widget.models.map((e) => e.toMap()).toList();
    return ModelsBackendUtils.calculateCategoryHeight(modelMaps, screenWidth);
  }

  List<Widget> _buildModelColumns(BuildContext context, double screenWidth,
      List<ModelEntity> filteredModels) {
    final List<Widget> columns = [];
    const int modelsPerColumn = 3;
    final int totalModels = filteredModels.length;
    final int totalColumns = (totalModels / modelsPerColumn).ceil();

    for (int i = 0; i < totalColumns; i++) {
      final int startIndex = i * modelsPerColumn;
      final int endIndex = (startIndex + modelsPerColumn > totalModels)
          ? totalModels
          : startIndex + modelsPerColumn;

      final List<ModelEntity> columnModels =
          filteredModels.sublist(startIndex, endIndex);

      columns.add(
        Padding(
          padding: EdgeInsetsDirectional.only(end: screenWidth * 0.001),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: columnModels.map((model) {
              bool isDownloaded = widget.downloadedStates[model.id] ?? false;
              DownloadManager? manager =
                  model.isServerSide ? null : widget.downloadManagers[model.id];

              // Offline Series Dashboard Logic: check variants for active metrics
              if (!model.isServerSide &&
                  (model.variants?.isNotEmpty ?? false)) {
                bool anyVariantDownloaded = false;
                bool anyVariantDownloading = false;
                DownloadManager? activeVariantManager;

                for (final variantKey in model.variants!.keys) {
                  if (widget.downloadedStates[variantKey] == true) {
                    anyVariantDownloaded = true;
                  }
                  final m = widget.downloadManagers[variantKey];
                  if (m != null && (m.isDownloading || m.isPaused)) {
                    anyVariantDownloading = true;
                    activeVariantManager = m;
                  }
                }

                isDownloaded = anyVariantDownloaded;
                if (anyVariantDownloading && activeVariantManager != null) {
                  manager = activeVariantManager;
                }
              }

              final compatibilityStatus = isDownloaded
                  ? CompatibilityStatus.compatible
                  : widget.getCompatibilityStatus(model.size);

              return ModelTile(
                model: model,
                isLastInColumn: model == columnModels.last,
                isSeeAll: false,
                manager: manager,
                isDownloaded: isDownloaded,
                compatibilityStatus: compatibilityStatus,
                onTileTap: () => widget.onModelTapped(model),
                onRemoveRequested: () async {
                  HapticFeedback.mediumImpact();
                  await widget.onRemovePressed(model.id, model.displayTitle);
                },
                onChatPressed: () => widget.onChatPressed(
                  model.id,
                  model.isServerSide,
                  isCustomModel: model.isCustomModel,
                  modelPath: null,
                ),
                onDownloadPressed: () {
                  final isOfflineSeries = !model.isServerSide &&
                      (model.variants?.isNotEmpty ?? false);
                  widget.onDownloadPressed(
                    id: isOfflineSeries
                        ? (ModelDataUtils.getOptimalVariantId(model) ??
                            model.id)
                        : model.id,
                    url: isOfflineSeries
                        ? ModelDataUtils.getOptimalDownloadUrl(model)
                        : model.url,
                    title: model.displayTitle,
                  );
                },
                onCancelDownload: () {
                  if (!model.isServerSide &&
                      (model.variants?.isNotEmpty ?? false)) {
                    for (final variantKey in model.variants!.keys) {
                      final m = widget.downloadManagers[variantKey];
                      if (m != null && (m.isDownloading || m.isPaused)) {
                        widget.onCancelDownload(variantKey);
                      }
                    }
                  } else {
                    widget.onCancelDownload(model.id);
                  }
                },
                onResumeDownload: () {
                  if (!model.isServerSide &&
                      (model.variants?.isNotEmpty ?? false)) {
                    for (final variantKey in model.variants!.keys) {
                      final m = widget.downloadManagers[variantKey];
                      if (m != null && m.isPaused) {
                        widget.onResumeDownload(variantKey);
                      }
                    }
                  } else {
                    widget.onResumeDownload(model.id);
                  }
                },
              );
            }).toList(),
          ),
        ),
      );
    }
    return columns;
  }

  String _getLocalizedCategory(String cat, AppLocalizations loc) {
    if (cat == 'categoryAll') return loc.categoryAll;
    if (cat == 'categoryFree') return loc.categoryFree;
    if (cat == 'categoryPremium') return loc.categoryPremium;
    if (cat == 'categoryVideo') return loc.categoryVideo;
    if (cat == 'categoryPhoto') return loc.categoryPhoto;
    if (cat == 'categoryMasculine') return loc.categoryMasculine;
    if (cat == 'categoryFeminine') return loc.categoryFeminine;
    if (cat == 'categoryInanimate') return loc.categoryInanimate;
    return cat;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.models.isEmpty) {
      return const SizedBox.shrink();
    }

    // Apply filtering based on selected category
    List<ModelEntity> filteredModels = widget.models;
    if (_selectedCategory != 'categoryAll') {
      filteredModels = widget.models.where((m) {
        if (_selectedCategory == 'categoryFree') return !m.isPremium;
        if (_selectedCategory == 'categoryPremium') return m.isPremium;
        if (_selectedCategory == 'categoryVideo') {
          final t = m.displayTitle.toLowerCase();
          final id = m.id.toLowerCase();
          return t.contains('video') ||
              id.contains('video') ||
              t.contains('sora') ||
              t.contains('kling') ||
              t.contains('veo');
        }
        if (_selectedCategory == 'categoryPhoto') {
          final t = m.displayTitle.toLowerCase();
          final id = m.id.toLowerCase();
          return t.contains('image') ||
              id.contains('image') ||
              t.contains('flux') ||
              t.contains('stable') ||
              t.contains('dall');
        }
        if (_selectedCategory == 'categoryMasculine') {
          return m.role?.toLowerCase().contains('erkek') == true ||
              m.role?.toLowerCase().contains('male') == true;
        }
        if (_selectedCategory == 'categoryFeminine') {
          return m.role?.toLowerCase().contains('kadın') == true ||
              m.role?.toLowerCase().contains('kız') == true ||
              m.role?.toLowerCase().contains('female') == true;
        }
        if (_selectedCategory == 'categoryInanimate') {
          return m.role?.toLowerCase().contains('nesne') == true ||
              m.role?.toLowerCase().contains('robot') == true;
        }
        return true;
      }).toList();
    }

    final double screenWidth = MediaQuery.of(context).size.width;
    const double horizontalPaddingRatio = 0.04;
    final double sectionHPad = screenWidth * horizontalPaddingRatio;

    final double availableWidth = screenWidth - 2 * sectionHPad;
    final double pageWidth = availableWidth * 0.98;
    final double sideInset = (availableWidth - pageWidth) / 2;
    final double trackShift = sideInset * 2;

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: sectionHPad),
          child: _buildHeader(screenWidth),
        ),
        // Fog efektinin ekranın gerçek kenarına kadar uzanması için Stack kullanıyoruz
        // Tablet'te fog'un kesik görünmemesi için fog, content'in dışına taşacak
        Stack(
          clipBehavior: Clip.none,
          children: [
            // Ana içerik
            SizedBox(
              height: _calculateHeight(screenWidth),
              child: NotificationListener<ScrollNotification>(
                onNotification: (notification) {
                  if (notification is OverscrollNotification) {
                    if (notification.overscroll < 0 &&
                        widget.onOverscrollStart != null) {
                      _triggerEdgeAction(widget.onOverscrollStart!);
                    } else if (notification.overscroll > 0 &&
                        widget.onOverscrollEnd != null) {
                      _triggerEdgeAction(widget.onOverscrollEnd!);
                    }
                  }
                  return false;
                },
                child: ScrollFogHorizontal(
                  scrollController: _pageController,
                  // Fog genişliğini padding + ekstra içerik kadar yap
                  startFogWidth: sectionHPad + 32.0,
                  endFogWidth: sectionHPad + 32.0,
                  // Fog'u widget sınırlarının dışına taşır (tablet'te ekran kenarına ulaşması için)
                  // sectionHPad kadar taşırarak fog'un tam ekran kenarından başlamasını sağlıyoruz
                  edgeOverflow: sectionHPad,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: sectionHPad),
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Transform.translate(
                        offset: Offset(-trackShift, 0),
                        child: PageView(
                          clipBehavior: Clip.none,
                          controller: _pageController,
                          padEnds: true,
                          physics: const ClampingScrollPhysics(),
                          children: _buildModelColumns(
                              context, screenWidth, filteredModels),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );

    if (widget.pulseAnimation != null) {
      return AnimatedBuilder(
        animation: widget.pulseAnimation!,
        builder: (context, child) {
          const double maxExpansionInPixels = 7.0;
          final double originalContentWidth =
              screenWidth - 2 * (screenWidth * 0.04);
          final double maxDesiredWidth =
              originalContentWidth + maxExpansionInPixels;
          final double targetWidth =
              (maxDesiredWidth < screenWidth) ? maxDesiredWidth : screenWidth;
          final double maxTargetScale = (originalContentWidth > 0)
              ? targetWidth / originalContentWidth
              : 1.0;
          final double animationProgress =
              (widget.pulseAnimation!.value - 1.0) / 0.10;
          final double finalAppliedScale =
              1.0 + (animationProgress * (maxTargetScale - 1.0));
          final double headerApproxHeight = screenWidth * 0.08;
          final double contentOriginalHeight =
              _calculateHeight(screenWidth) + headerApproxHeight;
          final double extraHeight =
              (contentOriginalHeight * finalAppliedScale) -
                  contentOriginalHeight;
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

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding:
          EdgeInsets.only(top: screenWidth * 0.02, bottom: screenWidth * 0.03),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: AppColors.primaryColor.inverted,
              fontSize: screenWidth * 0.05,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.subCategories != null && widget.subCategories!.isNotEmpty)
            GestureDetector(
              onTapDown: (details) {
                setState(() {
                  _isMenuOpen = true;
                });
                final loc = AppLocalizations.of(context)!;
                final List<ActionPanelButton> buttons = widget.subCategories!.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return ActionPanelButton(
                    customIcon: isSelected 
                      ? SvgPicture.asset('assets/icons/checkmark.svg', width: 18, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn))
                      : const SizedBox(width: 18),
                    iconColor: AppColors.primaryColor.inverted,
                    text: _getLocalizedCategory(cat, loc),
                    textColor: AppColors.primaryColor.inverted,
                    onPressed: () {
                      ActionPanelController.closeCurrent();
                      setState(() {
                        _selectedCategory = cat;
                        _isMenuOpen = false;
                      });
                      HapticFeedback.lightImpact();
                    },
                  );
                }).toList();

                showActionPanel(
                  context: context,
                  touchPosition: details.globalPosition,
                  onClosed: () {
                    if (mounted) setState(() => _isMenuOpen = false);
                  },
                  buttons: buttons,
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getLocalizedCategory(
                          _selectedCategory, AppLocalizations.of(context)!),
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.7),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _isMenuOpen
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 20,
                      color: AppColors.primaryColor.inverted
                          .withValues(alpha: 0.7),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
