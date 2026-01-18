// lib/meet.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:cortex/app.dart';
import 'package:cortex/initialization.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A custom ScrollPhysics to prevent swiping back in a PageView.
class NoGoBackScrollPhysics extends BouncingScrollPhysics {
  const NoGoBackScrollPhysics({super.parent});

  @override
  NoGoBackScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return NoGoBackScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // If the user tries to swipe back (offset is positive for PageView from left to right),
    // we block the movement by returning 0.0.
    if (offset > 0) {
      return 0.0;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }
}


/// A data class to hold the content for a single onboarding page.
class _OnboardingPageData {
  final String imageAsset;
  final String title;
  final String description;

  const _OnboardingPageData({
    required this.imageAsset,
    required this.title,
    required this.description,
  });
}

/// The main onboarding screen widget.
/// Manages the PageView, state, and navigation logic.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool _isPageReady = false;

  // Tracks the current page index for the "point of no return" logic.
  int _currentPage = 0;

  // Prevents listener from firing while an auto-scroll is in progress.
  bool _isAnimatingAutomatically = false;

  @override
  void initState() {
    super.initState();
    // Listen to scroll movements to implement the "point of no return" feature.
    _pageController.addListener(_scrollListener);
  }

  /// Implements "point of no return" swipe.
  /// If the user swipes more than 15% towards the next page,
  /// the animation completes automatically, preventing them from swiping back.
  void _scrollListener() {
    if (_isPageReady && !_isAnimatingAutomatically &&
        _pageController.page! > _currentPage + 0.15) {
      _isAnimatingAutomatically = true;
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ).whenComplete(() {
        if (mounted) {
          _isAnimatingAutomatically = false;
        }
      });
    }
  }

  Future<void> _onFinish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_onboarding', true);

    if (!mounted) return;
    context.read<AppInitializer>().completeOnboarding();
  }

  @override
  void dispose() {
    _pageController.removeListener(_scrollListener);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userProvider = context.watch<UserProvider>();

    String displayName;

    if (userProvider.isLoggedIn) {
      displayName = userProvider.username;
    } else {
      displayName = l10n.dude.toLowerCase();
    }

    final formattedDesc1 = l10n.onboardingDesc1(displayName);

    final List<_OnboardingPageData> pages = [
      _OnboardingPageData(
        imageAsset: 'assets/neuro/greeting.png',
        title: l10n.onboardingTitle1,
        description: formattedDesc1,
      ),
      _OnboardingPageData(
        imageAsset: 'assets/neuro/angry.png',
        title: l10n.onboardingTitle2,
        description: l10n.onboardingDesc2,
      ),
      _OnboardingPageData(
        imageAsset: 'assets/neuro/smiley.png',
        title: l10n.onboardingTitle3,
        description: l10n.onboardingDesc3,
      ),
      _OnboardingPageData(
        imageAsset: 'assets/neuro/powerful.png',
        title: l10n.onboardingTitle4,
        description: l10n.onboardingDesc4,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: PageView.builder(
          controller: _pageController,
          physics: _isPageReady
              ? const NoGoBackScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          onPageChanged: (int page) {
            setState(() {
              _isPageReady = false;
              _currentPage =
                  page; // Update current page for the scroll listener.
            });
          },
          itemCount: pages.length + 1,
          itemBuilder: (context, index) {
            if (index < pages.length) {
              return _OnboardingContentPage(
                key: ValueKey('onboarding_page_$index'),
                data: pages[index],
                pageController: _pageController,
                onAnimationComplete: () {
                  if (mounted) {
                    setState(() => _isPageReady = true);
                  }
                },
              );
            } else {
              return _FinalOnboardingPage(onFinish: _onFinish);
            }
          },
        ),
      ),
    );
  }
}

class _OnboardingContentPage extends StatefulWidget {
  final _OnboardingPageData data;
  final VoidCallback onAnimationComplete;
  final PageController pageController;

  const _OnboardingContentPage({
    super.key,
    required this.data,
    required this.onAnimationComplete,
    required this.pageController,
  });

  @override
  State<_OnboardingContentPage> createState() => _OnboardingContentPageState();
}

class _OnboardingContentPageState extends State<_OnboardingContentPage>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _slideController;

  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _imageSlideAnimation;
  late Animation<double> _imageFadeAnimation;

  bool _showSwipePrompt = false;

  @override
  void initState() {
    super.initState();
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )
      ..repeat();

    // Staggered animations for a more fluid feel
    _textSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
        ));
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOut),
    ));
    _imageSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
            .animate(CurvedAnimation(
          parent: _mainController,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
        ));
    _imageFadeAnimation = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));

    _mainController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onAnimationComplete(); // Enable swiping/tapping immediately.

        // Delay the appearance of the swipe prompt for a better UX.
        Future.delayed(const Duration(milliseconds: 750), () {
          if (mounted) {
            setState(() => _showSwipePrompt = true);
          }
        });
      }
    });

    _mainController.forward();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_showSwipePrompt) {
      widget.pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Same layout ratio as the original version:
        // - Top 60%: text
        // - Bottom 40%: visible part of image (only top 60% of full image is shown)
        final double textContainerHeight = availableHeight * 0.60;
        final double imageVisibleHeight = availableHeight * 0.40;

        // We want only 60% of the image to be visible inside imageVisibleHeight.
        // So: imageVisibleHeight = imageHeight * 0.60  ->  imageHeight = imageVisibleHeight / 0.60
        final double imageHeight = imageVisibleHeight / 0.6;
        final double imageOverflow = imageHeight - imageVisibleHeight;

        // Base font sizes derived from text container height, then clamped.
        double titleFontSize =
        (textContainerHeight * 0.12).clamp(22.0, 38.0);
        double descFontSize =
        (textContainerHeight * 0.055).clamp(14.0, 19.0);
        final double promptIconSize =
        (descFontSize * 1.1).clamp(16.0, 20.0);
        final double swipeFontSize =
        (textContainerHeight * 0.035).clamp(12.0, 16.0);

        return GestureDetector(
          onTap: _nextPage,
          child: Stack(
            children: [
              // IMAGE at the bottom, with only its top 60% visible (bottom clipped).
              Positioned(
                bottom: -imageOverflow,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _imageFadeAnimation,
                  child: SlideTransition(
                    position: _imageSlideAnimation,
                    child: Image.asset(
                      widget.data.imageAsset,
                      height: imageHeight,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // TEXT block at the top 60% of the screen.
              SizedBox(
                height: textContainerHeight,
                width: availableWidth,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    availableWidth * 0.10,
                    textContainerHeight * 0.06,
                    availableWidth * 0.10,
                    0,
                  ),
                  child: FadeTransition(
                    opacity: _textFadeAnimation,
                    child: SlideTransition(
                      position: _textSlideAnimation,
                      child: Center(
                        // FittedBox ensures the whole text block always fits
                        // into the reserved height without needing scroll.
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.topCenter,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: availableWidth * 0.86,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Title
                                Text(
                                  widget.data.title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor.inverted,
                                  ),
                                ),
                                SizedBox(height: textContainerHeight * 0.04),

                                // Description
                                Text(
                                  widget.data.description,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: descFontSize,
                                    color: AppColors.tertiaryColor,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: textContainerHeight * 0.06),

                                // Swipe hint
                                AnimatedOpacity(
                                  opacity: _showSwipePrompt ? 1.0 : 0.0,
                                  duration:
                                  const Duration(milliseconds: 500),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        AppLocalizations.of(context)!
                                            .swipeToContinue,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: swipeFontSize,
                                          color: AppColors.tertiaryColor,
                                        ),
                                      ),
                                      SizedBox(
                                        height:
                                        textContainerHeight * 0.015,
                                      ),
                                      _buildFlowingArrows(promptIconSize),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFlowingArrows(double iconSize) {
    const int arrowCount = 3;
    final double animationWidth = iconSize * 2.5;
    final double totalTravelDistance = animationWidth + iconSize;
    final double fadeStartPoint = animationWidth - iconSize;
    final double fadeEndPoint = animationWidth;

    return SizedBox(
      width: animationWidth,
      height: iconSize,
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _slideController,
          builder: (context, child) {
            return Stack(
              children: List.generate(arrowCount, (i) {
                final double offsetValue = (_slideController.value +
                    (i / arrowCount)) % 1.0;
                final double leftPosition = (offsetValue *
                    totalTravelDistance) - iconSize;

                double opacity = 1.0;
                if (leftPosition + (iconSize / 2) > fadeStartPoint) {
                  final double fadeProgress = (leftPosition + (iconSize / 2) -
                      fadeStartPoint) / (fadeEndPoint - fadeStartPoint);
                  opacity = (1.0 - fadeProgress).clamp(0.0, 1.0);
                }

                return Positioned(
                  left: leftPosition,
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: -math.pi / 2,
                      child: SvgPicture.asset(
                        'assets/icons/arrov.svg',
                        width: iconSize,
                        height: iconSize,
                        colorFilter: ColorFilter.mode(
                          AppColors.senaryColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class _FinalOnboardingPage extends StatefulWidget {
  final Future<void> Function() onFinish;

  const _FinalOnboardingPage({required this.onFinish});

  @override
  State<_FinalOnboardingPage> createState() => _FinalOnboardingPageState();
}

class _FinalOnboardingPageState extends State<_FinalOnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _buttonPulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _contentSlideAnimation;
  late Animation<double> _buttonPulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1500), vsync: this);

    _buttonPulseController = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this
    )
      ..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut)));

    _contentSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
            CurvedAnimation(parent: _controller,
                curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic)));

    _buttonPulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeInOut)
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final double availableHeight = constraints.maxHeight;
        final double availableWidth = constraints.maxWidth;

        // Same structure as the original:
        // - Top ~65%: text
        // - Bottom ~35%: visible part of the image (only top 60% of full image)
        final double textContainerHeight = availableHeight * 0.65;
        final double imageVisibleHeight = availableHeight * 0.35;

        // Only the top 60% of the image is visible.
        final double imageHeight = imageVisibleHeight / 0.6;
        final double imageOverflow = imageHeight - imageVisibleHeight;

        // Dynamic font sizes based on text container height.
        final double titleFontSize =
        (textContainerHeight * 0.08).clamp(22.0, 32.0);
        final double readyFontSize =
        (textContainerHeight * 0.12).clamp(28.0, 42.0);
        final double descFontSize =
        (textContainerHeight * 0.05).clamp(15.0, 19.0);
        final double buttonFontSize =
        (textContainerHeight * 0.15).clamp(36.0, 52.0);

        return Stack(
          children: [
            // IMAGE at the bottom with bottom part cropped out.
            Positioned(
              bottom: -imageOverflow,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/neuro/call.png',
                  height: imageHeight,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // TEXT + "YES" button block at the top, fully responsive.
            SizedBox(
              height: textContainerHeight,
              width: availableWidth,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  availableWidth * 0.10,
                  textContainerHeight * 0.06,
                  availableWidth * 0.10,
                  0,
                ),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _contentSlideAnimation,
                    child: Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.topCenter,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: availableWidth * 0.88,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Final title (e.g., "Revolution Time.")
                              Text(
                                l10n.onboardingFinalTitle,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: titleFontSize,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor.inverted,
                                ),
                              ),
                              SizedBox(
                                height: textContainerHeight * 0.03,
                              ),

                              // Description paragraph
                              Text(
                                l10n.onboardingFinalDescription,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: descFontSize,
                                  color: AppColors.tertiaryColor,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(
                                height: textContainerHeight * 0.05,
                              ),

                              // "ARE YOU READY?" text
                              Text(
                                l10n.onboardingFinalQuestion,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: readyFontSize,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.primaryColor.inverted,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              SizedBox(
                                height: textContainerHeight * 0.04,
                              ),

                              // Pulsing "YES" (or equivalent) button text
                              GestureDetector(
                                onTap: widget.onFinish,
                                child: FadeTransition(
                                  opacity: _buttonPulseAnimation,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical:
                                      textContainerHeight * 0.02,
                                    ),
                                    child: Text(
                                      l10n.onboardingFinalButton,
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: buttonFontSize,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.senaryColor,
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
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}