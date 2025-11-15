// search.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/utils.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../error.dart';
import '../../theme.dart';
import '../screen/models/widgets/cards.dart';
import '../screen/models/widgets/results.dart';
import 'data/entity.dart';
import 'download/download.dart';

/// Manages the search state and UI components for model searching.
class ModelsSearchController {
  /// Constructs a [ModelsSearchController].
  ModelsSearchController({
    required this.context,
    required this.allModels,
    required this.downloadManagers,
    required this.downloadedFileStates,
    required this.getCompatibilityStatus,
    required this.openModelDetail,
    required this.removeModel,
    required this.startChat,
    required this.startDownload,
    required this.cancelDownload,
    required this.resumeDownload,
    required this.focusNode,
  }) {
    // Listen to changes in the text controller to trigger search logic.
    _controller.addListener(() => _onChanged(_controller.text));
  }

  //--------------------------------------------------------------------
  // Dependencies - Injected from outside
  //--------------------------------------------------------------------

  final BuildContext context;
  final FocusNode focusNode;

  // --- The main data source is now List<ModelEntity> ---
  List<ModelEntity> allModels;

  Map<String, DownloadManager> downloadManagers;
  Map<String, bool> downloadedFileStates;
  final CompatibilityStatus Function(int? modelSizeInMB) getCompatibilityStatus;
  final void Function(String id) openModelDetail;
  final Future<void> Function(String id) removeModel;
  final Future<void> Function(String id, bool isServerSide, {bool isCustomModel, String? modelPath}) startChat;
  final void Function({required String id, required String url, required String title}) startDownload;
  final void Function(String id) cancelDownload;
  final void Function(String id) resumeDownload;

  //--------------------------------------------------------------------
  // Internal state
  //--------------------------------------------------------------------

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  // --- Internal state lists also use ModelEntity ---
  List<ModelEntity> _prev = [];
  final List<ModelEntity> _exiting = [];

  //--------------------------------------------------------------------
  // Getters
  //--------------------------------------------------------------------

  TextEditingController get textController => _controller;

  //--------------------------------------------------------------------
  // Public Methods
  //--------------------------------------------------------------------

  /// Updates the controller's internal list of models and re-filters if needed.
  void updateModels(List<ModelEntity> newModels) {
    allModels = newModels;
    final currentQuery = textController.text.trim();
    if (currentQuery.isNotEmpty) {
      filterSearchResults(currentQuery);
    }
  }

  //--------------------------------------------------------------------
  // Public UI builders
  //--------------------------------------------------------------------

  /// Builds the search bar widget. (Unchanged)
  Widget buildSearchBar(double w) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * .05, vertical: w * .025),
      child: TextField(
        controller: _controller,
        focusNode: focusNode,
        style: TextStyle(color: AppColors.primaryColor.inverted),
        decoration: InputDecoration(
          hintText: loc.searchHint,
          hintStyle: TextStyle(color: AppColors.primaryColor.inverted.withValues(alpha: 0.5)),
          prefixIcon: Icon(Icons.search, size: w * .06, color: AppColors.primaryColor.inverted),
          filled: true,
          fillColor: AppColors.quaternaryColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(w * .05),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Builds the main body of the search results with animations.
  Widget buildSearchBody(double w) {
    final String currentQuery = _controller.text.trim().toLowerCase();

    // If the search query is empty, we don't want to show anything.
    // This prevents the "no results" view from appearing when the user clears the search bar.
    if (currentQuery.isEmpty) {
      _prev.clear();
      _exiting.clear();
      // Using an AnimatedSwitcher with an empty SizedBox ensures a smooth fade-out
      // when the user clears the search text.
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: const SizedBox.shrink(key: ValueKey('empty-search')),
      );
    }

    final List<ModelEntity> currentResults = _filter(allModels, currentQuery);

    _exiting.removeWhere((exitingModel) =>
        currentResults.any((resultModel) => resultModel.id == exitingModel.id));
    final List<ModelEntity> newlyLeavingModels = _prev.where((prevModel) =>
    !currentResults.any((currentModel) => currentModel.id == prevModel.id)).toList();

    if (newlyLeavingModels.isNotEmpty) {
      _exiting.addAll(newlyLeavingModels);
      Future.delayed(const Duration(milliseconds: 150)).then((_) {
        _exiting.removeWhere(newlyLeavingModels.contains);
        if ((context as Element).mounted) {
          (context as Element).markNeedsBuild();
        }
      });
    }
    _prev = List.from(currentResults);

    final Set<String> idsInMerged = {};
    final List<ModelEntity> mergedDisplayList = [
      ...currentResults,
      ..._exiting.where((m) => !currentResults.any((r) => r.id == m.id))
    ].where((model) => idsInMerged.add(model.id)).toList();

    // THE FIX: Use AnimatedSwitcher for smooth transitions between the results list and the "no results" view.
    // The key ensures that AnimatedSwitcher knows which widget is which.
    // By default, AnimatedSwitcher stacks the old and new widgets. We can use the layoutBuilder
    // to ensure they are both aligned to the top center, preventing any "jump" effect.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),

      // This layout builder is the key to solving the jump.
      // It ensures that both the incoming (currentChild) and outgoing (previousChildren)
      // widgets are aligned to the top of the container.
      layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
        return Stack(
          alignment: Alignment.topCenter, // Align everything to the top
          children: <Widget>[
            ...previousChildren,
            if (currentChild != null) currentChild,
          ],
        );
      },

      child: mergedDisplayList.isEmpty
          ? _noResults(w, key: const ValueKey('no-results'))
          : ListView.builder(
        key: const ValueKey('search-results-list'),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: w * .04),
        itemCount: mergedDisplayList.length,
        itemBuilder: (ctx, i) {
          final model = mergedDisplayList[i];
          final bool isLeaving =
              _exiting.any((exitingModel) => exitingModel.id == model.id) &&
                  !currentResults.any((currentModel) => currentModel.id == model.id);
          return _buildResultTile(
            model,
            index: i,
            isLeaving: isLeaving,
          );
        },
      ),
    );
  }

  //--------------------------------------------------------------------
  // Private helpers
  //--------------------------------------------------------------------

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      filterSearchResults(text);
    });
  }

  void filterSearchResults(String query) {
    if ((context as Element).mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  /// Filters the model list based on the query.
  List<ModelEntity> _filter(List<ModelEntity> data, String q) {
    // If the query is empty, return no results.
    if (q.isEmpty) {
      return [];
    }

    // Prepare the query once by trimming and converting to lower case for efficiency.
    final String lowerCaseQuery = q.trim().toLowerCase();

    // If the prepared query is empty (e.g., user only typed spaces), return no results.
    if (lowerCaseQuery.isEmpty) {
      return [];
    }

    // Filter the data list.
    return data.where((model) {
      // Get the model's title and split it into individual words.
      // This handles titles like "Code Llama" or "DeepSeek Coder".
      final List<String> words = model.displayTitle.toLowerCase().split(' ');

      // Use .any() to check if ANY word in the list starts with the user's query.
      // .any() is efficient because it stops checking as soon as it finds a match.
      return words.any((word) => word.startsWith(lowerCaseQuery));
    }).toList();
  }

  Widget _noResults(double w, {required Key key}) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      key: key, // The key is crucial for AnimatedSwitcher to work correctly.
      padding: EdgeInsets.only(top: w * .15, left: w * .05, right: w * .05),
      child: ErrorView(
        // We are not showing a button, so buttonText and onRetry are null.
        title: loc.noModelsFoundTitle,
        message: loc.noModelsFoundMessage,
      ),
    );
  }

  /// Builds a single tile for a search result item.
  Widget _buildResultTile(ModelEntity model, {required int index, required bool isLeaving}) {
    final dm = downloadManagers.putIfAbsent(model.id, () => DownloadManager());
    final compatibilityStatus = getCompatibilityStatus(model.size);
    final isEffectivelyDownloaded = (downloadedFileStates[model.id] ?? false) || dm.isDownloaded;

    final tile = ModelTile(
      key: ValueKey(model.id),
      // Pass the entire entity to ModelTile's new constructor.
      model: model,
      // Pass the remaining live state and layout properties.
      isLastInColumn: false, // In a search list, no item is the "last in column".
      isSeeAll: true,
      manager: dm,
      compatibilityStatus: compatibilityStatus,
      isDownloaded: isEffectivelyDownloaded,
      onTileTap: () {
        openModelDetail(model.id);
      },
      onRemoveRequested: () => removeModel(model.id),
      onChatPressed: () => startChat(model.id, model.isServerSide, isCustomModel: model.isCustomModel, modelPath: null),
      onDownloadPressed: () => startDownload(id: model.id, url: model.url ?? '', title: model.displayTitle),
      onCancelDownload: () => cancelDownload(model.id),
      onResumeDownload: () => resumeDownload(model.id),
    );

    return SearchResultItem(
      key: ValueKey('res_${model.id}'),
      index: index,
      delay: Duration.zero,
      isExiting: isLeaving,
      child: tile,
    );
  }

  //--------------------------------------------------------------------
  // Lifecycle
  //--------------------------------------------------------------------

  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
  }
}