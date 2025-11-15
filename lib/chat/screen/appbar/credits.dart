// lib/chat/screen/appbar/credits.dart

import 'dart:math';
import 'package:cortex/app.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../banner.dart';
import '../../../funds/funds.dart';
import 'package:provider/provider.dart';

/// The main widget for the credits bar, containing the display, the button,
/// and the logic for the informational pop-up panel.
class CreditsBar extends StatefulWidget {
  final VoidCallback onCreditsInfoTapped;
  final VoidCallback? onPanelShown;
  final VoidCallback? onPanelHidden;

  const CreditsBar({
    super.key,
    required this.onCreditsInfoTapped,
    this.onPanelShown,
    this.onPanelHidden,
  });

  @override
  CreditsBarState createState() => CreditsBarState();
}

class CreditsBarState extends State<CreditsBar> with TickerProviderStateMixin {
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
    hideCreditsInfo(isDisposing: true); // Ensure overlay is removed
    super.dispose();
  }

  void _toggleCreditsInfo() {
    widget.onCreditsInfoTapped();

    if (_animationController.isDismissed) {
      _showCreditsInfo();
    } else {
      hideCreditsInfo();
    }
  }


  void hideCreditsInfo({bool isDisposing = false}) {
    if (_overlayEntry == null) return;

    widget.onPanelHidden?.call();

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
    context.read<BannerService>().triggerBannerManually();

    final RenderBox renderBox =
    _creditsInfoKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    final double panelWidth = screenWidth * 0.65;
    final double panelLeft = (offset.dx + size.width / 2) - (panelWidth / 2);
    final double titleFontSize = screenWidth * 0.04;
    final double bodyFontSize = screenWidth * 0.035;
    final double footerFontSize = screenWidth * 0.033;
    final double iconSize = screenWidth * 0.045;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: hideCreditsInfo,
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
                        onTap: () {},
                        child: Container(
                          width: panelWidth,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 12.0),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryColor,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                                color: AppColors.border, width: 0.8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.25),
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
                                        fontSize: titleFontSize,
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
                                          .withValues(alpha: 0.9),
                                      fontSize: bodyFontSize,
                                      height: 1.5,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    localizations.creditsInfoPanelFooter,
                                    style: GoogleFonts.heebo(
                                      color: AppColors.primaryColor.inverted
                                          .withValues(alpha: 0.7),
                                      fontSize: footerFontSize,
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
                                  width: iconSize,
                                  height: iconSize,
                                  colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted
                                      .withValues(alpha: 0.6), BlendMode.srcIn),
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
    widget.onPanelShown?.call();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return ValueListenableBuilder<int?>(
      valueListenable: CreditsManager.instance.totalCreditsNotifier,
      builder: (context, totalCredits, child) {
        final String creditsText = totalCredits == null ? '?' : totalCredits.toString();

        String ghostText;
        if (totalCredits == null) {
          ghostText = "999";
        } else if (totalCredits < 100 && totalCredits >= 0) { // Catch 1 and 2 digit numbers
          ghostText = "999";
        } else {
          ghostText = creditsText;
        }

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
                        color: AppColors.secondaryColor,
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
                              alignment: Alignment.center, // Center the content
                              child: Padding(
                                padding: const EdgeInsets.only(right: 5.0),
                                child: Stack(
                                  alignment: Alignment.center, // Center the text
                                  children: [
                                    Opacity(
                                      opacity: 0.0,
                                      child: Text(
                                        ghostText,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor.inverted,
                                        ),
                                      ),
                                    ),
                                    // FIX 3: Add AnimatedSwitcher for smooth transitions
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 250),
                                      transitionBuilder: (child, animation) {
                                        return FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        );
                                      },
                                      child: Text(
                                        creditsText,
                                        // Use a key to tell the switcher that the text has changed
                                        key: ValueKey<String>(creditsText),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryColor.inverted,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SvgPicture.asset(
                            'assets/icons/credit.svg',
                            width: screenWidth * 0.05,
                            height: screenWidth * 0.05,
                            colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
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
              child: _AnimatedHexagonButton(
                screenWidth: screenWidth,
                screenHeight: screenHeight,
                onTap: () {
                  hideCreditsInfo();
                  navigateToScreen(const FundsScreen(),
                      direction: const Offset(0.0, 1.0));
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A hexagon button with a continuous "pulsing" animation and a premium look.
class _AnimatedHexagonButton extends StatefulWidget {
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;

  const _AnimatedHexagonButton({
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
  });

  @override
  _AnimatedHexagonButtonState createState() => _AnimatedHexagonButtonState();
}

class _AnimatedHexagonButtonState extends State<_AnimatedHexagonButton>
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

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    final Gradient fillGradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: [
        AppColors.quaternaryColor.withValues(alpha: 0.9),
        AppColors.quaternaryColor,
      ],
    );

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.screenWidth * 0.1,
          height: widget.screenHeight * 0.045,
          child: CustomPaint(
            painter: _HexagonBorderPainter(
              fillColor: AppColors.quaternaryColor,
              fillGradient: fillGradient,
              strokeWidth: 2.5,
              gradient: borderGradient,
              hasGlow: true,
            ),
            child: Center(
              child: SvgPicture.asset(
                'assets/icons/sparkle.svg',
                colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
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

/// CustomPainter to support a "glow" effect and inner gradient for the hexagon.
class _HexagonBorderPainter extends CustomPainter {
  final Color fillColor;
  final Gradient? fillGradient;
  final double strokeWidth;
  final Gradient? gradient;
  final bool hasGlow;

  _HexagonBorderPainter({
    required this.fillColor,
    this.fillGradient,
    this.strokeWidth = 1.5,
    this.gradient,
    this.hasGlow = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = _getHexagonPath(size);

    if (hasGlow) {
      final Paint glowPaint = Paint()
        ..color = const Color(0xFF833AB4).withValues(alpha: 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawPath(path.shift(const Offset(0, 2)), glowPaint);
    }

    final Paint fillPaint = Paint();
    if (fillGradient != null) {
      fillPaint.shader = fillGradient!
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    } else {
      fillPaint.color = fillColor;
    }
    canvas.drawPath(path, fillPaint);

    if (gradient != null) {
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
  bool shouldRepaint(covariant _HexagonBorderPainter oldDelegate) {
    return oldDelegate.fillColor != fillColor ||
        oldDelegate.fillGradient != fillGradient ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradient != gradient ||
        oldDelegate.hasGlow != hasGlow;
  }
}