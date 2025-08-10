// extensions.dart

import 'dart:async';
import 'package:cortex/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cortex/theme.dart';

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
    required Map<String, dynamic> modelData,
    required Function(bool) updateCanHandleImage,
  }) {
    final rawExt = modelData['extensions'];
    final Map<String, dynamic> extMap = (rawExt is Map)
        ? Map<String, dynamic>.from(rawExt)
        : {};

    // If the model has no extensions, just reset internal state and exit.
    // DO NOT call updateCanHandleImage. The caller (`SelectionService`) has already set the correct state.
    if (extMap.isEmpty) {
      currentExtensions = [];
      extensionDisplayNames = {};
      currentBaseSeries = '';
      displayedExtensionLabel = '';
      // The line below was removed as it was causing the bug by incorrectly resetting the state.
      // updateCanHandleImage(modelData['canHandleImage'] as bool? ?? false);
      return;
    }

    // This part is for models WITH extensions and works as intended.
    currentExtensions = extMap.keys.map((k) => k.toString()).toList();
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

    final extData = extMap[chosenExt] is Map<String, dynamic> ? extMap[chosenExt] : {};
    final canImage = (extData['canHandleImage'] as bool?) ?? false;
    updateCanHandleImage(canImage);
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
  /// The complex `onInitialized` callback has been removed. It now uses a single,
  /// clean `updateModelId` callback that expects the full ID of the selected extension.
  /// This delegates the state management responsibility back to the calling widget (`ChatScreen`),
  /// promoting better separation of concerns.
  void showExtensionPanel({
    required BuildContext context,
    required GlobalKey extensionKey,
    required String modelTitle,
    required Function(String) updateModelId, // Now a simple callback with the selected extension ID.
  }) {
    if (currentExtensions.isEmpty) return;
    _panelIsClosing = false;
    const String logPrefix = "[Extensions.showExtensionPanel]";
    debugPrint("$logPrefix Panel opened for model series '$currentBaseSeries'.");


    final options = currentExtensions
        .map((ext) => MapEntry(ext, extensionDisplayNames[ext]!))
        .toList();
    final overlay = Overlay.of(context);
    final RenderBox? renderBox = extensionKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    _overlayEntry = OverlayEntry(builder: (BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;
      final double appBarBottom = MediaQuery.of(context).padding.top + kToolbarHeight;

      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Stack(
            children: [
              Positioned(
                top: appBarBottom,
                left: 0,
                right: 0,
                bottom: 0,
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
                      onSelect: (selectedEntry) async {
                        // --- CORE LOGIC CHANGE ---
                        // Instead of complex internal state changes, we now simply
                        // invoke the provided callback with the selected key.
                        debugPrint("$logPrefix User selected extension: '${selectedEntry.key}'. Invoking callback.");
                        displayedExtensionLabel = selectedEntry.key;
                        await updateModelId(selectedEntry.key);
                        // The panel is now closed by the parent widget's logic,
                        // ensuring the state update completes first.
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
          colorFilter: ColorFilter.mode(color.withOpacity(arrowOpacity), BlendMode.srcIn), // Using colorFilter is more appropriate
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

  static Widget buildExtensionPanelWidget({
    required BuildContext context,
    required List<MapEntry<String, String>> options,
    required String selectedExtension,
    required String modelTitle, // Not used
    required VoidCallback onDismiss, // Not used
    required Function(MapEntry<String, String>) onSelect,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final panelMaxWidth = screenWidth * 0.9;
    final optionMinHeight = screenWidth * 0.12;
    final horizontalPadding = screenWidth * 0.04;
    final verticalPadding = screenWidth * 0.02;
    final iconSize = screenWidth * 0.04;
    final panelBorderRadius = screenWidth * 0.02;
    final itemRadius = screenWidth * 0.02;
    final spaceBetweenIconAndText = horizontalPadding * 0.5;

    final textStyle = TextStyle(
      color: AppColors.primaryColor.inverted,
      fontSize: screenWidth * 0.04,
    );

    // Her seçenek için text genişliğini hesapla
    double longestTextWidth = 0;
    for (var entry in options) {
      final text = entry.value;
      final TextPainter tp = TextPainter(
        text: TextSpan(text: text, style: textStyle),
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout();

      if (tp.width > longestTextWidth) {
        longestTextWidth = tp.width;
      }
    }

    // Panel için gerekli minimum genişlik: icon + boşluk + en uzun text + padding'ler
    double requiredPanelWidth = iconSize + spaceBetweenIconAndText + longestTextWidth + (horizontalPadding * 2);

    double finalPanelWidth = requiredPanelWidth.clamp(80.0, panelMaxWidth);

    // Generate all extension rows
    List<Widget> itemWidgets = List.generate(options.length, (i) {
      return _buildExtensionButtonRow(
        context: context,
        option: options[i],
        isSelected: options[i].key == selectedExtension,
        variantTitle: options[i].value,
        iconSize: iconSize,
        horizontalPadding: horizontalPadding,
        verticalPadding: verticalPadding,
        minHeight: optionMinHeight,
        borderRadius: getItemBorderRadius(i, options.length, itemRadius),
        textStyle: textStyle,
        onTap: () => onSelect(options[i]),
        showBottomBorder: i < options.length - 1,
      );
    });

    Widget panelContent;
    const int maxVisibleItems = 5;

    if (options.length > maxVisibleItems) {
      double scrollableHeight = maxVisibleItems * optionMinHeight;

      panelContent = ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: scrollableHeight,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: itemWidgets,
          ),
        ),
      );
    } else {
      panelContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: itemWidgets,
      );
    }

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

  // 👉 extensions.dart
  static Widget _buildExtensionButtonRow({
    required BuildContext context,
    required MapEntry<String, String> option,
    required bool isSelected,
    required String variantTitle,
    required double iconSize,
    required double horizontalPadding,
    required double verticalPadding,
    required double minHeight,
    required BorderRadius borderRadius,
    required TextStyle textStyle,
    required VoidCallback onTap,
    required bool showBottomBorder,
  }) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Material(
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
              color: isSelected
                  ? AppColors.quaternaryColor.withOpacity(0.5)
                  : Colors.transparent,
              border: showBottomBorder
                  ? Border(
                bottom: BorderSide(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  width: 1.0,
                ),
              )
                  : null,
            ),
            child: Row(
              children: [
                // ikon
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
                // metin
                Expanded(
                  child: _buildScrollableText(
                    text: variantTitle,
                    textStyle: textStyle.copyWith(
                      fontWeight:
                      isSelected ? FontWeight.w500 : FontWeight.normal,
                      color: AppColors.primaryColor.inverted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
        )..layout();

        // 🔑 Kaydırma sadece gerçek taşma varsa
        final bool shouldScroll = textPainter.width > constraints.maxWidth;

        if (!shouldScroll) {
          // Metin sığıyorsa normal şekilde döndür
          return Text(
            text,
            style: textStyle,
            softWrap: false,
            overflow: TextOverflow.visible,
            maxLines: 1,
          );
        }

        // Metin taşarsa yatay kaydırma ekle
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

    // 1️⃣  Konuşma meta verisini güncelle
    await updateConversationModelId(newExtension);

    // 2️⃣  Uzantıyı kalıcı olarak kaydet  (EKLENDİ)
    await setLastSelectedExtension(modelId, newExtension);

    // 3️⃣  Extensions instance’ını tazele
    initializeExtensions(modelId, newExtension);

    return newExtension;          // Seçilen *tam* model-ID’yi döndür
  }
}