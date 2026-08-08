// lib/chat/screen/widgets/bottom/selection/sheet.dart

import 'package:cortex/chat/screen/widgets/bottom/panels/selection/skeleton.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/variants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';
import '../../../../../../library/providers/local.dart';
import '../../../../../../server/user.dart';
import '../../../../../../fog.dart';
import 'cards/main.dart';
import 'cards/variant.dart';

import 'package:cortex/sheet.dart';
import 'package:cortex/library/screen/models/widgets/sheet.dart';

Future<bool?> showModelSelectionSheet({
  required BuildContext context,
  required AppLocalizations localizations,
  required String currentModelId,
  required ValueChanged<String> onModelSelected,
  required List<ModelEntity> initialModels,
}) {
  FocusScope.of(context).unfocus();

  final modelService = context.read<ModelService>();
  final localStateProvider = context.read<ModelLocalStateProvider>();

  // Sync access for instant load check
  final cachedModels = initialModels.isNotEmpty
      ? initialModels
      : modelService.getCachedModelsSync();
  final downloadMap = localStateProvider.downloadCompleted;

  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: false,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width,
    ),
    builder: (BuildContext modalContext) {
      return ScaledBottomSheet(
        child: _ModelSheetContent(
          localizations: localizations,
          currentModelId: currentModelId,
          onModelSelected: onModelSelected,
          initialModels: cachedModels,
          downloadMap: downloadMap,
        ),
      );
    },
  );
}

class _ModelSheetContent extends StatefulWidget {
  final AppLocalizations localizations;
  final String currentModelId;
  final ValueChanged<String> onModelSelected;
  final List<ModelEntity>? initialModels;
  final Map<String, bool> downloadMap;

  const _ModelSheetContent({
    required this.localizations,
    required this.currentModelId,
    required this.onModelSelected,
    required this.initialModels,
    required this.downloadMap,
  });

  @override
  State<_ModelSheetContent> createState() => _ModelSheetContentState();
}

class _ModelSheetContentState extends State<_ModelSheetContent>
    with TickerProviderStateMixin {
  // Data Lists
  List<ModelEntity> _selfModels = [];
  List<ModelEntity> _offlineModels = [];
  List<ModelEntity> _onlineSeries = [];
  List<ModelEntity> _videoSeries = [];
  List<ModelEntity> _imageSeries = [];
  List<ModelEntity> _audioSeries = [];
  List<ModelEntity> _characterModels = [];

  bool _isLoading = true;
  String? _expandedSeriesId;

  // Cached Layout Values
  late double sw;
  late double sh;
  late double sp16;
  late double sp12;
  late double sp8;
  late double iconSize;
  late double titleSize;
  late double categoryTitleSize;
  late double mainCardAspectRatio;

  @override
  void initState() {
    super.initState();

    if (widget.initialModels != null && widget.initialModels!.isNotEmpty) {
      _processData(widget.initialModels!);
      _isLoading = false;
    }
    // _fetchAsync() is now called in didChangeDependencies
    // to safely access Localizations and context
  }

  void _processData(List<ModelEntity> models) {
    final self = <ModelEntity>[];
    final offline = <ModelEntity>[];
    final character = <ModelEntity>[];
    final online = <ModelEntity>[];
    final video = <ModelEntity>[];
    final image = <ModelEntity>[];
    final audio = <ModelEntity>[];

    for (var m in models) {
      if (m.category == 'self') {
        self.add(m);
      } else if (m.category == 'roleplay') {
        character.add(m);
      } else if (m.type == 'offline') {
        // For offline models: check if it's a series with variants.
        if (m.variants != null && m.variants!.isNotEmpty) {
          // Series model: include it only if at least one variant is downloaded.
          final hasDownloadedVariant = m.variants!.keys.any(
            (variantId) => widget.downloadMap[variantId] == true,
          );
          if (hasDownloadedVariant) {
            offline.add(m);
          }
        } else {
          // Non-series offline model: use the old direct check.
          if (widget.downloadMap[m.id] == true) {
            offline.add(m);
          }
        }
      } else if (m.type == 'online') {
        if (m.category == 'video') {
          video.add(m);
        } else if (m.category == 'image') {
          image.add(m);
        } else if (m.category == 'audio') {
          audio.add(m);
        } else {
          online.add(m);
        }
      }
    }

    online.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
    video.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
    image.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
    audio.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));
    offline.sort((a, b) =>
        (a.series ?? a.displayTitle).compareTo(b.series ?? b.displayTitle));

    _selfModels = self;
    _offlineModels = offline;
    _characterModels = character;
    _onlineSeries = online;
    _videoSeries = video;
    _imageSeries = image;
    _audioSeries = audio;
  }

  Future<void> _fetchAsync() async {
    if (!mounted) return;
    final modelService = context.read<ModelService>();
    final langCode = Localizations.localeOf(context).languageCode;
    final models = await modelService.getModels(langCode: langCode);

    if (mounted && models != null) {
      // Simulate a small delay if needed for smoother transition, or remove.
      // await Future.delayed(const Duration(milliseconds: 100));

      setState(() {
        _processData(models);
        _isLoading = false;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check missing initial models safely here where context/localization is ready
    if (_isLoading &&
        (widget.initialModels == null || widget.initialModels!.isEmpty)) {
      // Delay fetch to avoid calling Provider's API that triggers notifyListeners
      // while the widget tree is currently building (setState() / markNeedsBuild() exception).
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAsync();
      });
    }

    sw = MediaQuery.sizeOf(context).width;
    sh = MediaQuery.sizeOf(context).height;

    sp16 = sw * 0.04;
    sp12 = sw * 0.03;
    sp8 = sw * 0.02;
    final bool isTablet = sw >= 600;
    titleSize = isTablet ? sw * 0.035 : sw * 0.055;
    categoryTitleSize = isTablet ? sw * 0.025 : sw * 0.038;
    iconSize = isTablet ? sw * 0.03 : sw * 0.05;

    final gridWidth = sw - (2 * sp16);
    final itemWidth = (gridWidth - sp12) / 2;
    final desiredHeight = sh * 0.085;
    mainCardAspectRatio = itemWidth / desiredHeight;
  }

  void _handleSeriesExpansion(String seriesId) {
    setState(() {
      if (_expandedSeriesId == seriesId) {
        _expandedSeriesId = null;
      } else {
        _expandedSeriesId = seriesId;
      }
    });
  }

  Future<String> _resolveSeriesSelection(String modelId) async {
    final allSeries = <ModelEntity>[
      ..._selfModels,
      ..._offlineModels,
      ..._onlineSeries,
      ..._videoSeries,
      ..._imageSeries,
      ..._audioSeries,
      ..._characterModels,
    ];

    final int seriesIndex = allSeries.indexWhere((m) => m.id == modelId);
    if (seriesIndex == -1) return modelId;

    final series = allSeries[seriesIndex];
    final variantsMap = series.variants;
    if (variantsMap == null || variantsMap.isEmpty) return modelId;

    // For offline series: only resolve to DOWNLOADED variants.
    if (series.type == 'offline') {
      final lastUsedId = await Variants.getLastSelectedVariant(series.id);
      // Check if last used variant is still downloaded.
      if (lastUsedId.isNotEmpty &&
          variantsMap.containsKey(lastUsedId) &&
          widget.downloadMap[lastUsedId] == true) {
        return lastUsedId;
      }
      // Fall back to first downloaded variant.
      for (final variantId in variantsMap.keys) {
        if (widget.downloadMap[variantId] == true) {
          return variantId;
        }
      }
      // No variant downloaded — should not happen (filtered in _processData).
      return modelId;
    }

    // Online series: original logic.
    final lastUsedId = await Variants.getLastSelectedVariant(series.id);
    if (lastUsedId.isNotEmpty && variantsMap.containsKey(lastUsedId)) {
      return lastUsedId;
    }
    // Prefer first non-premium variant to avoid unnecessary credit spend.
    for (final entry in variantsMap.entries) {
      final variantData = entry.value;
      if (variantData is Map<String, dynamic> &&
          variantData['tier'] != 'premium') {
        return entry.key;
      }
    }
    return variantsMap.keys.first;
  }

  Future<void> _handleSelection(String modelId) async {
    final model = _findModelById(modelId);
    if (model != null && model.isPremium && mounted) {
      final userProvider = context.read<UserProvider>();
      if (!userProvider.isSubscriptionActive) {
        showPremiumBottomSheet(context);
        return;
      }
    }
    final resolvedModelId = await _resolveSeriesSelection(modelId);
    widget.onModelSelected(resolvedModelId);
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  ModelEntity? _findModelById(String modelId) {
    final allSeries = <ModelEntity>[
      ..._selfModels,
      ..._offlineModels,
      ..._onlineSeries,
      ..._videoSeries,
      ..._imageSeries,
      ..._audioSeries,
      ..._characterModels,
    ];
    for (final model in allSeries) {
      if (model.id == modelId) return model;
      if (model.variants != null && model.variants!.containsKey(modelId)) {
        return model;
      }
    }
    return null;
  }

  bool _isSeriesActive(ModelEntity series) {
    if (widget.currentModelId == series.id) return true;
    if (series.variants != null) {
      return series.variants!.containsKey(widget.currentModelId);
    }
    return widget.currentModelId.startsWith('${series.id}-');
  }

  // Internal controller for the list content
  final ScrollController _internalScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final double topRadius = sw * 0.07;

    final bool cortexVisible = true;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.4,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.55, 1.0],
      expand: false,
      builder: (context, sheetScrollController) {
        return Material(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              // 1. HEADER AREA (Always visible, handled by Sheet Controller)
              SingleChildScrollView(
                controller: sheetScrollController,
                physics: const ClampingScrollPhysics(),
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {}, // Capture taps
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: sw * 0.08),
                      // Handle Bar
                      Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        width: sw * 0.12,
                        height: 5,
                        decoration: BoxDecoration(
                          color: AppColors.quaternaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Center(
                          child: Text(
                            widget.localizations.allModels,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: titleSize,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. CONTENT AREA (Switches between Skeleton and Real Data)
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  child: _isLoading
                      ? const ModelSelectionSkeleton(key: ValueKey('skeleton'))
                      : ScrollFog(
                          key: const ValueKey('content'),
                          scrollController: _internalScrollController,
                          topFogHeight: 20,
                          bottomFogHeight: 50,
                          child: CustomScrollView(
                            controller: _internalScrollController,
                            physics: const ClampingScrollPhysics(),
                            slivers: [
                              // --- DYNAMIC CHAT (CORTEX) ---
                              if (cortexVisible) ...[
                                _buildSliverHeader(
                                    widget.localizations.dynamicChatTitle),
                                SliverPadding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: sp16),
                                  sliver: SliverToBoxAdapter(
                                    child: Center(
                                      child: SizedBox(
                                        width: (sw - (2 * sp16) - sp12) / 2,
                                        height: sh * 0.085,
                                        child: ModelCard(
                                          title: 'Cortex',
                                          imagePath: 'assets/cortex.svg',
                                          isSelected: widget.currentModelId ==
                                              'cortex/auto',
                                          onBodyTap: () =>
                                              _handleSelection('cortex/auto'),
                                          showExpansionArrow: false,
                                          backgroundGradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            stops: const [0.1, 1],
                                            colors: [
                                              Colors.blueAccent
                                                  .withValues(alpha: 0.0),
                                              Colors.blueAccent
                                                  .withValues(alpha: 0.2),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],

                              if (_selfModels.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.customModels),
                                _buildSliverGrid(_selfModels),
                              ],
                              if (_offlineModels.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.offlineModels),
                                _buildOfflineSeriesList(_offlineModels),
                              ],
                              if (_onlineSeries.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.languageModels),
                                _buildSliverOnlineList(_onlineSeries),
                              ],
                              if (_videoSeries.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.videoModels),
                                _buildSliverOnlineList(_videoSeries),
                              ],
                              if (_imageSeries.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.imageModels),
                                _buildSliverOnlineList(_imageSeries),
                              ],
                              if (_audioSeries.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.audioModels),
                                _buildSliverOnlineList(_audioSeries),
                              ],
                              if (_characterModels.isNotEmpty) ...[
                                _buildSliverHeader(
                                    widget.localizations.characterModels),
                                _buildSliverGrid(_characterModels),
                              ],

                              SliverPadding(
                                padding: EdgeInsets.only(
                                  bottom:
                                      MediaQuery.paddingOf(context).bottom + 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSliverHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sp16, vertical: 12),
        child: Row(
          children: [
            Expanded(child: Container(height: 1, color: AppColors.border)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sp12),
              child: Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: categoryTitleSize,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryColor.inverted,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Expanded(child: Container(height: 1, color: AppColors.border)),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverGrid(List<ModelEntity> models) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sp16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: mainCardAspectRatio,
          crossAxisSpacing: sp12,
          mainAxisSpacing: sp12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final model = models[index];
            return ModelCard(
              title: model.displayTitle,
              imagePath: model.imagePath ?? '',
              isSelected: widget.currentModelId == model.id,
              onBodyTap: () => _handleSelection(model.id),
              showExpansionArrow: false,
            );
          },
          childCount: models.length,
        ),
      ),
    );
  }

  /// Builds the offline model series list — identical to online series but
  /// shows only downloaded variants in the expansion panel.
  Widget _buildOfflineSeriesList(List<ModelEntity> seriesList) {
    // Separate: series models (with variants) vs single offline models
    final withVariants =
        seriesList.where((m) => m.variants?.isNotEmpty ?? false).toList();
    final withoutVariants = seriesList
        .where((m) => m.variants == null || m.variants!.isEmpty)
        .toList();

    return SliverMainAxisGroup(
      slivers: [
        // 1. Series with expandable variants (like online)
        if (withVariants.isNotEmpty) _buildOfflineSeriesRows(withVariants),
        // 2. Single offline models (no variants — old behavior grid)
        if (withoutVariants.isNotEmpty)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: sp16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: mainCardAspectRatio,
                crossAxisSpacing: sp12,
                mainAxisSpacing: sp12,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final model = withoutVariants[index];
                  return ModelCard(
                    title: model.displayTitle,
                    imagePath: model.imagePath ?? '',
                    isSelected: widget.currentModelId == model.id,
                    onBodyTap: () => _handleSelection(model.id),
                    showExpansionArrow: false,
                  );
                },
                childCount: withoutVariants.length,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOfflineSeriesRows(List<ModelEntity> seriesList) {
    final int rowCount = (seriesList.length / 2).ceil();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sp16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final int itemIndex = index * 2;
            final item1 = seriesList[itemIndex];
            final item2 = (itemIndex + 1 < seriesList.length)
                ? seriesList[itemIndex + 1]
                : null;

            final bool isItem1Expanded = _expandedSeriesId == item1.id;
            final bool isItem2Expanded =
                item2 != null && _expandedSeriesId == item2.id;

            final bool isItem1Active = _isSeriesActive(item1);
            final bool isItem2Active = item2 != null && _isSeriesActive(item2);

            // Determine if this series has multiple downloaded variants
            // (only show expansion arrow if more than 1 downloaded variant).
            final int item1DownloadedCount = _countDownloadedVariants(item1);
            final int item2DownloadedCount =
                item2 != null ? _countDownloadedVariants(item2) : 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: sp12),
                  child: SizedBox(
                    height: (sw - (2 * sp16) - sp12) / 2 / mainCardAspectRatio,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModelCard(
                            title: item1.series ?? item1.displayTitle,
                            imagePath: item1.imagePath ?? '',
                            isSelected: isItem1Active,
                            isExpanded: isItem1Expanded,
                            showExpansionArrow: item1DownloadedCount > 1,
                            onBodyTap: () => _handleSelection(item1.id),
                            onArrowTap: item1DownloadedCount > 1
                                ? () => _handleSeriesExpansion(item1.id)
                                : null,
                          ),
                        ),
                        SizedBox(width: sp12),
                        Expanded(
                          child: item2 != null
                              ? ModelCard(
                                  title: item2.series ?? item2.displayTitle,
                                  imagePath: item2.imagePath ?? '',
                                  isSelected: isItem2Active,
                                  isExpanded: isItem2Expanded,
                                  showExpansionArrow: item2DownloadedCount > 1,
                                  onBodyTap: () => _handleSelection(item2.id),
                                  onArrowTap: item2DownloadedCount > 1
                                      ? () => _handleSeriesExpansion(item2.id)
                                      : null,
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
                _VariantsPanel(
                  seriesModel: item1,
                  isVisible: isItem1Expanded,
                  localizations: widget.localizations,
                  currentModelId: widget.currentModelId,
                  onSelect: _handleSelection,
                  width: sw,
                  padding: sp16,
                  iconSize: iconSize,
                  titleSize: categoryTitleSize,
                  downloadMap: widget.downloadMap,
                ),
                if (item2 != null)
                  _VariantsPanel(
                    seriesModel: item2,
                    isVisible: isItem2Expanded,
                    localizations: widget.localizations,
                    currentModelId: widget.currentModelId,
                    onSelect: _handleSelection,
                    width: sw,
                    padding: sp16,
                    iconSize: iconSize,
                    titleSize: categoryTitleSize,
                    downloadMap: widget.downloadMap,
                  ),
              ],
            );
          },
          childCount: rowCount,
        ),
      ),
    );
  }

  /// Counts how many variants of a model are downloaded.
  int _countDownloadedVariants(ModelEntity model) {
    if (model.variants == null || model.variants!.isEmpty) return 0;
    return model.variants!.keys
        .where((id) => widget.downloadMap[id] == true)
        .length;
  }

  Widget _buildSliverOnlineList(List<ModelEntity> seriesList) {
    final int rowCount = (seriesList.length / 2).ceil();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sp16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final int itemIndex = index * 2;
            final item1 = seriesList[itemIndex];
            final item2 = (itemIndex + 1 < seriesList.length)
                ? seriesList[itemIndex + 1]
                : null;

            final bool isItem1Expanded = _expandedSeriesId == item1.id;
            final bool isItem2Expanded =
                item2 != null && _expandedSeriesId == item2.id;

            final bool isItem1Active = _isSeriesActive(item1);
            final bool isItem2Active = item2 != null && _isSeriesActive(item2);

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(bottom: sp12),
                  child: SizedBox(
                    height: (sw - (2 * sp16) - sp12) / 2 / mainCardAspectRatio,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModelCard(
                            title: item1.displayTitle,
                            imagePath: item1.imagePath ?? '',
                            isSelected: isItem1Active,
                            isExpanded: isItem1Expanded,
                            showExpansionArrow: true,
                            onBodyTap: () => _handleSelection(item1.id),
                            onArrowTap: () => _handleSeriesExpansion(item1.id),
                          ),
                        ),
                        SizedBox(width: sp12),
                        Expanded(
                          child: item2 != null
                              ? ModelCard(
                                  title: item2.displayTitle,
                                  imagePath: item2.imagePath ?? '',
                                  isSelected: isItem2Active,
                                  isExpanded: isItem2Expanded,
                                  showExpansionArrow: true,
                                  onBodyTap: () => _handleSelection(item2.id),
                                  onArrowTap: () =>
                                      _handleSeriesExpansion(item2.id),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                ),
                _VariantsPanel(
                  seriesModel: item1,
                  isVisible: isItem1Expanded,
                  localizations: widget.localizations,
                  currentModelId: widget.currentModelId,
                  onSelect: _handleSelection,
                  width: sw,
                  padding: sp16,
                  iconSize: iconSize,
                  titleSize: categoryTitleSize,
                ),
                if (item2 != null)
                  _VariantsPanel(
                    seriesModel: item2,
                    isVisible: isItem2Expanded,
                    localizations: widget.localizations,
                    currentModelId: widget.currentModelId,
                    onSelect: _handleSelection,
                    width: sw,
                    padding: sp16,
                    iconSize: iconSize,
                    titleSize: categoryTitleSize,
                  ),
              ],
            );
          },
          childCount: rowCount,
        ),
      ),
    );
  }
}

class _VariantsPanel extends StatelessWidget {
  final ModelEntity seriesModel;
  final bool isVisible;
  final AppLocalizations localizations;
  final String currentModelId;
  final ValueChanged<String> onSelect;
  final double width;
  final double padding;
  final double iconSize;
  final double titleSize;

  /// If provided, only variants with downloadMap[id] == true are shown.
  final Map<String, bool>? downloadMap;

  const _VariantsPanel({
    required this.seriesModel,
    required this.isVisible,
    required this.localizations,
    required this.currentModelId,
    required this.onSelect,
    required this.width,
    required this.padding,
    required this.iconSize,
    required this.titleSize,
    this.downloadMap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedCrossFade(
      firstChild: SizedBox(width: width, height: 0),
      secondChild: _buildContent(),
      crossFadeState:
          isVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 250),
      sizeCurve: Curves.fastOutSlowIn,
      firstCurve: Curves.easeOut,
      secondCurve: Curves.easeIn,
      alignment: Alignment.topCenter,
    );
  }

  Widget _buildContent() {
    final variantsMap = seriesModel.variants ?? {};
    if (variantsMap.isEmpty) return const SizedBox.shrink();

    // Build variant list, optionally filtering by download status.
    final List<Map<String, dynamic>> variants = variantsMap.entries.where((e) {
      // If downloadMap is provided, only show downloaded variants.
      if (downloadMap != null) {
        return downloadMap![e.key] == true;
      }
      return true;
    }).map((e) {
      if (e.value is Map<String, dynamic>) {
        return e.value as Map<String, dynamic>;
      }
      return {'id': e.key, 'title': e.key};
    }).toList();

    if (variants.isEmpty) return const SizedBox.shrink();

    final gridWidth = width - (2 * padding) - (2 * padding);
    final sp8 = width * 0.02;
    final itemWidth = (gridWidth - sp8) / 2;
    final itemHeight = 45.0;
    final variantRatio = itemWidth / itemHeight;

    return Container(
      width: width,
      margin: EdgeInsets.only(bottom: padding),
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(width * 0.05),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              SvgPicture.asset(
                'assets/icons/route.svg',
                width: iconSize * 0.8,
                height: iconSize * 0.8,
                colorFilter:
                    ColorFilter.mode(AppColors.tertiaryColor, BlendMode.srcIn),
              ),
              SizedBox(width: sp8),
              Text(
                "${seriesModel.series ?? seriesModel.displayTitle} ${localizations.variants}",
                style: TextStyle(
                    fontSize: titleSize * 0.8,
                    color: AppColors.tertiaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: sp8),
            child: Text(
              localizations.variantsDescription,
              style: TextStyle(
                fontSize: titleSize * 0.75,
                fontStyle: FontStyle.normal,
                color: AppColors.tertiaryColor.withValues(alpha: 0.8),
                height: 1.3,
              ),
            ),
          ),
          SizedBox(height: sp8),
          GridView.builder(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: variantRatio,
              crossAxisSpacing: sp8,
              mainAxisSpacing: sp8,
            ),
            itemCount: variants.length,
            itemBuilder: (context, index) {
              final variant = variants[index];
              final String id = variant['id'];
              final String title = variant['title'] ?? id;
              final bool isPremium = variant['tier'] == 'premium';
              // Show the variant as selected if it matches the current model.
              final bool isSelected = currentModelId == id;

              return ModelVariantCard(
                title: title,
                isSelected: isSelected,
                isPremium: isPremium,
                onTap: () => onSelect(id),
              );
            },
          ),
        ],
      ),
    );
  }
}
