// lib/screens/models/screen/new/widgets/selector.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/data/service.dart';
import '../../../utils.dart';

/// A widget for selecting a base model, used in the 'Create' (roleplay) screen.
///
/// This widget displays the currently selected base model and provides an
/// expandable panel to choose from a list of available models. It is a
/// stateless widget that gets all its data and state (like `isPanelExpanded`)
/// from a parent provider.
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

    if (availableBaseModels.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
          border: Border.all(color: AppColors.border.withValues(alpha:0.5)),
        ),
        child: Text(
          localizations.noMatchingModels,
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.038),
        ),
      );
    }

    bool isCurrentlySelectedPremium = false;
    if (selectedBaseModelId != null) {
      for (var series in availableBaseModels) {
        if (series.extensions?.containsKey(selectedBaseModelId) ?? false) {
          final variantData = series.extensions![selectedBaseModelId]!;
          isCurrentlySelectedPremium = (variantData['tier'] as String? ?? 'free') == 'premium';
          break;
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Section Title & Description ---
        Text(localizations.baseModelTitle, style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.w600)),
        const SizedBox(height: 5),
        Text(localizations.baseModelDescription, style: GoogleFonts.roboto(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
        const SizedBox(height: 15),

        // --- Selection Button ---
        Material(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(screenWidth * 0.025),
          child: InkWell(
            onTap: onTogglePanel,
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 15),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedBaseModelDisplayTitle ?? localizations.selectBaseModel,
                      style: GoogleFonts.roboto(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isCurrentlySelectedPremium)
                    Padding(
                      padding: EdgeInsets.only(right: screenWidth * 0.02),
                      child: SvgPicture.asset(
                        'assets/icons/sparkle.svg',
                        width: screenWidth * 0.05,
                        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha:0.8), BlendMode.srcIn),
                      ),
                    ),
                  AnimatedRotation(
                    turns: isPanelExpanded ? 0.5 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor.inverted),
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
              ? _buildBaseModelList(context, modelService)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  /// Builds the list of selectable base models.
  Widget _buildBaseModelList(BuildContext context, ModelService modelService) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.025),
      ),
      child: ListView(
        padding: EdgeInsets.zero,
        children: availableBaseModels.expand<Widget>((series) {
          // Safely default to empty map
          final Map<String, dynamic> extensions =
              series.extensions ?? const {};

          if (extensions.isEmpty) return [];

          return extensions.entries.map((ext) {
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

            return ListTile(
              leading: CircleAvatar(
                backgroundImage: imageProvider,
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                modelTitle,
                style: TextStyle(color: AppColors.primaryColor.inverted),
              ),
              trailing: isVariantPremium
                  ? SvgPicture.asset(
                'assets/icons/sparkle.svg',
                width: screenWidth * 0.05,
                colorFilter: ColorFilter.mode(
                  AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                  BlendMode.srcIn,
                ),
              )
                  : null,
              onTap: () => onSelectBaseModel(modelId, modelTitle),
            );
          }).toList();
        }).toList(),
      ),
    );
  }
}