// lib/chat/screen/unselected/views/explore.dart
// A self-contained view for discovering, searching, and filtering models,
// featuring a scroll-aware fog effect and caching for performance.

import 'package:flutter/material.dart';
import 'package:cortex/error.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:provider/provider.dart';
import '../../../../cache.dart';
import '../../../../fog.dart';
import '../../../../library/backend/data/entity.dart';
import '../../../../library/providers/local.dart';
import '../widgets/cards.dart';
import '../widgets/filter.dart';
import '../widgets/search.dart';

/// The ExploreView is a dedicated "View" for discovering, searching, and
/// filtering all available models.
class ExploreView extends StatefulWidget {
  final TextEditingController searchController;
  final List<ModelEntity> allModels;
  final AppLocalizations localizations;
  final bool isLoading;
  final bool conversationLimitReached;
  final Function(ModelEntity, BuildContext) onSelectModel;

  const ExploreView({
    super.key,
    required this.searchController,
    required this.allModels,
    required this.localizations,
    required this.isLoading,
    required this.conversationLimitReached,
    required this.onSelectModel,
  });

  @override
  State<ExploreView> createState() => _ExploreViewState();
}

class _ExploreViewState extends State<ExploreView> {
  List<ModelEntity> _filteredModels = [];
  FilterType _activeFilter = FilterType.all;

  // Manages the scroll position of the model grid to enable the fog effect.
  late final ScrollController _scrollController;
  late ModelLocalStateProvider _localStateProvider;
  bool _isListenerAdded = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    widget.searchController.addListener(_filterModels);

    final cachedModels = CacheService.get<List<ModelEntity>>(CacheKey.filteredModels);
    if (cachedModels != null) {
      _filteredModels = cachedModels;
    }
  }

  // This is called after initState and whenever dependencies change.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure we only add the listener once.
    if (!_isListenerAdded) {
      _localStateProvider = Provider.of<ModelLocalStateProvider>(context);
      // Listen for changes in download states, which affects sorting.
      _localStateProvider.addListener(_filterModels);
      _isListenerAdded = true;

      // If the cache was empty, perform the initial filtering after the first frame.
      if (_filteredModels.isEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _filterModels());
      }
    }
  }

  @override
  void didUpdateWidget(covariant ExploreView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the master list of models changes (e.g., after a sync), we must refilter.
    if (widget.allModels != oldWidget.allModels) {
      _filterModels();
    }
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_filterModels);
    // Always remove listeners to prevent memory leaks.
    if (_isListenerAdded) {
      _localStateProvider.removeListener(_filterModels);
    }
    _scrollController.dispose();
    super.dispose();
  }

  /// Filters and sorts the master list of models based on the current
  /// filter type and search query, then updates the cache.
  void _filterModels() {
    // Guard clause to prevent execution if the widget is no longer mounted.
    if (!mounted) return;

    final downloadedStates = _localStateProvider.downloadCompleted;

    List<ModelEntity> tempFiltered = widget.allModels.where((model) {
      if (model.isServerSide) {
        return true;
      }
      return downloadedStates[model.id] ?? false;
    }).toList();

    // --- 1. Filtering Logic ---
    if (_activeFilter != FilterType.all) {
      tempFiltered = tempFiltered.where((model) {
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

    final query = widget.searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      tempFiltered = tempFiltered
          .where((model) => model.displayTitle.toLowerCase().contains(query))
          .toList();
    }

    // --- 2. Sorting Logic ---
    tempFiltered.sort((a, b) {
      final isADownloaded = downloadedStates[a.id] == true && !a.isServerSide;
      final isBDownloaded = downloadedStates[b.id] == true && !b.isServerSide;

      int getCategoryPriority(ModelEntity model, bool isDownloaded) {
        if (isDownloaded) return 0;
        if (model.category == 'self') return 1;
        if (model.isServerSide && model.category != 'roleplay') return 2;
        if (model.isServerSide && model.category == 'roleplay') return 3;
        return 4;
      }

      final priorityA = getCategoryPriority(a, isADownloaded);
      final priorityB = getCategoryPriority(b, isBDownloaded);

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      switch (priorityA) {
        case 0:
          final ramA = a.ram ?? 99999;
          final ramB = b.ram ?? 99999;
          final ramComparison = ramA.compareTo(ramB);
          if (ramComparison != 0) return ramComparison;
          final sizeA = a.size ?? 99999;
          final sizeB = b.size ?? 99999;
          return sizeA.compareTo(sizeB);

        case 1:
        case 2:
        case 3:
          if (a.id == 'neuro') return -1;
          if (b.id == 'neuro') return 1;
          return a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());

        default:
          return 0;
      }
    });

    // --- 3. Update State and Cache ---
    setState(() {
      _filteredModels = tempFiltered;
    });
    CacheService.set(CacheKey.filteredModels, tempFiltered);
  }

  /// Opens the filter selection bottom sheet.
  void _openFilterSheet() {
    showModelFilterSheet(
      context: context,
      localizations: widget.localizations,
      activeFilter: _activeFilter,
      onFilterChanged: (newFilter) {
        // Update the active filter and immediately re-run the filtering logic.
        setState(() {
          _activeFilter = newFilter;
        });
        _filterModels();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ThemeProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final Widget content = _buildContent();

    return Padding(
      key: const ValueKey('explore_view'),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      child: Column(
        children: [
          SizedBox(height: screenHeight * 0.02),
          SearchBarWidget(
            controller: widget.searchController,
            localizations: widget.localizations,
            onFilterTap: _openFilterSheet,
          ),
          SizedBox(height: screenHeight * 0.02),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),

              child: ScrollFog(
                key: ValueKey(content.hashCode),
                scrollController: _scrollController,
                fogColor: AppColors.background,
                topFogHeight: screenHeight * 0.02,
                bottomFogHeight: screenHeight * 0.05,
                child: content,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Determines which content to display: shimmer, empty state, or the model grid.
  Widget _buildContent() {
    const gridPadding = EdgeInsets.only(top: 8.0, bottom: 16.0);

    if (widget.isLoading) {
      return Padding(
        key: const ValueKey('shimmer_grid_all_padded'),
        padding: gridPadding,
        child: ShimmerModelGridView(
          itemCount: 15,
          scrollController: _scrollController,
        ),
      );
    }

    if (_filteredModels.isEmpty) {
      final bool hasActiveFilter = _activeFilter != FilterType.all;
      final bool hasActiveSearch = widget.searchController.text.isNotEmpty;

      if (widget.allModels.isNotEmpty && (hasActiveFilter || hasActiveSearch)) {
        return _buildEmptyState(
          title: widget.localizations.noModelsFoundTitle,
          message: widget.localizations.noModelsFoundMessage,
        );
      }

      if (widget.allModels.isEmpty) {
        return _buildEmptyState(
          title: widget.localizations.anErrorOccurred,
          message: widget.localizations.noModelsFoundMessage,
        );
      }

      return Padding(
        key: const ValueKey('shimmer_grid_initial_padded'),
        padding: gridPadding,
        child: ShimmerModelGridView(
          itemCount: 30,
          scrollController: _scrollController,
        ),
      );
    }

    return Padding(
      key: ValueKey('model_grid_${_activeFilter.name}_${widget.searchController.text}'),
      padding: gridPadding,
      child: ModelGridView(
        models: _filteredModels,
        conversationLimitReached: widget.conversationLimitReached,
        onSelectModel: (model) => widget.onSelectModel(model, context),
        scrollController: _scrollController,
      ),
    );
  }

  /// Builds a centered message for empty or error states.
  Widget _buildEmptyState({required String title, required String message}) {
    return Center(
      child: ErrorView(
        key: ValueKey(title),
        title: title,
        message: message,
      ),
    );
  }
}