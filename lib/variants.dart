// variants.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/theme.dart';
import 'library/backend/data/entity.dart';

/// Manages the UI and data for model variants (variants of a base model).
class Variants {
  // --- Instance State ---
  List<String> currentVariants = [];
  String currentBaseSeries = "";
  String displayedVariantLabel = "";
  Map<String, String> variantDisplayNames = {};

  // --- UI Controllers ---
  AnimationController? variantFadeOutController;
  AnimationController? variantFadeInController;
  OverlayEntry? _overlayEntry;
  bool _panelIsClosing = false;

  bool get isPanelVisible => _overlayEntry != null;

  Variants({required TickerProvider vsync}) {
    variantFadeOutController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
    variantFadeInController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
  }

  void dispose() {
    closePanel();
    variantFadeOutController?.dispose();
    variantFadeInController?.dispose();
  }

  void initialize({
    required String mainId,
    required String ext,
    required ModelEntity model,
  }) {
    final extMap = model.variants;

    if (extMap == null || extMap.isEmpty) {
      currentVariants = [];
      variantDisplayNames = {};
      currentBaseSeries = '';
      displayedVariantLabel = '';
      return;
    }

    currentVariants = extMap.keys.toList();
    variantDisplayNames = {
      for (final key in currentVariants)
        key: (extMap[key] is Map && extMap[key]['title'] is String)
            ? extMap[key]['title'] as String
            : key,
    };

    final chosenExt = (ext.isNotEmpty && currentVariants.contains(ext))
        ? ext
        : currentVariants.first;

    currentBaseSeries = mainId;
    displayedVariantLabel = chosenExt;
  }

  void closePanel() {
    if (_overlayEntry != null && !_panelIsClosing) {
      _panelIsClosing = true;
      _overlayEntry!.markNeedsBuild();
    }
  }

  void animateVariantChange(String newFullModelId) {
    if (displayedVariantLabel == newFullModelId) return;

    variantFadeOutController?.forward(from: 0.0).then((_) {
      displayedVariantLabel = newFullModelId;
      variantFadeInController?.forward(from: 0.0);
    });
  }

  void removeVariantPanel() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _panelIsClosing = false;
    }
  }

  // --- Static Helper Methods ---

  static Future<String> getLastSelectedVariant(String mainId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_variant_$mainId") ?? "";
  }

  static Future<void> setLastSelectedVariant(
      String mainId, String variantFullId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_variant_$mainId", variantFullId);
  }

  void showVariantPanel({
    required BuildContext context,
    required GlobalKey variantKey,
    required String modelTitle,
    required Function(String) updateModelId,
    required ModelService modelService,
    required VoidCallback onPanelClosed,
  }) {
    if (currentVariants.isEmpty) return;
    _panelIsClosing = false;
    const String logPrefix = "[Variants.showVariantPanel]";

    final langCode = Localizations.localeOf(context).languageCode;
    final modelSeriesEntity =
        modelService.getPreciseModelData(currentBaseSeries, langCode: langCode);
    final variantsMap = modelSeriesEntity.variants ?? {};
    final seriesTitle = modelSeriesEntity.displayTitle.trim();

    final List<Map<String, dynamic>> options = currentVariants.map((extId) {
      if (variantsMap.containsKey(extId) &&
          variantsMap[extId] is Map<String, dynamic>) {
        final option = Map<String, dynamic>.from(
            variantsMap[extId] as Map<String, dynamic>);
        option['id'] = option['id'] ?? extId;
        option['displayTitle'] = _composeVariantDisplayTitle(
          seriesTitle: seriesTitle,
          variantTitle: option['title']?.toString() ?? extId,
        );
        return option;
      }
      return {
        'id': extId,
        'title': extId,
        'displayTitle': _composeVariantDisplayTitle(
          seriesTitle: seriesTitle,
          variantTitle: extId,
        ),
      };
    }).toList();

    final overlay = Overlay.of(context);
    final RenderBox? renderBox =
        variantKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset =
        renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    debugPrint(
                        "$logPrefix Panel dismissed by tapping outside.");
                    setState(() {
                      _panelIsClosing = true;
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: offset.dy,
                left: 0,
                right: 0,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(
                    begin: _panelIsClosing ? 1.0 : 0.4,
                    end: _panelIsClosing ? 0.4 : 1.0,
                  ),
                  duration: const Duration(milliseconds: 50),
                  curve: Curves.easeOut,
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: child,
                    );
                  },
                  onEnd: () {
                    if (_panelIsClosing) {
                      removeVariantPanel();
                      onPanelClosed();
                    }
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Variants.buildVariantPanelWidget(
                      context: context,
                      options: options,
                      selectedVariant: displayedVariantLabel,
                      modelTitle: modelTitle,
                      onDismiss: () {
                        setState(() {
                          _panelIsClosing = true;
                        });
                      },
                      onSelect: (selectedOption) async {
                        final selectedId = selectedOption['id'] as String;
                        debugPrint(
                            "$logPrefix User selected variant: '$selectedId'.");
                        displayedVariantLabel = selectedId;
                        await updateModelId(selectedId);
                        closePanel();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    });

    overlay.insert(_overlayEntry!);
  }

  static Widget buildAnimatedArrowIcon(
    AnimationController fadeOut,
    AnimationController fadeIn,
    Color color,
  ) {
    // Use AnimatedBuilder instead of manual opacity calculation to avoid flickering
    return AnimatedBuilder(
      animation: Listenable.merge([fadeOut, fadeIn]),
      builder: (context, child) {
        double arrowOpacity = 1.0;
        if (fadeOut.status == AnimationStatus.forward ||
            fadeOut.status == AnimationStatus.reverse) {
          arrowOpacity = 1.0 - fadeOut.value;
        } else if (fadeIn.status == AnimationStatus.forward ||
            fadeIn.status == AnimationStatus.reverse) {
          arrowOpacity = fadeIn.value;
        }
        return Opacity(
          opacity: arrowOpacity.clamp(0.0, 1.0),
          child: child,
        );
      },
      child: Transform.rotate(
        angle: 4.7124,
        child: SvgPicture.asset(
          'assets/icons/arrov.svg',
          colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  static Widget buildModelVariantSelector({
    required VoidCallback onTap,
    required AnimationController fadeOut,
    required AnimationController fadeIn,
    required Color color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          buildAnimatedArrowIcon(fadeOut, fadeIn, color),
        ],
      ),
    );
  }

  // --- RESTORED ORIGINAL SIGNATURE (No panelWidth arg) ---
  static Widget buildVariantPanelWidget({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String selectedVariant,
    required String modelTitle,
    required VoidCallback onDismiss,
    required Function(Map<String, dynamic>) onSelect,
  }) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    // --- 1. DEFINE CONSTANTS (Scaled for Tablet/Phone) ---
    final double iconSize = isTablet ? screenWidth * 0.035 : screenWidth * 0.04;
    final double fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double horizontalPadding =
        isTablet ? screenWidth * 0.03 : screenWidth * 0.04;
    final double verticalPadding =
        isTablet ? screenWidth * 0.02 : screenWidth * 0.02;
    final double panelBorderRadius =
        isTablet ? screenWidth * 0.015 : screenWidth * 0.02;
    final double optionMinHeight =
        isTablet ? screenWidth * 0.095 : screenWidth * 0.145;

    // --- 2. CALCULATE DYNAMIC WIDTH ---
    // Constraints: Tablet Max 50%, Phone Max 90%.
    final double maxAllowedWidth =
        isTablet ? screenWidth * 0.6 : screenWidth * 0.9;
    final double minAllowedWidth =
        isTablet ? screenWidth * 0.25 : screenWidth * 0.5;

    final TextStyle textStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: fontSize,
    );

    // Measure longest text
    double maxTextWidth = 0;
    final TextStyle measureStyle =
        textStyle.copyWith(fontWeight: FontWeight.w500);

    for (var option in options.take(15)) {
      final text = _cleanVariantTitle(
        option['displayTitle']?.toString() ??
            option['title']?.toString() ??
            option['id']?.toString() ??
            '',
      );
      final TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: measureStyle),
        maxLines: 2,
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout(maxWidth: maxAllowedWidth * 0.72);

      if (tp.width > maxTextWidth) maxTextWidth = tp.width;
    }

    // Calculate content width
    double contentWidth = (horizontalPadding * 2) +
        iconSize +
        (horizontalPadding * 0.5) +
        maxTextWidth +
        (horizontalPadding * 0.5);
    contentWidth += (iconSize * 1.5); // Space for sparkle icon

    // Final Width
    final double finalPanelWidth =
        contentWidth.clamp(minAllowedWidth, maxAllowedWidth);

    const int maxVisibleItems = 5;
    final double totalHeight = options.length * optionMinHeight;
    final double constrainedHeight =
        (maxVisibleItems * optionMinHeight).clamp(0, totalHeight);

    Widget panelContent = SizedBox(
      height: constrainedHeight,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final optionData = options[index];
          return _buildVariantButtonRow(
            context: context,
            option: optionData,
            isSelected: optionData['id'] == selectedVariant,
            iconSize: iconSize,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            minHeight: optionMinHeight,
            borderRadius: BorderRadius.zero,
            textStyle: textStyle,
            onTap: () => onSelect(optionData),
            showBottomBorder: index < options.length - 1,
          );
        },
      ),
    );

    return Material(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(panelBorderRadius),
      ),
      clipBehavior: Clip.antiAlias,
      elevation: 4.0,
      shadowColor: Colors.black26,
      color: AppColors.secondaryColor,
      child: SizedBox(
        width: finalPanelWidth,
        child: panelContent,
      ),
    );
  }

  static Widget _buildVariantButtonRow({
    required BuildContext context,
    required Map<String, dynamic> option,
    required bool isSelected,
    required double iconSize,
    required double horizontalPadding,
    required double verticalPadding,
    required double minHeight,
    required BorderRadius borderRadius,
    required TextStyle textStyle,
    required VoidCallback onTap,
    required bool showBottomBorder,
  }) {
    final String tier = option['tier'] as String? ?? 'free';
    final bool isPremium = tier == 'premium';

    final String variantTitle = _cleanVariantTitle(
      option['displayTitle']?.toString() ??
          option['title']?.toString() ??
          option['id']?.toString() ??
          '',
    );

    Widget rowContent = Row(
      children: [
        Transform.scale(
          scale: isSelected ? 1.2 : 1.0,
          child: SvgPicture.asset(
            'assets/icons/variant.svg',
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted,
              BlendMode.srcIn,
            ),
          ),
        ),
        SizedBox(width: horizontalPadding * 0.5),
        Expanded(
          child: _buildScrollableText(
            text: variantTitle,
            textStyle: textStyle.copyWith(
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
        if (isPremium) ...[
          SizedBox(width: horizontalPadding * 0.25),
          SvgPicture.asset(
            'assets/icons/sparkle.svg',
            width: iconSize * 0.8,
            height: iconSize * 0.8,
            colorFilter: ColorFilter.mode(
              AppColors.primaryColor.inverted.withValues(alpha: 0.8),
              BlendMode.srcIn,
            ),
          ),
        ],
      ],
    );

    Widget clickableContainer = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        hoverColor: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(minHeight: minHeight),
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.quaternaryColor.withValues(alpha: 0.5)
                : Colors.transparent,
            border: showBottomBorder
                ? Border(
                    bottom: BorderSide(
                        color: AppColors.primaryColor.withValues(alpha: 0.1),
                        width: 1.0))
                : null,
          ),
          child: rowContent,
        ),
      ),
    );

    final finalWidget = ClipRRect(
      borderRadius: borderRadius,
      child: isPremium
          // No arguments needed! _ShineAnimationWrapper will calculate width itself using LayoutBuilder.
          ? _ShineAnimationWrapper(child: clickableContainer)
          : clickableContainer,
    );

    return finalWidget;
  }

  static String _cleanVariantTitle(String value) {
    var result = value.trim();
    while (result.startsWith('-') || result.startsWith(' ')) {
      result = result.substring(1).trim();
    }
    return result;
  }

  static String _normalizeVariantTitleForCompare(String value) {
    return _cleanVariantTitle(value)
        .replaceAll(RegExp(r'[\s_\-/]+'), '')
        .toLowerCase();
  }

  static String _composeVariantDisplayTitle({
    required String seriesTitle,
    required String variantTitle,
  }) {
    final cleanSeries = _cleanVariantTitle(seriesTitle);
    final cleanVariant = _cleanVariantTitle(variantTitle);
    if (cleanSeries.isEmpty) return cleanVariant;
    if (cleanVariant.isEmpty) return cleanSeries;

    final normalizedSeries = _normalizeVariantTitleForCompare(cleanSeries);
    final normalizedVariant = _normalizeVariantTitleForCompare(cleanVariant);
    if (normalizedVariant.startsWith(normalizedSeries)) {
      return cleanVariant;
    }
    return '$cleanSeries $cleanVariant';
  }

  static Widget _buildScrollableText({
    required String text,
    required TextStyle textStyle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter oneLinePainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();

        if (oneLinePainter.width <= constraints.maxWidth) {
          return Text(
            text,
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          );
        }

        final TextPainter twoLinePainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 2,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout(maxWidth: constraints.maxWidth);

        if (!twoLinePainter.didExceedMaxLines) {
          return Text(
            text,
            style: textStyle,
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: 2,
          );
        }

        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: constraints.maxWidth,
            child: Text(
              text,
              style: textStyle,
              softWrap: true,
              overflow: TextOverflow.clip,
              maxLines: 2,
            ),
          ),
        );
      },
    );
  }

  static BorderRadius getItemBorderRadius(int index, int total, double radius) {
    if (total == 1) {
      return BorderRadius.circular(radius);
    } else if (index == 0) {
      return BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );
    } else if (index == total - 1) {
      return BorderRadius.only(
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      return BorderRadius.zero;
    }
  }

  static Future<String> onVariantSelected(
      String? modelId, String newVariant) async {
    if (modelId == null || modelId.isEmpty) return '';
    await setLastSelectedVariant(modelId, newVariant);
    return newVariant;
  }

  static Future<String> onChangeModelVariant({
    required String modelId,
    required String newVariant,
    required Future<void> Function(String newFullModelId)
        updateConversationModelId,
    required Map<String, dynamic> Function(String mainId) getModelDataFromId,
    required Function(String mainId, String newVariant) initializeVariants,
  }) async {
    if (modelId.isEmpty || newVariant.isEmpty) return modelId;

    await updateConversationModelId(newVariant);

    await setLastSelectedVariant(modelId, newVariant);

    initializeVariants(modelId, newVariant);

    return newVariant;
  }
}

/// A wrapper for the premium shine animation.
/// Uses LayoutBuilder to determine animation width dynamically without extra parameters.
class _ShineAnimationWrapper extends StatefulWidget {
  final Widget child;

  const _ShineAnimationWrapper({required this.child});

  @override
  State<_ShineAnimationWrapper> createState() => _ShineAnimationWrapperState();
}

class _ShineAnimationWrapperState extends State<_ShineAnimationWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _shineController;
  late Animation<double> _shineAnimation;

  @override
  void initState() {
    super.initState();
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _shineAnimation = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _shineController, curve: Curves.linear));

    _shineController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _shineController.forward(from: 0.0);
          }
        });
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _shineController.forward();
      }
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: LayoutBuilder(
            // KEY FIX: Use LayoutBuilder to get the exact width of this row
            // without needing to pass it from the parent.
            builder: (context, constraints) {
              final widthToAnimate = constraints.maxWidth;

              return IgnorePointer(
                child: AnimatedBuilder(
                  animation: _shineAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(widthToAnimate * _shineAnimation.value, 0),
                      child: child,
                    );
                  },
                  child: Container(
                    width: widthToAnimate * 0.3,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.secondaryColor.withValues(alpha: 0.0),
                          AppColors.secondaryColor.withValues(alpha: 0.5),
                          AppColors.secondaryColor.withValues(alpha: 0.0),
                        ],
                        stops: const [0.4, 0.5, 0.6],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
