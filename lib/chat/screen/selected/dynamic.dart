// lib/chat/services/dynamic.dart

import 'package:cortex/chat/chat.dart';
import 'package:cortex/extensions.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/models/backend/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A dedicated service class to handle all logic related to the Dynamic Chat feature.
///
/// This includes managing the pinned assistant preference, building the list of
/// available assistants, and showing the selection panel. It decouples this
/// complex feature from the main ChatScreenState, making the code cleaner and
/// more maintainable.
class DynamicChatService {
  /// A reference to the parent ChatScreenState to access its properties and methods.
  final ChatScreenState _state;

  /// A private key for storing the pinned assistant's ID in SharedPreferences.
  static const String _dynamicAssistantKey = 'dynamic_chat_assistant_id';

  DynamicChatService(this._state);

  /// Loads the user's preferred dynamic assistant from SharedPreferences.
  ///
  /// It validates that the saved model ID is still available and updates the
  /// ChatScreenState accordingly. If the saved ID is invalid or not found,
  /// it reverts to the default random dynamic mode.
  Future<void> loadDynamicAssistantPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final assistantId = prefs.getString(_dynamicAssistantKey);

    if (assistantId == null || assistantId.isEmpty) {
      debugPrint("[DynamicChatService] No dynamic assistant preference found. Using default random mode.");
      if (!_state.isPersistentlyDynamic) {
        _state.setState(() => _state.isPersistentlyDynamic = true);
      }
      return;
    }

    // Validate that the saved model still exists in the currently loaded model list.
    final allModels = _state.loadService.allModels;
    bool isValid = allModels.any((model) {
      if (model.id == assistantId) return true;
      final extensions = model.extensions;
      return extensions?.containsKey(assistantId) ?? false;
    });

    if (isValid) {
      debugPrint("[DynamicChatService] Valid dynamic assistant found: '$assistantId'. Pinning model.");
      final preciseData = ModelData.getPreciseModelData(assistantId);
      _state.setState(() {
        _state.modelId = assistantId;
        _state.isPersistentlyDynamic = false; // Disable random model selection.
        _state.role = preciseData['role'] as String?;
        _state.canHandleImage = ModelData.hasModality(assistantId, 'image');
        _state.isCurrentModelServerSide = (preciseData['type'] as String? ?? 'online') != 'offline';
      });
    } else {
      debugPrint("[DynamicChatService] WARN: Saved assistant '$assistantId' is no longer available. Reverting to default.");
      await _saveDynamicAssistantPreference(null); // Clear the invalid preference.
      _state.setState(() {
        _state.modelId = null;
        _state.isPersistentlyDynamic = true;
      });
    }
  }


  /// Displays the overlay panel for the user to select their default dynamic assistant.
  /// This method encapsulates all the UI logic for creating and showing the panel.
  /// It now uses a proven animation and dismissal logic to ensure a smooth UX.
  void showDynamicAssistantPanel() {
    debugPrint("[DynamicChatService] Attempting to show dynamic assistant panel.");
    final context = _state.context;
    final RenderBox? renderBox = _state.chatTitleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("[DynamicChatService] CRITICAL: Could not find renderBox for chatTitleKey. Panel cannot be shown.");
      return;
    }

    // Heavy lifting is done here, BEFORE the animation starts.
    final allOptions = _buildDynamicAssistantOptions();
    final currentlySelectedId = _state.isPersistentlyDynamic ? '--dynamic--' : _state.modelId;

    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    // This flag controls the closing animation.
    bool isPanelClosing = false;

    overlayEntry = OverlayEntry(builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      // StatefulBuilder allows the overlay to manage its own state (like 'isPanelClosing').
      return StatefulBuilder(builder: (context, setModalState) {
        return Stack(
          children: [
            // This full-screen GestureDetector catches taps outside the panel to dismiss it.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // Trigger the closing animation.
                  setModalState(() => isPanelClosing = true);
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: offset.dy,
              left: horizontalMargin,
              right: horizontalMargin,
              child: TweenAnimationBuilder<double>(
                // Animate scale from 0.4 to 1.0 on open, and 1.0 to 0.4 on close.
                tween: Tween<double>(begin: isPanelClosing ? 1.0 : 0.4, end: isPanelClosing ? 0.4 : 1.0),
                duration: const Duration(milliseconds: 100), // Fast but smooth animation
                curve: Curves.easeOut,
                onEnd: () {
                  // CRITICAL: Remove the overlay from the screen ONLY after the closing animation is complete.
                  if (isPanelClosing) {
                    overlayEntry?.remove();
                    overlayEntry = null;
                  }
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    // Animate opacity for a fade effect as well.
                    child: Opacity(
                        opacity: (scale - 0.4) / (1.0 - 0.4), // maps 0.4-1.0 scale to 0.0-1.0 opacity
                        child: child
                    ),
                  );
                },
                child: Extensions.buildExtensionPanelWidget(
                  context: context,
                  options: allOptions,
                  selectedExtension: currentlySelectedId ?? '--dynamic--',
                  modelTitle: AppLocalizations.of(context)!.dynamicChatTitle,
                  onDismiss: () => setModalState(() => isPanelClosing = true),
                  onSelect: (selectedOption) {
                    // When an item is selected, also trigger the closing animation.
                    setModalState(() => isPanelClosing = true);
                    final selectedId = selectedOption['id'] as String;
                    _handleDynamicAssistantSelection(selectedId);
                  },
                ),
              ),
            ),
          ],
        );
      });
    });

    overlay.insert(overlayEntry!);
  }

  /// Gathers and flattens all usable models into a sorted and categorized list
  /// for the assistant panel. This logic is now centralized here.
  List<Map<String, dynamic>> _buildDynamicAssistantOptions() {
    final localizations = AppLocalizations.of(_state.context)!;
    final allModelInfos = _state.loadService.allModels;

    // --- STEP 1: Process and Categorize All Models ---

    final List<Map<String, dynamic>> offlineOptions = [];
    final List<Map<String, dynamic>> characterOptions = [];
    final List<Map<String, dynamic>> selfOptions = [];

    // Key: The series title (e.g., "Gemma").
    // Value: A list of all SELECTABLE extension/model data maps for that series.
    final Map<String, List<Map<String, dynamic>>> onlineSeriesMap = {};

    for (final modelInfo in allModelInfos) {
      final preciseData = ModelData.getPreciseModelData(modelInfo.id);
      final String category = preciseData['category'] as String? ?? 'online';
      final String type = preciseData['type'] as String? ?? 'online';

      if (type == 'online' && category != 'roleplay' && category != 'self') {
        final seriesTitle = preciseData['title'] as String;
        final extensions = preciseData['extensions'] as Map<String, dynamic>?;

        // Ensure the series exists in the map.
        onlineSeriesMap.putIfAbsent(seriesTitle, () => []);

        // --- CORE LOGIC CHANGE ---
        // If the model has extensions, it's a non-selectable series.
        // We ONLY add its children (the extensions) to the map.
        if (extensions != null && extensions.isNotEmpty) {
          for (final extId in extensions.keys) {
            onlineSeriesMap[seriesTitle]!.add(ModelData.getPreciseModelData(extId));
          }
        }
        // If the model has NO extensions, it's a standalone, selectable model.
        // We add the model itself to the map.
        else {
          onlineSeriesMap[seriesTitle]!.add(preciseData);
        }

      } else if (type == 'offline') {
        offlineOptions.add(preciseData);
      } else if (category == 'roleplay') {
        characterOptions.add(preciseData);
      } else if (category == 'self') {
        selfOptions.add(preciseData);
      }
    }

    // --- STEP 2: Perform Multi-Level Sorting for Online Models ---

    final List<Map<String, dynamic>> onlineOptions = [];
    final sorter = (Map<String, dynamic> a, Map<String, dynamic> b) =>
        (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase());

    // Primary Sort: Sort the series titles alphabetically.
    final sortedSeriesTitles = onlineSeriesMap.keys.toList()..sort();

    // Secondary Sort & Flatten: Iterate through sorted series, sort extensions within them, then add to final list.
    for (final seriesTitle in sortedSeriesTitles) {
      final extensionsInSeries = onlineSeriesMap[seriesTitle]!;
      // This is a safety check: if a series ended up with no selectable children, skip it.
      if (extensionsInSeries.isEmpty) continue;

      extensionsInSeries.sort(sorter); // Sort extensions/models within the series.
      onlineOptions.addAll(extensionsInSeries); // Add the sorted group.
    }

    // --- STEP 3: Sort Other Categories and Combine All Lists ---

    offlineOptions.sort(sorter);
    characterOptions.sort(sorter);
    selfOptions.sort(sorter);

    // Combine all sorted lists in the final desired order.
    final List<Map<String, dynamic>> finalOptions = [];
    finalOptions.add({'id': '--dynamic--', 'title': localizations.dynamicChatTitle, 'tier': 'free'});
    finalOptions.addAll(onlineOptions);
    finalOptions.addAll(offlineOptions);
    finalOptions.addAll(characterOptions);
    finalOptions.addAll(selfOptions);

    debugPrint("[DynamicChatService] Built dynamic assistant panel with ${finalOptions.length} selectable & sorted options.");
    return finalOptions;
  }

  /// Handles the state update logic after a user selects an assistant from the panel.
  Future<void> _handleDynamicAssistantSelection(String selectedId) async {
    if (selectedId == '--dynamic--') {
      await _saveDynamicAssistantPreference(null);
      // When reverting to fully dynamic mode...
      _state.setState(() {
        _state.isPersistentlyDynamic = true;
        _state.modelId = null;
        _state.role = null;
        _state.canHandleImage = true; // Revert to assuming image capability
        _state.modelTitle = null;     // Clear the model-specific details from the UI state
        _state.modelImagePath = null;
        _state.modelProducer = null;
      });
    } else {
      await _saveDynamicAssistantPreference(selectedId);
      final preciseData = ModelData.getPreciseModelData(selectedId);
      _state.setState(() {
        _state.isPersistentlyDynamic = false;
        _state.modelId = selectedId;
        _state.role = preciseData['role'] as String?;
        _state.canHandleImage = ModelData.hasModality(selectedId, 'image');

        // This ensures that if the new model can't handle images, the photo
        // button in the input field disables immediately, and the app bar title
        // reflects the new assistant correctly.
        _state.modelTitle = preciseData['title'] as String?;
        _state.modelImagePath = preciseData['imagePath'] as String?;
        _state.modelProducer = preciseData['producer'] as String?;
        _state.updatePremiumBriefingVisibility(selectedId);
        // --- END NEW ---
      });
    }
  }

  /// Saves the user's choice of dynamic assistant to SharedPreferences.
  /// A `null` value clears the preference.
  Future<void> _saveDynamicAssistantPreference(String? modelId) async {
    final prefs = await SharedPreferences.getInstance();
    if (modelId == null) {
      await prefs.remove(_dynamicAssistantKey);
      debugPrint("[DynamicChatService] Dynamic assistant preference cleared.");
    } else {
      await prefs.setString(_dynamicAssistantKey, modelId);
      debugPrint("[DynamicChatService] Saved '$modelId' as the new dynamic assistant.");
    }
  }
}