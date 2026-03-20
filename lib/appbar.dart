// lib/appbar.dart

import 'dart:math' as math;
import 'package:cortex/app.dart';
import 'package:cortex/screen.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

/// Defines the behavior of the leading (left) button.
enum CortexLeadingMode {
  auto,
  axon,
  back,
  none,
}

// --- 1. THE UNIVERSAL APP BAR ---
class CortexAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onLeadingPressed;
  final Widget? actionButton;
  final List<Widget>? actions;
  final List<Widget>? leadingActions;
  final Widget? title;
  final String? titleText;
  final bool showGradient;
  final ScrollController? scrollController;
  final CortexLeadingMode leadingMode;

  const CortexAppBar({
    super.key,
    this.onLeadingPressed,
    this.actionButton,
    this.actions,
    this.leadingActions,
    this.title,
    this.titleText,
    this.showGradient = true,
    this.scrollController,
    this.leadingMode = CortexLeadingMode.auto,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;

    final double buttonSize = isTablet ? 48.0 : 42.0;
    final double iconSize = isTablet ? 26.0 : 22.0;
    final double horizontalPadding = screenWidth * 0.04;
    final double gapSize = 12.0;

    // --- LEADING LOGIC ---
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPopThisRoute = parentRoute?.canPop ?? false;

    final bool showBackButton = leadingMode == CortexLeadingMode.back ||
        (leadingMode == CortexLeadingMode.auto && canPopThisRoute);
    final bool hideLeading = leadingMode == CortexLeadingMode.none;

    final List<Widget> leftWidgets = [];
    double calculatedLeadingWidth = 0;

    if (!hideLeading) {
      if (showBackButton) {
        leftWidgets.add(
          _BackButton(
            buttonSize: buttonSize,
            iconSize: iconSize,
            onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          ),
        );
        calculatedLeadingWidth += buttonSize;
      } else {
        leftWidgets.add(
          _AxonToggleButton(
            buttonSize: buttonSize,
            iconSize: iconSize,
            onPressed: onLeadingPressed ??
                () {
                  context
                      .findAncestorStateOfType<MainScreenState>()
                      ?.toggleAxon();
                },
          ),
        );
        calculatedLeadingWidth += buttonSize;
      }
    }

    if (leadingActions != null && leadingActions!.isNotEmpty) {
      if (leftWidgets.isNotEmpty) {
        leftWidgets.add(SizedBox(width: gapSize));
        calculatedLeadingWidth += gapSize;
      }
      for (int i = 0; i < leadingActions!.length; i++) {
        leftWidgets.add(leadingActions![i]);
        calculatedLeadingWidth += buttonSize;
        if (i < leadingActions!.length - 1) {
          leftWidgets.add(SizedBox(width: gapSize));
          calculatedLeadingWidth += gapSize;
        }
      }
    }

    if (leftWidgets.isNotEmpty) {
      calculatedLeadingWidth += horizontalPadding;
    }

    // --- RIGHT WIDGETS LOGIC (UPDATED FOR DYNAMIC WIDTH) ---
    final List<Widget> rightWidgets = [];
    double calculatedActionsWidth = 0;
    final List<Widget> sourceActions =
        actions ?? (actionButton != null ? [actionButton!] : []);

    for (int i = 0; i < sourceActions.length; i++) {
      // [FIX] Removed fixed SizedBox constraint to allow pills to expand
      rightWidgets.add(
        Container(
          height: buttonSize,
          constraints: BoxConstraints(minWidth: buttonSize),
          alignment: Alignment.center,
          child: sourceActions[i],
        ),
      );

      // Estimate width for centering logic (Assuming standard size if not dual)
      // This is an approximation for the center title calculation.
      calculatedActionsWidth += buttonSize;

      if (i < sourceActions.length - 1) {
        rightWidgets.add(SizedBox(width: gapSize));
        calculatedActionsWidth += gapSize;
      }
    }

    if (rightWidgets.isNotEmpty) {
      rightWidgets.add(SizedBox(width: horizontalPadding));
      calculatedActionsWidth += horizontalPadding;
    }

    // --- CENTER CALCULATION ---
    final double maxSideWidth =
        math.max(calculatedLeadingWidth, calculatedActionsWidth);
    final double availableCenteredSpace = screenWidth - (maxSideWidth * 2);
    final double targetWidth = screenWidth * 0.70;
    final double finalTitleMaxWidth =
        math.min(targetWidth, availableCenteredSpace);

    return Stack(
      children: [
        AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          toolbarHeight: kToolbarHeight,
          flexibleSpace: showGradient
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.background.withValues(alpha: 1),
                        AppColors.background.withValues(alpha: 0),
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                )
              : null,
          leading: leftWidgets.isNotEmpty
              ? Padding(
                  padding: EdgeInsetsDirectional.only(start: horizontalPadding),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: leftWidgets,
                  ),
                )
              : null,
          leadingWidth: leftWidgets.isNotEmpty ? calculatedLeadingWidth : null,
          actions: rightWidgets,
          title: null,
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top,
          left: 0,
          right: 0,
          height: kToolbarHeight,
          child: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: finalTitleMaxWidth > 0 ? finalTitleMaxWidth : 0,
              ),
              child: _AnimatedTitleWrapper(
                controller: scrollController,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.center,
                  child: title ??
                      (titleText != null
                          ? Text(
                              titleText!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Ubuntu',
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: AppColors.primaryColor.inverted,
                              ),
                              maxLines: 1,
                            )
                          : const SizedBox.shrink()),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// --- 2. DUAL ACTION PILL (The Morphing Button) ---
class DualActionPill extends StatelessWidget {
  final bool isDual;
  final Widget mainIcon; // Right side (New Chat / Flux)
  final Widget? secondaryIcon; // Left side (Share)
  final VoidCallback onMainTap;
  final VoidCallback? onSecondaryTap;
  final double size;

  const DualActionPill({
    super.key,
    required this.isDual,
    required this.mainIcon,
    this.secondaryIcon,
    required this.onMainTap,
    this.onSecondaryTap,
    this.size = 42.0,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final invertedColor = AppColors.primaryColor.inverted;
    final Color backgroundColor = AppColors.background;
    final Color borderColor = invertedColor.withValues(alpha: 0.12);
    final Color splashColor = invertedColor.withValues(alpha: 0.1);

    // Using 16.0 to match AppBarButton's radius
    const double radius = 16.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      // Bouncy expansion
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- LEFT BUTTON (Secondary / Share) ---
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: Alignment.centerRight,
              child: isDual
                  ? Row(
                      children: [
                        SizedBox(
                          width: size,
                          height: size,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              onSecondaryTap?.call();
                            },
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(radius),
                              bottomLeft: Radius.circular(radius),
                            ),
                            splashColor: splashColor,
                            highlightColor: splashColor.withValues(alpha: 0.05),
                            child: Center(
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: secondaryIcon ?? const SizedBox.shrink(),
                              ),
                            ),
                          ),
                        ),
                        // --- DIVIDER ---
                        Container(
                          width: 1,
                          height: size * 0.6, // Slightly shorter for elegance
                          color: borderColor,
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),

            // --- RIGHT BUTTON (Main / New Chat / Flux) ---
            SizedBox(
              width: size,
              height: size,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onMainTap();
                },
                borderRadius: isDual
                    ? const BorderRadius.only(
                        topRight: Radius.circular(radius),
                        bottomRight: Radius.circular(radius),
                      )
                    : BorderRadius.circular(radius),
                splashColor: splashColor,
                highlightColor: splashColor.withValues(alpha: 0.05),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, animation) {
                      return ScaleTransition(
                        scale: animation,
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: mainIcon,
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

// --- 3. BACK BUTTON ---
class _BackButton extends StatelessWidget {
  final double buttonSize;
  final double iconSize;
  final VoidCallback onPressed;

  const _BackButton({
    required this.buttonSize,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;
    final double rotationAngle = isRtl ? -math.pi / 2 : math.pi / 2;

    return AppBarButton(
      size: buttonSize,
      onTap: onPressed,
      child: Transform.rotate(
        angle: rotationAngle,
        child: SvgPicture.asset(
          'assets/icons/arrov.svg',
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

// --- 4. AXON TOGGLE BUTTON ---
class _AxonToggleButton extends StatefulWidget {
  final double buttonSize;
  final double iconSize;
  final VoidCallback onPressed;

  const _AxonToggleButton({
    required this.buttonSize,
    required this.iconSize,
    required this.onPressed,
  });

  @override
  State<_AxonToggleButton> createState() => _AxonToggleButtonState();
}

class _AxonToggleButtonState extends State<_AxonToggleButton> {
  bool _isActivated = false;
  Animation<double>? _axonAnimation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mainScreen = context.findAncestorStateOfType<MainScreenState>();

    if (mainScreen != null) {
      _axonAnimation?.removeListener(_onAxonStateChanged);
      _axonAnimation = mainScreen.axonAnimation;
      _axonAnimation?.addListener(_onAxonStateChanged);
      _onAxonStateChanged();
    }
  }

  @override
  void dispose() {
    _axonAnimation?.removeListener(_onAxonStateChanged);
    super.dispose();
  }

  void _onAxonStateChanged() {
    if (_axonAnimation == null) return;
    final bool isOpen = _axonAnimation!.value > 0.01;
    if (_isActivated != isOpen) {
      setState(() {
        _isActivated = isOpen;
      });
    }
  }

  void _handleTap() {
    HapticFeedback.mediumImpact();
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return AppBarButton(
      size: widget.buttonSize,
      enableHaptic: false,
      onTap: _handleTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeInOutBack,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (Widget child, Animation<double> animation) {
          return ScaleTransition(
            scale: animation,
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        child: SvgPicture.asset(
          _isActivated
              ? 'assets/icons/on/axon.svg'
              : 'assets/icons/off/axon.svg',
          key: ValueKey<bool>(_isActivated),
          width: widget.iconSize,
          height: widget.iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }
}

// --- 5. ANIMATED TITLE WIDGET ---
class _AnimatedTitleWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController? controller;

  const _AnimatedTitleWrapper({
    required this.child,
    this.controller,
  });

  @override
  State<_AnimatedTitleWrapper> createState() => _AnimatedTitleWrapperState();
}

class _AnimatedTitleWrapperState extends State<_AnimatedTitleWrapper> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
  }

  @override
  void didUpdateWidget(_AnimatedTitleWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onScroll);
      widget.controller?.addListener(_onScroll);
      WidgetsBinding.instance.addPostFrameCallback((_) => _checkVisibility());
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    _checkVisibility();
  }

  void _checkVisibility() {
    if (widget.controller == null || !widget.controller!.hasClients) return;
    if (!mounted) return;

    final double screenHeight = MediaQuery.sizeOf(context).height;
    final double dynamicThreshold = screenHeight * 0.025;
    final double offset = widget.controller!.offset;
    final bool shouldBeVisible = offset <= dynamicThreshold;

    if (_isVisible != shouldBeVisible) {
      setState(() {
        _isVisible = shouldBeVisible;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null) {
      return widget.child;
    }
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: widget.child,
    );
  }
}

// --- 6. STANDARD PILL BUTTON ---
class AppBarButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size;
  final bool isTitle;
  final bool enableHaptic;

  const AppBarButton({
    super.key,
    required this.child,
    required this.onTap,
    this.size = 42.0,
    this.isTitle = false,
    this.enableHaptic = true,
  });

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();
    final invertedColor = AppColors.primaryColor.inverted;
    final Color backgroundColor = AppColors.background;
    final Color borderColor = invertedColor.withValues(alpha: 0.12);
    final Color splashColor = invertedColor.withValues(alpha: 0.1);

    const double radius = 16.0;

    return Container(
      width: isTitle ? null : size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          onTap: () {
            if (enableHaptic) HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: BorderRadius.circular(radius),
          splashColor: splashColor,
          highlightColor: splashColor.withValues(alpha: 0.05),
          child: Container(
            alignment: Alignment.center,
            padding: isTitle
                ? const EdgeInsets.symmetric(horizontal: 20)
                : EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
