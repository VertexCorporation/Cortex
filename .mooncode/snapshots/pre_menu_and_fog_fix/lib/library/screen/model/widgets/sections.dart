// lib/library/screen/model/widgets/sections.dart

import 'dart:io';
import 'package:cortex/app.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../../l10n/app_localizations.dart';
import '../../../../../theme.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/data/service.dart';
import '../../../providers/details.dart';
import '../../../utils.dart';
import '../../../../../server/user.dart';
import '../../../../../navigation.dart';
import '../../../../../login/upgrade.dart';

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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

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
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final fullDescription = provider.displayDescription;

    final textStyle = TextStyle(
        color: AppColors.quinaryColor,
        fontSize: screenWidth * 0.04,
        height: 1.6);

    final textPainter = TextPainter(
      text: TextSpan(text: fullDescription, style: textStyle),
      maxLines: 4,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: screenWidth - (screenWidth * 0.16));

    final bool isOverflowing = textPainter.didExceedMaxLines;
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
                  onTap: () {
                    HapticFeedback.lightImpact();
                    provider.toggleDescriptionExpanded();
                  },
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
                        colorFilter: ColorFilter.mode(
                            AppColors.quinaryColor, BlendMode.srcIn),
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
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
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
    final linkStyle = style.copyWith(
        color: AppColors.senaryColor, fontWeight: FontWeight.w600);

    final boldStyle = style.copyWith(
        fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted);

    // Regex to capture:
    // 1. **Bold** -> (\*\*(.*?)\*\*)
    // 2. [Label](url) -> (\[([^\]]+)\]\(([^)]+)\))
    // 3. Raw URL -> (https?://\S+)
    final combinedRegExp =
    RegExp(r'(\*\*(.*?)\*\*)|(\*(.*?)\*(?!\*))|(\[([^\]]+)\]\(([^)]+)\))|(https?://\S+)');

    final spans = <TextSpan>[];
    int lastEnd = 0;

    final italicStyle = style.copyWith(
        fontStyle: FontStyle.italic, color: AppColors.primaryColor.inverted);

    for (final match in combinedRegExp.allMatches(fullText)) {
      // Add plain text before the match
      if (match.start > lastEnd) {
        spans.add(TextSpan(
            text: fullText.substring(lastEnd, match.start), style: style));
      }

      final String matchText = match.group(0)!;

      if (matchText.startsWith('**')) {
        // --- BOLD HANDLING ---
        // Group 2 contains the text inside **...**
        final content = match.group(2) ?? "";
        spans.add(TextSpan(text: content, style: boldStyle));
      } else if (matchText.startsWith('*') && !matchText.startsWith('**')) {
        // --- ITALIC HANDLING ---
        // Group 4 contains the text inside *...*
        final content = match.group(4) ?? "";
        spans.add(TextSpan(text: content, style: italicStyle));
      } else if (matchText.startsWith('[')) {
        // --- MARKDOWN LINK HANDLING ---
        // Group 4 is label, Group 5 is URL
        final label = match.group(4) ?? "";
        final href = match.group(5) ?? "";

        spans.add(TextSpan(
            text: label,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async => _launchUrl(href)));
      } else {
        // --- RAW URL HANDLING ---
        // Group 6 is the raw URL
        final url = match.group(6) ?? matchText;
        spans.add(TextSpan(
            text: url,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () async => _launchUrl(url)));
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
class BaseModelSelectionSection extends StatefulWidget {
  final ModelDetailProvider provider;

  const BaseModelSelectionSection({super.key, required this.provider});

  @override
  State<BaseModelSelectionSection> createState() =>
      _BaseModelSelectionSectionState();
}

class _BaseModelSelectionSectionState
    extends State<BaseModelSelectionSection> {
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
  void didUpdateWidget(BaseModelSelectionSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.provider.isBaseModelPanelExpanded &&
        oldWidget.provider.isBaseModelPanelExpanded) {
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    if (widget.provider.availableBaseModels.isEmpty) return const SizedBox.shrink();

    final rawSelectedTitle = widget.provider.selectedBaseModel?.displayTitle;
    final selectedModelTitle =
    (rawSelectedTitle == null || rawSelectedTitle
        .trim()
        .isEmpty)
        ? localizations.selectBaseModel
        : ModelDataUtils.cleanTitle(rawSelectedTitle);
    final isPremium = widget.provider.selectedBaseModel?.isPremium ?? false;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: localizations.baseModelTitle),
          SizedBox(height: screenWidth * 0.01),
          Text(
            localizations.baseModelForCharacterDescription,
            style: TextStyle(
                color: AppColors.quinaryColor, fontSize: screenWidth * 0.035),
          ),
          SizedBox(height: screenWidth * 0.02),
          Material(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                widget.provider.toggleBaseModelPanelExpanded();
              },
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.04,
                  vertical: screenWidth * 0.035,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedModelTitle,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: screenWidth * 0.042,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium)
                      Padding(
                        padding: EdgeInsets.only(right: screenWidth * 0.02),
                        child: SvgPicture.asset(
                          'assets/icons/sparkle.svg',
                          width: screenWidth * 0.05,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted.withValues(
                                alpha: 0.8),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    AnimatedRotation(
                      turns: widget.provider.isBaseModelPanelExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.primaryColor.inverted,
                        size: screenWidth * 0.06,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: widget.provider.isBaseModelPanelExpanded
                ? Padding(
                    padding: EdgeInsets.only(top: screenWidth * 0.02),
                    child: Column(
                      children: [
                        // Search bar
                        SizedBox(
                          height: screenWidth * 0.115,
                          child: TextField(
                            controller: _searchController,
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: screenWidth * 0.038,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)!.searchHint,
                              hintStyle: TextStyle(
                                  color: AppColors.tertiaryColor,
                                  fontSize: screenWidth * 0.038),
                              prefixIcon: Icon(Icons.search_rounded,
                                  color: AppColors.tertiaryColor,
                                  size: screenWidth * 0.05),
                              suffixIcon: _searchQuery.isNotEmpty
                                  ? GestureDetector(
                                      onTap: () => _searchController.clear(),
                                      child: Icon(Icons.close_rounded,
                                          color: AppColors.tertiaryColor,
                                          size: screenWidth * 0.045),
                                    )
                                  : null,
                              filled: true,
                              fillColor: AppColors.background,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.03,
                                  vertical: screenWidth * 0.02),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.circular(screenWidth * 0.03),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: screenWidth * 0.02),
                        _buildBaseModelList(
                            context, context.read<ModelService>()),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  /// Builds the list of selectable base models with search filter.
  Widget _buildBaseModelList(BuildContext context, ModelService modelService) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final langCode = Localizations.localeOf(context).languageCode;

    final List<Widget> variantListTiles = [];
    final double iconSize = screenWidth * 0.11;

    for (final series in widget.provider.availableBaseModels) {
      final variants = series.variants;
      if (variants == null || variants.isEmpty) continue;

      for (final entry in variants.entries) {
        final variantId = entry.key;
        if (entry.value is! Map<String, dynamic>) continue;

        final variantData = entry.value as Map<String, dynamic>;
        final variantEntity = ModelEntity.fromMap(variantData, langCode);
        final cleanedTitle =
            ModelDataUtils.cleanTitle(variantEntity.displayTitle);

        // Apply search filter
        if (_searchQuery.isNotEmpty &&
            !cleanedTitle.toLowerCase().contains(_searchQuery) &&
            !(series.series ?? series.displayTitle)
                .toLowerCase()
                .contains(_searchQuery)) {
          continue;
        }

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
          final ImageProvider imgProvider =
              isAsset ? AssetImage(imagePath) : FileImage(File(imagePath));
          imageWidget = CircleAvatar(
            radius: iconSize / 2,
            backgroundImage: imgProvider,
            backgroundColor: Colors.transparent,
          );
        }

        variantListTiles.add(
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                final userProvider = context.read<UserProvider>();
                if (variantId != 'cortex/auto' && !userProvider.isSubscriptionActive) {
                  final target = const UpgradeAccountScreen(showLoginFirst: false);
                  navigateToScreen(target, direction: const Offset(0.0, 1.0));
                  return;
                }
                widget.provider.selectBaseModel(context, variantId);
              },
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenWidth * 0.03,
                  vertical: screenWidth * 0.025,
                ),
                child: Row(
                  children: [
                    Container(
                      width: iconSize,
                      height: iconSize,
                      decoration: const BoxDecoration(shape: BoxShape.circle),
                      child: imageWidget,
                    ),
                    SizedBox(width: screenWidth * 0.04),
                    Expanded(
                      child: Text(
                        cleanedTitle,
                        style: TextStyle(
                          color: AppColors.primaryColor.inverted,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (variantEntity.isPremium)
                      Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.02),
                        child: SvgPicture.asset(
                          'assets/icons/sparkle.svg',
                          width: screenWidth * 0.05,
                          colorFilter: ColorFilter.mode(
                              AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.8),
                              BlendMode.srcIn),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    if (variantListTiles.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: screenWidth * 0.04),
        child: Center(
          child: Text(
            AppLocalizations.of(context)!.noMatchingModels,
            style: TextStyle(
                color: AppColors.quinaryColor, fontSize: screenWidth * 0.038),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
      ),
      constraints: BoxConstraints(maxHeight: screenHeight * 0.35),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: variantListTiles,
        ),
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
      'photo': [
        localizations.featurePhotoTitle,
        localizations.featurePhotoDescription
      ],
      'offline': [
        localizations.featureOfflineTitle,
        localizations.featureOfflineDescription
      ],
      'roleplay': [
        localizations.featureRoleplayTitle,
        localizations.featureRoleplayDescription
      ],
      'plural': [
        localizations.featurePluralTitle,
        localizations.featurePluralDescription
      ],
      'document': [
        localizations.featureDocumentTitle,
        localizations.featureDocumentDescription
      ],
      'audio_recognition': [
        localizations.featureAudioRecognitionTitle,
        localizations.featureAudioRecognitionDescription
      ],
      'video_recognition': [
        localizations.featureVideoRecognitionTitle,
        localizations.featureVideoRecognitionDescription
      ],
      'image_recognition': [
        localizations.featureImageRecognitionTitle,
        localizations.featureImageRecognitionDescription
      ],
      'image_generation': [
        localizations.featureImageGenerationTitle,
        localizations.featureImageGenerationDescription
      ],
      'audio_generation': [
        localizations.featureAudioGenerationTitle,
        localizations.featureAudioGenerationDescription
      ],
      'video_generation': [
        localizations.featureVideoGenerationTitle,
        localizations.featureVideoGenerationDescription
      ],
      'tool_use': [
        localizations.featureToolUseTitle,
        localizations.featureToolUseDescription
      ],
    };

    // Icon + colour per capability key
    const featureIcons = <String, IconData>{
      'photo': Icons.camera_alt_rounded,
      'offline': Icons.wifi_off_rounded,
      'roleplay': Icons.theater_comedy_rounded,
      'plural': Icons.forum_rounded,
      'document': Icons.description_rounded,
      'audio_recognition': Icons.hearing_rounded,
      'video_recognition': Icons.videocam_rounded,
      'image_recognition': Icons.image_search_rounded,
      'image_generation': Icons.auto_awesome_rounded,
      'audio_generation': Icons.graphic_eq_rounded,
      'video_generation': Icons.movie_creation_rounded,
      'tool_use': Icons.build_rounded,
    };

    const featureColors = <String, Color>{
      'photo': Color(0xFF5E99FF),
      'offline': Color(0xFF8E8E93),
      'roleplay': Color(0xFFFF6B9D),
      'plural': Color(0xFF34C759),
      'document': Color(0xFFFF9500),
      'audio_recognition': Color(0xFF30B0C7),
      'video_recognition': Color(0xFFAF52DE),
      'image_recognition': Color(0xFF5E99FF),
      'image_generation': Color(0xFFFF2D55),
      'audio_generation': Color(0xFF00C7BE),
      'video_generation': Color(0xFFFF6B00),
      'tool_use': Color(0xFF636366),
    };

    final validFeatures = provider.parsedFeatures
        .where((key) => featureDetails.containsKey(key))
        .toList();

    if (validFeatures.isEmpty) return const SizedBox.shrink();

    final double iconBoxSize = screenWidth * 0.1;
    final double iconSize = screenWidth * 0.055;
    final double iconRadius = screenWidth * 0.025;

    return SectionContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(title: localizations.capabilitiesSection),
          SizedBox(height: screenWidth * 0.02),
          ...List.generate(validFeatures.length, (index) {
            final key = validFeatures[index];
            final details = featureDetails[key]!;
            final iconData = featureIcons[key] ?? Icons.star_rounded;
            final iconColor = featureColors[key] ?? AppColors.senaryColor;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index > 0)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: screenWidth * 0.02),
                    child: Divider(color: AppColors.border, thickness: 1),
                  ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Coloured icon badge
                    Container(
                      width: iconBoxSize,
                      height: iconBoxSize,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(iconRadius),
                      ),
                      child: Icon(iconData, color: iconColor, size: iconSize),
                    ),
                    SizedBox(width: screenWidth * 0.035),
                    // Title + description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            details[0],
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.005),
                          Text(
                            details[1],
                            style: TextStyle(
                              color: AppColors.quinaryColor,
                              fontSize: screenWidth * 0.033,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
