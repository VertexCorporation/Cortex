// lib/screens/models/screen/new/widgets/selector.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/data/service.dart';
import '../../../utils.dart';
import '../../../../../server/user.dart';
import '../../../../../login/upgrade.dart';
import '../../../../../navigation.dart';

/// A widget for selecting a base model, used in the 'Create' (roleplay) screen.
class BaseModelSelector extends StatefulWidget {
  final List<ModelEntity> availableBaseModels;
  final String? selectedBaseModelId;
  final String? selectedBaseModelDisplayTitle;
  final bool isPanelExpanded;
  final VoidCallback onTogglePanel;
  final Function(String id, String title) onSelectBaseModel;

  const BaseModelSelector({
    super.key,
    required this.availableBaseModels,
    required this.selectedBaseModelId,
    required this.selectedBaseModelDisplayTitle,
    required this.isPanelExpanded,
    required this.onTogglePanel,
    required this.onSelectBaseModel,
  });

  @override
  State<BaseModelSelector> createState() => _BaseModelSelectorState();
}

class _BaseModelSelectorState extends State<BaseModelSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(
          () => _searchQuery = _searchController.text.toLowerCase().trim());
    });
  }

  @override
  void didUpdateWidget(BaseModelSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Clear search when the panel collapses
    if (!widget.isPanelExpanded && oldWidget.isPanelExpanded) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ModelEntity> _filter(List<ModelEntity> list) {
    if (_searchQuery.isEmpty) return list;
    return list.where((series) {
      final seriesTitle = (series.series ?? series.displayTitle).toLowerCase();
      if (seriesTitle.contains(_searchQuery)) return true;
      if (series.variants != null) {
        return series.variants!.values.whereType<Map<String, dynamic>>().any(
            (v) => (v['title'] as String? ?? '')
                .toLowerCase()
                .contains(_searchQuery));
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final modelService = context.read<ModelService>();
    final bool isTablet = screenWidth >= 600;

    // --- DYNAMIC DIMENSIONS ---
    final double titleSize = isTablet ? 26.0 : screenWidth * 0.05;
    final double descSize = isTablet ? 18.0 : screenWidth * 0.035;
    final double textSize = isTablet ? 20.0 : screenWidth * 0.04;
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.03;
    final double iconSize = isTablet ? 28.0 : screenWidth * 0.05;
    final double paddingV = isTablet ? 20.0 : screenWidth * 0.035;
    final double paddingH = isTablet ? 24.0 : screenWidth * 0.04;

    if (widget.availableBaseModels.isEmpty) {
      return Container(
        padding: EdgeInsets.all(paddingH),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        ),
        child: Text(
          localizations.noMatchingModels,
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.quinaryColor, fontSize: textSize),
        ),
      );
    }

    bool isCurrentlySelectedPremium = false;
    if (widget.selectedBaseModelId != null) {
      for (var series in widget.availableBaseModels) {
        if (series.variants?.containsKey(widget.selectedBaseModelId) ?? false) {
          final variantData = series.variants![widget.selectedBaseModelId]!;
          isCurrentlySelectedPremium =
              (variantData['tier'] as String? ?? 'free') == 'premium';
          break;
        } else if (series.id == widget.selectedBaseModelId) {
          isCurrentlySelectedPremium = series.tier == 'premium';
          break;
        }
      }
    }

    final filteredModels = _filter(widget.availableBaseModels);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title & Description ---
        Text(localizations.baseModelTitle,
            style: TextStyle(
                color: AppColors.primaryColor.inverted,
                fontSize: titleSize,
                fontWeight: FontWeight.w600)),
        SizedBox(height: screenWidth * 0.015),
        Text(localizations.baseModelDescription,
            style:
                TextStyle(color: AppColors.quinaryColor, fontSize: descSize)),
        SizedBox(height: screenWidth * 0.04),

        // --- Selection Button (Fixed to Cortex) ---
        Material(
          color: AppColors.secondaryColor.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(borderRadius),
          child: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: paddingH, vertical: paddingV),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.selectedBaseModelDisplayTitle ??
                        localizations.selectBaseModel,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted
                            .withValues(alpha: 0.5),
                        fontSize: textSize),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isCurrentlySelectedPremium)
                  Padding(
                    padding: EdgeInsets.only(
                        right: isTablet ? 12.0 : screenWidth * 0.02),
                    child: SvgPicture.asset(
                      'assets/icons/sparkle.svg',
                      width: iconSize,
                      colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted
                              .withValues(alpha: 0.5),
                          BlendMode.srcIn),
                    ),
                  ),
                Icon(Icons.lock_outline,
                    color:
                        AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                    size: isTablet ? 24 : screenWidth * 0.05),
              ],
            ),
          ),
        ),

        // --- Expandable List Panel ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: widget.isPanelExpanded
              ? _buildBaseModelList(context, modelService, borderRadius,
                  textSize, isTablet, filteredModels, localizations)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Builds the list of selectable base models.
  Widget _buildBaseModelList(
    BuildContext context,
    ModelService modelService,
    double radius,
    double textSize,
    bool isTablet,
    List<ModelEntity> filteredModels,
    AppLocalizations localizations,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    final double listHeight = isTablet ? 350.0 : screenWidth * 0.65;
    final double avatarSize = isTablet ? 56.0 : screenWidth * 0.11;
    final double itemVerticalPadding = isTablet ? 16.0 : screenWidth * 0.03;
    final double itemHorizontalPadding = isTablet ? 24.0 : screenWidth * 0.04;
    final double searchHeight = isTablet ? 52.0 : screenWidth * 0.115;
    final double sp12 = isTablet ? 12.0 : screenWidth * 0.03;
    final double sp8 = isTablet ? 8.0 : screenWidth * 0.02;

    Widget buildListItem(
        ModelEntity series, String modelId, String modelTitle, bool isPremium) {
      final imagePath = modelService.getModelImagePath(series);

      final bool isSvg = imagePath.endsWith('.svg');
      final bool isAsset = imagePath.startsWith('assets/');

      Widget imageWidget;
      if (isSvg) {
        imageWidget = Padding(
          padding: const EdgeInsets.all(2.0),
          child: SvgPicture.asset(
            imagePath,
            fit: BoxFit.contain,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted, BlendMode.srcIn),
          ),
        );
      } else {
        ImageProvider? provider;
        if (isAsset) {
          provider = AssetImage(imagePath);
        } else {
          provider = FileImage(File(imagePath));
        }
        imageWidget = CircleAvatar(
          backgroundImage: provider,
          backgroundColor: Colors.transparent,
          radius: avatarSize / 2,
        );
      }

      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            final userProvider = context.read<UserProvider>();
            if (modelId != 'cortex/auto' &&
                !userProvider.isSubscriptionActive) {
              final target = const UpgradeAccountScreen(showLoginFirst: false);
              navigateToScreen(target, direction: const Offset(0.0, 1.0));
              return;
            }
            widget.onSelectBaseModel(modelId, modelTitle);
          },
          splashFactory: NoSplash.splashFactory,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal: itemHorizontalPadding,
                vertical: itemVerticalPadding),
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: imageWidget,
                ),
                SizedBox(width: screenWidth * 0.04),
                Expanded(
                  child: Text(
                    modelTitle,
                    style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: textSize,
                        fontWeight: FontWeight.w500),
                  ),
                ),
                if (isPremium)
                  Padding(
                    padding: EdgeInsets.only(left: screenWidth * 0.02),
                    child: SvgPicture.asset(
                      'assets/icons/sparkle.svg',
                      width: screenWidth * 0.05,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.02),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Search bar inside the panel
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sp12, vertical: sp8),
              child: SizedBox(
                height: searchHeight,
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: textSize * 0.9,
                  ),
                  decoration: InputDecoration(
                    hintText: localizations.searchHint,
                    hintStyle: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: textSize * 0.9,
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: AppColors.tertiaryColor,
                      size: screenWidth * 0.05,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () => _searchController.clear(),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.tertiaryColor,
                              size: screenWidth * 0.045,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: sp12, vertical: sp8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(radius * 0.75),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            // Results list
            if (filteredModels.isEmpty)
              Padding(
                padding: EdgeInsets.all(itemHorizontalPadding),
                child: Text(
                  localizations.noMatchingModels,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.quinaryColor, fontSize: textSize),
                ),
              )
            else
              SizedBox(
                height: listHeight,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: filteredModels.expand<Widget>((series) {
                    final Map<String, dynamic> variants =
                        series.variants ?? const {};

                    if (variants.isNotEmpty) {
                      return variants.entries.map((ext) {
                        final modelId = ext.key;
                        final variantData =
                            ext.value as Map<String, dynamic>? ?? {};
                        var modelTitle =
                            variantData['title'] as String? ?? modelId;
                        modelTitle = ModelDataUtils.cleanTitle(modelTitle);
                        final isVariantPremium =
                            (variantData['tier'] as String? ?? 'free') ==
                                'premium';
                        return buildListItem(
                            series, modelId, modelTitle, isVariantPremium);
                      }).toList();
                    } else {
                      final modelId = series.id;
                      final modelTitle =
                          ModelDataUtils.cleanTitle(series.displayTitle);
                      final isPremium = series.tier == 'premium';
                      return [
                        buildListItem(series, modelId, modelTitle, isPremium)
                      ];
                    }
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
