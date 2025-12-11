// lib/chat/screen/appbar/credits.dart

import 'dart:math';
import 'package:cortex/app.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/credits.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../banner.dart';
import '../../../funds/funds.dart';
import 'package:provider/provider.dart';

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
    hideCreditsInfo(isDisposing: true);
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

    if (isDisposing) {
      widget.onPanelHidden?.call();
      _overlayEntry?.remove();
      _overlayEntry = null;
      return;
    }

    _animationController.reverse().then((_) {
      if (mounted) {
        _overlayEntry?.remove();
        _overlayEntry = null;
        widget.onPanelHidden?.call();
      }
    });
  }

  void _showCreditsInfo() {
    if (_overlayEntry != null) return;
    final TargetPlatform platform = Theme.of(context).platform;
    final bool isIOS = platform == TargetPlatform.iOS;

    // On Android: we can safely trigger the share/credits banner.
    // On iOS: we completely skip it so the "invite & earn credits" banner never shows.
    if (!isIOS) {
      context.read<BannerService>().triggerBannerManually();
    }

    final RenderBox renderBox =
    _creditsInfoKey.currentContext!.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero);

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = mediaQuery.size.shortestSide > 600;
    final localizations = AppLocalizations.of(context)!;

    // --- RESPONSIVE PANEL DIMENSIONS ---
    final double panelWidth = isTablet ? screenWidth * 0.45 : screenWidth * 0.65;

    // Calculate position
    final double panelLeft = ((offset.dx + size.width / 2) - (panelWidth / 2));
    final double panelTop = offset.dy + size.height + 16;

    // --- RESPONSIVE FONT SIZES ---
    final double titleFontSize = isTablet ? screenWidth * 0.03 : screenWidth * 0.04;
    final double bodyFontSize = isTablet ? screenWidth * 0.022 : screenWidth * 0.035;
    final double footerFontSize = isTablet ? screenWidth * 0.02 : screenWidth * 0.033;
    final double iconSize = isTablet ? screenWidth * 0.03 : screenWidth * 0.045;

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
                  top: panelTop,
                  child: FadeTransition(
                    opacity: _animation,
                    child: ScaleTransition(
                      scale: _animation,
                      alignment: Alignment.topLeft,
                      child: GestureDetector(
                        onTap: () {},
                        child: Container(
                          width: panelWidth,
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.04, vertical: screenWidth * 0.03),
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
                                    padding: EdgeInsets.only(right: screenWidth * 0.06),
                                    child: Text(
                                      localizations.creditsInfoPanelTitle,
                                      style: TextStyle(
                                        color: AppColors.primaryColor.inverted,
                                        fontSize: titleFontSize,
                                        fontWeight: FontWeight.bold,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.02),
                                  Text(
                                    localizations.creditsInfoPanelBody,
                                    style: TextStyle(
                                      color: AppColors.primaryColor.inverted
                                          .withValues(alpha: 0.9),
                                      fontSize: bodyFontSize,
                                      height: 1.5,
                                      decoration: TextDecoration.none,
                                    ),
                                  ),
                                  SizedBox(height: screenWidth * 0.025),
                                  Text(
                                    localizations.creditsInfoPanelFooter,
                                    style: TextStyle(
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
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = mediaQuery.size.shortestSide > 600;

    // --- FULLY DYNAMIC DIMENSIONS & OPTIMIZATION ---

    // 1. Container Width:
    // Tablet: 22% width. Phone: 26%.
    final double containerWidth = isTablet ? screenWidth * 0.21 : screenWidth * 0.26;

    // 2. Container Height:
    // Tablet: Scaled to width. Phone: Fixed manageable height (38.0) to fit in 80.0 AppBar.
    final double containerHeight = isTablet ? screenWidth * 0.07 : 38.0;

    // 3. Icon Size:
    final double iconSize = isTablet ? screenWidth * 0.03 : 20.0;

    // 4. Panel Padding (Left Margin):
    // Standardizes the start position from the edge of the screen.
    final double leftMargin = isTablet ? screenWidth * 0.04 : 16.0;

    // 5. Hexagon Left Position:
    // The Hexagon should overlap slightly. We calculate it relative to the margin.
    final double hexagonOverlapOffset = isTablet ? - (screenWidth * 0.015) : -6.0;

    // 6. Font Size:
    final double creditsFontSize = isTablet ? screenWidth * 0.025 : 13.0;

    return ValueListenableBuilder<int?>(
      valueListenable: CreditsManager.instance.totalCreditsNotifier,
      builder: (context, totalCredits, child) {
        final String creditsText = totalCredits == null ? '?' : totalCredits.toString();
        String ghostText;
        if (totalCredits == null) {
          ghostText = "999";
        } else if (totalCredits < 100 && totalCredits >= 0) {
          ghostText = "999";
        } else {
          ghostText = creditsText;
        }

        // OPTIMIZATION: Removed 'top' positioning.
        // We now use Alignment.centerLeft to ensure vertical centering inside the AppBar.
        return Padding(
          padding: EdgeInsets.only(left: leftMargin),
          child: Stack(
            alignment: Alignment.centerLeft, // Key fix for vertical alignment
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GestureDetector(
                  onTap: _toggleCreditsInfo,
                  behavior: HitTestBehavior.opaque,
                  child: Container(color: Colors.transparent),
                ),
              ),

              // The Content Container (Pill)
              // We move it to the right to make room for the hexagon.
              Padding(
                padding: EdgeInsets.only(left: (isTablet ? screenWidth * 0.025 : 12.0)),
                child: IgnorePointer(
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      // Background
                      Container(
                        key: _creditsInfoKey,
                        width: containerWidth,
                        height: containerHeight,
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(isTablet ? screenWidth * 0.03 : 18.0),
                          border: Border.all(color: AppColors.border, width: 0.5),
                        ),
                      ),
                      // Text Content
                      Container(
                        width: containerWidth,
                        height: containerHeight,
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        alignment: Alignment.center,
                        child: Row(
                          children: [
                            SizedBox(width: isTablet ? screenWidth * 0.04 : 20.0), // Spacer for hexagon overlap
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 4.0),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Opacity(
                                        opacity: 0.0,
                                        child: Text(
                                          ghostText,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: creditsFontSize,
                                            color: AppColors.primaryColor.inverted,
                                          ),
                                        ),
                                      ),
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
                                          key: ValueKey<String>(creditsText),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: creditsFontSize,
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
                              width: iconSize,
                              height: iconSize,
                              colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
                            ),
                            const SizedBox(width: 4.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // The Hexagon Button
              // Aligned to the far left (plus overlap offset) and vertically centered automatically by Stack.
              Positioned(
                left: hexagonOverlapOffset,
                child: _AnimatedHexagonButton(
                  screenWidth: screenWidth,
                  screenHeight: MediaQuery.of(context).size.height,
                  isTablet: isTablet,
                  onTap: () {
                    hideCreditsInfo();
                    navigateToScreen(const FundsScreen(),
                        direction: const Offset(0.0, 1.0));
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedHexagonButton extends StatefulWidget {
  final VoidCallback onTap;
  final double screenWidth;
  final double screenHeight;
  final bool isTablet;

  const _AnimatedHexagonButton({
    required this.onTap,
    required this.screenWidth,
    required this.screenHeight,
    required this.isTablet,
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
    // --- RESPONSIVE HEXAGON SIZE (Dynamic) ---
    // Tablet: Dynamic based on width.
    // Phone: Fixed size to ensure it fits the 80.0 AppBar perfectly.
    final double width = widget.isTablet ? widget.screenWidth * 0.08 : 40.0;
    final double height = widget.isTablet ? widget.screenWidth * 0.075 : 40.0;

    // Icon: Scaled or fixed
    final double iconSize = widget.isTablet ? widget.screenWidth * 0.035 : 18.0;

    const Gradient borderGradient = SweepGradient(
      center: FractionalOffset.center,
      colors: <Color>[
        Color(0xFF405DE6),
        Color(0xFF833AB4),
        Color(0xFFE1306C),
        Color(0xFFF77737),
        Color(0xFFFFDC80),
        Color(0xFF405DE6),
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
          width: width,
          height: height,
          child: RepaintBoundary(
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
                  width: iconSize,
                  height: iconSize,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
        ..color = const Color(0xFF833AB4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.5);
      canvas.drawPath(path.shift(const Offset(0, 1)), glowPaint);
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