// lib/library/screen/model/widgets/sections.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/data/service.dart';
import '../../../providers/details.dart';
import '../../../utils.dart';

//================================================================================
// Section Widgets
// This file contains all the individual content sections for the Model Detail Body.
//================================================================================

/// A generic container for styling each section uniformly.
class SectionContainer extends StatelessWidget {
  final Widget child;
  const SectionContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: child,
    );
  }
}

/// A generic title widget for each section.
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Text(
      title,
      style: TextStyle(
        color: AppColors.primaryColor.inverted,
        fontSize: screenWidth * 0.05,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

/// Displays the model's summary.
class SummarySection extends StatelessWidget {
  final ModelDetailProvider provider;
  const SummarySection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: localizations.summary),
          SizedBox(height: screenWidth * 0.02),
          Text(
            provider.displaySummary,
            style: TextStyle(
              color: AppColors.quinaryColor,
              fontSize: screenWidth * 0.04,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Displays the model's description with an expandable/collapsible view.
class DescriptionSection extends StatelessWidget {
  final ModelDetailProvider provider;
  const DescriptionSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final fullDescription = provider.displayDescription;

    const collapsedHeight = 100.0;
    final textStyle = TextStyle(
        color: AppColors.quinaryColor,
        fontSize: screenWidth * 0.04,
        height: 1.6);

    final textPainter = TextPainter(
      text: TextSpan(text: fullDescription, style: textStyle),
      maxLines: null,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: screenWidth - (screenWidth * 0.16));

    final bool isOverflowing = textPainter.size.height > collapsedHeight;
    final isExpanded = provider.isDescriptionExpanded;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SectionTitle(title: localizations.descriptionSection),
              if (isOverflowing)
                InkWell(
                  onTap: provider.toggleDescriptionExpanded,
                  borderRadius: BorderRadius.circular(100),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 200),
                      child: SvgPicture.asset(
                        'assets/icons/arrov.svg',
                        width: screenWidth * 0.06,
                        height: screenWidth * 0.06,
                        colorFilter: ColorFilter.mode(AppColors.quinaryColor, BlendMode.srcIn),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: screenWidth * 0.02),
          AnimatedSize(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            alignment: Alignment.topCenter,
            child: AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: _ParsedText(
                fullText: fullDescription,
                style: textStyle,
                maxLines: 4,
              ),
              secondChild: _ParsedText(
                fullText: fullDescription,
                style: textStyle,
                maxLines: null,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A helper widget to parse and display text with embedded markdown-style links AND bold text.
class _ParsedText extends StatelessWidget {
  final String fullText;
  final TextStyle style;
  final int? maxLines;
  final TextOverflow overflow;

  const _ParsedText({
    required this.fullText,
    required this.style,
    this.maxLines,
    this.overflow = TextOverflow.clip,
  });

  @override
  Widget build(BuildContext context) {
    // Styles
    final linkStyle = style.copyWith(color: AppColors.senaryColor, fontWeight: FontWeight.w600);

    final boldStyle = style.copyWith(fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted);

    // Regex to capture:
    // 1. **Bold** -> (\*\*(.*?)\*\*)
    // 2. [Label](url) -> (\[([^\]]+)\]\(([^)]+)\))
    // 3. Raw URL -> (https?://\S+)
    final combinedRegExp = RegExp(r'(\*\*(.*?)\*\*)|(\[([^\]]+)\]\(([^)]+)\))|(https?://\S+)');

    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final match in combinedRegExp.allMatches(fullText)) {
      // Add plain text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: fullText.substring(lastEnd, match.start), style: style));
      }

      final String matchText = match.group(0)!;

      if (matchText.startsWith('**')) {
        // --- BOLD HANDLING ---
        // Group 2 contains the text inside **...**
        final content = match.group(2) ?? "";
        spans.add(TextSpan(text: content, style: boldStyle));

      } else if (matchText.startsWith('[')) {
        // --- MARKDOWN LINK HANDLING ---
        // Group 4 is label, Group 5 is URL
        final label = match.group(4) ?? "";
        final href = match.group(5) ?? "";

        spans.add(TextSpan(
            text: label,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async => _launchUrl(href)
        ));

      } else {
        // --- RAW URL HANDLING ---
        // Group 6 is the raw URL
        final url = match.group(6) ?? matchText;
        spans.add(TextSpan(
            text: url,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async => _launchUrl(url)
        ));
      }

      lastEnd = match.end;
    }

    // Add remaining plain text
    if (lastEnd < fullText.length) {
      spans.add(TextSpan(text: fullText.substring(lastEnd), style: style));
    }

    // Using Text.rich allows for better handling of maxLines and overflow compared to RichText
    return Text.rich(
      TextSpan(children: spans),
      maxLines: maxLines,
      overflow: overflow,
      softWrap: true,
    );
  }

  Future<void> _launchUrl(String href) async {
    try {
      final uri = Uri.tryParse(href);
      if (uri != null && await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("[_ParsedText] Could not launch URL: $href");
      }
    } catch (e) {
      debugPrint("[_ParsedText] Error launching URL: $e");
    }
  }
}

/// Displays the base model selection UI for custom models.
class BaseModelSelectionSection extends StatelessWidget {
  final ModelDetailProvider provider;
  const BaseModelSelectionSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    if (provider.availableBaseModels.isEmpty) return const SizedBox.shrink();

    final rawSelectedTitle = provider.selectedBaseModel?.displayTitle;
    final selectedModelTitle =
    (rawSelectedTitle == null || rawSelectedTitle.trim().isEmpty)
        ? localizations.selectBaseModel
        : ModelDataUtils.cleanTitle(rawSelectedTitle);
    final isPremium = provider.selectedBaseModel?.isPremium ?? false;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: localizations.baseModelTitle),
          SizedBox(height: screenWidth * 0.01),
          Text(
            localizations.baseModelForCharacterDescription,
            style: TextStyle(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
          ),
          SizedBox(height: screenWidth * 0.02),
          Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(screenWidth * 0.02),
            child: InkWell(
              onTap: provider.toggleBaseModelPanelExpanded,
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.03),
                child: Row(
                  children: [
                    Expanded(child: Text(selectedModelTitle, style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04), overflow: TextOverflow.ellipsis)),
                    if (isPremium)
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: SvgPicture.asset('assets/icons/sparkle.svg', width: screenWidth * 0.05, colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha:0.8), BlendMode.srcIn)),
                      ),
                    AnimatedRotation(
                      turns: provider.isBaseModelPanelExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(Icons.keyboard_arrow_down, color: AppColors.primaryColor.inverted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: provider.isBaseModelPanelExpanded
                ? _buildBaseModelList(context, context.read<ModelService>())
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of selectable base models.
  Widget _buildBaseModelList(BuildContext context, ModelService modelService) {
    final screenWidth = MediaQuery.of(context).size.width;
    final langCode = Localizations.localeOf(context).languageCode;

    final List<Widget> variantListTiles = [];

    for (final series in provider.availableBaseModels) {
      final extensions = series.extensions;
      if (extensions == null || extensions.isEmpty) {
        continue;
      }

      for (final entry in extensions.entries) {
        final variantId = entry.key;
        if (entry.value is Map<String, dynamic>) {
          final variantData = entry.value as Map<String, dynamic>;
          final variantEntity = ModelEntity.fromMap(variantData, langCode);

          final rawTitle = variantEntity.displayTitle;
          final cleanedTitle = ModelDataUtils.cleanTitle(rawTitle);

          final imagePath = modelService.getModelImagePath(series);
          final imageProvider = imagePath.startsWith('assets/')
              ? AssetImage(imagePath) as ImageProvider
              : FileImage(File(imagePath));

          variantListTiles.add(
            ListTile(
              leading: CircleAvatar(
                backgroundImage: imageProvider,
                backgroundColor: Colors.transparent,
              ),
              title: Text(
                cleanedTitle,
                style: TextStyle(color: AppColors.primaryColor.inverted),
              ),
              trailing: variantEntity.isPremium
                  ? SvgPicture.asset(
                  'assets/icons/sparkle.svg', width: screenWidth * 0.05,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted.withValues(alpha:0.8),
                      BlendMode.srcIn))
                  : null,
              onTap: () => provider.selectBaseModel(context, variantId),
            ),
          );
        }
      }
    }

    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.02),
      height: MediaQuery.of(context).size.height * 0.25,
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha:0.5),
        borderRadius: BorderRadius.circular(screenWidth * 0.02),
      ),
      child: ListView(
        shrinkWrap: true,
        children: variantListTiles,
      ),
    );
  }
}

/// Displays the list of features/capabilities for the model.
class FeaturesSection extends StatelessWidget {
  final ModelDetailProvider provider;
  const FeaturesSection({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;

    final featureDetails = {
      'photo': [localizations.featurePhotoTitle, localizations.featurePhotoDescription],
      'offline': [localizations.featureOfflineTitle, localizations.featureOfflineDescription],
      'roleplay': [localizations.featureRoleplayTitle, localizations.featureRoleplayDescription],
      'plural': [localizations.featurePluralTitle, localizations.featurePluralDescription],
      'document': [localizations.featureDocumentTitle, localizations.featureDocumentDescription],
      'audio': [localizations.featureAudioTitle, localizations.featureAudioDescription],
      'image_generation': [localizations.featureImageGenerationTitle, localizations.featureImageGenerationDescription],
    };

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: localizations.capabilitiesSection),
          SizedBox(height: screenWidth * 0.02),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: provider.parsedFeatures.length,
            separatorBuilder: (_, __) => Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
              child: Divider(color: AppColors.border, thickness: 1),
            ),
            itemBuilder: (context, index) {
              final featureKey = provider.parsedFeatures[index];
              final details = featureDetails[featureKey];
              if (details == null) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(details[0], style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.04, fontWeight: FontWeight.w500)),
                  SizedBox(height: screenWidth * 0.01),
                  Text(details[1], style: TextStyle(color: AppColors.quinaryColor, fontSize: screenWidth * 0.035)),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}