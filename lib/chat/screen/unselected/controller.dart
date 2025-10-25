// lib/chat/screen/unselected/screen/screen.dart

import 'dart:ui';
import 'package:cortex/app.dart';
import 'package:cortex/chat/screen/unselected/widgets/cards.dart';
import 'package:cortex/chat/screen/unselected/widgets/search.dart';
import 'package:cortex/chat/screen/unselected/widgets/news/view.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/main.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:cortex/error.dart';
import '../../../library/backend/data/entity.dart';
import '../../../library/backend/data/user.dart';

enum FilterType { all, online, offline, characters, custom }

/// A sophisticated screen that serves a dual purpose:
/// 1. A welcoming initial selection view with quick actions, recent and pinned models, and news.
/// 2. A comprehensive, searchable grid of all available models.
///
/// It uses an [AnimatedSwitcher] to provide a seamless, animated transition
/// between these two views without navigating to a new page, offering a fluid
/// user experience. The state `_isShowingAllModels` controls which view is active.
class SelectionScreen extends StatefulWidget {
  final TextEditingController searchController;
  final List<ModelEntity> allModels;
  final List<ModelEntity> recentModels;
  final VoidCallback onReloadModels;
  final bool conversationLimitReached;
  final Function(ModelEntity, BuildContext) onSelectModel;
  final VoidCallback onScrollToBottom;
  final AppLocalizations localizations;
  final bool isLoading;
  final Map<String, dynamic>? userData;
  final Function(bool isShowingAllModels) onViewModeChanged;

  const SelectionScreen({
    super.key,
    required this.searchController,
    required this.allModels,
    required this.recentModels,
    required this.onReloadModels,
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
  List<ModelEntity> _filteredModels = [];
  // It's nullable because initially, no filter is applied.
  FilterType _activeFilter = FilterType.all;

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

  /// NEW: A dedicated empty state widget to show when a filter is active
  /// but no matching models are found.
  Widget _buildFilterEmptyState() {
    return Center(
      child: ErrorView(
        key: const ValueKey<String>('filter_empty_state'),
        title: widget.localizations.noModelsFoundTitle,
        message: widget.localizations.noModelsFoundMessage,
      ),
    );
  }

  void _filterModels() {
    // widget.allModels is now List<ModelEntity>
    List<ModelEntity> modelsToFilter = widget.allModels;

    if (_activeFilter != FilterType.all) {
      modelsToFilter = modelsToFilter.where((model) {
        // --- REFACTORED: Use direct entity properties for filtering ---
        switch (_activeFilter) {
          case FilterType.online:
            return model.isServerSide && model.category != 'roleplay';
          case FilterType.offline:
            return !model.isServerSide;
          case FilterType.characters:
            return model.category == 'roleplay';
          case FilterType.custom:
            return model.category == 'self';
          case FilterType.all:
            return true;
        }
      }).toList();
    }

    final query = widget.searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      modelsToFilter = modelsToFilter
          .where((model) => model.displayTitle.toLowerCase().contains(query))
          .toList();
    }

    if (mounted) {
      setState(() {
        // The state variable _filteredModels should also be List<ModelEntity>
        _filteredModels = modelsToFilter;
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
        _activeFilter = FilterType.all;
      });
      widget.searchController.clear();
      _filterModels();
      FocusScope.of(context).unfocus();
    }
  }

  void showAllModelsView() {
    if (mounted) {
      widget.onViewModeChanged(true);
      setState(() {
        _isShowingAllModels = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isShowingAllModels,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        // Since canPop is false, didPop will also be false.
        // This confirms our logic is taking over.
        if (didPop) return;

        // 3. Implement the custom back logic.
        if (_isShowingAllModels) {
          // If in the "all models" view, go back to the selection view.
          showSelectionView();
        } else {
          // If in the main selection view, allow the pop to happen by calling it manually.
          Navigator.of(context).pop();
        }
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
                top: screenHeight * 0.15,
                left: -screenWidth * 0.3,
                child: Container(
                  width: screenWidth * 0.6,
                  height: screenWidth * 0.6,
                  decoration: BoxDecoration(
                      color: AppColors.senaryColor.withValues(alpha: 0.4),
                      shape: BoxShape.circle),
                ),
              ),
              Positioned(
                top: screenHeight * 0.14,
                right: -screenWidth * 0.4,
                child: Container(
                  width: screenWidth * 0.8,
                  height: screenWidth * 0.8,
                  decoration: BoxDecoration(
                      color: AppColors.quaternaryColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle),
                ),
              ),
            ],
          ),
        ),
      ),
    ];
  }

  /// Builds and displays the fully functional bottom sheet with filter options.
  void _showFilterBottomSheet() {
    // Get screen dimensions once to use for dynamic sizing
    final screen = MediaQuery.of(context);
    final screenWidth = screen.size.width;
    final screenHeight = screen.size.height;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      constraints: BoxConstraints(
        maxWidth: screenWidth,
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {

            Widget buildFilterChip({
              required String title,
              required FilterType filter,
              required int index,
            }) {
              final bool isActive = _activeFilter == filter;
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 100)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0.0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    // 1. Store the Navigator before the async gap.
                    //    The context is guaranteed to be valid at this point.
                    final navigator = Navigator.of(context);

                    // 2. Perform synchronous state updates.
                    setModalState(() => _activeFilter = filter);
                    // The parent widget's setState.
                    setState(() {});
                    _filterModels();

                    // 3. Start the async delay.
                    Future.delayed(const Duration(milliseconds: 250), () {
                      // 4. After the delay, use the stored navigator.
                      //    The 'mounted' check is still a good practice here.
                      if (mounted) {
                        navigator.pop();
                      }
                    });
                    // --- END REFACTORED SECTION ---
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.045,
                        vertical: screenHeight * 0.012
                    ),
                    decoration: BoxDecoration(
                      color: isActive ? AppColors.primaryColor.inverted : Colors.transparent,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: screenWidth * 0.035,
                        fontWeight: FontWeight.bold,
                        color: isActive ? AppColors.secondaryColor : AppColors.primaryColor.inverted,
                      ),
                    ),
                  ),
                ),
              );
            }

            final filters = [
              {'title': widget.localizations.allModels, 'filter': FilterType.all},
              {'title': widget.localizations.onlineModels, 'filter': FilterType.online},
              {'title': widget.localizations.offlineModels, 'filter': FilterType.offline},
              {'title': widget.localizations.characterModels, 'filter': FilterType.characters},
              {'title': widget.localizations.customModels, 'filter': FilterType.custom},
            ];

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                border: Border(top: BorderSide(color: AppColors.border, width: 1.0)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container( // Drag handle
                    width: screenWidth * 0.1,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      children: [
                        Text(
                          widget.localizations.filters,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted),
                        ),
                        SizedBox(height: screenHeight * 0.01),
                        Text(
                          widget.localizations.filterPanelDescription,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: screenWidth * 0.035,
                            color: AppColors.primaryColor.inverted.withValues(alpha: 0.7),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: screenWidth * 0.025,
                          runSpacing: screenWidth * 0.025,
                          children: List.generate(filters.length, (index) {
                            return buildFilterChip(
                              title: filters[index]['title'] as String,
                              filter: filters[index]['filter'] as FilterType,
                              index: index,
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screen.padding.bottom + screenHeight * 0.02),
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
                /// --- UI GLITCH FIX ---
                /// By wrapping the AnimatedSwitcher in an AnimatedSize widget, we ensure that
                /// any change in the child's height (e.g., from skeleton grid to placeholder text)
                /// will be smoothly animated, preventing the "jump" effect on the layout.
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: widget.isLoading
                        ? const ShimmerModelGridView(
                      gridKey: ValueKey('shimmer_grid_recent'),
                      itemCount: 3,
                      shrinkWrap: true,
                    )
                        : widget.recentModels.isEmpty
                    // This now calls the interactive placeholder
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
            // News Section
            SizedBox(height: screenHeight * 0.04),
            FadeTransition(
              opacity: _newsHeaderFadeAnimation,
              child: SlideTransition(
                position: _newsHeaderSlideAnimation,
                child: _buildSectionHeader(context, screenWidth, widget.localizations.selectionScreenNewsAndUpdates),
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
        onTap: showAllModelsView, // Action: Show the model selection screen
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
            color: Colors.transparent, // Color is now handled by Material
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

  Widget _buildAllModelsView() {
    // Condition for when search text is entered but finds nothing
    final isSearchEmpty =
        _filteredModels.isEmpty && widget.searchController.text.isNotEmpty;
    // Condition for when a filter is active but finds nothing
    final isFilterEmpty = _filteredModels.isEmpty &&
        widget.searchController.text.isEmpty &&
        _activeFilter != FilterType.all;

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
              )
                  : isFilterEmpty
                  ? _buildFilterEmptyState() // Shows when filter has no results
                  : isSearchEmpty
                  ? _buildEmptyState() // Shows when search has no results
                  : ModelGridView(
                key: ValueKey(
                    'model_grid_${_activeFilter.name}_${widget.searchController.text}'),
                models: _filteredModels,
                conversationLimitReached:
                widget.conversationLimitReached,
                onSelectModel: (model) => widget.onSelectModel(model, context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A new handler for the "Use Offline" feature button.
  ///
  /// This function provides an intelligent user experience:
  /// - If the user has already downloaded at least one offline model, it switches
  ///   to the "all models" view and automatically applies the "offline" filter.
  /// - If the user has no downloaded offline models, it navigates them to the
  ///   downloads page so they can get one.
  Future<void> _onOfflineFeatureTap() async {
    final downloadedModelIds = (await UserModels.loadDownloadedModelPaths()).keys;

    if (downloadedModelIds.isEmpty) {
      mainScreenKey.currentState?.onItemTapped(1, pulseOffline: true);
      return;
    }

    // --- REFACTORED SECTION ---
    // The widget.allModels is now a List<ModelEntity>.
    final bool hasDownloadedOfflineModels = widget.allModels.any((model) {
      // Use the safe 'isServerSide' getter and 'id' property.
      return !model.isServerSide && downloadedModelIds.contains(model.id);
    });
    // --- END REFACTORED SECTION ---

    if (!mounted) return;

    if (hasDownloadedOfflineModels) {
      setState(() => _activeFilter = FilterType.offline);
      _filterModels();
      showAllModelsView();
    } else {
      mainScreenKey.currentState?.onItemTapped(1, pulseOffline: true);
    }
  }

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
          child: _FeatureCard(
            text: '${widget.localizations.selectionScreenFeatureDynamicChat} (Beta)',
            iconPath: 'assets/icons/chat.svg',
            height: largeCardSize,
            onTap: () => mainScreenKey.currentState?.startNewConversation(isDynamic: true),
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
                onTap: _onOfflineFeatureTap,
              ),
              SizedBox(height: spaceBetweenSmallCards),
              _FeatureCard(
                text: widget.localizations.selectionScreenFeatureSelectModel,
                iconPath: 'assets/icons/library.svg',
                height: smallCardHeight,
                isSmall: true,
                onTap: showAllModelsView,
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
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
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
                    colorFilter: ColorFilter.mode(AppColors.primaryColor.inverted.withValues(alpha: 0.8), BlendMode.srcIn),
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