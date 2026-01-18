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
  /// Automatically decides: Shows 'Back' if the THIS ROUTE can pop.
  /// Ignores overlays/sheets/dialogs open on top of it.
  auto,

  /// Forces the Axon (Sidebar) toggle button.
  axon,

  /// Forces the Back (Exit) button.
  back,

  /// Hides the main leading button entirely (useful if you only want custom leadingActions).
  none,
}

// --- 1. THE UNIVERSAL APP BAR (Zero-Lag, Haptic & Animated & RTL-Ready) ---
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
    final double screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final bool isTablet = screenWidth >= 600;

    final double buttonSize = isTablet ? 48.0 : 42.0;
    final double iconSize = isTablet ? 26.0 : 22.0;
    final double horizontalPadding = screenWidth * 0.04;
    final double gapSize = 12.0;

    // --- SMART LEADING LOGIC ---
    final ModalRoute<dynamic>? parentRoute = ModalRoute.of(context);
    final bool canPopThisRoute = parentRoute?.canPop ?? false;

    final bool showBackButton = leadingMode == CortexLeadingMode.back ||
        (leadingMode == CortexLeadingMode.auto && canPopThisRoute);
    final bool hideLeading = leadingMode == CortexLeadingMode.none;

    // --- PREPARE LEFT WIDGETS ---
    // Note: In RTL, these will visually appear on the Right side.
    final List<Widget> leftWidgets = [];

    if (!hideLeading) {
      if (showBackButton) {
        leftWidgets.add(
          _BackButton(
            buttonSize: buttonSize,
            iconSize: iconSize,
            onPressed: onLeadingPressed ?? () => Navigator.of(context).pop(),
          ),
        );
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
      }
    }

    if (leadingActions != null && leadingActions!.isNotEmpty) {
      if (leftWidgets.isNotEmpty) {
        leftWidgets.add(SizedBox(width: gapSize));
      }
      for (int i = 0; i < leadingActions!.length; i++) {
        leftWidgets.add(leadingActions![i]);
        if (i < leadingActions!.length - 1) {
          leftWidgets.add(SizedBox(width: gapSize));
        }
      }
    }

    // --- PREPARE RIGHT WIDGETS ---
    // Note: In RTL, these will visually appear on the Left side.
    final List<Widget> rightWidgets = [];
    final List<Widget> sourceActions =
        actions ?? (actionButton != null ? [actionButton!] : []);

    for (int i = 0; i < sourceActions.length; i++) {
      rightWidgets.add(
        SizedBox(
          width: buttonSize,
          height: buttonSize,
          child: Center(child: sourceActions[i]),
        ),
      );
      if (i < sourceActions.length - 1) {
        rightWidgets.add(SizedBox(width: gapSize));
      }
    }

    if (rightWidgets.isEmpty) {
      rightWidgets.add(SizedBox(width: buttonSize));
    }

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      titleSpacing: horizontalPadding,
      centerTitle: true,
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
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // "Leading" Section (Visually Right in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: leftWidgets,
          ),
          // Title Section
          if (title != null)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Center(child: title!),
              ),
            )
          else
            if (titleText != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Center(
                    child: _AnimatedTitle(
                      text: titleText!,
                      controller: scrollController,
                    ),
                  ),
                ),
              )
            else
              const Spacer(),
          // "Actions" Section (Visually Left in RTL)
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: rightWidgets,
          ),
        ],
      ),
    );
  }
}

// --- 2. BACK BUTTON (Direction-Aware Rotation) ---
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
    // Detect RTL
    final bool isRtl = Directionality.of(context) == TextDirection.rtl;

    // LTR Logic: Rotate 90deg (pi/2) to point Left (assuming SVG points Down).
    // RTL Logic: Rotate -90deg (-pi/2) to point Right.
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

// --- 3. AXON TOGGLE BUTTON (Synced & Elastic Animation) ---
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

// --- 4. ANIMATED TITLE WIDGET (FADE ONLY - No Slide) ---
class _AnimatedTitle extends StatefulWidget {
  final String text;
  final ScrollController? controller;

  const _AnimatedTitle({
    required this.text,
    this.controller,
  });

  @override
  State<_AnimatedTitle> createState() => _AnimatedTitleState();
}

class _AnimatedTitleState extends State<_AnimatedTitle> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_AnimatedTitle oldWidget) {
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

    final double screenHeight = MediaQuery
        .of(context)
        .size
        .height;
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
    final TextStyle textStyle = TextStyle(
      fontFamily: 'Ubuntu',
      fontWeight: FontWeight.w500,
      fontSize: 18,
      color: AppColors.primaryColor.inverted,
    );

    if (widget.controller == null) {
      return Text(widget.text,
          style: textStyle, overflow: TextOverflow.ellipsis);
    }

    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Text(widget.text,
          style: textStyle, overflow: TextOverflow.ellipsis),
    );
  }
}

// --- 5. HIGH-PERFORMANCE PILL BUTTON (Faux-Glass & Auto Haptics) ---
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