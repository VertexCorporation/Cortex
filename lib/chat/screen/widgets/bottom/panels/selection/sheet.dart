// lib/chat/screen/widgets/bottom/selection/sheet.dart

import 'package:cortex/chat/screen/widgets/bottom/panels/selection/skeleton.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../../app.dart';
import '../../../../../../library/providers/local.dart';
import '../../../../../../fog.dart';
import 'cards/main.dart';
import 'cards/variant.dart';

void showModelSelectionSheet({
  required BuildContext context,
  required AppLocalizations localizations,
  required String currentModelId,
  required ValueChanged<String> onModelSelected,
}) {
  FocusScope.of(context).unfocus();

  final modelService = context.read<ModelService>();
  final localStateProvider = context.read<ModelLocalStateProvider>();

  // Sync access for instant load check
  final cachedModels = modelService.getCachedModelsSync();
  final downloadMap = localStateProvider.downloadCompleted;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: false,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
    ),
    builder: (BuildContext modalContext) {
      return _ModelSheetContent(
        localizations: localizations,
        currentModelId: currentModelId,
        onModelSelected: onModelSelected,
        initialModels: cachedModels,
        downloadMap: downloadMap,
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
    } else {
      _fetchAsync();
    }
  }

  void _processData(List<ModelEntity> models) {
    final self = <ModelEntity>[];
    final offline = <ModelEntity>[];
    final character = <ModelEntity>[];
    final online = <ModelEntity>[];

    for (var m in models) {
      if (m.category == 'self') {
        self.add(m);
      } else if (m.category == 'roleplay') {
        character.add(m);
      } else if (m.type == 'offline') {
        if (widget.downloadMap[m.id] == true) {
          offline.add(m);
        }
      } else if (m.type == 'online') {
        online.add(m);
      }
    }

    online.sort((a, b) => a.displayTitle.compareTo(b.displayTitle));

    _selfModels = self;
    _offlineModels = offline;
    _characterModels = character;
    _onlineSeries = online;
  }

  Future<void> _fetchAsync() async {
    if (!mounted) return;
    final modelService = context.read<ModelService>();
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
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
    final mediaQuery = MediaQuery.of(context);
    sw = mediaQuery.size.width;
    sh = mediaQuery.size.height;

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

  void _handleSelection(String modelId) {
    widget.onModelSelected(modelId);
    Navigator.pop(context);
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
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Center(
                          child: Text(
                            widget.localizations.allModels,
                            style: TextStyle(
                              fontFamily: 'Roboto',
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
                  duration: const Duration(milliseconds: 500),
                  switchInCurve: Curves.easeOutQuart,
                  switchOutCurve: Curves.easeInQuart,
                  transitionBuilder: (Widget child,
                      Animation<double> animation) {
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
                        _buildSliverHeader(
                            widget.localizations.dynamicChatTitle),
                        SliverPadding(
                          padding: EdgeInsets.symmetric(horizontal: sp16),
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
                                      Colors.blueAccent.withValues(
                                          alpha: 0.0),
                                      Colors.blueAccent.withValues(
                                          alpha: 0.2),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        if (_selfModels.isNotEmpty) ...[
                          _buildSliverHeader(
                              widget.localizations.customModels),
                          _buildSliverGrid(_selfModels),
                        ],
                        if (_offlineModels.isNotEmpty) ...[
                          _buildSliverHeader(
                              widget.localizations.offlineModels),
                          _buildSliverGrid(_offlineModels),
                        ],
                        if (_onlineSeries.isNotEmpty) ...[
                          _buildSliverHeader(
                              widget.localizations.onlineModels),
                          _buildSliverOnlineList(),
                        ],
                        if (_characterModels.isNotEmpty) ...[
                          _buildSliverHeader(
                              widget.localizations.characterModels),
                          _buildSliverGrid(_characterModels),
                        ],

                        SliverPadding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery
                                .of(context)
                                .padding
                                .bottom +
                                20,
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
                  fontFamily: 'Roboto',
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

  Widget _buildSliverOnlineList() {
    final int rowCount = (_onlineSeries.length / 2).ceil();

    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sp16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final int itemIndex = index * 2;
            final item1 = _onlineSeries[itemIndex];
            final item2 = (itemIndex + 1 < _onlineSeries.length)
                ? _onlineSeries[itemIndex + 1]
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

    final List<Map<String, dynamic>> variants = variantsMap.entries.map((e) {
      if (e.value is Map<String, dynamic>) {
        return e.value as Map<String, dynamic>;
      }
      return {'id': e.key, 'title': e.key};
    }).toList();

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
                "${seriesModel.displayTitle} ${localizations.variants}",
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