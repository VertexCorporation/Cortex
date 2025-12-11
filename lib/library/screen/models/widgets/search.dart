// search.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:cortex/library/backend/utils.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../error.dart';
import '../../../../theme.dart';
import 'cards.dart';
import 'results.dart';
import '../../../backend/data/entity.dart';
import '../../../backend/download/download.dart';

class ModelsSearchController {
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
    _controller.addListener(() => _onChanged(_controller.text));
  }

  final BuildContext context;
  final FocusNode focusNode;
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

  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;
  List<ModelEntity> _prev = [];
  final List<ModelEntity> _exiting = [];

  TextEditingController get textController => _controller;

  void updateModels(List<ModelEntity> newModels) {
    allModels = newModels;
    final currentQuery = textController.text.trim();
    if (currentQuery.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if ((context as Element).mounted) {
          filterSearchResults(currentQuery);
        }
      });
    }
  }

  Widget buildSearchBar(double w) {
    final loc = AppLocalizations.of(context)!;
    final bool isTablet = w >= 600;

    final EdgeInsets outerPadding = isTablet
        ? const EdgeInsets.only(top: 40, bottom: 8, left: 2, right: 2)
        : EdgeInsets.symmetric(horizontal: w * .05, vertical: w * .025);

    final double iconSize = isTablet ? 36.0 : w * .06;
    final double borderRadius = isTablet ? 24.0 : w * .05;
    final double maxBarWidth = isTablet ? 700 : double.infinity;
    final double? fontSize = isTablet ? 22.0 : null;
    final EdgeInsets? contentPadding = isTablet
        ? const EdgeInsets.symmetric(horizontal: 30, vertical: 26)
        : null;

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxBarWidth),
        padding: outerPadding,
        child: TextField(
          controller: _controller,
          focusNode: focusNode,
          style: TextStyle(
            color: AppColors.primaryColor.inverted,
            fontSize: fontSize,
          ),
          decoration: InputDecoration(
            hintText: loc.searchHint,
            hintStyle: TextStyle(
              color: AppColors.primaryColor.inverted.withValues(alpha: 0.5),
              fontSize: fontSize,
            ),
            prefixIcon: Icon(
                Icons.search,
                size: iconSize,
                color: AppColors.primaryColor.inverted
            ),
            filled: true,
            fillColor: AppColors.quaternaryColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide.none,
            ),
            contentPadding: contentPadding,
          ),
        ),
      ),
    );
  }

  Widget buildSearchBody(double w) {
    final String currentQuery = _controller.text.trim().toLowerCase();
    final bool isTablet = w >= 600;

    // 1. Initial State
    if (currentQuery.isEmpty) {
      _prev.clear();
      _exiting.clear();
      return Align(
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: const SizedBox.shrink(key: ValueKey('empty-search')),
        ),
      );
    }

    final List<ModelEntity> currentResults = _filter(allModels, currentQuery);

    // 2. Animation Logic
    if (currentResults.isEmpty) {
      _exiting.clear();
    } else {
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
    }

    _prev = List.from(currentResults);

    final Set<String> idsInMerged = {};
    final List<ModelEntity> mergedDisplayList = [
      ...currentResults,
      ..._exiting.where((m) => !currentResults.any((r) => r.id == m.id))
    ].where((model) => idsInMerged.add(model.id)).toList();

    final double maxListWidth = isTablet ? 700 : double.infinity;

    // Check if we effectively have results to show (or are animating them out)
    final bool showResults = mergedDisplayList.isNotEmpty;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxListWidth,
          // IMPORTANT: We ensure the container fills the height so the Stack doesn't collapse.
          // This allows 'Positioned' to work correctly relative to the search body area.
          minHeight: MediaQuery.of(context).size.height * 0.5,
        ),
        child: Stack(
          // Stack allows us to overlay the "No Results" exactly where we want.
          children: [

            // LAYER 1: The List
            // Using AnimatedOpacity to fade it out without removing it from layout immediately,
            // preventing sudden layout shifts.
            AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: showResults ? 1.0 : 0.0,
              curve: Curves.easeInOut,
              child: ListView.builder(
                key: const ValueKey('search-results-list'),
                shrinkWrap: true,
                physics: const ScrollPhysics(),
                padding: isTablet
                    ? const EdgeInsets.only(bottom: 20)
                    : EdgeInsets.symmetric(horizontal: w * .04),
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
            ),

            // LAYER 2: The "No Results" Screen
            // POSITIONED ABSOLUTELY.
            // By using Positioned(top: 0), we force this widget to stick to the top pixel
            // of the Stack, regardless of how tall or short the ListView behind it is.
            // It physically cannot jump to the center.
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: showResults, // Allow clicks to pass through to list when results exist
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 250),
                  opacity: showResults ? 0.0 : 1.0, // Fade in when no results
                  curve: Curves.easeInOut,
                  child: _noResults(w, key: const ValueKey('no-results')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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

  List<ModelEntity> _filter(List<ModelEntity> data, String q) {
    if (q.isEmpty) return [];
    final String lowerCaseQuery = q.trim().toLowerCase();
    if (lowerCaseQuery.isEmpty) return [];

    return data.where((model) {
      final List<String> words = model.displayTitle.toLowerCase().split(' ');
      return words.any((word) => word.startsWith(lowerCaseQuery));
    }).toList();
  }

  Widget _noResults(double w, {required Key key}) {
    final loc = AppLocalizations.of(context)!;
    final bool isTablet = w >= 600;

    return Container(
      key: key,
      // Padding ensures it sits nicely under the search bar
      padding: EdgeInsets.only(
          top: isTablet ? 40 : w * .15,
          left: w * .05,
          right: w * .05
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Takes minimal vertical space
        children: [
          ErrorView(
            title: loc.noModelsFoundTitle,
            message: loc.noModelsFoundMessage,
          ),
        ],
      ),
    );
  }

  Widget _buildResultTile(ModelEntity model, {required int index, required bool isLeaving}) {
    final dm = downloadManagers.putIfAbsent(model.id, () => DownloadManager());
    final compatibilityStatus = getCompatibilityStatus(model.size);
    final isEffectivelyDownloaded = (downloadedFileStates[model.id] ?? false) || dm.isDownloaded;

    final tile = ModelTile(
      key: ValueKey(model.id),
      model: model,
      isLastInColumn: false,
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

  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
  }
}