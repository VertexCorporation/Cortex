// appbar.dart
//
// This file defines a custom AppBar widget for the chat application.
// The widget is responsible for rendering the navigation bar, displaying
// model title information, and handling actions such as exit and account tap.
//
// Note: This widget expects an "extensions" object (for managing extension panels)
// which must be provided during construction.

import 'dart:math';
import 'package:cortex/funds/subscriptions/subscriptions.dart';
import 'package:cortex/main.dart';
import 'package:cortex/navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../hexagons.dart';
import '../../../server/credits.dart';
import '../../../server/fetch.dart';
import '../../../theme.dart'; // Provides HexagonClipper, HexagonBorderPainter

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final bool isModelSelected;
  final String? modelTitle;
  final String? modelImagePath;
  final GlobalKey exitButtonKey;
  final GlobalKey accountButtonKey;
  final Map<String, dynamic>? userData;
  final VoidCallback onExit;
  final VoidCallback onAccountTap;
  final VoidCallback onTitleTap;
  final VoidCallback onExtensionTap;
  final String appTitle;
  final GlobalKey extensionKey;
  final dynamic extensions;
  final VoidCallback onCreditsInfoTapped;

  const Appbar({
    Key? key,
    required this.isModelSelected,
    this.modelTitle,
    this.modelImagePath,
    required this.exitButtonKey,
    required this.accountButtonKey,
    this.userData,
    required this.onExit,
    required this.onAccountTap,
    required this.onTitleTap,
    required this.onExtensionTap,
    required this.appTitle,
    required this.extensionKey,
    required this.extensions,
    required this.onCreditsInfoTapped,
  }) : super(key: key);

  @override
  State<Appbar> createState() => _AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppbarState extends State<Appbar> with SingleTickerProviderStateMixin {
  final GlobalKey _creditsInfoKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _hideCreditsInfo(isDisposing: true); // Ensure overlay is removed.
    super.dispose();
  }

  /// Hides any open panels (extensions or credits info)
  void _closeAllPanels() {
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
    _hideCreditsInfo();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return AppBar(
      toolbarHeight: screenHeight * 0.08,
      backgroundColor: AppColors.background,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leadingWidth: widget.isModelSelected ? null : screenWidth * 0.3,
      leading: widget.isModelSelected
          ? IconButton(
        key: widget.exitButtonKey,
        icon: Icon(
          Icons.arrow_back,
          color: AppColors.primaryColor.inverted,
          size: screenWidth * 0.06,
        ),
        onPressed: () {
          _closeAllPanels();
          if (widget.isModelSelected) {
            widget.onExit();
          } else {
            SystemNavigator.pop();
          }
        },
      )
          : _buildCreditsHexagonRow(context, screenWidth, screenHeight),
      title: GestureDetector(
        onTap: () {
          if (widget.extensions.isPanelVisible || _overlayEntry != null) {
            _closeAllPanels();
            return;
          }
          widget.onTitleTap();
        },
        child: widget.isModelSelected
            ? _buildModelTitleWithSelector(context, screenWidth)
            : Text(
          widget.appTitle,
          style: GoogleFonts.mavenPro(
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.08,
          ),
        ),
      ),
      actions: <Widget>[
        GestureDetector(
          key: widget.accountButtonKey,
          onTap: () {
            _closeAllPanels();
            widget.onAccountTap();
          },
          behavior: HitTestBehavior.translucent,
          child: _buildUserAvatar(context, screenWidth, screenHeight),
        ),
      ],
      flexibleSpace: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _closeAllPanels,
        child: Container(),
      ),
    );
  }

  /// Builds the model title widget with an extension selector positioned at the end.
  Widget _buildModelTitleWithSelector(
      BuildContext context, double screenWidth) {
    final bool hasExtensions = widget.extensions.currentExtensions.isNotEmpty;

    return GestureDetector(
      onTap: () {
        if (widget.extensions.isPanelVisible) {
          widget.extensions.closePanel();
        } else if (hasExtensions) {
          widget.onExtensionTap();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxWidth = constraints.maxWidth;
          final textStyle = GoogleFonts.heebo(
            fontSize: screenWidth * 0.055,
            color: AppColors.primaryColor.inverted,
            fontWeight: FontWeight.w600,
          );
          final textSpan =
          TextSpan(text: widget.modelTitle ?? '', style: textStyle);
          final textPainter =
          TextPainter(text: textSpan, textDirection: TextDirection.ltr)
            ..layout();
          final textWidth = textPainter.width;
          final extLeftPos = (maxWidth / 2) - (textWidth / 2) + textWidth;

          return Stack(
            children: [
              Center(child: Text(widget.modelTitle ?? '', style: textStyle)),
              if (hasExtensions)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: extLeftPos,
                  child: Align(
                    alignment: Alignment.center,
                    child: _buildModelExtensionSelector(context),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  /// Builds the extension-selector icon (arrow).
  Widget _buildModelExtensionSelector(BuildContext context) {
    if (widget.extensions.currentExtensions.isEmpty) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      key: widget.extensionKey,
      onTap: () {
        if (widget.extensions.isPanelVisible) {
          widget.extensions.closePanel();
        } else {
          widget.onExtensionTap();
        }
      },
      child: Transform.rotate(
        angle: -pi / 2,
        child: SvgPicture.asset(
          'assets/icons/arrov.svg',
          width: MediaQuery.of(context).size.width * 0.08 * 0.8,
          height: MediaQuery.of(context).size.width * 0.08 * 0.8,
          color: AppColors.primaryColor.inverted,
        ),
      ),
    );
  }

  Widget _buildUserAvatar(
      BuildContext context, double screenWidth, double screenHeight) {
    // --- FIX: Replaced FutureBuilder with direct data handling ---s
    // The Appbar is now a "dumb" widget. It receives user data and displays it.
    // The logic for fetching and listening to data has been moved up to ChatScreenState
    // for better state management and to resolve race conditions.

    String initial = '?'; // Default initial
    if (widget.userData != null) {
      // Prioritize 'username', fall back to 'displayName', then to 'email'.
      final String? username = widget.userData!['username'] as String?;
      final String? displayName = widget.userData!['displayName'] as String?;
      final String? email = widget.userData!['email'] as String?;

      String nameSource = "";
      if (username != null && username.isNotEmpty) {
        nameSource = username;
      } else if (displayName != null && displayName.isNotEmpty) {
        nameSource = displayName;
      } else if (email != null && email.isNotEmpty) {
        nameSource = email;
      }

      if (nameSource.isNotEmpty) {
        initial = nameSource[0].toUpperCase();
      }
    }

    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          child: CircleAvatar(
            radius: screenWidth * 0.05,
            backgroundColor: AppColors.quaternaryColor,
            // The AnimatedSwitcher provides a smooth transition when the initial
            // changes from '?' to the actual letter.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                initial,
                // The key ensures the AnimatedSwitcher correctly detects a change.
                key: ValueKey<String>(initial),
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                  color: AppColors.primaryColor.inverted,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  /// Layering Logic:
  /// - Layer 1 (Bottom): A 'catch-all' `GestureDetector` that fills the entire
  ///   space. It is set to `HitTestBehavior.opaque` to ensure it captures all
  ///   taps within its bounds, even in visually transparent areas. It triggers
  ///   the info panel.
  /// - Layer 2 (Middle): `IgnorePointer` containing all visual (non-interactive)
  ///   elements like the background bar, text, and credit icon. Clicks pass
  ///   through this layer to Layer 1.
  /// - Layer 3 (Top): The interactive hexagon button. It sits on top and
  ///   intercepts its own clicks, preventing them from reaching the background
  ///   GestureDetector.
  Widget _buildCreditsHexagonRow(
      BuildContext context, double screenWidth, double screenHeight) {
    return ValueListenableBuilder<int>(
      valueListenable: CreditsManager.instance.totalCreditsNotifier,
      builder: (context, totalCredits, child) {
        // The Stack now correctly fills the expanded `leading` area.
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            // LAYER 1: THE 'CATCH-ALL' CLICK AREA
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleCreditsInfo,
                // CRITICAL: Makes the GestureDetector capture taps in its entire
                // rectangular area, not just where there are visible children.
                behavior: HitTestBehavior.opaque,
                // A transparent container is needed for the behavior to apply.
                child: Container(color: Colors.transparent),
              ),
            ),

            // LAYER 2: VISUAL, NON-INTERACTIVE ELEMENTS
            IgnorePointer(
              child: Stack(
                // We don't clip here to avoid any visual cut-offs if needed.
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  // Visual background bar for the credits display
                  Positioned(
                    top: screenHeight * 0.0129,
                    left: screenWidth * 0.05,
                    child: Container(
                      key: _creditsInfoKey, // Key for positioning the overlay
                      width: screenWidth * 0.26,
                      height: screenHeight * 0.045,
                      decoration: BoxDecoration(
                        color: AppColors.quaternaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                    ),
                  ),
                  // Visual text and icon overlaying the bar
                  Positioned(
                    top: screenHeight * 0.0129,
                    left: screenWidth * 0.05,
                    child: Container(
                      width: screenWidth * 0.26,
                      height: screenHeight * 0.045,
                      padding:
                      EdgeInsets.symmetric(horizontal: screenWidth * 0.016),
                      alignment: Alignment.center,
                      child: Row(
                        children: [
                          SizedBox(width: screenWidth * 0.07),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.contain,
                              alignment: Alignment.centerLeft,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Text(
                                  '$totalCredits',
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.02,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor.inverted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/credit.svg',
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            color: AppColors.primaryColor.inverted,
                          ),
                          SizedBox(width: screenWidth * 0.01),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LAYER 3: INTERACTIVE HEXAGON BUTTON (CLICK INTERCEPTOR)
            Positioned(
              top: screenHeight * 0.0129,
              left: screenWidth * 0.02,
              child: _buildHexagonButton(context, screenWidth, screenHeight),
            ),
          ],
        );
      },
    );
  }


  /// Builds the hexagon button widget that navigates to the Premium screen.
  Widget _buildHexagonButton(
      BuildContext context, double screenWidth, double screenHeight) {
    return ClipPath(
      clipper: HexagonClipper(),
      child: SizedBox(
        width: screenWidth * 0.1,
        height: screenHeight * 0.045,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _closeAllPanels();
              navigateToScreen(context, PremiumScreen(),
                  direction: const Offset(0.0, 1.0));
            },
            child: CustomPaint(
              painter: HexagonBorderPainter(
                fillColor: AppColors.quaternaryColor,
                borderColor: AppColors.border,
                strokeWidth: 1.5,
              ),
              child: Padding(
                padding: EdgeInsets.all(screenWidth * 0.02),
                child: SvgPicture.asset(
                  'assets/icons/sparkle.svg',
                  color: AppColors.primaryColor.inverted,
                  width: screenWidth * 0.05,
                  height: screenWidth * 0.05,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- NEW AND UPDATED METHODS FOR ANIMATED CREDITS INFO PANEL ---

  /// Toggles the visibility of the credits information panel with animation.
  void _toggleCreditsInfo() {
    // NEW: When the user toggles the info panel, we also trigger the callback
    // to notify the parent screen, allowing it to show the promotional banner.
    widget.onCreditsInfoTapped();

    if (_animationController.isDismissed) {
      _showCreditsInfo();
    } else {
      _hideCreditsInfo();
    }
  }
  /// Hides the credits information panel with a reverse animation.
  void _hideCreditsInfo({bool isDisposing = false}) {
    if (_overlayEntry == null) return; // Do nothing if already hidden.

    if (isDisposing) {
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    _animationController.reverse().then((_) {
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  /// Creates and displays the credits information panel using an Overlay and animation.
  void _showCreditsInfo() {
    if (_overlayEntry != null) return;

    final RenderBox renderBox =
    _creditsInfoKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    final double panelWidth = screenWidth * 0.55;
    final double panelLeft = (offset.dx + size.width / 2) - (panelWidth / 2);

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: _hideCreditsInfo,
          behavior: HitTestBehavior.translucent,
          child: Material(
            color: Colors.transparent,
            child: Stack(
              children: [
                Positioned(
                  left: max(12.0, panelLeft),
                  top: offset.dy + size.height + 8,
                  child: FadeTransition(
                    opacity: _animation,
                    child: ScaleTransition(
                      scale: _animation,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () {}, // Swallow taps on the panel itself.
                        child: Container(
                          width: panelWidth,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: AppColors.quaternaryColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              // The main content of the panel
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min, // Important for Stack
                                children: [
                                  // Added padding to the right of the title
                                  // to prevent it from overlapping with the icon.
                                  Padding(
                                    padding: const EdgeInsets.only(right: 24.0),
                                    child: Text(
                                      localizations.creditsInfoPanelTitle,
                                      style: GoogleFonts.heebo(
                                        color: AppColors.primaryColor.inverted,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    localizations.creditsInfoPanelBody,
                                    style: GoogleFonts.heebo(
                                      color: AppColors.primaryColor.inverted.withOpacity(0.9),
                                      fontSize: 13,
                                      height: 1.5,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    localizations.creditsInfoPanelFooter,
                                    style: GoogleFonts.heebo(
                                      color: AppColors.primaryColor.inverted.withOpacity(0.7),
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              // The icon positioned in the top-right corner.
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  'assets/icons/credit.svg',
                                  width: 18,
                                  height: 18,
                                  color: AppColors.primaryColor.inverted.withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward();
  }
}