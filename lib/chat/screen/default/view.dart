// lib/chat/screen/default/view.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/main.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/login/upgrade.dart';
import '../../../../app.dart';

class ChatEmptyState extends StatefulWidget {
  final double bottomPadding;

  const ChatEmptyState({super.key, this.bottomPadding = 0});

  @override
  State<ChatEmptyState> createState() => _ChatEmptyStateState();
}

class _ChatEmptyStateState extends State<ChatEmptyState>
    with TickerProviderStateMixin {
  // 1. Breathing Animation (Continuous)
  late AnimationController _breathingController;
  late Animation<double> _breathingScaleAnimation;

  // 2. Entrance Animation (On Load)
  late AnimationController _entranceController;

  // 2.5 Timed sequence (description <-> buttons)
  late final AnimationController _swapController;
  int _sequenceToken = 0;

  // 2.6 Bounce Animation (Cortex Icon Tap)
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // 2.7 Rainbow Border Animation
  late AnimationController _rainbowController;

  // 3. Mode Transition Animation (Standard <-> Flux)
  late AnimationController _modeController;
  late Animation<double> _modeAnimation;

  // State tracking to trigger animations
  bool? _wasFluxMode;

  @override
  void initState() {
    super.initState();

    // --- Breathing Setup ---
    _breathingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _breathingScaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _breathingController,
        curve: Curves.easeInOutQuad,
      ),
    );

    // --- Entrance Setup ---
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _entranceController.forward();

    _swapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    // --- Bounce Setup (for Cortex icon tap) ---
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.85), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.85, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeInOut,
    ));

    // --- Rainbow Setup ---
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    // --- Mode Transition Setup ---
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutCubic,
    );

    _startStandardDefaultSequence();
  }

  bool _isVisible = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // TickerMode Visibility Handling
    final isVisible = TickerMode.valuesOf(context).enabled;
    if (_isVisible != isVisible) {
      _isVisible = isVisible;
      if (!isVisible) {
        // Stop async sequence loop when hidden
        _sequenceToken++;
      } else {
        // Resume sequence when visible
        _startStandardDefaultSequence();
      }
    }

    // Flux Mode State Handling
    final isFlux = context.read<ChatSessionProvider>().isFluxMode;

    // Initialize state on first run
    if (_wasFluxMode == null) {
      _wasFluxMode = isFlux;
      if (isFlux) {
        _modeController.value = 1.0;
        _sequenceToken++;
      }
      return;
    }

    // Handle subsequent mode changes
    if (_wasFluxMode != isFlux) {
      _wasFluxMode = isFlux;
      if (isFlux) {
        _sequenceToken++; // Cancel text cycle
        _modeController.forward();
      } else {
        _modeController.reverse();
        _startStandardDefaultSequence();
      }
    }
  }

  void _startStandardDefaultSequence([bool? startingWithButtonsOverride]) {
    final int token = ++_sequenceToken;

    // Kick a rebuild in case we were mid-state (e.g. widget recreated).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sequenceToken != token) return;
      setState(() {});
    });

    () async {
      // Determine starting mode based on current _swapController value
      final bool startingWithButtons =
          startingWithButtonsOverride ?? (_swapController.value > 0.5);

      if (startingWithButtons) {
        // We're in Button Mode — wait 8s, then crossfade to text
        await Future.delayed(const Duration(seconds: 8));
        if (!mounted || _sequenceToken != token) return;

        await _swapController.reverse(from: 1.0).catchError((_) {});
        if (!mounted || _sequenceToken != token) return;
      }

      // Infinite loop: Text(4s) -> Buttons(8s) -> repeat
      while (mounted && _sequenceToken == token) {
        // Text mode for 4 seconds
        await Future.delayed(const Duration(seconds: 4));
        if (!mounted || _sequenceToken != token) return;

        // Crossfade to buttons
        await _swapController.forward(from: 0.0).catchError((_) {});
        if (!mounted || _sequenceToken != token) return;

        // Button mode for 8 seconds
        await Future.delayed(const Duration(seconds: 8));
        if (!mounted || _sequenceToken != token) return;

        // Crossfade back to text
        await _swapController.reverse(from: 1.0).catchError((_) {});
        if (!mounted || _sequenceToken != token) return;
      }
    }();
  }

  void _handleIconTap() {
    HapticFeedback.lightImpact();

    // 1. Play bounce animation
    _bounceController.forward(from: 0.0);

    bool targetAsButtons;
    // 2. Toggle current mode (let animation complete naturally)
    if (_swapController.value > 0.5) {
      // Currently showing buttons -> switch to text
      _swapController.reverse();
      targetAsButtons = false;
    } else {
      // Currently showing text -> switch to buttons
      _swapController.forward();
      targetAsButtons = true;
    }

    // 3. Restart the timer loop for the new mode
    _startStandardDefaultSequence(targetAsButtons);
  }

  Widget _buildFeatureButtons(BuildContext context, AppLocalizations l10n) {
    context.watch<ThemeProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    final horizontalPadding = screenWidth * 0.02;
    final buttonSpacing = screenWidth * 0.04;
    final rowSpacing = screenHeight * 0.012;
    final buttonHeight = screenHeight * 0.05;
    final iconSize = screenWidth * 0.052;
    final fontSize = screenWidth * 0.03;
    final borderRadius = screenWidth * 0.12;

    final catalog = context.watch<ModelCatalogProvider>();

    final hasImage = catalog.allModels
        .any((m) => m.outputs['image'] == true || m.category == 'image');
    final hasVideo = catalog.allModels
        .any((m) => m.outputs['video'] == true || m.category == 'video');
    final hasAudio = catalog.allModels
        .any((m) => m.outputs['audio'] == true || m.category == 'audio');

    final userProvider = context.watch<UserProvider>();
    final int subLevel = userProvider.activeSubscriptionLevel;
    // Lifetime or Ultra
    final bool isUltra = subLevel >= 3;

    return Padding(
      padding: EdgeInsets.only(
        left: horizontalPadding,
        right: horizontalPadding,
        top: buttonHeight * 0.15,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/make.svg',
                  title: l10n.featureCreateImageTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasImage,
                  onTap: () => _handleGeneration(context, 'image'),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/transition.svg',
                  title: l10n.featureCreateVideoTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasVideo,
                  isAnimatedRainbowBorder: !isUltra,
                  onTap: () => _handleGeneration(context, 'video'),
                ),
              ),
            ],
          ),
          SizedBox(height: rowSpacing),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/voice.svg',
                  title: l10n.featureCreateAudioTitle,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: !hasAudio,
                  onTap: () => _handleGeneration(context, 'audio'),
                ),
              ),
              SizedBox(width: buttonSpacing),
              Expanded(
                child: _buildBoxButton(
                  context,
                  width: null,
                  height: buttonHeight,
                  iconSize: iconSize,
                  fontSize: fontSize,
                  borderRadius: borderRadius,
                  buttonSpacing: buttonSpacing,
                  iconPath: 'assets/icons/context.svg',
                  title: l10n.useOffline,
                  iconColor:
                      AppColors.background.inverted.withValues(alpha: 0.2),
                  isDisabled: false,
                  onTap: () => _handleOfflineAction(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxButton(
    BuildContext context, {
    double? width,
    required double height,
    required double iconSize,
    required double fontSize,
    required double borderRadius,
    required double buttonSpacing,
    required String iconPath,
    required String title,
    required Color iconColor,
    required bool isDisabled,
    required VoidCallback onTap,
    bool isPremiumFeature = false,
    bool isAnimatedRainbowBorder = false,
  }) {
    final horizontalPadding = MediaQuery.sizeOf(context).width * 0.018;

    final border = BorderRadius.circular(borderRadius);
    final innerBorder = BorderRadius.circular(borderRadius - 1.5);

    final innerContent = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          iconPath,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
        SizedBox(width: buttonSpacing * 0.35),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted,
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (isPremiumFeature) ...[
                  SizedBox(width: buttonSpacing * 0.2),
                  SvgPicture.asset(
                    'assets/icons/sparkle.svg',
                    width: fontSize * 0.9,
                    height: fontSize * 0.9,
                    colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted,
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    final innerContainer = Ink(
      width: isAnimatedRainbowBorder ? null : width,
      height: isAnimatedRainbowBorder ? null : height,
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      decoration: BoxDecoration(
        color: isAnimatedRainbowBorder
            ? AppColors.background
            : AppColors.background.withValues(alpha: 0.4),
        border: isAnimatedRainbowBorder
            ? null
            : Border.all(
                color: AppColors.border,
                width: 0.5,
              ),
        borderRadius: isAnimatedRainbowBorder ? innerBorder : border,
      ),
      child: innerContent,
    );

    return Opacity(
      opacity: isDisabled ? 0.4 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: border,
        child: InkWell(
          borderRadius: border,
          onTap: isDisabled ? null : onTap,
          splashColor: iconColor.withValues(alpha: 0.14),
          highlightColor: iconColor.withValues(alpha: 0.06),
          child: isAnimatedRainbowBorder
              ? AnimatedBuilder(
                  animation: _rainbowController,
                  builder: (context, child) {
                    return Ink(
                      width: width,
                      height: height,
                      padding: const EdgeInsets.all(1.5),
                      decoration: BoxDecoration(
                        borderRadius: border,
                        gradient: SweepGradient(
                          transform: GradientRotation(
                              _rainbowController.value * 2 * math.pi),
                          colors: const [
                            Color(0xFFFF0080), // Pink
                            Color(0xFFFF4D4D), // Red
                            Color(0xFFFFAA00), // Orange
                            Color(0xFFFFDD00), // Yellow
                            Color(0xFF00CC76), // Green
                            Color(0xFF00AAFF), // Cyan
                            Color(0xFF7B61FF), // Purple
                            Color(0xFFFF0080), // Pink
                          ],
                        ),
                      ),
                      child: child,
                    );
                  },
                  child: innerContainer,
                )
              : innerContainer,
        ),
      ),
    );
  }

  void _handleGeneration(BuildContext context, String targetType) {
    if (targetType == 'video') {
      final userProvider = context.read<UserProvider>();
      if (userProvider.isAnonymous) {
        navigateToScreen(const UpgradeAccountScreen(showLoginFirst: true),
            direction: const Offset(0, 1));
        return;
      }
    }

    final catalog = context.read<ModelCatalogProvider>();
    final session = context.read<ChatSessionProvider>();
    final inputProvider = context.read<InputProvider>();
    final selectionService = context.read<SelectionService>();

    final candidates = catalog.allModels
        .where((m) => m.outputs[targetType] == true || m.category == targetType)
        .toList();

    if (candidates.isEmpty) return;

    final currentModel = session.selectedModel;
    final bool currentSupportsTarget = currentModel != null &&
        (currentModel.outputs[targetType] == true ||
            currentModel.category == targetType);

    inputProvider.clearFeatureMode();
    inputProvider.clearWebSearch();

    final targetModel = candidates.firstWhere(
      (m) => !m.isPremium,
      orElse: () => candidates.first,
    );

    // Select only if current model does not already support this generation type.
    if (!currentSupportsTarget) {
      selectionService.switchActiveModel(targetModel, context: context);
    }
  }

  void _handleOfflineAction(BuildContext context) {
    final catalog = context.read<ModelCatalogProvider>();
    final local = context.read<ModelLocalStateProvider>();
    final selectionService = context.read<SelectionService>();
    final inputProvider = context.read<InputProvider>();

    final offlineModels = catalog.allModels.where((m) => m.type == 'offline');
    final downloadedModels = offlineModels.where((m) {
      final path = local.getFilePathById(m.id);
      return local.isModelOnDisk(path);
    }).toList();

    if (downloadedModels.isNotEmpty) {
      inputProvider.clearWebSearch();
      inputProvider.setFeatureMode(ChatInputMode.offline);
      selectionService.switchActiveModel(downloadedModels.first,
          context: context);
    } else {
      mainScreenKey.currentState?.switchToLibrary(pulse: true);
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _entranceController.dispose();
    _swapController.dispose();
    _bounceController.dispose();
    _rainbowController.dispose();
    _modeController.dispose();
    super.dispose();
  }

  // --- Animation Helper for Initial Entrance ---
  Widget _buildEntranceItem({
    required Widget child,
    required double startTime,
    required double endTime,
  }) {
    final Animation<double> fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(startTime, endTime, curve: Curves.easeOut),
      ),
    );

    final Animation<Offset> slide = Tween<Offset>(
      begin: const Offset(0.0, -0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Interval(startTime, endTime, curve: Curves.easeOutCubic),
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
    context.watch<ThemeProvider>();
    context.watch<ChatSessionProvider>();

    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final l10n = AppLocalizations.of(context)!;
    final bool isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final bool isDesktop = screenWidth >= 800;

    // Colors
    final Color contentColor = AppColors.primaryColor.inverted;

    final double logoSize =
        isDesktop ? 120.0 : (isTablet ? screenWidth * 0.2 : screenWidth * 0.16);

    final double verticalSpacing = screenHeight * 0.025;

    final double titleSize =
        isDesktop ? 36.0 : (isTablet ? screenWidth * 0.04 : screenWidth * 0.06);
    final double bodyFontSize = isDesktop
        ? 16.0
        : (isTablet ? screenWidth * 0.025 : screenWidth * 0.04);

    final double contentMaxWidth =
        isDesktop ? 600.0 : (isTablet ? screenWidth * 0.6 : screenWidth);
    final double horizontalPadding =
        isDesktop ? 0 : (isTablet ? 0 : screenWidth * 0.12);
    final double topPadding = MediaQuery.paddingOf(context).top;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _modeAnimation,
          builder: (context, child) {
            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: AnimatedPadding(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(bottom: widget.bottomPadding),
                    child: Column(
                      children: [
                        const Spacer(),
                        Container(
                          width: contentMaxWidth,
                          padding: EdgeInsets.only(
                              top: topPadding,
                              right: horizontalPadding,
                              left: horizontalPadding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // --- 1. LOGO AREA (Swapping) ---
                              Center(
                                child: SizedBox(
                                  height: logoSize,
                                  width: logoSize,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // CORTEX Logo
                                      Opacity(
                                        opacity: (1.0 - _modeAnimation.value)
                                            .clamp(0.0, 1.0),
                                        child: Transform.scale(
                                          scale: 1.0 -
                                              (_modeAnimation.value * 0.2),
                                          child: ScaleTransition(
                                            scale: _breathingScaleAnimation,
                                            child: AnimatedBuilder(
                                              animation: _bounceAnimation,
                                              builder: (context, child) {
                                                return Transform.scale(
                                                  scale: _bounceAnimation.value,
                                                  child: child,
                                                );
                                              },
                                              child: IconButton(
                                                onPressed:
                                                    _modeAnimation.value < 0.5
                                                        ? _handleIconTap
                                                        : null,
                                                iconSize: logoSize,
                                                padding: EdgeInsets.zero,
                                                icon: SvgPicture.asset(
                                                  'assets/cortex.svg',
                                                  width: logoSize,
                                                  height: logoSize,
                                                  fit: BoxFit.fitWidth,
                                                  colorFilter: ColorFilter.mode(
                                                    AppColors
                                                        .primaryColor.inverted,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // FLUX (GHOST) Logo
                                      IgnorePointer(
                                        child: Opacity(
                                          opacity: _modeAnimation.value
                                              .clamp(0.0, 1.0),
                                          child: Transform.scale(
                                            scale: 0.8 +
                                                (_modeAnimation.value * 0.2),
                                            child: ScaleTransition(
                                              scale: _breathingScaleAnimation,
                                              child: SvgPicture.asset(
                                                'assets/icons/on/ghost.svg',
                                                width: logoSize,
                                                height: logoSize,
                                                fit: BoxFit.contain,
                                                colorFilter: ColorFilter.mode(
                                                    contentColor,
                                                    BlendMode.srcIn),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Fixed gap
                              SizedBox(height: verticalSpacing * 0.8),

                              // --- 2. CONTENT AREA (Sliding & Fading) ---
                              Stack(
                                children: [
                                  // STANDARD CONTENT
                                  IgnorePointer(
                                    ignoring: _modeAnimation.value > 0.1,
                                    child: Opacity(
                                      opacity: (1.0 - _modeAnimation.value * 2)
                                          .clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(
                                            0, -30.0 * _modeAnimation.value),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            // Title (Standard)
                                            _buildEntranceItem(
                                              startTime: 0.0,
                                              endTime: 0.5,
                                              child: Text(
                                                l10n.defaultViewTitle,
                                                style: TextStyle(
                                                  fontSize: titleSize,
                                                  letterSpacing: 0.5,
                                                  color: contentColor,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(
                                                height: verticalSpacing * 0.5),

                                            // Description <-> Buttons (Timed, smooth crossfade, same position)
                                            SizedBox(
                                              height:
                                                  (screenHeight * 0.05) * 2 +
                                                      (screenHeight * 0.018) +
                                                      (screenHeight * 0.03),
                                              child: AnimatedBuilder(
                                                animation: _swapController,
                                                builder: (context, _) {
                                                  final t =
                                                      _swapController.value;
                                                  final descOpacity =
                                                      (1.0 - t).clamp(0.0, 1.0);
                                                  final btnOpacity =
                                                      t.clamp(0.0, 1.0);

                                                  // Adding smooth sliding transition similar to a cube effect
                                                  final descOffset =
                                                      Offset(0, 30.0 * t);
                                                  final btnOffset = Offset(
                                                      0, -30.0 * (1 - t));

                                                  return Stack(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    children: [
                                                      IgnorePointer(
                                                        ignoring:
                                                            descOpacity < 0.05,
                                                        child: RepaintBoundary(
                                                          child: Transform
                                                              .translate(
                                                            offset: descOffset,
                                                            child: Opacity(
                                                              opacity:
                                                                  descOpacity,
                                                              child:
                                                                  _buildEntranceItem(
                                                                startTime: 0.1,
                                                                endTime: 0.6,
                                                                child: Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        logoSize *
                                                                            0.1,
                                                                  ),
                                                                  child: Text(
                                                                    l10n.defaultViewDescription,
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          bodyFontSize,
                                                                      color: contentColor.withValues(
                                                                          alpha:
                                                                              0.8),
                                                                      height:
                                                                          1.5,
                                                                    ),
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      IgnorePointer(
                                                        ignoring:
                                                            btnOpacity < 0.05,
                                                        child: RepaintBoundary(
                                                          child: Transform
                                                              .translate(
                                                            offset: btnOffset,
                                                            child: Opacity(
                                                              opacity:
                                                                  btnOpacity,
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                  horizontal:
                                                                      logoSize *
                                                                          0.1,
                                                                ),
                                                                child:
                                                                    _buildFeatureButtons(
                                                                  context,
                                                                  l10n,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // FLUX CONTENT
                                  IgnorePointer(
                                    ignoring: _modeAnimation.value < 0.9,
                                    child: Opacity(
                                      opacity:
                                          ((_modeAnimation.value - 0.5) * 2)
                                              .clamp(0.0, 1.0),
                                      child: Transform.translate(
                                        offset: Offset(
                                            0,
                                            30.0 *
                                                (1.0 - _modeAnimation.value)),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            SizedBox(
                                                height: verticalSpacing * 0.2),
                                            Text(
                                              l10n.fluxChatTitle,
                                              style: TextStyle(
                                                fontSize: titleSize,
                                                letterSpacing: 0.5,
                                                color: contentColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(
                                                height: verticalSpacing * 0.6),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: logoSize * 0.1),
                                              child: Text(
                                                l10n.fluxChatDescription,
                                                style: TextStyle(
                                                  fontSize: bodyFontSize,
                                                  color: contentColor
                                                      .withValues(alpha: 0.8),
                                                  height: 1.5,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
