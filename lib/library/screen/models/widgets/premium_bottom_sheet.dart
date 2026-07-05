// lib/library/screen/models/widgets/premium_bottom_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../theme.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../navigation.dart';
import '../../../../funds/funds.dart';
import '../../../../app.dart';
import 'dart:async';
import 'package:cortex/scaled_bottom_sheet.dart';

void showPremiumBottomSheet(BuildContext context) {
  HapticFeedback.lightImpact();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    isDismissible: true,
    enableDrag: true,
    useSafeArea: false,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.of(context).size.width,
    ),
    builder: (BuildContext modalContext) {
      return const ScaledBottomSheet(child: PremiumBottomSheetContent());
    },
  );
}

class PremiumBottomSheetContent extends StatefulWidget {
  const PremiumBottomSheetContent({super.key});

  @override
  State<PremiumBottomSheetContent> createState() =>
      _PremiumBottomSheetContentState();
}

class _PremiumBottomSheetContentState extends State<PremiumBottomSheetContent>
    with TickerProviderStateMixin {
  late final AnimationController _entranceController;
  late final AnimationController _glowController;
  late final Animation<double> _glowScaleAnimation;
  late final Animation<double> _glowOpacityAnimation;
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    // Entrance animation (fades and slides up items)
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Breathing glow animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _glowScaleAnimation = Tween<double>(begin: 0.85, end: 1.2).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );

    _glowOpacityAnimation = Tween<double>(begin: 0.1, end: 0.4).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOutSine,
      ),
    );

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward(from: 0.0);
    });

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        _shineController.forward(from: 0.0);
      }
    });

    _entranceController.forward();
    _glowController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _glowController.dispose();
    _shineController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Widget _buildAnimatedItem({
    required Widget child,
    required double start,
    required double end,
  }) {
    final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    final slide = Tween<Offset>(
      begin: const Offset(0.0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      ),
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double w = MediaQuery.sizeOf(context).width;
    final loc = AppLocalizations.of(context)!;
    final theme = AppColors.currentTheme;

    // Use contrast colors
    final Color textColor = AppColors.primaryColor.inverted;
    final Color subTextColor = textColor.withValues(alpha: 0.65);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28.0)),
        border: Border.all(
          color: theme == 'light'
              ? Colors.black.withValues(alpha: 0.06)
              : Colors.white.withValues(alpha: 0.06),
          width: 1.0,
        ),
      ),
      padding: EdgeInsets.fromLTRB(w * 0.06, w * 0.04, w * 0.06, w * 0.06),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: w * 0.12,
              height: 4.5,
              decoration: BoxDecoration(
                color: theme == 'light'
                    ? Colors.black.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            SizedBox(height: w * 0.06),

            // Animated Logo & Ambient Glow
            _buildAnimatedItem(
              start: 0.0,
              end: 0.5,
              child: SizedBox(
                width: w * 0.42,
                height: w * 0.42,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ambient Glow behind the logo
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _glowScaleAnimation.value,
                          child: Opacity(
                            opacity: _glowOpacityAnimation.value,
                            child: Container(
                              width: w * 0.32,
                              height: w * 0.32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppColors.premium,
                                    AppColors.premium.withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    // Inner logo container
                    Container(
                      width: w * 0.26,
                      height: w * 0.26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.background,
                        border: Border.all(
                          color: AppColors.premium.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.premium.withValues(alpha: 0.15),
                            blurRadius: 15.0,
                            spreadRadius: 2.0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: SvgPicture.asset(
                          'assets/cortex.svg',
                          width: w * 0.12,
                          height: w * 0.12,
                          colorFilter: ColorFilter.mode(
                            textColor,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title
            _buildAnimatedItem(
              start: 0.2,
              end: 0.7,
              child: Text(
                "Sınırları Kaldırın!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textColor,
                  fontSize: w * 0.065,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            SizedBox(height: w * 0.03),

            // Description
            _buildAnimatedItem(
              start: 0.3,
              end: 0.8,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: w * 0.02),
                child: Text(
                  "Bu güçlü yapay zeka modeline ve çok daha fazlasına sınırsız erişim sağlamak için Cortex Premium'a geçiş yapın.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: subTextColor,
                    fontSize: w * 0.038,
                    height: 1.45,
                  ),
                ),
              ),
            ),
            SizedBox(height: w * 0.08),

            // Primary Button (Premium'u İncele)
            _buildAnimatedItem(
              start: 0.4,
              end: 0.9,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(w * 0.035),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      Navigator.pop(context);
                      final target = const FundsScreen();
                      navigateToScreen(target,
                          direction: const Offset(0.0, 1.0));
                    },
                    borderRadius: BorderRadius.circular(w * 0.035),
                    splashColor: AppColors.premium.withValues(alpha: 0.1),
                    highlightColor: AppColors.premium.withValues(alpha: 0.05),
                    child: Stack(
                      children: [
                        // 1. Base Content
                        Ink(
                          decoration: BoxDecoration(
                            color: Color.alphaBlend(
                                AppColors.premium.withValues(alpha: 0.15),
                                AppColors.background),
                            borderRadius: BorderRadius.circular(w * 0.035),
                            border: Border.all(
                              color: AppColors.premium.withValues(alpha: 0.25),
                              width: 1.0,
                            ),
                          ),
                          child: Container(
                            height: w * 0.135,
                            width: double.infinity,
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Premium'a Katıl",
                                    style: TextStyle(
                                      color: AppColors.premium,
                                      fontSize: w * 0.045,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
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
                            borderRadius: BorderRadius.circular(w * 0.035),
                            child: AnimatedBuilder(
                              animation: _shineAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(
                                      w * 1.5 * _shineAnimation.value, 0.0),
                                  child: child,
                                );
                              },
                              child: Container(
                                width: w * 0.4,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.0),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.5),
                                      Colors.white.withValues(alpha: 0.3),
                                      Colors.white.withValues(alpha: 0.0),
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
                ),
              ),
            ),
            SizedBox(height: w * 0.03),

            // Secondary Button (Cancel)
            _buildAnimatedItem(
              start: 0.5,
              end: 1.0,
              child: TextButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
                child: Text(
                  loc.cancel,
                  style: TextStyle(
                    color: AppColors.tertiaryColor,
                    fontSize: w * 0.04,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
