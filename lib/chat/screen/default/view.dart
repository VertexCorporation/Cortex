// lib/chat/screen/default/view.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/chat/providers/session.dart';
import '../../../../app.dart';
import '../../../../library/providers/catalog.dart';
import '../../../../library/providers/local.dart';
import '../../../../main.dart';
import '../../services/select.dart';
import '../widgets/bottom/panels/selection/sheet.dart';
import 'cards.dart';

class ChatEmptyState extends StatefulWidget {
  const ChatEmptyState({super.key});

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

    // --- Mode Transition Setup ---
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _modeAnimation = CurvedAnimation(
      parent: _modeController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final isFlux = context.read<ChatSessionProvider>().isFluxMode;

    // Initialize state on first run
    if (_wasFluxMode == null) {
      _wasFluxMode = isFlux;
      _modeController.value = isFlux ? 1.0 : 0.0;
      return;
    }

    // Trigger animation if state changed
    if (_wasFluxMode != isFlux) {
      _wasFluxMode = isFlux;
      if (isFlux) {
        _modeController.forward();
      } else {
        _modeController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _entranceController.dispose();
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

    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final screenHeight = mediaQuery.size.height;
    final l10n = AppLocalizations.of(context)!;
    final bool isTablet = mediaQuery.size.shortestSide >= 600;

    // Colors
    final Color contentColor = AppColors.primaryColor.inverted;

    // Dimensions
    final double logoSize = isTablet ? screenWidth * 0.15 : screenWidth * 0.22;
    final double verticalSpacing = screenHeight * 0.025;
    final double cardHeight =
        isTablet ? screenHeight * 0.08 : screenWidth * 0.14;
    final double titleSize = isTablet ? screenWidth * 0.04 : screenWidth * 0.06;
    final double bodyFontSize =
        isTablet ? screenWidth * 0.025 : screenWidth * 0.04;
    final double iconSize = isTablet ? screenWidth * 0.04 : screenWidth * 0.065;
    final double contentMaxWidth = isTablet ? screenWidth * 0.6 : screenWidth;
    final double horizontalPadding = isTablet ? 0 : screenWidth * 0.12;
    final double gapSize = screenHeight * 0.015;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: _modeAnimation,
          builder: (context, child) {
            // "Smart Algorithm" for dynamic spacing
            // Normal Mode (0.0): Top 2x, Bottom 1x
            // Flux Mode (1.0): Top 3x, Bottom 1x
            // We interpolate the top weight smoothly
            final double topWeight = 2.0 + _modeAnimation.value;
            final int topFlex = (topWeight * 1000).round();
            final int bottomFlex = 1000;

            return CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: [
                      Spacer(flex: topFlex),
                      Container(
                        width: contentMaxWidth,
                        padding:
                            EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // --- 1. LOGO AREA (Swapping) ---
                            SizedBox(
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
                                      scale: 1.0 - (_modeAnimation.value * 0.2),
                                      child: ScaleTransition(
                                        scale: _breathingScaleAnimation,
                                        child: SvgPicture.asset(
                                          'assets/cortex.svg',
                                          width: logoSize,
                                          height: logoSize,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                            AppColors.primaryColor.inverted,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // FLUX (GHOST) Logo
                                  Opacity(
                                    opacity:
                                        _modeAnimation.value.clamp(0.0, 1.0),
                                    child: Transform.scale(
                                      scale: 0.8 + (_modeAnimation.value * 0.2),
                                      child: ScaleTransition(
                                        scale: _breathingScaleAnimation,
                                        child: SvgPicture.asset(
                                          'assets/icons/on/ghost.svg',
                                          width: logoSize,
                                          height: logoSize,
                                          fit: BoxFit.contain,
                                          colorFilter: ColorFilter.mode(
                                              contentColor, BlendMode.srcIn),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Fixed gap
                            SizedBox(height: verticalSpacing - gapSize),

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
                                          0, -50.0 * _modeAnimation.value),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          // Greeting
                                          _buildEntranceItem(
                                            startTime: 0.0,
                                            endTime: 0.5,
                                            child: Text(
                                              l10n.howCanIHelpWith,
                                              style: TextStyle(
                                                fontSize: titleSize,
                                                letterSpacing: 0.5,
                                                color: contentColor,
                                                fontWeight: FontWeight.w600,
                                                height: 1.2,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          SizedBox(height: verticalSpacing),

                                          // Buttons
                                          _buildEntranceItem(
                                            startTime: 0.2,
                                            endTime: 0.7,
                                            child: DefaultCard(
                                              text: l10n.explore,
                                              height: cardHeight,
                                              iconWidget: Icon(
                                                Icons.visibility_outlined,
                                                color: contentColor,
                                                size: iconSize,
                                              ),
                                              onTap: () {
                                                showModelSelectionSheet(
                                                  context: context,
                                                  localizations: l10n,
                                                  currentModelId: context
                                                          .read<
                                                              ChatSessionProvider>()
                                                          .modelId ??
                                                      '',
                                                  onModelSelected: (String id) {
                                                    final catalog = context.read<
                                                        ModelCatalogProvider>();
                                                    final model = catalog
                                                        .allModels
                                                        .firstWhere(
                                                            (m) => m.id == id);
                                                    context
                                                        .read<
                                                            SelectionService>()
                                                        .selectModel(model);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                          SizedBox(height: gapSize),
                                          _buildEntranceItem(
                                            startTime: 0.4,
                                            endTime: 0.9,
                                            child: DefaultCard(
                                              text: l10n.useOffline,
                                              height: cardHeight,
                                              iconWidget: SvgPicture.asset(
                                                'assets/icons/context.svg',
                                                width: iconSize,
                                                height: iconSize,
                                                colorFilter: ColorFilter.mode(
                                                    contentColor,
                                                    BlendMode.srcIn),
                                              ),
                                              onTap: () =>
                                                  _handleOfflineTap(context),
                                            ),
                                          ),
                                          SizedBox(height: gapSize),
                                          _buildEntranceItem(
                                            startTime: 0.6,
                                            endTime: 1.0,
                                            child: DefaultCard(
                                              text: l10n.news,
                                              height: cardHeight,
                                              iconWidget: SvgPicture.asset(
                                                'assets/icons/news.svg',
                                                width: iconSize,
                                                height: iconSize,
                                                colorFilter: ColorFilter.mode(
                                                    contentColor,
                                                    BlendMode.srcIn),
                                              ),
                                              onTap: () {
                                                mainScreenKey.currentState
                                                    ?.openNewsScreen();
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
                                    opacity: ((_modeAnimation.value - 0.5) * 2)
                                        .clamp(0.0, 1.0),
                                    child: Transform.translate(
                                      offset: Offset(0,
                                          50.0 * (1.0 - _modeAnimation.value)),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          SizedBox(height: verticalSpacing),
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
                                                horizontal: logoSize * 0.2),
                                            child: Text(
                                              l10n.fluxChatDescription,
                                              style: TextStyle(
                                                fontSize: bodyFontSize,
                                                color: contentColor.withValues(
                                                    alpha: 0.8),
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
                      Spacer(flex: bottomFlex),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- Helper: Logic for Offline Button ---
  void _handleOfflineTap(BuildContext context) {
    final catalog = context.read<ModelCatalogProvider>();
    final local = context.read<ModelLocalStateProvider>();
    final session = context.read<ChatSessionProvider>();
    final selectionService = context.read<SelectionService>();
    final l10n = AppLocalizations.of(context)!;

    // 1. Check if we have any offline model downloaded on disk
    final offlineModels = catalog.allModels.where((m) => m.type == 'offline');
    final hasDownloadedModel = offlineModels.any((m) {
      final path = local.getFilePathById(m.id);
      return local.isModelOnDisk(path);
    });

    if (hasDownloadedModel) {
      showModelSelectionSheet(
        context: context,
        localizations: l10n,
        currentModelId: session.modelId ?? '',
        onModelSelected: (String id) {
          final model = catalog.allModels.firstWhere((m) => m.id == id);
          selectionService.selectModel(model);
        },
      );
    } else {
      mainScreenKey.currentState?.switchToLibrary(pulse: true);
    }
  }
}
