// lib/chat/screen/appbar/chat.dart

import 'dart:math';
import 'package:cortex/extensions.dart';
import 'package:cortex/main.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

    // Define all dynamic sizes once for consistency.
    final double fontSize = screenWidth * 0.056;

    // Create the arrow widget once to be reused.
    final Widget arrowIcon = _buildModelExtensionSelector(context, fontSize);

    // --- THE FLAWLESS SYMMETRICAL ROW SOLUTION ---
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 1. THE GHOST SPACER: An invisible clone of the arrow on the left.
        //    This creates perfect symmetry for centering the text.
        //    'maintainSize: true' is critical for it to occupy space.
        if (hasExtensions)
          Opacity(
            opacity: 0.0,
            child: arrowIcon,
          ),

        // 2. THE DYNAMIC TEXT: The text is now allowed to be flexible
        //    and will scale down gracefully if it's too long to fit.
        Flexible(
          child: Padding(
            // Add horizontal padding to prevent text from touching the arrows.
            padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.015),
            child: FittedBox(
              fit: BoxFit.scaleDown, // Only shrinks the text if it's too large.
              child: Text(
                widget.modelTitle ?? '',
                style: GoogleFonts.mavenPro(
                  fontSize: fontSize,
                  color: AppColors.primaryColor.inverted,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ),

        // 3. THE REAL ARROW: The visible arrow on the right.
        if (hasExtensions)
          arrowIcon,
      ],
    );
  }

  /// Builds the extension selector arrow icon, sized relative to the title's font size.
  Widget _buildModelExtensionSelector(BuildContext context, double fontSize) {
    // The arrow's size is now equal to the font size of the title.
    final double arrowSize = MediaQuery.of(context).size.width * 0.056;

    return GestureDetector(
      key: widget.extensionKey,
      onTap: widget.onTitleTap,
      // No vertical translation needed anymore, as Row handles vertical alignment perfectly.
      child: Transform.rotate(
        angle: -pi / 2,
        child: SvgPicture.asset(
          'assets/icons/arrov.svg',
          width: arrowSize,
          height: arrowSize,
          colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
        ),
      ),
    );
  }

  // --- METHODS MOVED FROM AppbarState ---

  /// Checks if the extension info panel should be shown and displays it.
  /// It only shows once per session and a maximum of 3 times in total.
  /// This method is now public to be called from the parent AppBar.
  Future<void> showExtensionInfoIfNeeded() async {
    if (ChatTitle.extensionInfoShownThisSession) return;

    final prefs = await SharedPreferences.getInstance();
    int showCount = prefs.getInt(ChatTitle.extensionInfoCountKey) ?? 0;

    if (showCount < 3) {
      // Use addPostFrameCallback to ensure the widget is laid out.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _showExtensionInfo();
          prefs.setInt(ChatTitle.extensionInfoCountKey, showCount + 1);
          ChatTitle.extensionInfoShownThisSession = true;
        }
      });
    }
  }

  /// Hides the extension info panel with an animation.
  /// This method is now public to be called from the parent AppBar.
  void hideExtensionInfo({bool isDisposing = false}) {
    if (_extensionOverlayEntry == null) return;

    if (isDisposing) {
      _extensionOverlayEntry?.remove();
      _extensionOverlayEntry = null;
      return;
    }

    _extensionAnimationController.reverse().then((_) {
      if (mounted && _extensionOverlayEntry != null) {
        _extensionOverlayEntry?.remove();
        _extensionOverlayEntry = null;
      }
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
        return Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              GestureDetector(
                onTap: hideExtensionInfo,
                child: Container(
                  color: Colors.black.withOpacity(0.6),
                ),
              ),
              Positioned(
                top: offset.dy + size.height + topMargin,
                left: max(minHorizontalMargin, min(panelLeft, screenWidth - panelWidth - minHorizontalMargin)),
                child: FadeTransition(
                  opacity: _extensionAnimation,
                  child: ScaleTransition(
                    scale: _extensionAnimation,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: hideExtensionInfo,
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
      },
    );

    Overlay.of(context).insert(_extensionOverlayEntry!);
    _extensionAnimationController.forward();
  }
}