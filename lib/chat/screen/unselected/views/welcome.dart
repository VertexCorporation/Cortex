// lib/chat/screen/unselected/views/welcome.dart

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../../fog.dart';
import '../../../../library/backend/data/entity.dart';
import '../widgets/cards.dart';
import '../widgets/feature.dart';
import '../widgets/news/service.dart';
import '../widgets/news/skeleton.dart';
import '../widgets/news/view.dart';

/// The WelcomeView is a dedicated "View" responsible for displaying the initial
/// animated welcome screen.
///
/// It encapsulates all entry animations and the layout for the greeting,
/// feature buttons, recent models, and news sections. It is designed to be
/// a self-contained unit managed by a parent controller.
class WelcomeView extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final List<ModelEntity> recentModels;
  final bool isLoading;
  final AppLocalizations localizations;
  final bool conversationLimitReached;
  final Function(ModelEntity, BuildContext) onSelectModel;
  final VoidCallback onShowExploreView;
  final VoidCallback onOfflineFeatureTap;
  final VoidCallback onStartDynamicChat;

  const WelcomeView({
    super.key,
    this.userData,
    required this.recentModels,
    required this.isLoading,
    required this.localizations,
    required this.conversationLimitReached,
    required this.onSelectModel,
    required this.onShowExploreView,
    required this.onOfflineFeatureTap,
    required this.onStartDynamicChat,
  });

  @override
  State<WelcomeView> createState() => _WelcomeViewState();
}

class _WelcomeViewState extends State<WelcomeView> with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _greetingSlideAnimation;
  late final Animation<double> _greetingFadeAnimation;
  late final Animation<Offset> _buttonsSlideAnimation;
  late final Animation<double> _buttonsFadeAnimation;
  late final Animation<Offset> _recentHeaderSlideAnimation;
  late final Animation<double> _recentHeaderFadeAnimation;
  late final Animation<Offset> _recentGridSlideAnimation;
  late final Animation<double> _recentGridFadeAnimation;
  late final Animation<Offset> _newsHeaderSlideAnimation;
  late final Animation<double> _newsHeaderFadeAnimation;
  late final Animation<Offset> _newsSectionSlideAnimation;
  late final Animation<double> _newsSectionFadeAnimation;

  // This flag ensures the entry animation only runs once per app session.
  static bool _hasAnimatedThisSession = false;
  // Manages the scroll position of the view to enable the fog effect.
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scrollController = ScrollController();

    // Animation intervals are staggered to create a cascading effect.
    _greetingSlideAnimation = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.2, curve: Curves.easeOutQuart)));
    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.2)));

    _buttonsSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.3, curve: Curves.easeOutCubic)));
    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.3)));

    _recentHeaderSlideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.4, curve: Curves.easeOutCubic)));
    _recentHeaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.4)));

    _recentGridSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.5, curve: Curves.easeOutCubic)));
    _recentGridFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.5)));

    _newsHeaderSlideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 0.8, curve: Curves.easeOutCubic)));
    _newsHeaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.6, 0.8)));

    _newsSectionSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic)));
    _newsSectionFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.7, 1.0)));

    if (!_hasAnimatedThisSession) {
      _animationController.forward();
      _hasAnimatedThisSession = true;
    } else {
      _animationController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String? name = widget.userData?['displayName'] ?? widget.userData?['username'];
    final String greetingText = (name != null && name.isNotEmpty)
        ? widget.localizations.selectionScreenGreetingUser(name)
        : widget.localizations.selectionScreenGreetingGeneric;

    return ScrollFog(
      scrollController: _scrollController,
      fogColor: AppColors.background,
      topFogHeight: screenHeight * 0.02,
      showTop: true,
      showBottom: false,
      child: SingleChildScrollView(
        key: const ValueKey('welcome_view'),
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.02),
              // Greeting
              FadeTransition(
                opacity: _greetingFadeAnimation,
                child: SlideTransition(
                  position: _greetingSlideAnimation,
                  child: Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.1),
                    child: Text(
                      greetingText,
                      style: TextStyle(fontSize: screenWidth * 0.075, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted, height: 1.2),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              // Feature Buttons
              FadeTransition(
                opacity: _buttonsFadeAnimation,
                child: SlideTransition(
                  position: _buttonsSlideAnimation,
                  child: _buildFeatureButtons(context, screenWidth),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              // Recent Models Section
              FadeTransition(
                opacity: _recentHeaderFadeAnimation,
                child: SlideTransition(
                  position: _recentHeaderSlideAnimation,
                  child: _buildSectionHeader(context, screenWidth, widget.localizations.selectionScreenRecentModels),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              FadeTransition(
                opacity: _recentGridFadeAnimation,
                child: SlideTransition(
                  position: _recentGridSlideAnimation,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: widget.isLoading
                          ? const ShimmerModelGridView(
                        key: ValueKey('shimmer_grid_recent'),
                        itemCount: 3,
                        shrinkWrap: true,
                      )
                          : widget.recentModels.isEmpty
                          ? _buildNoRecentModelsPlaceholder()
                          : ModelGridView(
                        gridKey: const ValueKey('recent_models_grid'),
                        models: widget.recentModels,
                        conversationLimitReached: widget.conversationLimitReached,
                        onSelectModel: (model) => widget.onSelectModel(model, context),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                      ),
                    ),
                  ),
                ),
              ),
              Consumer<NewsService>(
                builder: (context, newsService, child) {
                  // --- MODIFIED LOGIC ---
                  // We now always show the NewsSection container, but its content
                  // is conditionally displayed based on the newsService state.
                  // This ensures the category area is present during loading.
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      FadeTransition(
                        opacity: _newsHeaderFadeAnimation,
                        child: SlideTransition(
                          position: _newsHeaderSlideAnimation,
                          child: _buildSectionHeader(context, screenWidth, widget.localizations.selectionScreenNewsAndUpdates),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SizeTransition(
                              sizeFactor: animation,
                              axisAlignment: -1.0,
                              child: child,
                            ),
                          );
                        },
                        child: newsService.state == NewsState.loading
                            ? const ShimmerNewsList(key: ValueKey('news_loading_skeleton')) // Show skeleton while loading
                            : newsService.state == NewsState.success && newsService.articles.isNotEmpty
                            ? FadeTransition( // Fade in the actual news content
                          opacity: _newsSectionFadeAnimation,
                          child: SlideTransition(
                            position: _newsSectionSlideAnimation,
                            child: const NewsSection(),
                          ),
                        )
                            : const SizedBox.shrink( // Hide if no news or error
                          key: ValueKey('news_empty_or_error'),
                        ),
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: screenHeight * 0.02), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a reusable header for a section.
  Widget _buildSectionHeader(BuildContext context, double screenWidth, String title) {
    return Text(
      title,
      style: TextStyle(
          fontSize: screenWidth * 0.048,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor.inverted),
    );
  }

  /// An interactive placeholder displayed when there are no recent chats.
  /// Tapping it navigates the user to the "all models" view.
  Widget _buildNoRecentModelsPlaceholder() {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(20);

    return Material(
      key: const ValueKey('no_recent_placeholder'),
      color: AppColors.background,
      borderRadius: borderRadius,
      child: InkWell(
        onTap: widget.onShowExploreView, // Calls the callback passed from the controller
        borderRadius: borderRadius,
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenWidth * 0.06,
          ),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Text(
            widget.localizations.noRecentChatsMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the grid of main feature buttons.
  Widget _buildFeatureButtons(BuildContext context, double screenWidth) {
    final double horizontalPadding = screenWidth * 0.04 * 2;
    final double spaceBetweenColumns = screenWidth * 0.03;
    final double availableFlexWidth = screenWidth - horizontalPadding - spaceBetweenColumns;
    final double largeCardSize = availableFlexWidth * (5 / 9);
    final double spaceBetweenSmallCards = screenWidth * 0.03;
    final double smallCardHeight = (largeCardSize - spaceBetweenSmallCards) / 2;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: FeatureCard(
            text: widget.localizations.selectionScreenFeatureDynamicChat,
            iconPath: 'assets/icons/chat.svg',
            height: largeCardSize,
            onTap: widget.onStartDynamicChat,
          ),
        ),
        SizedBox(width: spaceBetweenColumns),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              FeatureCard(
                text: widget.localizations.selectionScreenFeatureOffline,
                iconPath: 'assets/icons/context.svg',
                height: smallCardHeight,
                isSmall: true,
                onTap: widget.onOfflineFeatureTap,
              ),
              SizedBox(height: spaceBetweenSmallCards),
              FeatureCard(
                text: widget.localizations.selectionScreenFeatureSelectModel,
                iconPath: 'assets/icons/library.svg',
                height: smallCardHeight,
                isSmall: true,
                onTap: widget.onShowExploreView,
              ),
            ],
          ),
        ),
      ],
    );
  }
}