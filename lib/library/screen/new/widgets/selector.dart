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
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;
    final modelService = context.read<ModelService>();
    final bool isTablet = screenWidth >= 600;

    // --- TABLET OPTIMIZATIONS ---
    final double titleSize = isTablet ? 26.0 : screenWidth * 0.05;
    final double descSize = isTablet ? 18.0 : screenWidth * 0.035;
    final double textSize = isTablet ? 20.0 : screenWidth * 0.04;
    final double borderRadius = isTablet ? 16.0 : screenWidth * 0.025;
    final double iconSize = isTablet ? 28.0 : screenWidth * 0.05;
    final double paddingV = isTablet ? 20.0 : 15.0;
    final double paddingH = isTablet ? 24.0 : screenWidth * 0.04;

    if (availableBaseModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        const SizedBox(height: 5),
        Text(localizations.baseModelDescription,
            style:
                TextStyle(color: AppColors.quinaryColor, fontSize: descSize)),
        const SizedBox(height: 15),

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
                        size: isTablet ? 32 : 24),
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
                  iconSize, textSize, isTablet)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Builds the list of selectable base models.
  Widget _buildBaseModelList(BuildContext context, ModelService modelService,
      double radius, double iconSize, double textSize, bool isTablet) {
    // List Layout Constants
    final double listHeight = isTablet ? 350.0 : 250.0;
    final double avatarRadius = isTablet ? 28.0 : 20.0;
    final double itemVerticalPadding = isTablet ? 16.0 : 12.0;
    final double itemHorizontalPadding = isTablet ? 24.0 : 16.0;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: listHeight,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(radius),
      ),
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
            final imageProvider = imagePath.startsWith('assets/')
                ? AssetImage(imagePath) as ImageProvider
                : FileImage(File(imagePath));

            final isVariantPremium =
                (variantData['tier'] as String? ?? 'free') == 'premium';

            // REPLACED ListTile WITH CUSTOM INKWELL TO KILL THE WHITE HIGHLIGHT
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSelectBaseModel(modelId, modelTitle);
                },
                // CRITICAL: All splash and highlight colors set to transparent
                splashFactory: NoSplash.splashFactory,
                splashColor: Colors.transparent,
                highlightColor:
                    Colors.transparent, // This kills the white light
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,

                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: itemHorizontalPadding,
                      vertical: itemVerticalPadding),
                  child: Row(
                    children: [
                      // Leading: Avatar
                      CircleAvatar(
                        backgroundImage: imageProvider,
                        backgroundColor: Colors.transparent,
                        radius: avatarRadius,
                      ),

                      SizedBox(width: isTablet ? 24.0 : 16.0), // Gap

                      // Title
                      Expanded(
                        child: Text(
                          modelTitle,
                          style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: textSize),
                        ),
                      ),

                      // Trailing: Sparkle Icon (if premium)
                      if (isVariantPremium)
                        SvgPicture.asset(
                          'assets/icons/sparkle.svg',
                          width: iconSize,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted
                                .withValues(alpha: 0.8),
                            BlendMode.srcIn,
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
    );
  }
}
