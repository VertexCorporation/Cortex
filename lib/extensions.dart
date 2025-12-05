// extensions.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/theme.dart';
import 'library/backend/data/entity.dart';

/// Manages the UI and data for model extensions (variants of a base model).
class Extensions {
  // --- Instance State ---
  List<String> currentExtensions = [];
  String currentBaseSeries = "";
  String displayedExtensionLabel = "";
  Map<String, String> extensionDisplayNames = {};

  // --- UI Controllers ---
  AnimationController? extensionFadeOutController;
  AnimationController? extensionFadeInController;
  OverlayEntry? _overlayEntry;
  bool _panelIsClosing = false;

  bool get isPanelVisible => _overlayEntry != null;

  Extensions({required TickerProvider vsync}) {
    extensionFadeOutController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
    extensionFadeInController = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 200),
    );
  }

  void dispose() {
    closePanel();
    extensionFadeOutController?.dispose();
    extensionFadeInController?.dispose();
  }

  void initialize({
    required String mainId,
    required String ext,
    required ModelEntity model,
  }) {
    final extMap = model.extensions;

    if (extMap == null || extMap.isEmpty) {
      currentExtensions = [];
      extensionDisplayNames = {};
      currentBaseSeries = '';
      displayedExtensionLabel = '';
      return;
    }

    currentExtensions = extMap.keys.toList();
    extensionDisplayNames = {
      for (final key in currentExtensions)
        key: (extMap[key] is Map && extMap[key]['title'] is String)
            ? extMap[key]['title'] as String
            : key,
    };

    final chosenExt = (ext.isNotEmpty && currentExtensions.contains(ext))
        ? ext
        : currentExtensions.first;

    currentBaseSeries = mainId;
    displayedExtensionLabel = chosenExt;
  }

  void closePanel() {
    if (_overlayEntry != null && !_panelIsClosing) {
      _panelIsClosing = true;
      _overlayEntry!.markNeedsBuild();
    }
  }

  void animateExtensionChange(String newFullModelId) {
    if (displayedExtensionLabel == newFullModelId) return;

    extensionFadeOutController?.forward(from: 0.0).then((_) {
      displayedExtensionLabel = newFullModelId;
      extensionFadeInController?.forward(from: 0.0);
    });
  }

  void removeExtensionPanel() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _panelIsClosing = false;
    }
  }

  // --- Static Helper Methods ---

  static Future<String> getLastSelectedExtension(String mainId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_extension_$mainId") ?? "";
  }

  static Future<void> setLastSelectedExtension(String mainId, String extensionFullId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_extension_$mainId", extensionFullId);
  }

  void showExtensionPanel({
    required BuildContext context,
    required GlobalKey extensionKey,
    required String modelTitle,
    required Function(String) updateModelId,
    required ModelService modelService,
    required VoidCallback onPanelClosed,
  }) {
    if (currentExtensions.isEmpty) return;
    _panelIsClosing = false;
    const String logPrefix = "[Extensions.showExtensionPanel]";
    debugPrint("$logPrefix Panel opened for model series '$currentBaseSeries'.");

    final langCode = Localizations.localeOf(context).languageCode;
    final modelSeriesEntity = modelService.getPreciseModelData(currentBaseSeries, langCode: langCode);
    final extensionsMap = modelSeriesEntity.extensions ?? {};

    final List<Map<String, dynamic>> options = currentExtensions
        .map((extId) {
      if (extensionsMap.containsKey(extId) && extensionsMap[extId] is Map<String, dynamic>) {
        return extensionsMap[extId] as Map<String, dynamic>;
      }
      return {'id': extId, 'title': extId};
    })
        .toList();

    final overlay = Overlay.of(context);
    final RenderBox? renderBox = extensionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final bool isTablet = screenWidth >= 600;

      // DYNAMIC WIDTH CALCULATION
      // Tablet: 50% of screen width. Phone: 90% of screen width.
      final panelWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              // Full screen detector for "Tap Outside"
              Positioned.fill(
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    debugPrint("$logPrefix Panel dismissed by tapping outside.");
                    setState(() {
                      _panelIsClosing = true;
                    });
                  },
                  child: Container(color: Colors.transparent),
                ),
              ),
              Positioned(
                top: offset.dy,
                left: horizontalMargin,
                // Explicit width constraint
                width: panelWidth,
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
                      removeExtensionPanel();
                      onPanelClosed();
                    }
                  },
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Extensions.buildExtensionPanelWidget(
                      context: context,
                      options: options,
                      selectedExtension: displayedExtensionLabel,
                      modelTitle: modelTitle,
                      onDismiss: () {
                        setState(() {
                          _panelIsClosing = true;
                        });
                      },
                      onSelect: (selectedOption) async {
                        final selectedId = selectedOption['id'] as String;
                        debugPrint("$logPrefix User selected extension: '$selectedId'.");
                        displayedExtensionLabel = selectedId;
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
    double arrowOpacity = 1.0;
    if (fadeOut.isAnimating) {
      arrowOpacity = 1.0 - fadeOut.value;
    } else if (fadeIn.isAnimating) {
      arrowOpacity = fadeIn.value;
    }
    return AnimatedOpacity(
      opacity: arrowOpacity,
      duration: const Duration(milliseconds: 50),
      child: Transform.rotate(
        angle: 4.7124,
        child: SvgPicture.asset(
          'assets/icons/arrov.svg',
          colorFilter: ColorFilter.mode(color.withValues(alpha: arrowOpacity), BlendMode.srcIn),
          width: 20,
          height: 20,
        ),
      ),
    );
  }

  static Widget buildModelExtensionSelector({
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

  static Widget buildExtensionPanelWidget({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String selectedExtension,
    required String modelTitle,
    required VoidCallback onDismiss,
    required Function(Map<String, dynamic>) onSelect,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    // --- FULLY DYNAMIC / PROPORTIONAL SCALING ---

    // Width: Tablet 50%, Phone 90%
    final panelWidth = isTablet ? screenWidth * 0.5 : screenWidth * 0.9;

    // Row Height: Tablet 8% (e.g. 64px on 800w), Phone 12%
    final optionMinHeight = isTablet ? screenWidth * 0.08 : screenWidth * 0.12;

    // Padding: Tablet 3% (e.g. 24px), Phone 4%
    final horizontalPadding = isTablet ? screenWidth * 0.03 : screenWidth * 0.04;
    final verticalPadding = isTablet ? screenWidth * 0.02 : screenWidth * 0.02;

    // Icon Size: Tablet 3.5% (e.g. 28px), Phone 4%
    final iconSize = isTablet ? screenWidth * 0.035 : screenWidth * 0.04;

    // Font Size: Tablet 2.5% (e.g. 20px on 800w), Phone 4%
    final fontSize = isTablet ? screenWidth * 0.025 : screenWidth * 0.04;

    // Border Radius: Tablet 1.5% (e.g. 12px), Phone 2%
    final panelBorderRadius = isTablet ? screenWidth * 0.015 : screenWidth * 0.02;

    final textStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: fontSize,
    );

    const int maxVisibleItems = 5;
    final double totalHeight = options.length * optionMinHeight;
    final double constrainedHeight = (maxVisibleItems * optionMinHeight).clamp(0, totalHeight);

    Widget panelContent = SizedBox(
      height: constrainedHeight,
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final optionData = options[index];
          return _buildExtensionButtonRow(
            context: context,
            option: optionData,
            isSelected: optionData['id'] == selectedExtension,
            iconSize: iconSize,
            horizontalPadding: horizontalPadding,
            verticalPadding: verticalPadding,
            minHeight: optionMinHeight,
            borderRadius: BorderRadius.zero,
            textStyle: textStyle,
            onTap: () => onSelect(optionData),
            showBottomBorder: index < options.length - 1,
            // Pass down panelWidth for shine calculations
            panelWidth: panelWidth,
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
        width: panelWidth,
        child: panelContent,
      ),
    );
  }

  static Widget _buildExtensionButtonRow({
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
    required double panelWidth,
  }) {
    final String tier = option['tier'] as String? ?? 'free';
    final bool isPremium = tier == 'premium';

    String variantTitle = (option['title'] as String? ?? option['id']).trim();
    while (variantTitle.startsWith('-') || variantTitle.startsWith(' ')) {
      variantTitle = variantTitle.substring(1).trim();
    }

    Widget rowContent = Row(
      children: [
        Transform.scale(
          scale: isSelected ? 1.2 : 1.0,
          child: SvgPicture.asset(
            'assets/icons/extension.svg',
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
        // --- SPLASH & HIGHLIGHT REMOVED ---
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
            color: isSelected ? AppColors.quaternaryColor.withValues(alpha: 0.5) : Colors.transparent,
            border: showBottomBorder
                ? Border(bottom: BorderSide(color: AppColors.primaryColor.withValues(alpha: 0.1), width: 1.0))
                : null,
          ),
          child: rowContent,
        ),
      ),
    );

    final finalWidget = ClipRRect(
      borderRadius: borderRadius,
      child: isPremium
      // Pass the calculated panel width to the shine wrapper
          ? _ShineAnimationWrapper(panelWidth: panelWidth, child: clickableContainer)
          : clickableContainer,
    );

    return finalWidget;
  }

  static Widget _buildScrollableText({
    required String text,
    required TextStyle textStyle,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final TextPainter textPainter = TextPainter(
          text: TextSpan(text: text, style: textStyle),
          maxLines: 1,
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.of(context).textScaler,
        )..layout();

        final bool shouldScroll = textPainter.width > constraints.maxWidth;

        if (!shouldScroll) {
          return Text(
            text,
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: Text(
              text,
              style: textStyle,
              softWrap: false,
              overflow: TextOverflow.visible,
              maxLines: 1,
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

  static Future<String> onExtensionSelected(String? modelId, String newExtension) async {
    if (modelId == null || modelId.isEmpty) return '';
    await setLastSelectedExtension(modelId, newExtension);
    return newExtension;
  }

  static Future<String> onChangeModelExtension({
    required String modelId,
    required String newExtension,
    required Future<void> Function(String newFullModelId) updateConversationModelId,
    required Map<String, dynamic> Function(String mainId) getModelDataFromId,
    required Function(String mainId, String newExtension) initializeExtensions,
  }) async {
    if (modelId.isEmpty || newExtension.isEmpty) return modelId;

    await updateConversationModelId(newExtension);

    await setLastSelectedExtension(modelId, newExtension);

    initializeExtensions(modelId, newExtension);

    return newExtension;
  }
}

class _ShineAnimationWrapper extends StatefulWidget {
  final Widget child;
  final double panelWidth; // We need this to animate correctly across the dynamic width

  const _ShineAnimationWrapper({required this.child, required this.panelWidth});

  @override
  State<_ShineAnimationWrapper> createState() => _ShineAnimationWrapperState();
}

class _ShineAnimationWrapperState extends State<_ShineAnimationWrapper> with SingleTickerProviderStateMixin {
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
        CurvedAnimation(parent: _shineController, curve: Curves.linear)
    );

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
    final widthToAnimate = widget.panelWidth;

    return Stack(
      children: [
        widget.child,
        Positioned.fill(
          child: IgnorePointer(
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
          ),
        ),
      ],
    );
  }
}