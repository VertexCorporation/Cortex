// lib/screens/models/screen/new/widgets/selector.dart

import 'package:universal_io/io.dart';
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

/// A widget for selecting a base model, used in the 'Create' (roleplay) screen.
class BaseModelSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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

    if (availableBaseModels.isEmpty) {
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
    if (selectedBaseModelId != null) {
      for (var series in availableBaseModels) {
        if (series.variants?.containsKey(selectedBaseModelId) ?? false) {
          final variantData = series.variants![selectedBaseModelId]!;
          isCurrentlySelectedPremium =
              (variantData['tier'] as String? ?? 'free') == 'premium';
          break;
        }
      }
    }

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

        // --- Selection Button ---
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(borderRadius),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              onTogglePanel();
            },
            borderRadius: BorderRadius.circular(borderRadius),
            // Button Splash/Highlight Removal
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: paddingH, vertical: paddingV),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedBaseModelDisplayTitle ??
                          localizations.selectBaseModel,
                      style: TextStyle(
                          color: AppColors.primaryColor.inverted,
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
                                .withValues(alpha: 0.8),
                            BlendMode.srcIn),
                      ),
                    ),
                  AnimatedRotation(
                    turns: isPanelExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down,
                        color: AppColors.primaryColor.inverted,
                        size: isTablet ? 32 : screenWidth * 0.06),
                  ),
                ],
              ),
            ),
          ),
        ),

        // --- Expandable List Panel ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: isPanelExpanded
              ? _buildBaseModelList(context, modelService, borderRadius,
              textSize, isTablet)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Builds the list of selectable base models.
  Widget _buildBaseModelList(BuildContext context, ModelService modelService,
      double radius, double textSize, bool isTablet) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    // List Layout Constants
    final double listHeight = isTablet ? 350.0 : screenWidth * 0.65;
    // Avatar size relative to screen width (approx 40px-50px)
    final double avatarSize = isTablet ? 56.0 : screenWidth * 0.11;

    final double itemVerticalPadding = isTablet ? 16.0 : screenWidth * 0.03;
    final double itemHorizontalPadding = isTablet ? 24.0 : screenWidth * 0.04;

    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.02),
      height: listHeight,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ListView(
          padding: EdgeInsets.zero,
          children: availableBaseModels.expand<Widget>((series) {
            final Map<String, dynamic> variants = series.variants ?? const {};
            if (variants.isEmpty) return [];

            return variants.entries.map((ext) {
              final modelId = ext.key;
              final variantData = ext.value as Map<String, dynamic>? ?? {};
              var modelTitle = variantData['title'] as String? ?? modelId;
              modelTitle = ModelDataUtils.cleanTitle(modelTitle);

              final imagePath = modelService.getModelImagePath(series);

              // --- SVG CHECK LOGIC (Prevents Crashes) ---
              final bool isSvg = imagePath.endsWith('.svg');
              final bool isAsset = imagePath.startsWith('assets/');

              Widget imageWidget;
              if (isSvg) {
                // Safe rendering for SVGs (like cortex.svg)
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
                // Bitmap rendering
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
              // ------------------------------------------

              final isVariantPremium =
                  (variantData['tier'] as String? ?? 'free') == 'premium';

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    onSelectBaseModel(modelId, modelTitle);
                  },
                  // Clean look: No splash/highlight
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
                        // Leading: Avatar / Icon
                        Container(
                          width: avatarSize,
                          height: avatarSize,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle),
                          child: imageWidget,
                        ),

                        SizedBox(width: screenWidth * 0.04), // Gap

                        // Title
                        Expanded(
                          child: Text(
                            modelTitle,
                            style: TextStyle(
                                color: AppColors.primaryColor.inverted,
                                fontSize: textSize,
                                fontWeight: FontWeight.w500),
                          ),
                        ),

                        // Trailing: Sparkle Icon (if premium)
                        if (isVariantPremium)
                          Padding(
                            padding: EdgeInsets.only(left: screenWidth * 0.02),
                            child: SvgPicture.asset(
                              'assets/icons/sparkle.svg',
                              width: screenWidth * 0.05,
                              colorFilter: ColorFilter.mode(
                                AppColors.primaryColor.inverted
                                    .withValues(alpha: 0.8),
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList();
          }).toList(),
        ),
      ),
    );
  }
}