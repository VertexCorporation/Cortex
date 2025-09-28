// lib/chat/screen/unselected/screen/screen.dart

import 'dart:ui';
import 'package:cortex/chat/screen/unselected/cards.dart';
import 'package:cortex/chat/screen/unselected/search.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/main.dart';
import 'package:cortex/notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cortex/models/backend/data.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:cortex/errorview.dart';

import '../news.dart';

/// A sophisticated screen that serves a dual purpose:
/// 1. A welcoming initial selection view with quick actions, recent and pinned models, and news.
/// 2. A comprehensive, searchable grid of all available models.
///
/// It uses an [AnimatedSwitcher] to provide a seamless, animated transition
/// between these two views without navigating to a new page, offering a fluid
/// user experience. The state `_isShowingAllModels` controls which view is active.
class SelectionScreen extends StatefulWidget {
  final TextEditingController searchController;
  final List<ModelInfo> allModels;
  final List<ModelInfo> pinnedModels; // New property for pinned models
  final VoidCallback onReloadModels;
  final bool hasInternetConnection;
  final bool conversationLimitReached;
  final Function(ModelInfo) onSelectModel;
  final VoidCallback onScrollToBottom;
  final AppLocalizations localizations;
  final bool isLoading;
  final Map<String, dynamic>? userData;
  final Function(bool isShowingAllModels) onViewModeChanged;

  const SelectionScreen({
    super.key,
    required this.searchController,
    required this.allModels,
    required this.pinnedModels, // Added to constructor
    required this.onReloadModels,
    required this.hasInternetConnection,
    required this.conversationLimitReached,
    required this.onSelectModel,
    required this.onScrollToBottom,
    required this.localizations,
    required this.isLoading,
    this.userData,
    required this.onViewModeChanged,
  });

  @override
  State<SelectionScreen> createState() => SelectionScreenState();
}

class SelectionScreenState extends State<SelectionScreen>
    with SingleTickerProviderStateMixin {
  bool _isShowingAllModels = false;
  List<ModelInfo> _filteredModels = [];

  late final AnimationController _animationController;
  // Existing animations
  late final Animation<Offset> _greetingSlideAnimation;
  late final Animation<double> _greetingFadeAnimation;
  late final Animation<Offset> _buttonsSlideAnimation;
  late final Animation<double> _buttonsFadeAnimation;
  late final Animation<Offset> _recentHeaderSlideAnimation;
  late final Animation<double> _recentHeaderFadeAnimation;
  late final Animation<Offset> _recentGridSlideAnimation;
  late final Animation<double> _recentGridFadeAnimation;
  // New animations for Pinned and News sections
  late final Animation<Offset> _pinnedHeaderSlideAnimation;
  late final Animation<double> _pinnedHeaderFadeAnimation;
  late final Animation<Offset> _pinnedGridSlideAnimation;
  late final Animation<double> _pinnedGridFadeAnimation;
  late final Animation<Offset> _newsHeaderSlideAnimation;
  late final Animation<double> _newsHeaderFadeAnimation;
  late final Animation<Offset> _newsSectionSlideAnimation;
  late final Animation<double> _newsSectionFadeAnimation;


  static bool _hasAnimatedThisSession = false;

  @override
  void initState() {
    super.initState();
    _filteredModels = widget.allModels;
    widget.searchController.addListener(_filterModels);
    _filterModels();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsService>(context, listen: false).loadNews(context);
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000), // Increased duration for more animations
      vsync: this,
    );

    // Animation intervals are staggered to create a cascading effect.
    _greetingSlideAnimation = Tween<Offset>(begin: const Offset(-1.5, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.2, curve: Curves.easeOutQuart)));
    _greetingFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.0, 0.2)));
    _buttonsSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.3, curve: Curves.easeOutCubic)));
    _buttonsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.1, 0.3)));

    _recentHeaderSlideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.4, curve: Curves.easeOutCubic)));
    _recentHeaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.2, 0.4)));
    _recentGridSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.5, curve: Curves.easeOutCubic)));
    _recentGridFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.3, 0.5)));

    _pinnedHeaderSlideAnimation = Tween<Offset>(begin: const Offset(-1.0, 0), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 0.6, curve: Curves.easeOutCubic)));
    _pinnedHeaderFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.4, 0.6)));
    _pinnedGridSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 0.7, curve: Curves.easeOutCubic)));
    _pinnedGridFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _animationController, curve: const Interval(0.5, 0.7)));

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
  void didUpdateWidget(covariant SelectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.allModels != oldWidget.allModels) {
      _filterModels();
    }
  }

  void _filterModels() {
    final query = widget.searchController.text.toLowerCase();
    if (mounted) {
      setState(() {
        _filteredModels = widget.allModels
            .where((model) => model.title.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterModels);
    _animationController.dispose();
    super.dispose();
  }

  void showSelectionView() {
    if (mounted) {
      widget.onViewModeChanged(false);
      setState(() {
        _isShowingAllModels = false;
      });
      widget.searchController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showAllModelsView() {
    if (mounted) {
      widget.onViewModeChanged(true);
      setState(() {
        _isShowingAllModels = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isShowingAllModels) {
          showSelectionView();
          return false;
        }
        return true;
      },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              ..._buildBackgroundEffects(context),
              SafeArea(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 400),
                  layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
                      children: <Widget>[
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    );
                  },
                  transitionBuilder: (child, animation) {
                    final slideAnimation = Tween<Offset>(
                      begin: const Offset(0.0, 0.3),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeInOutCubic,
                    ));
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: slideAnimation,
                        child: child,
                      ),
                    );
                  },
                  child: _isShowingAllModels
                      ? _buildAllModelsView()
                      : _buildSelectionView(),
                ),
              ),
            ],
          ),
        ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, double screenWidth, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: screenWidth * 0.048,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor.inverted),
        ),
      ],
    );
  }

  List<Widget> _buildBackgroundEffects(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return [
      AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: _isShowingAllModels ? 0.0 : 1.0,
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 80.0, sigmaY: 80.0),
          child: Stack(
            children: [
              Positioned(
                top: screenHeight * 0.06,
                left: -screenWidth * 0.3,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                      color: AppColors.senaryColor.withOpacity(0.4),
                      shape: BoxShape.circle),
                ),
              ),
              Positioned(
                top: screenHeight * 0.05,
                right: -screenWidth * 0.4,
                child: Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      color: AppColors.quaternaryColor.withOpacity(0.3),
                      shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.4,
          minChildSize: 0.2,
          maxChildSize: 0.8,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.border.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.localizations.save, // Placeholder title
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryColor.inverted,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppColors.primaryColor.inverted),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  const Divider(indent: 16, endIndent: 16),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.localizations.comingSoon,
                        style: TextStyle(color: AppColors.primaryColor.inverted.withOpacity(0.7)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSelectionView() {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final String? name = widget.userData?['displayName'] ?? widget.userData?['username'];
    final String greetingText = (name != null && name.isNotEmpty)
        ? widget.localizations.selectionScreenGreetingUser(name)
        : widget.localizations.selectionScreenGreetingGeneric;
    final recentModels = widget.allModels.take(3).toList();

    return SingleChildScrollView(
      key: const ValueKey('selection_view'),
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
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: widget.isLoading
                      ? const ShimmerModelGridView(
                    gridKey: ValueKey('shimmer_grid_recent'),
                    itemCount: 3,
                    isDetailed: false,
                    shrinkWrap: true,
                  )
                      : ModelGridView(
                    gridKey: const ValueKey('recent_models_grid'),
                    models: recentModels,
                    hasInternetConnection: widget.hasInternetConnection,
                    conversationLimitReached: widget.conversationLimitReached,
                    onSelectModel: widget.onSelectModel,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
              ),
            ),
            // Pinned Models Section - Renders only if there are pinned models
            if (widget.pinnedModels.isNotEmpty) ...[
              SizedBox(height: screenHeight * 0.04),
              FadeTransition(
                opacity: _pinnedHeaderFadeAnimation,
                child: SlideTransition(
                  position: _pinnedHeaderSlideAnimation,
                  child: _buildSectionHeader(context, screenWidth, "Pinned Models"), // TODO: Add to localizations
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              FadeTransition(
                opacity: _pinnedGridFadeAnimation,
                child: SlideTransition(
                  position: _pinnedGridSlideAnimation,
                  child: ModelGridView(
                    gridKey: const ValueKey('pinned_models_grid'),
                    models: widget.pinnedModels,
                    hasInternetConnection: widget.hasInternetConnection,
                    conversationLimitReached: widget.conversationLimitReached,
                    onSelectModel: widget.onSelectModel,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ),
              ),
            ],
            // News Section
            SizedBox(height: screenHeight * 0.04),
            FadeTransition(
              opacity: _newsHeaderFadeAnimation,
              child: SlideTransition(
                position: _newsHeaderSlideAnimation,
                child: _buildSectionHeader(context, screenWidth, "News & Updates"), // TODO: Add to localizations
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            FadeTransition(
              opacity: _newsSectionFadeAnimation,
              child: SlideTransition(
                position: _newsSectionSlideAnimation,
                child: const NewsSection(), // The new News widget
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildAllModelsView() {
    final isSearchEmpty =
        _filteredModels.isEmpty && widget.searchController.text.isNotEmpty;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Padding(
      key: const ValueKey('all_models_view'),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          SearchBarWidget(
            controller: widget.searchController,
            localizations: widget.localizations,
            onFilterTap: _showFilterBottomSheet,
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: widget.isLoading
                  ? ShimmerModelGridView(
                gridKey: const ValueKey('shimmer_grid_all'),
                itemCount: 15,
                isDetailed: true,
              )
                  : isSearchEmpty
                  ? _buildEmptyState()
                  : ModelGridView(
                gridKey: ValueKey(
                    'model_grid_${widget.searchController.text}'),
                models: _filteredModels,
                hasInternetConnection: widget.hasInternetConnection,
                conversationLimitReached:
                widget.conversationLimitReached,
                onSelectModel: widget.onSelectModel,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureButtons(BuildContext context, double screenWidth) {
    final double horizontalPadding = screenWidth * 0.04 * 2;
    final double spaceBetweenColumns = screenWidth * 0.03;
    final double availableFlexWidth = screenWidth - horizontalPadding - spaceBetweenColumns;
    final double largeCardSize = availableFlexWidth * (5 / 9);
    final double spaceBetweenSmallCards = screenWidth * 0.03;
    final double smallCardHeight = (largeCardSize - spaceBetweenSmallCards) / 2;
    final notificationService = Provider.of<NotificationService>(context, listen: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 5,
          child: _FeatureCard(
            text: widget.localizations.selectionScreenFeatureDynamicChat,
            iconPath: 'assets/icons/chat.svg',
            height: largeCardSize,
            onTap: () => notificationService.showNotification(message: widget.localizations.comingSoon),
          ),
        ),
        SizedBox(width: spaceBetweenColumns),
        Expanded(
          flex: 4,
          child: Column(
            children: [
              _FeatureCard(
                text: widget.localizations.selectionScreenFeatureOffline,
                iconPath: 'assets/icons/context.svg',
                height: smallCardHeight,
                isSmall: true,
                onTap: () => mainScreenKey.currentState?.onItemTapped(1),
              ),
              SizedBox(height: spaceBetweenSmallCards),
              _FeatureCard(
                text: widget.localizations.selectionScreenFeatureSelectModel,
                iconPath: 'assets/icons/library.svg',
                height: smallCardHeight,
                isSmall: true,
                onTap: _showAllModelsView,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: ErrorView(
        key: const ValueKey<String>('empty_state'),
        title: widget.localizations.noModelsFoundTitle,
        message: widget.localizations.noModelsFoundMessage,
      ),
    );
  }
}

/// A reusable card for feature buttons on the main selection view.
class _FeatureCard extends StatelessWidget {
  final String text;
  final String iconPath;
  final double height;
  final VoidCallback onTap;
  final bool isSmall;

  const _FeatureCard({
    required this.text,
    required this.iconPath,
    required this.height,
    required this.onTap,
    this.isSmall = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final borderRadius = BorderRadius.circular(24);
    final iconSize = screenWidth * 0.06;

    return Material(
      color: AppColors.background,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
        highlightColor: AppColors.primaryColor.inverted.withOpacity(0.05),
        child: Container(
          height: height,
          padding: EdgeInsets.all(screenWidth * 0.04),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(color: AppColors.border, width: 1.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    iconPath,
                    width: iconSize,
                    height: iconSize,
                    colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withOpacity(0.8), BlendMode.srcIn),
                  ),
                  Icon(Icons.arrow_forward, color: AppColors.primaryColor.inverted, size: screenWidth * 0.05),
                ],
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: isSmall ? screenWidth * 0.04 : screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor.inverted,
                        height: 1.2,
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