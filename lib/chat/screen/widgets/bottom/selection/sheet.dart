// lib/chat/screen/widgets/bottom/selection/sheet.dart

import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../app.dart';
import '../../../../../library/providers/local.dart';
import '../../../../../../fog.dart';
import 'cards/main.dart';
import 'cards/variant.dart';

enum ModelCategory { self, offline, online, roleplay }

void showModelSelectionSheet({
  required BuildContext context,
  required AppLocalizations localizations,
  required String currentModelId,
  required ValueChanged<String> onModelSelected,
}) {
  FocusScope.of(context).unfocus();

  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;
  final double topRadius = mediaQuery.size.width * 0.07;

  final modelService = Provider.of<ModelService>(context, listen: false);
  final localStateProvider = Provider.of<ModelLocalStateProvider>(
      context, listen: false);

  final cachedModels = modelService.getCachedModelsSync();
  final downloadMap = localStateProvider.downloadCompleted;

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxWidth: double.infinity,
      maxHeight: screenHeight * 0.85,
    ),
    builder: (BuildContext modalContext) {
      return _ModelSheetContent(
        localizations: localizations,
        currentModelId: currentModelId,
        onModelSelected: onModelSelected,
        topRadius: topRadius,
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
  final double topRadius;
  final List<ModelEntity>? initialModels;
  final Map<String, bool> downloadMap;

  const _ModelSheetContent({
    required this.localizations,
    required this.currentModelId,
    required this.onModelSelected,
    required this.topRadius,
    required this.initialModels,
    required this.downloadMap,
  });

  @override
  State<_ModelSheetContent> createState() => _ModelSheetContentState();
}

class _ModelSheetContentState extends State<_ModelSheetContent>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _entryController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Data Lists
  List<ModelEntity> _selfModels = [];
  List<ModelEntity> _offlineModels = [];
  List<ModelEntity> _onlineSeries = [];
  List<ModelEntity> _characterModels = [];

  bool _isLoading = true;
  String? _expandedSeriesId;

  // --- Dynamic Dimension Holders ---
  late double sw;
  late double sh;
  late double sp16;
  late double sp12;
  late double sp8;
  late double iconSize;
  late double titleSize;
  late double categoryTitleSize;

  @override
  void initState() {
    super.initState();

    if (widget.initialModels != null && widget.initialModels!.isNotEmpty) {
      _processInitialData(widget.initialModels!);
      _isLoading = false;
    } else {
      _fetchAsync();
    }

    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeOutCubic,
    ));

    if (!_isLoading) {
      _entryController.forward();
    }
  }

  void _processInitialData(List<ModelEntity> models) {
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
    final modelService = Provider.of<ModelService>(context, listen: false);
    final langCode = Localizations
        .localeOf(context)
        .languageCode;
    final models = await modelService.getModels(langCode: langCode);

    if (mounted && models != null) {
      setState(() {
        _processInitialData(models);
        _isLoading = false;
      });
      _entryController.forward();
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
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _entryController.dispose();
    super.dispose();
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

  double _calculateMainCardAspectRatio() {
    final gridWidth = sw - (2 * sp16);
    final itemWidth = (gridWidth - sp12) / 2;
    final desiredHeight = sh * 0.075;
    return itemWidth / desiredHeight;
  }

  @override
  Widget build(BuildContext context) {
    final double mainAspectRatio = _calculateMainCardAspectRatio();

    return Material(
      color: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
            top: Radius.circular(widget.topRadius)),
        side: BorderSide(color: AppColors.border, width: 1.0),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Drag Handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: sh * 0.015),
            child: Container(
              width: sw * 0.12,
              height: sh * 0.005,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.only(bottom: sh * 0.02),
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

          // Content
          Expanded(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryColor.inverted,
              ),
            )
                : FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ScrollFog(
                  scrollController: _scrollController,
                  fogColor: AppColors.background,
                  topFogHeight: sh * 0.03,
                  bottomFogHeight: sh * 0.06,
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      if (_selfModels.isNotEmpty) ...[
                        _buildSliverHeader(widget.localizations.customModels),
                        _buildSliverGrid(_selfModels, mainAspectRatio),
                      ],
                      if (_offlineModels.isNotEmpty) ...[
                        _buildSliverHeader(widget.localizations.offlineModels),
                        _buildSliverGrid(_offlineModels, mainAspectRatio),
                      ],
                      if (_onlineSeries.isNotEmpty) ...[
                        _buildSliverHeader(widget.localizations.onlineModels),
                        _buildSliverOnlineList(mainAspectRatio),
                      ],
                      if (_characterModels.isNotEmpty) ...[
                        _buildSliverHeader(widget.localizations
                            .characterModels),
                        _buildSliverGrid(_characterModels, mainAspectRatio),
                      ],
                      SliverPadding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery
                              .of(context)
                              .padding
                              .bottom + (sh * 0.05),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Sliver Components ---

  Widget _buildSliverHeader(String title) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: sp16, vertical: sh * 0.02),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
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
            Expanded(
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverGrid(List<ModelEntity> models, double aspectRatio) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: sp16),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: aspectRatio,
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
              onArrowTap: null,
            );
          },
          childCount: models.length,
        ),
      ),
    );
  }

  Widget _buildSliverOnlineList(double mainAspectRatio) {
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

            final bool isItem1Selected = widget.currentModelId == item1.id ||
                widget.currentModelId.startsWith('${item1.id}-');

            final bool isItem2Selected = item2 != null &&
                (widget.currentModelId == item2.id ||
                    widget.currentModelId.startsWith('${item2.id}-'));

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Two Main Cards
                Padding(
                  padding: EdgeInsets.only(bottom: sp12),
                  child: SizedBox(
                    height: (sw - (2 * sp16) - sp12) / 2 / mainAspectRatio,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ModelCard(
                            title: item1.displayTitle,
                            imagePath: item1.imagePath ?? '',
                            isSelected: isItem1Selected,
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
                            isSelected: isItem2Selected,
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
                _buildVariantsPanel(item1, isVisible: isItem1Expanded),
                if (item2 != null)
                  _buildVariantsPanel(item2, isVisible: isItem2Expanded),
              ],
            );
          },
          childCount: rowCount,
        ),
      ),
    );
  }

  Widget _buildVariantsPanel(ModelEntity seriesModel,
      {required bool isVisible}) {
    final variantsMap = seriesModel.variants ?? {};
    if (variantsMap.isEmpty) return const SizedBox.shrink();

    final List<Map<String, dynamic>> variants = variantsMap.entries.map((e) {
      if (e.value is Map<String, dynamic>) {
        return e.value as Map<String, dynamic>;
      }
      return {'id': e.key, 'title': e.key};
    }).toList();

    final gridWidth = sw - (2 * sp16) - (2 * sp16);
    final itemWidth = (gridWidth - sp8) / 2;
    final itemHeight = sh * 0.055;
    final variantRatio = itemWidth / itemHeight;

    return AnimatedCrossFade(
      firstChild: const SizedBox(width: double.infinity),
      secondChild: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: sp16),
        padding: EdgeInsets.all(sp16),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(sw * 0.05),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: sw * 0.025,
              offset: Offset(0, sw * 0.01),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/route.svg',
                  width: iconSize * 0.8,
                  height: iconSize * 0.8,
                  colorFilter: ColorFilter.mode(
                      AppColors.tertiaryColor, BlendMode.srcIn),
                ),
                SizedBox(width: sp8),
                Text(
                  "${seriesModel.displayTitle} ${widget.localizations
                      .variants}",
                  style: TextStyle(
                      fontSize: categoryTitleSize * 0.8,
                      color: AppColors.tertiaryColor,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: sp8),
              child: Text(
                widget.localizations.variantsDescription,
                style: TextStyle(
                  fontSize: categoryTitleSize * 0.75,
                  fontStyle: FontStyle.normal,
                  color: AppColors.tertiaryColor.withValues(alpha: 0.8),
                  height: 1.3,
                ),
              ),
            ),
            SizedBox(height: sp8),
            GridView.builder(
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
                final bool isSelected = widget.currentModelId == id;

                return ModelVariantCard(
                  title: title,
                  isSelected: isSelected,
                  isPremium: isPremium,
                  onTap: () => _handleSelection(id),
                );
              },
            ),
          ],
        ),
      ),
      crossFadeState:
      isVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 350),
      sizeCurve: Curves.easeInOutCubic,
      alignment: Alignment.topCenter,
    );
  }
}