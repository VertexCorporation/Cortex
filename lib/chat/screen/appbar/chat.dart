// lib/chat/screen/appbar/chat.dart

import 'dart:math';
import 'package:cortex/extensions.dart';
import 'package:cortex/main.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../l10n/app_localizations.dart';

/// A reusable, stateful widget that displays the model's title and a dropdown
/// arrow for selecting extensions. It also manages the logic for showing
/// a one-time "extension info panel" to the user.
class ChatTitle extends StatefulWidget {
  final String? modelTitle;
  final Extensions extensions;
  final VoidCallback onTitleTap;
  final GlobalKey extensionKey;

  // Static properties moved from Appbar to keep related logic together.
  static bool extensionInfoShownThisSession = false;
  static const String extensionInfoCountKey = 'extensionInfoPanelShowCount';

  const ChatTitle({
    Key? key,
    required this.modelTitle,
    required this.extensions,
    required this.onTitleTap,
    required this.extensionKey,
  }) : super(key: key);

  @override
  State<ChatTitle> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitle> with TickerProviderStateMixin {
  OverlayEntry? _extensionOverlayEntry;
  late AnimationController _extensionAnimationController;
  late Animation<double> _extensionAnimation;
  bool get isPanelVisible => _extensionOverlayEntry != null;
  VoidCallback? _onPanelClosed;

  @override
  void initState() {
    super.initState();
    _extensionAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _extensionAnimation = CurvedAnimation(
      parent: _extensionAnimationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _extensionAnimationController.dispose();
    hideExtensionInfo(isDisposing: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool hasExtensions = widget.extensions.currentExtensions.isNotEmpty;
    final double fontSize = screenWidth * 0.056;

    // The core content: a Row that grows naturally with its text content.
    final Widget titleContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min, // Crucial: makes the Row as wide as its children.
      children: [
        // 1. THE GHOST SPACER: For perfect symmetrical alignment.
        if (hasExtensions)
          Opacity(
            opacity: 0.0,
            child: _buildArrowIcon(fontSize),
          ),

        // 2. THE DYNAMIC TEXT: Now allowed to be its full size.
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
          child: Text(
            widget.modelTitle ?? '',
            style: GoogleFonts.mavenPro(
              fontSize: fontSize,
              color: AppColors.primaryColor.inverted,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            // No overflow handling here; the parent FittedBox will handle it.
          ),
        ),

        // 3. THE REAL ARROW: The visible, interactive counterpart.
        if (hasExtensions)
          _buildArrowIcon(fontSize),
      ],
    );

    // This is the wrapper that applies the sophisticated sizing rules.
    return GestureDetector(
      key: widget.extensionKey,
      onTap: hasExtensions ? widget.onTitleTap : null,
      behavior: HitTestBehavior.opaque,
      child: ConstrainedBox(
        // Rule 1: The entire title area can be at most 65% of the screen width.
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.65,
        ),
        // Rule 2: If the child (titleContent) is WIDER than the maxWidth,
        //         proportionally scale it down until it fits. If it's smaller,
        //         do nothing and let it render at its natural size.
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: titleContent,
        ),
      ),
    );
  }

  /// Helper method to build just the visual arrow icon, without any interactivity.
  Widget _buildArrowIcon(double fontSize) {
    // Match arrow size to font size for visual harmony.
    final double arrowSize = fontSize;

    return Transform.rotate(
      angle: -pi / 2,
      child: SvgPicture.asset(
        'assets/icons/arrov.svg',
        width: arrowSize,
        height: arrowSize,
        colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
      ),
    );
  }

  /// Checks if the extension info panel should be shown and displays it.
  Future<void> showExtensionInfoIfNeeded({VoidCallback? onPanelClosed}) async {
    // Prevent re-showing if already shown in this session.
    if (ChatTitle.extensionInfoShownThisSession) {
      // If the panel won't be shown, call the callback immediately.
      onPanelClosed?.call();
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    int showCount = prefs.getInt(ChatTitle.extensionInfoCountKey) ?? 0;

    if (showCount < 3) {
      if (mounted) {
        // Store the callback to be used when the panel is dismissed.
        _onPanelClosed = onPanelClosed;
        _showExtensionInfo(); // Attempt to show directly.
        await prefs.setInt(ChatTitle.extensionInfoCountKey, showCount + 1);
        ChatTitle.extensionInfoShownThisSession = true;
      }
    } else {
      // If the panel won't be shown, call the callback immediately.
      onPanelClosed?.call();
    }
  }

  /// Hides the extension info panel with an animation.
  void hideExtensionInfo({bool isDisposing = false}) {
    if (_extensionOverlayEntry == null) return;

    // A local function to handle cleanup and trigger the callback.
    void cleanup() {
      if (mounted) {
        _extensionOverlayEntry?.remove();
        _extensionOverlayEntry = null;
        // Trigger the callback to notify the parent that the panel is closed.
        _onPanelClosed?.call();
        _onPanelClosed = null; // Clear the callback after use.
      }
    }

    if (isDisposing) {
      _extensionOverlayEntry?.remove();
      _extensionOverlayEntry = null;
      return;
    }

    _extensionAnimationController.reverse().then((_) {
      cleanup();
    });
  }

  /// Creates and displays the extension info panel as an overlay.
  void _showExtensionInfo() {
    if (_extensionOverlayEntry != null || widget.extensionKey.currentContext == null) return;

    final RenderBox renderBox = widget.extensionKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final localizations = AppLocalizations.of(context)!;

    // --- Sizing and positioning variables remain the same ---
    final double panelWidth = screenWidth * 0.8;
    final double panelLeft = offset.dx + size.width / 2 - (panelWidth / 2);
    final double minHorizontalMargin = screenWidth * 0.04;
    final double topMargin = screenHeight * 0.015;
    final double borderRadiusValue = screenWidth * 0.04;
    final double borderWidth = screenWidth * 0.002;
    final double shadowBlurRadius = screenWidth * 0.05;
    final double shadowOffsetY = screenHeight * 0.01;
    final double titleFontSize = screenWidth * 0.042;
    final double bodyFontSize = screenWidth * 0.035;
    final double footerFontSize = screenWidth * 0.033;
    final double horizontalPadding = screenWidth * 0.045;
    final double verticalPadding = screenWidth * 0.035;
    final double smallSpacing = screenHeight * 0.012;
    final double mediumSpacing = screenHeight * 0.015;

    _extensionOverlayEntry = OverlayEntry(
      builder: (context) {
        // --- MODIFICATION START ---
        // Wrap the entire overlay in a Material widget to ensure text styles and
        // theming are applied correctly.
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              // 1. THE BACKGROUND: A full-screen GestureDetector to catch taps and dismiss the panel.
              GestureDetector(
                onTap: hideExtensionInfo,
                child: Container(
                  // Animate the background color for a smoother appearance.
                  color: Colors.black.withOpacity(0.6 * _extensionAnimation.value),
                ),
              ),
              // 2. THE PANEL: Positioned on top of the background.
              Positioned(
                top: offset.dy + size.height + topMargin,
                left: max(minHorizontalMargin, min(panelLeft, screenWidth - panelWidth - minHorizontalMargin)),
                child: FadeTransition(
                  opacity: _extensionAnimation,
                  child: ScaleTransition(
                    scale: _extensionAnimation,
                    alignment: Alignment.topCenter,
                    // This inner GestureDetector prevents taps on the panel itself
                    // from propagating to the background detector and closing it.
                    child: GestureDetector(
                      onTap: () {}, // Absorb the tap
                      child: Container(
                        width: panelWidth,
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(borderRadiusValue),
                          border: Border.all(color: AppColors.border, width: borderWidth),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: shadowBlurRadius,
                              offset: Offset(0, shadowOffsetY),
                            )
                          ],
                        ),
                        // The content of the panel (Column with Text widgets) remains unchanged.
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(localizations.extensionInfoPanelTitle,
                                style: GoogleFonts.heebo(
                                    color: AppColors.primaryColor.inverted,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.none)),
                            SizedBox(height: smallSpacing),
                            Text(localizations.extensionInfoPanelBody1,
                                style: GoogleFonts.heebo(
                                    color: AppColors.primaryColor.inverted.withOpacity(0.9),
                                    fontSize: bodyFontSize,
                                    height: 1.5,
                                    decoration: TextDecoration.none)),
                            SizedBox(height: smallSpacing),
                            Text(localizations.extensionInfoPanelBody2,
                                style: GoogleFonts.heebo(
                                    color: AppColors.primaryColor.inverted.withOpacity(0.9),
                                    fontSize: bodyFontSize,
                                    height: 1.5,
                                    decoration: TextDecoration.none)),
                            SizedBox(height: mediumSpacing),
                            Text(localizations.extensionInfoPanelFooter,
                                style: GoogleFonts.heebo(
                                    color: AppColors.primaryColor.inverted.withOpacity(0.7),
                                    fontSize: footerFontSize,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.none)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        // --- MODIFICATION END ---
      },
    );

    Overlay.of(context).insert(_extensionOverlayEntry!);
    // We need to rebuild the overlay as the animation progresses.
    _extensionAnimationController.addListener(() {
      _extensionOverlayEntry?.markNeedsBuild();
    });
    _extensionAnimationController.forward();
  }
}