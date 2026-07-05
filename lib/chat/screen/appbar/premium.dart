// lib/chat/screen/premium.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import '../../../theme.dart';

import 'dart:async'; // Add this import

class PremiumButton extends StatefulWidget {
  final VoidCallback onTap;

  const PremiumButton({
    super.key,
    required this.onTap,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    // Sweep from left (-1.5) to right (1.5)
    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    // Start initial animation after 1 second
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward(from: 0.0);
    });

    // Schedule periodic animation every 30 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _shineController.forward(from: 0.0);
      }
    });

    _shineController.addStatusListener((status) {
      // Just to be safe, if we wanted to loop we'd do it here,
      // but we are using a Timer for precise long intervals.
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final double screenWidth = MediaQuery.of(context).size.width;

    final double scale = (screenWidth / 375.0).clamp(0.85, 1.2);

    final double buttonHeight = 36.0 * scale;
    final double iconSize = 14.0 * scale;
    final double fontSize = 13.0 * scale;
    final double paddingH = 14.0 * scale;
    final double gap = 6.0 * scale;
    final double borderRadius = 36.0 * scale;
    final double borderWidth = 0.8 * scale;

    final Color baseColor = AppColors.premium.withValues(alpha: 0.15);
    final Color backgroundColor =
        Color.alphaBlend(baseColor, AppColors.background);
    final Color contentColor = AppColors.premium;
    final Color borderColor = baseColor.withValues(alpha: 0.8);

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: contentColor.withValues(alpha: 0.1),
          highlightColor: contentColor.withValues(alpha: 0.05),
          child: Stack(
            children: [
              // 1. Base Content
              Ink(
                decoration: BoxDecoration(
                  color: backgroundColor,
                  borderRadius: BorderRadius.circular(borderRadius),
                  border: Border.all(
                    color: borderColor,
                    width: borderWidth,
                  ),
                ),
                child: Container(
                  height: buttonHeight,
                  padding: EdgeInsets.symmetric(horizontal: paddingH),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/icons/sparkle.svg',
                        colorFilter: ColorFilter.mode(
                          contentColor,
                          BlendMode.srcIn,
                        ),
                        width: iconSize,
                        height: iconSize,
                      ),
                      SizedBox(width: gap),
                      Flexible(
                        child: Text(
                          "Cortex Premium",
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.w500,
                            letterSpacing: -0.5,
                            color: contentColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Shine Overlay
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(
                            screenWidth * 0.4 * _shineAnimation.value,
                            0.0), // Approximate width for effect
                        child: child,
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.2, // Width of the light beam
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.4),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.1, 0.5, 0.9],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
