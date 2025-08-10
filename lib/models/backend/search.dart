// search.dart

import 'dart:async';
import 'package:cortex/main.dart'; // Assuming this is your project's main entry
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Assuming these are local project imports
import '../../theme.dart'; // Your app's theme
import '../widgets/cards.dart'; // Custom card widgets
import '../widgets/results.dart'; // Custom result widgets
import 'data.dart'; // Data structures, potentially CompatibilityStatus
import 'download.dart'; // DownloadManager class

/// A type alias for a map representing model data.
/// Keys are strings (e.g., 'id', 'title') and values can be of any dynamic type.
typedef ModelMap = Map<String, dynamic>;

/// Manages the search state and UI components for model searching.
/// This controller is designed to be driven by the widget's state with minimal parameters,
/// handling the rest of the logic internally to keep the `ModelsScreen` (or similar widget) clean.
class ModelsSearchController {
  /// Constructs a [ModelsSearchController].
  ///
  /// Requires various dependencies to interact with the broader application:
  /// - [context]: The build context for accessing theme, localizations, and triggering rebuilds.
  /// - [allModels]: A list of all available models to search through.
  /// - [downloadManagers]: A map to manage download state for each model.
  /// - [downloadedFileStates]: A map representing the persistent download state from the file system.
  /// - [getCompatibilityStatus]: A function to determine a model's compatibility.
  /// - [openModelDetail]: Callback to navigate to the model detail screen.
  /// - [removeModel]: Callback to handle model removal.
  /// - [startChat]: Callback to initiate a chat with a model.
  /// - [startDownload]: Callback to begin downloading a model.
  /// - [cancelDownload]: Callback to cancel an ongoing model download.
  /// - [resumeDownload]: Callback to resume a paused model download.
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
  }) {
    _printLog('Initializing...');
    // Listen to changes in the text controller to trigger search logic.
    _controller.addListener(() => _onChanged(_controller.text));
    _printLog('TextEditingController listener added.');
  }

  //--------------------------------------------------------------------
  // Dependencies - Injected from outside
  //--------------------------------------------------------------------

  /// The build context, used for accessing localizations, theme, and triggering UI updates.
  final BuildContext context;

  /// A list containing all models (as [ModelMap]) available for searching.
  List<ModelMap> allModels;

  /// A map storing [DownloadManager] instances, keyed by model ID, to manage download states.
  final Map<String, DownloadManager> downloadManagers;

  /// A map indicating the persistent download state of models from the file system.
  /// This field is mutable and updated from outside when the source data changes.
  Map<String, bool> downloadedFileStates;

  /// A function that returns the [CompatibilityStatus] of a model given its size.
  final CompatibilityStatus Function(int? modelSizeInMB) getCompatibilityStatus;

  /// A callback function to open the detail view for a specific model.
  final Future<void> Function({
  required String id,
  required String description,
  required String imagePath,
  required int? size,
  required int? ram,
  required String producer,
  required bool isServerSide,
  required bool isDownloaded,
  required bool isDownloading,
  required CompatibilityStatus compatibilityStatus,
  required String? url,
  required bool isCustomModel,
  required String? modelPath,
  required bool isFullyLocalized,
  }) openModelDetail;

  /// A callback function to remove a model, identified by its [id].
  final Future<void> Function(String id) removeModel;

  /// A callback function to start a chat session with a model.
  final Future<void> Function(String id, bool isServerSide,
      {bool isCustomModel, String? modelPath}) startChat;

  /// A callback function to initiate the download of a model.
  final void Function(
      {required String id,
      required String url,
      required String title}) startDownload;

  /// A callback function to cancel an ongoing download for a model.
  final void Function(String id) cancelDownload;

  /// A callback function to resume a paused download for a model.
  final void Function(String id) resumeDownload;

  //--------------------------------------------------------------------
  // Internal state
  //--------------------------------------------------------------------

  /// The text editing controller for the search input field.
  final TextEditingController _controller = TextEditingController();

  /// A timer used to debounce search queries, preventing excessive processing on rapid input.
  Timer? _debounce;

  /// Stores the list of models from the previous search result set. Used for animations.
  List<ModelMap> _prev = [];

  /// Stores models that are currently "exiting" the search results (e.g., due to a changed query).
  /// This list is used to animate their departure from the UI.
  List<ModelMap> _exiting = [];

  //--------------------------------------------------------------------
  // Getters
  //--------------------------------------------------------------------

  /// Provides access to the internal [TextEditingController].
  TextEditingController get textController => _controller;

  //--------------------------------------------------------------------
  // Public Methods
  //--------------------------------------------------------------------

  /// Updates the controller's internal list of models.
  ///
  /// This is called from outside (e.g., from `_ModelsScreenState`) when the
  /// main model data source has been refreshed. If a search is currently
  /// active, it triggers a re-filtering of the results.
  void updateModels(List<Map<String, dynamic>> newModels) {
    allModels = newModels;
    _printLog('updateModels: Model list updated with ${newModels.length} items.');
    // If a search is active, re-filter the results with the new data.
    final currentQuery = textController.text.trim();
    if (currentQuery.isNotEmpty) {
      filterSearchResults(currentQuery);
    }
  }

  //--------------------------------------------------------------------
  // Public UI builders
  //--------------------------------------------------------------------

  /// Builds the search bar widget.
  ///
  /// [w] is typically the screen width, used for responsive sizing.
  Widget buildSearchBar(double w) {
    _printLog('buildSearchBar called with width: $w');
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: w * .05, vertical: w * .025),
      child: TextField(
        controller: _controller,
        style: TextStyle(color: AppColors.primaryColor.inverted),
        decoration: InputDecoration(
          hintText: loc.searchHint, // Localized hint text
          hintStyle: TextStyle(color: AppColors.primaryColor.inverted.withOpacity(0.5)),
          prefixIcon: Icon(Icons.search,
              size: w * .06, color: AppColors.primaryColor.inverted),
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

  /// Builds the main body of the search results.
  /// This includes logic for animating items entering and leaving the list.
  ///
  /// [w] is typically the screen width, used for responsive sizing.
  Widget buildSearchBody(double w) {
    _printLog('buildSearchBody called with width: $w');
    final String currentQuery = _controller.text.trim().toLowerCase();
    _printLog('Current search query: "$currentQuery"');

    final List<ModelMap> currentResults = _filter(allModels, currentQuery);
    _printLog('Filtered ${currentResults.length} models based on query.');

    // 1️⃣ If a model "returns" to the results, remove it from the exiting queue.
    _exiting.removeWhere((exitingModel) =>
        currentResults.any((resultModel) => resultModel['id'] == exitingModel['id']));

    // 2️⃣ Identify new "leaving" items and add them to the exiting queue for animation.
    final List<ModelMap> newlyLeavingModels = _prev.where((prevModel) =>
    !currentResults.any((currentModel) => currentModel['id'] == prevModel['id'])).toList();

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

    // 3️⃣ Combine current results and exiting items for display, ensuring uniqueness.
    final Set<String> idsInMerged = {};
    final List<ModelMap> mergedDisplayList = [
      ...currentResults,
      ..._exiting.where((m) => !currentResults.any((r) => r['id'] == m['id']))
    ].where((model) => idsInMerged.add(model['id'] as String)).toList();


    if (currentQuery.isEmpty) {
      _prev.clear();
      _exiting.clear();
      return const SizedBox.shrink();
    }

    if (mergedDisplayList.isEmpty) {
      return _noResults(w);
    }

    return ListView.builder(
      key: const ValueKey('searchResults'),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: w * .04),
      itemCount: mergedDisplayList.length,
      itemBuilder: (ctx, i) {
        final model = mergedDisplayList[i];
        final bool isLeaving =
            _exiting.any((exitingModel) => exitingModel['id'] == model['id']) &&
                !currentResults.any((currentModel) => currentModel['id'] == model['id']);
        return _buildResultTile(
          model,
          w,
          index: i,
          isLeaving: isLeaving,
        );
      },
    );
  }

  //--------------------------------------------------------------------
  // Private helpers
  //--------------------------------------------------------------------

  void _printLog(String message) {
    // print('[ModelsSearchController] $message'); // Uncomment for verbose logging
  }

  /// Handles text changes from the search input field.
  ///
  /// It uses a debounce timer to avoid excessive UI updates during rapid typing.
  /// After the debounce period, it calls `filterSearchResults` to update the UI.
  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      filterSearchResults(text);
    });
  }

  /// Triggers a UI update to re-evaluate the search results.
  ///
  /// This method is called when the search query changes or when the underlying
  /// model list is updated, ensuring the displayed results are always current.
  /// It works by calling `markNeedsBuild` on the widget's context.
  void filterSearchResults(String query) {
    _printLog('filterSearchResults: Forcing a rebuild for query "$query".');
    if ((context as Element).mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  /// Filters the model list based on the query.
  List<ModelMap> _filter(List<ModelMap> data, String q) {
    if (q.isEmpty) {
      return [];
    }
    // Perform a case-insensitive search on the model title.
    return data.where((model) {
      final title = (model['title'] ?? '').toString().toLowerCase();
      return title.contains(q);
    }).toList();
  }

  /// Builds a widget to display when no search results are found.
  Widget _noResults(double w) {
    final loc = AppLocalizations.of(context)!;
    return Padding(
      padding: EdgeInsets.all(w * .05),
      child: Text(
        loc.noMatchingModels,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: w * .045,
          color: AppColors.primaryColor.inverted,
        ),
      ),
    );
  }

  /// Builds a single tile for a search result item.
  Widget _buildResultTile(ModelMap model, double w, {required int index, required bool isLeaving}) {
    final String id = model['id'] as String;
    final dm = downloadManagers.putIfAbsent(id, () => DownloadManager());

    // --- UPDATED & ROBUST DATA HANDLING ---
    final bool isServerSide = model['type'] != 'offline';
    final bool isCustomModel = model['category'] == 'self';
    final String title = model['title'] as String? ?? 'Untitled Model';
    final String summary = model['summary'] as String? ?? '';
    final String fullDescription = model['description'] as String? ?? summary;
    final String imagePath = ModelData.getModelImagePath(model);
    final String producer = model['producer'] as String? ?? 'Unknown';
    final String? url = model['url'] as String?;
    final String? modelPath = model['path'] as String?;
    final int? sizeInt = model['size'] as int?;
    final int? ramInt = model['ram'] as int?;
    final bool isFullyLocalized = model['isFullyLocalized'] as bool? ?? true;
    final String sizeStringForTile = sizeInt?.toString() ?? 'N/A';
    final String ramStringForTile = ramInt?.toString() ?? 'N/A';
    final compatibilityStatus = getCompatibilityStatus(sizeInt);

    // --- THE PERFECT FIX ---
    // Calculate the reliable download state using BOTH the persistent file state
    // and the temporary manager state. This is the single source of truth.
    final bool isEffectivelyDownloaded = (downloadedFileStates[id] ?? false) || dm.isDownloaded;
    // --- END OF FIX ---

    final tile = ModelTile(
      key: ValueKey(id),
      id: id,
      title: title,
      description: summary,
      imagePath: imagePath,
      producer: producer,
      url: url,
      size: sizeStringForTile,
      requirements: ramStringForTile,
      modelPath: modelPath,
      isServerSide: isServerSide,
      isCustomModel: isCustomModel,
      isLastInColumn: false,
      isSeeAll: true,
      manager: dm,
      compatibilityStatus: compatibilityStatus,
      isDownloaded: isEffectivelyDownloaded, // Provide the required, reliable state.
      onTileTap: () => openModelDetail(
        id: id,
        description: fullDescription,
        imagePath: imagePath,
        size: sizeInt,
        ram: ramInt,
        producer: producer,
        isServerSide: isServerSide,
        isDownloaded: isEffectivelyDownloaded, // Pass the reliable state to the detail page.
        isDownloading: dm.isDownloading,
        compatibilityStatus: compatibilityStatus,
        url: url,
        isCustomModel: isCustomModel,
        modelPath: modelPath,
        isFullyLocalized: isFullyLocalized,
      ),
      onRemoveRequested: () => removeModel(id),
      onChatPressed: () => startChat(id, isServerSide, isCustomModel: isCustomModel, modelPath: modelPath),
      onDownloadPressed: () => startDownload(id: id, url: url ?? '', title: title),
      onCancelDownload: () => cancelDownload(id),
      onResumeDownload: () => resumeDownload(id),
    );

    return SearchResultItem(
      key: ValueKey('res_$id'),
      index: index,
      delay: Duration.zero,
      isExiting: isLeaving,
      child: tile,
    );
  }

  //--------------------------------------------------------------------
  // Lifecycle
  //--------------------------------------------------------------------

  /// Cleans up resources, such as the text controller and debounce timer.
  void dispose() {
    _printLog('dispose called.');
    _controller.dispose();
    _debounce?.cancel();
    _printLog('ModelsSearchController disposed.');
  }
}