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
import 'package:cortex/l10n/app_localizations.dart';

import '../../../hexagons.dart';
import '../../../server/credits.dart';
import '../../../theme.dart'; // Provides HexagonClipper

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
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: Text(
                initial,
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

  Widget _buildCreditsHexagonRow(
      BuildContext context, double screenWidth, double screenHeight) {
    return ValueListenableBuilder<int>(
      valueListenable: CreditsManager.instance.totalCreditsNotifier,
      builder: (context, totalCredits, child) {
        return Stack(
          alignment: Alignment.centerLeft,
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleCreditsInfo,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.transparent),
              ),
            ),
            IgnorePointer(
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.centerLeft,
                children: [
                  Positioned(
                    top: screenHeight * 0.0129,
                    left: screenWidth * 0.05,
                    child: Container(
                      key: _creditsInfoKey,
                      width: screenWidth * 0.26,
                      height: screenHeight * 0.045,
                      decoration: BoxDecoration(
                        color: AppColors.quaternaryColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.border, width: 0.5),
                      ),
                    ),
                  ),
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
    return AnimatedHexagonButton(
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      onTap: () {
        _closeAllPanels();
        navigateToScreen(context, PremiumScreen(),
            direction: const Offset(0.0, 1.0));
      },
    );
  }

  void _toggleCreditsInfo() {
    widget.onCreditsInfoTapped();

    if (_animationController.isDismissed) {
      _showCreditsInfo();
    } else {
      _hideCreditsInfo();
    }
  }

  void _hideCreditsInfo({bool isDisposing = false}) {
    if (_overlayEntry == null) return;

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
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: AppColors.quaternaryColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.border, width: 0.8),
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Padding(
                                    padding:
                                    const EdgeInsets.only(right: 24.0),
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
                                      color: AppColors.primaryColor.inverted
                                          .withOpacity(0.9),
                                      fontSize: 13,
                                      height: 1.5,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    localizations.creditsInfoPanelFooter,
                                    style: GoogleFonts.heebo(
                                      color: AppColors.primaryColor.inverted
                                          .withOpacity(0.7),
                                      fontSize: 13,
                                      fontStyle: FontStyle.italic,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                ],
                              ),
                              Positioned(
                                top: 0,
                                right: 0,
                                child: SvgPicture.asset(
                                  'assets/icons/credit.svg',
                                  width: 18,
                                  height: 18,
                                  color: AppColors.primaryColor.inverted
                                      .withOpacity(0.6),
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

// --- NEW WIDGET: A hexagon button with a continuous "pulsing" animation and a premium look ---
class AnimatedHexagonButton extends StatefulWidget {
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const AnimatedHexagonButton({
    Key? key,
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  }) : super(key: key);

  @override
  _AnimatedHexagonButtonState createState() => _AnimatedHexagonButtonState();
}

class _AnimatedHexagonButtonState extends State<AnimatedHexagonButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // The animation will scale between 1.0 (normal) and 1.08 (8% larger).
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    // Make the animation loop back and forth.
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Gradient for the vibrant, multi-colored border.
    const Gradient borderGradient = SweepGradient(
      center: FractionalOffset.center,
      colors: <Color>[
        Color(0xFF405DE6), // Blue
        Color(0xFF833AB4), // Purple
        Color(0xFFE1306C), // Red
        Color(0xFFF77737), // Orange
        Color(0xFFFFDC80), // Yellow
        Color(0xFF405DE6), // Blue to complete the loop
      ],
    );

    // Subtle gradient for the button's fill to give it depth.
    final Gradient fillGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        AppColors.quaternaryColor.withOpacity(0.9),
        AppColors.quaternaryColor,
      ],
    );

    // The ScaleTransition widget applies the continuous pulsing animation.
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.screenWidth * 0.1,
          height: widget.screenHeight * 0.045,
          child: CustomPaint(
            painter: HexagonBorderPainter(
              fillColor: AppColors.quaternaryColor,
              fillGradient: fillGradient, // Apply the inner gradient.
              strokeWidth: 2.5, // Thicker border for more visual impact.
              gradient: borderGradient,
              hasGlow: true, // Enable the premium glow effect.
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/sparkle.svg',
                color: AppColors.primaryColor.inverted,
                width: widget.screenWidth * 0.045,
                height: widget.screenWidth * 0.045,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- UPDATED CustomPainter to support a "glow" effect and inner gradient ---
class HexagonBorderPainter extends CustomPainter {
  final Color fillColor;
  final Gradient? fillGradient;
  final double strokeWidth;
  final Color? borderColor;
  final Gradient? gradient;
  final bool hasGlow; // Replaced hasShadow with hasGlow for clarity

  HexagonBorderPainter({
    required this.fillColor,
    this.fillGradient,
    this.strokeWidth = 1.5,
    this.borderColor,
    this.gradient,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _getHexagonPath(size);

    // 1. DRAW THE GLOW (if enabled)
    // Uses a key color from the gradient for a more thematic, premium feel.
    if (hasGlow) {
      final Paint glowPaint = Paint()
        ..color = const Color(0xFF833AB4).withOpacity(0.6) // Vibrant purple glow
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path.shift(const Offset(0, 2)), glowPaint);
    }

    // 2. DRAW THE FILL (using gradient if provided, otherwise solid color)
    final Paint fillPaint = Paint();
    if (fillGradient != null) {
      fillPaint.shader = fillGradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      fillPaint.color = fillColor;
    }
    canvas.drawPath(path, fillPaint);

    // 3. DRAW THE BORDER (only if a style is provided)
    if (gradient != null || borderColor != null) {
      final Paint strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      if (gradient != null) {
        strokePaint.shader = gradient!.createShader(
          Rect.fromCenter(
            center: size.center(Offset.zero),
            width: size.width,
            height: size.height,
          ),
        );
      } else {
        strokePaint.color = borderColor!;
      }
      canvas.drawPath(path, strokePaint);
    }
  }

  Path _getHexagonPath(Size size) {
    final Path path = Path();
    double w = size.width;
    double h = size.height;

    path.moveTo(w * 0.25, 0);
    path.lineTo(w * 0.75, 0);
    path.lineTo(w, h * 0.5);
    path.lineTo(w * 0.75, h);
    path.lineTo(w * 0.25, h);
    path.lineTo(0, h * 0.5);
    path.close();

    return path;
  }

  @override
  bool shouldRepaint(covariant HexagonBorderPainter oldDelegate) {
    // Repaint only if properties have actually changed for better performance.
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.fillGradient != fillGradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.gradient != gradient ||
        oldDelegate.hasGlow != hasGlow;
  }
}