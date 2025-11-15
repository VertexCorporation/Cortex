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
///
/// This class is designed as a UI/utility helper. It is responsible for:
/// 1.  Holding the available extensions for the *currently selected* model series.
/// 2.  Displaying the extension selection panel (Overlay).
/// 3.  Reporting the user's selection back to the calling widget (`ChatScreen`).
///
/// It does NOT manage persistent state like "what is the default extension?". That
/// responsibility lies with the ChatScreen and the static helper methods below.
class Extensions {
  // --- Instance State ---
  // These variables are specific to the currently active model in the chat.
  // They are reset/re-initialized whenever the model changes.
  List<String> currentExtensions = [];
  String currentBaseSeries = "";
  String displayedExtensionLabel = ""; // The full ID of the extension to show in the UI.
  Map<String, String> extensionDisplayNames = {}; // Maps full ID to user-friendly title.

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
    closePanel(); // Ensure the overlay is removed on dispose.
    extensionFadeOutController?.dispose();
    extensionFadeInController?.dispose();
  }

  /// Initializes or re-initializes the extension data for a given model.
  /// This should be called by the `SelectionService` whenever a model is selected.
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

  /// Closes the extension selection panel if it's open.
  void closePanel() {
    if (_overlayEntry != null && !_panelIsClosing) {
      // Trigger the closing animation. The overlay will be removed on animation end.
      _panelIsClosing = true;
      _overlayEntry!.markNeedsBuild();
    }
  }

  /// Animates the change of the extension label in the UI.
  /// This is purely a visual effect triggered by the `ChatScreen`.
  void animateExtensionChange(String newFullModelId) {
    if (displayedExtensionLabel == newFullModelId) return;

    extensionFadeOutController?.forward(from: 0.0).then((_) {
      // Once the old label has faded out, update the text and fade the new one in.
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
  // These methods manage persistent storage and can be called from anywhere.

  /// Retrieves the last selected extension for a given model series from persistent storage.
  static Future<String> getLastSelectedExtension(String mainId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_extension_$mainId") ?? "";
  }

  /// Saves the selected extension for a model series to persistent storage.
  static Future<void> setLastSelectedExtension(String mainId, String extensionFullId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("last_extension_$mainId", extensionFullId);
  }

  /// Displays the extension selection panel overlay.
  ///
  /// This method now prepares a rich list of data for each extension and
  /// uses a simple `updateModelId` callback that expects the full ID of the
  /// selected extension. This delegates state management responsibility back
  /// to the calling widget (`ChatScreen`).
  void showExtensionPanel({
    required BuildContext context,
    required GlobalKey extensionKey,
    required String modelTitle,
    required Function(String) updateModelId,
    required ModelService modelService,
  }) {
    if (currentExtensions.isEmpty) return;
    _panelIsClosing = false;
    const String logPrefix = "[Extensions.showExtensionPanel]";
    debugPrint("$logPrefix Panel opened for model series '$currentBaseSeries'.");

    // Get the current language code from the context.
    final langCode = Localizations.localeOf(context).languageCode;

    // Fetch the type-safe ModelEntity for the current series.
    // We now pass the required `langCode`.
    final modelSeriesEntity = modelService.getPreciseModelData(currentBaseSeries, langCode: langCode);

    // Safely access the extensions map from the entity.
    final extensionsMap = modelSeriesEntity.extensions ?? {};

    // Create the 'options' list by mapping over the extension IDs and pulling
    // the corresponding data from the extensions map.
    final List<Map<String, dynamic>> options = currentExtensions
        .map((extId) {
      if (extensionsMap.containsKey(extId) && extensionsMap[extId] is Map<String, dynamic>) {
        return extensionsMap[extId] as Map<String, dynamic>;
      }
      // Provide a safe fallback if the extension data is somehow missing.
      return {'id': extId, 'title': extId};
    })
        .toList();

    final overlay = Overlay.of(context);
    final RenderBox? renderBox = extensionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              // This GestureDetector now fills the ENTIRE screen. It sits behind the
              // panel. Tapping anywhere that isn't the panel will be caught by this
              // detector, ensuring a clean dismissal from the AppBar or any other area.
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
                right: horizontalMargin,
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
                        // The 'selectedOption' is now a Map, not a MapEntry.
                        final selectedId = selectedOption['id'] as String;
                        debugPrint("$logPrefix User selected extension: '$selectedId'. Invoking callback.");
                        displayedExtensionLabel = selectedId;
                        await updateModelId(selectedId);
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
        angle: 4.7124, // Approximately 270 degrees (3*PI/2)
        child: SvgPicture.asset(
          'assets/icons/arrov.svg', // Maybe it should be 'arrow.svg'? 'arrov.svg' could be a typo.
          colorFilter: ColorFilter.mode(color.withValues(alpha: arrowOpacity), BlendMode.srcIn), // Using colorFilter is more appropriate
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
        mainAxisSize: MainAxisSize.max, // MainAxisSize.min is generally safer if the wrapping widget manages the size.
        children: [
          buildAnimatedArrowIcon(fadeOut, fadeIn, color),
        ],
      ),
    );
  }

  /// Builds the main panel container with a list of extension options.
  ///
  /// This version has been heavily optimized for performance with long lists by using ListView.builder.
  /// This ensures that the entrance/exit animations are smooth even with 100+ options.
  static Widget buildExtensionPanelWidget({
    required BuildContext context,
    required List<Map<String, dynamic>> options,
    required String selectedExtension,
    required String modelTitle,
    required VoidCallback onDismiss,
    required Function(Map<String, dynamic>) onSelect,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelMaxWidth = screenWidth * 0.9;
    final optionMinHeight = screenWidth * 0.12;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenWidth * 0.02;
    final iconSize = screenWidth * 0.04;
    final panelBorderRadius = screenWidth * 0.02;

    final textStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: screenWidth * 0.04,
    );

    // Calculate text width based on a sample of items or a fixed value for performance.
    // For extreme performance, we avoid iterating the whole list here.
    // A fixed reasonable width or calculating from the first few items is often sufficient.
    double longestTextWidth = 0;
    for (var entry in options.take(10)) { // Check first 10 items for a good estimate
      final text = entry['title'] as String? ?? entry['id'];
      final TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (tp.width > longestTextWidth) {
        longestTextWidth = tp.width;
      }
    }
    double requiredPanelWidth = iconSize + (horizontalPadding * 0.5) + longestTextWidth + (horizontalPadding * 2);
    double finalPanelWidth = requiredPanelWidth.clamp(screenWidth * 0.5, panelMaxWidth);

    // --- PERFORMANCE CRITICAL CHANGE ---
    const int maxVisibleItems = 5;
    final double totalHeight = options.length * optionMinHeight;
    final double constrainedHeight = (maxVisibleItems * optionMinHeight).clamp(0, totalHeight);

    Widget panelContent = SizedBox(
      height: constrainedHeight,
      child: ListView.builder(
        padding: EdgeInsets.zero, // Remove default padding
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

  /// Builds a single clickable row for an extension in the panel.
  ///
  /// This method now reads the 'tier' and 'title' from the provided map.
  /// It conditionally renders the sparkle icon and wraps the row in the
  /// shine animation if the tier is 'premium'.
  /// Builds a single clickable row for an extension in the panel.
  ///
  /// This method now reads the 'tier' and 'title' from the provided map.
  /// It conditionally renders the sparkle icon and wraps the row in the
  /// shine animation if the tier is 'premium'.
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
  }) {
    // Extract tier and determine if the extension is premium.
    final String tier = option['tier'] as String? ?? 'free';
    final bool isPremium = tier == 'premium';

    // Format the variant title to remove leading dashes and spaces for a cleaner UI.
    String variantTitle = (option['title'] as String? ?? option['id']).trim();
    while (variantTitle.startsWith('-') || variantTitle.startsWith(' ')) {
      variantTitle = variantTitle.substring(1).trim();
    }

    // The base UI for the row content.
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
            // Use the newly formatted title.
            text: variantTitle,
            textStyle: textStyle.copyWith(
              fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
        // Conditionally display the sparkle icon for premium models.
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

    // The clickable container for the row.
    Widget clickableContainer = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
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

    // Conditionally wrap the entire row in the shine animation widget.
    final finalWidget = ClipRRect(
      borderRadius: borderRadius,
      child: isPremium
          ? _ShineAnimationWrapper(child: clickableContainer)
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
      return BorderRadius.circular(radius); // All corners if it's a single item
    } else if (index == 0) {
      return BorderRadius.only( // Top corners if it's the first item
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(radius),
      );
    } else if (index == total - 1) {
      return BorderRadius.only( // Bottom corners if it's the last item
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      return BorderRadius.zero; // No corners for intermediate items
    }
  }

  static Future<String> onExtensionSelected(String? modelId, String newExtension) async {
    if (modelId == null || modelId.isEmpty) return '';
    await setLastSelectedExtension(modelId, newExtension); // Direct modelId instead of modelId ?? '', null check done above.
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

/// A stateful widget that wraps its child with a recurring shine animation.
/// This logic is adapted from `credits.dart` to be reusable and is used
/// to highlight premium extension options.
class _ShineAnimationWrapper extends StatefulWidget {
  final Widget child;

  const _ShineAnimationWrapper({required this.child});

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
        // Wait for a few seconds before the next shine.
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _shineController.forward(from: 0.0);
          }
        });
      }
    });

    // Start the first animation after a short delay.
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      children: [
        // The original content (the extension row).
        widget.child,
        // The animated shine effect on top.
        Positioned.fill(
          child: IgnorePointer( // The shine effect should not capture touch events.
            child: AnimatedBuilder(
              animation: _shineAnimation,
              builder: (context, child) {
                return Transform.translate(
                  // The panel width is 90% of the screen, so we adjust the translate distance.
                  offset: Offset(screenWidth * 0.9 * _shineAnimation.value, 0),
                  child: child,
                );
              },
              child: Container(
                width: screenWidth * 0.25, // The width of the shine itself.
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