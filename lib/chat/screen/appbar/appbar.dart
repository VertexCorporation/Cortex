// appbar.dart

import 'dart:math';
import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../extensions.dart';
import '../../../theme.dart';
import '../../providers/session.dart';
import 'chat.dart';
import 'credits.dart';

/// A self-contained, animated painter for creating a rotating gradient border.
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;

    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: AppColors.animatedBorderGradientColors,
        startAngle: 0.0,
        endAngle: 2 * pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final String? modelTitle;
  final String? modelImagePath;
  final GlobalKey exitButtonKey;
  final GlobalKey accountButtonKey;
  final VoidCallback onExit;
  final VoidCallback onAccountTap;
  final VoidCallback onTitleTap;
  final String appTitle;
  final GlobalKey extensionKey;
  final Extensions extensions;
  final VoidCallback onCreditsInfoTapped;
  final VoidCallback? onInfoPanelWillShow;
  final VoidCallback? onInfoPanelDidHide;
  final GlobalKey<ChatTitleState> chatTitleKey;
  final VoidCallback onShowExtensionInfoRequest;

  const Appbar({
    super.key,
    this.modelTitle,
    this.modelImagePath,
    required this.exitButtonKey,
    required this.accountButtonKey,
    required this.onExit,
    required this.onAccountTap,
    required this.onTitleTap,
    required this.appTitle,
    required this.extensionKey,
    required this.extensions,
    required this.onCreditsInfoTapped,
    this.onInfoPanelWillShow,
    this.onInfoPanelDidHide,
    required this.chatTitleKey,
    required this.onShowExtensionInfoRequest,
  });

  @override
  State<Appbar> createState() => AppbarState();

  @override
  // We return a generous height to ensure Scaffold allocates space.
  Size get preferredSize => const Size.fromHeight(120);
}

class AppbarState extends State<Appbar> with TickerProviderStateMixin {
  final GlobalKey<CreditsBarState> _creditsBarKey = GlobalKey<CreditsBarState>();

  late AnimationController _animationController;
  late AnimationController _borderAnimationController;
  late Animation<double> _borderAnimation;
  bool _isCreditsPanelVisible = false;

  bool isAPanelShowing() {
    return _isCreditsPanelVisible || widget.extensions.isPanelVisible;
  }

  void closeAnyOpenPanels() {
    if (_isCreditsPanelVisible) {
      _creditsBarKey.currentState?.hideCreditsInfo();
    }
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _borderAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _borderAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_borderAnimationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _borderAnimationController.dispose();
    _creditsBarKey.currentState?.hideCreditsInfo(isDisposing: true);
    super.dispose();
  }

  void closeAllPanels() {
    if (widget.extensions.isPanelVisible) {
      widget.extensions.closePanel();
    }
    _creditsBarKey.currentState?.hideCreditsInfo();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;

    // RESPONSIVE LOGIC
    final bool isTablet = size.shortestSide > 600;

    // --- DIMENSIONS & SCALING ---

    // 1. Toolbar Height: Matches the "0.14" logic of other screens for Tablet.
    final double toolbarHeight = isTablet ? screenWidth * 0.14 : kToolbarHeight;

    // 2. Element Sizes: Scaled up for Tablet to fill the taller bar.
    final double leadingWidth = isTablet ? screenWidth * 0.22 : screenWidth * 0.3;
    final double titleFontSize = isTablet ? 32.0 : screenWidth * 0.08;
    final double subtitleFontSize = isTablet ? 18.0 : screenWidth * 0.025;
    final double iconSize = isTablet ? 36.0 : screenWidth * 0.06;

    // Avatar is significantly larger on tablet
    final double avatarRadius = isTablet ? 28.0 : screenWidth * 0.05;
    final double avatarFontSize = isTablet ? 24.0 : screenWidth * 0.045;

    final localizations = AppLocalizations.of(context)!;
    final sessionProvider = context.watch<ChatSessionProvider>();
    final isUserSubscribed = sessionProvider.isUserSubscribed;

    final mode = sessionProvider.appBarMode;

    if (isUserSubscribed && !_borderAnimationController.isAnimating) {
      _borderAnimationController.repeat();
    } else if (!isUserSubscribed && _borderAnimationController.isAnimating) {
      _borderAnimationController.stop();
    }

    void handleExitPress() {
      if (_isCreditsPanelVisible) {
        _creditsBarKey.currentState?.hideCreditsInfo();
      } else {
        widget.onExit();
      }
    }

    Widget leadingWidget;
    Widget titleContentWidget;

    switch (mode) {
      case AppBarMode.notSelected:
        leadingWidget = CreditsBar(
          key: _creditsBarKey,
          onCreditsInfoTapped: widget.onCreditsInfoTapped,
          onPanelShown: () {
            if (mounted) setState(() => _isCreditsPanelVisible = true);
          },
          onPanelHidden: () {
            if (mounted) setState(() => _isCreditsPanelVisible = false);
          },
        );
        titleContentWidget = Text(
          widget.appTitle,
          key: const ValueKey('app_title'),
          style: GoogleFonts.mavenPro(
              color: AppColors.primaryColor.inverted,
              fontSize: titleFontSize),
        );
        break;

      case AppBarMode.dynamicChat:
        leadingWidget = Padding(
          padding: EdgeInsets.only(left: isTablet ? 16.0 : 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                key: const ValueKey('exit_dynamic_chat_button'),
                icon: Icon(Icons.arrow_back,
                    color: AppColors.primaryColor.inverted,
                    size: iconSize),
                onPressed: handleExitPress),
          ),
        );
        titleContentWidget = Container(
          key: widget.chatTitleKey,
          child: Column(
            key: const ValueKey('dynamic_chat_title_column'),
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.appTitle,
                style: GoogleFonts.mavenPro(
                  color: AppColors.primaryColor.inverted,
                  fontSize: titleFontSize,
                  height: 1.0,
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (child, animation) {
                  final offsetAnimation = Tween<Offset>(
                    begin: const Offset(0.0, -0.5),
                    end: Offset.zero,
                  ).animate(
                      CurvedAnimation(
                          parent: animation, curve: Curves.easeOut));
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: offsetAnimation,
                      child: child,
                    ),
                  );
                },
                child: KeyedSubtree(
                  key: const ValueKey('dynamic_subtitle'),
                  child: Container(
                    margin: const EdgeInsets.only(top: 2.0),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    child: Text(
                      localizations.dynamicChatTitle,
                      style: GoogleFonts.mavenPro(
                        color:
                        AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                        fontSize: subtitleFontSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        break;

      case AppBarMode.inSelection:
      case AppBarMode.modelSelected:
        leadingWidget = Padding(
          padding: EdgeInsets.only(left: isTablet ? 16.0 : 8.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
                key: const ValueKey('back_button'),
                icon: Icon(Icons.arrow_back,
                    color: AppColors.primaryColor.inverted,
                    size: iconSize),
                onPressed: handleExitPress),
          ),
        );
        titleContentWidget = mode == AppBarMode.inSelection
            ? FittedBox(
          key: const ValueKey('explore_title'),
          fit: BoxFit.scaleDown,
          child: Text(
            localizations.explore,
            style: GoogleFonts.mavenPro(
              color: AppColors.primaryColor.inverted,
              fontSize: titleFontSize,
            ),
          ),
        )
            : ChatTitle(
          key: widget.chatTitleKey,
          modelTitle: widget.modelTitle,
          extensions: widget.extensions,
          onTitleTap: widget.onTitleTap,
          extensionKey: widget.extensionKey,
          onShowInfoRequest: widget.onShowExtensionInfoRequest,
        );
        break;
    }

    String initial = '?';
    final String? displayName = sessionProvider.displayName;
    final String? email = sessionProvider.email;
    String nameSource = "";

    if (displayName != null && displayName.isNotEmpty) {
      nameSource = displayName;
    } else if (email != null && email.isNotEmpty) {
      nameSource = email;
    } else {
      nameSource = localizations.anonymousEntity;
    }

    if (nameSource.isNotEmpty) {
      initial = nameSource[0].toUpperCase();
    }

    return AppBar(
      toolbarHeight: toolbarHeight,
      backgroundColor: AppColors.background,
      centerTitle: true,
      scrolledUnderElevation: 0,
      leadingWidth: leadingWidth,
      leading: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        transitionBuilder: (child, animation) {
          final slideAnimation = Tween<Offset>(
            begin: const Offset(-0.5, 0.0),
            end: Offset.zero,
          ).animate(animation);
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: slideAnimation,
              child: child,
            ),
          );
        },
        child: leadingWidget,
      ),
      title: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: (mode == AppBarMode.modelSelected ||
            mode == AppBarMode.dynamicChat)
            ? widget.onTitleTap
            : null,
        child: Container(
          alignment: Alignment.center,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.95, end: 1.0)
                      .animate(animation),
                  child: child,
                ),
              );
            },
            child: titleContentWidget,
          ),
        ),
      ),
      actions: [
        SizedBox(
          width: leadingWidth, // Balance the leading width
          child: Stack(
            children: [
              Positioned(
                right: isTablet ? 32.0 : 16.0,
                top: 0,
                bottom: 0, // Center vertically
                child: Center(
                  child: GestureDetector(
                    key: widget.accountButtonKey,
                    onTap: widget.onAccountTap,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.8, end: 1.0).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutBack,
                              ),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: _buildUserAvatar(
                        key: ValueKey('$initial-$isUserSubscribed'),
                        context: context,
                        radius: avatarRadius,
                        fontSize: avatarFontSize,
                        isUserSubscribed: isUserSubscribed,
                        initial: initial,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserAvatar({
    required BuildContext context,
    required double radius,
    required double fontSize,
    required bool isUserSubscribed,
    required String initial,
    Key? key,
  }) {
    Widget avatarCore = Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.border,
          width: 1.0,
        ),
      ),
      child: CircleAvatar(
        radius: radius,
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
              fontSize: fontSize,
              color: AppColors.primaryColor.inverted,
            ),
          ),
        ),
      ),
    );

    Widget finalAvatar;

    if (isUserSubscribed) {
      finalAvatar = AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return RepaintBoundary(
            child: CustomPaint(
              painter:
              AnimatedBorderPainter(animationValue: _borderAnimation.value),
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: child,
              ),
            ),
          );
        },
        child: avatarCore,
      );
    } else {
      finalAvatar = avatarCore;
    }

    return Center(key: key, child: finalAvatar);
  }
}