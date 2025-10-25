// lib/chat/services/dynamic.dart

import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/extensions.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/models/backend/data/data.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A dedicated service class to handle all logic related to the Dynamic Chat feature.
///
/// This service manages the user's preference for a "pinned" dynamic assistant,
/// handles the UI for selecting that assistant, and interacts exclusively with the
/// ChatSessionProvider to read and modify the application's session state.
class DynamicChatService {
  /// A reference to the central session state management provider.
  final ChatSessionProvider _sessionProvider;

  /// A private key for storing the pinned assistant's ID in SharedPreferences.
  static const String dynamicAssistantKey = 'dynamic_chat_assistant_id';

  /// Constructs the DynamicChatService with its required dependency.
  DynamicChatService(this._sessionProvider);

  /// Loads the user's preferred dynamic assistant from SharedPreferences.
  ///
  /// It validates the saved model ID against the models loaded in the provider
  /// and triggers the appropriate state change via the provider's methods.
  Future<void> loadDynamicAssistantPreference() async {
    final prefs = await SharedPreferences.getInstance();
    final assistantId = prefs.getString(dynamicAssistantKey);

    if (assistantId == null || assistantId.isEmpty) {
      debugPrint("[DynamicChatService] No dynamic assistant preference found. Using default random mode.");
      // Ensure state is set to generic dynamic mode if no preference exists.
      if (_sessionProvider.isDynamicChat && _sessionProvider.modelId != null) {
        _sessionProvider.unpinDynamicAssistant();
      }
      return;
    }

    // Validate that the saved model still exists by checking the master list.
    final allModels = _sessionProvider.allModels;
    bool isValid = allModels.any((model) {
      if (model.id == assistantId) return true;
      // Also check if the ID belongs to an extension of a known model series.
      final extensions = ModelData.getPreciseModelData(model.id)['extensions'] as Map<String, dynamic>?;
      return extensions?.containsKey(assistantId) ?? false;
    });

    if (isValid) {
      debugPrint("[DynamicChatService] Valid dynamic assistant found: '$assistantId'. Pinning model.");
      _sessionProvider.pinDynamicAssistant(assistantId);
    } else {
      debugPrint("[DynamicChatService] WARN: Saved assistant '$assistantId' is no longer available. Reverting to default.");
      await _saveDynamicAssistantPreference(null); // Clear the invalid preference.
      _sessionProvider.unpinDynamicAssistant();
    }
  }

  /// Displays the overlay panel for the user to select their default dynamic assistant.
  ///
  /// This method encapsulates all UI logic for creating, showing, and securely
  /// dismissing the selection panel using a robust animation approach.
  void showDynamicAssistantPanel({
    required BuildContext context,
    required GlobalKey chatTitleKey,
  }) {
    debugPrint("[DynamicChatService] Attempting to show dynamic assistant panel.");
    final RenderBox? renderBox = chatTitleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("[DynamicChatService] CRITICAL: Could not find renderBox for chat title. Panel cannot be shown.");
      return;
    }

    // Pre-calculate options before triggering any UI updates.
    final allOptions = _buildDynamicAssistantOptions(context);
    final currentlySelectedId = (_sessionProvider.isDynamicChat && _sessionProvider.modelId == null)
        ? '--dynamic--'
        : _sessionProvider.modelId;

    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    // A local flag to track if the closing animation has started.
    bool isPanelClosing = false;

    overlayEntry = OverlayEntry(builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      // StatefulBuilder is essential here to manage the local animation state of the overlay.
      return StatefulBuilder(builder: (context, setModalState) {
        return Stack(
          children: [
            // A full-screen transparent detector to catch taps outside the panel.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () {
                  // Start the closing animation.
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
                // Animate scale: 0.4 -> 1.0 (open), 1.0 -> 0.4 (close)
                tween: Tween<double>(
                    begin: isPanelClosing ? 1.0 : 0.4,
                    end: isPanelClosing ? 0.4 : 1.0
                ),
                duration: const Duration(milliseconds: 150), // Smooth, quick animation.
                curve: Curves.easeOutCubic,
                onEnd: () {
                  // CRITICAL: Only remove the overlay AFTER the closing animation finishes.
                  if (isPanelClosing) {
                    overlayEntry?.remove();
                    overlayEntry = null;
                  }
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    // Fade opacity concurrently with scale for a smoother effect.
                    child: Opacity(
                        opacity: (scale - 0.4) / (1.0 - 0.4),
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
                    // Trigger closing animation immediately upon selection.
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

  /// Gathers, categorizes, and sorts all usable models for the assistant panel.
  /// It correctly separates base model series from their selectable extension variants.
  List<Map<String, dynamic>> _buildDynamicAssistantOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final allModelInfos = _sessionProvider.allModels;

    final List<Map<String, dynamic>> offlineOptions = [];
    final List<Map<String, dynamic>> characterOptions = [];
    final List<Map<String, dynamic>> selfOptions = [];
    final Map<String, List<Map<String, dynamic>>> onlineSeriesMap = {};

    for (final modelInfo in allModelInfos) {
      final preciseData = ModelData.getPreciseModelData(modelInfo.id);
      final String category = preciseData['category'] as String? ?? 'online';
      final String type = preciseData['type'] as String? ?? 'online';

      if (type == 'online' && category != 'roleplay' && category != 'self') {
        final seriesTitle = preciseData['title'] as String;
        final extensions = preciseData['extensions'] as Map<String, dynamic>?;

        onlineSeriesMap.putIfAbsent(seriesTitle, () => []);

        // CORE LOGIC: If a series has extensions, only the extensions are selectable.
        // If it has none, the series itself is selectable.
        if (extensions != null && extensions.isNotEmpty) {
          for (final extId in extensions.keys) {
            onlineSeriesMap[seriesTitle]!.add(ModelData.getPreciseModelData(extId));
          }
        } else {
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

    // Sort and flatten the online options.
    final List<Map<String, dynamic>> onlineOptions = [];
    int sorter(Map<String, dynamic> a, Map<String, dynamic> b) =>
        (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase());

    final sortedSeriesTitles = onlineSeriesMap.keys.toList()..sort();
    for (final seriesTitle in sortedSeriesTitles) {
      final extensionsInSeries = onlineSeriesMap[seriesTitle]!;
      if (extensionsInSeries.isEmpty) continue;
      extensionsInSeries.sort(sorter);
      onlineOptions.addAll(extensionsInSeries);
    }

    offlineOptions.sort(sorter);
    characterOptions.sort(sorter);
    selfOptions.sort(sorter);

    // Combine into the final list with the "Random" option first.
    final List<Map<String, dynamic>> finalOptions = [
      {'id': '--dynamic--', 'title': localizations.dynamicChatTitle, 'tier': 'free'},
      ...onlineOptions,
      ...offlineOptions,
      ...characterOptions,
      ...selfOptions,
    ];

    debugPrint("[DynamicChatService] Built dynamic assistant panel with ${finalOptions.length} selectable options.");
    return finalOptions;
  }

  /// Handles the state update logic after a user selects an assistant.
  /// It updates persistent storage and delegates state changes to the provider.
  Future<void> _handleDynamicAssistantSelection(String selectedId) async {
    if (selectedId == '--dynamic--') {
      await _saveDynamicAssistantPreference(null);
      _sessionProvider.unpinDynamicAssistant();
    } else {
      await _saveDynamicAssistantPreference(selectedId);
      _sessionProvider.pinDynamicAssistant(selectedId);
    }
  }

  /// Saves the user's choice to SharedPreferences.
  Future<void> _saveDynamicAssistantPreference(String? modelId) async {
    final prefs = await SharedPreferences.getInstance();
    if (modelId == null) {
      await prefs.remove(dynamicAssistantKey);
      debugPrint("[DynamicChatService] Dynamic assistant preference cleared.");
    } else {
      await prefs.setString(dynamicAssistantKey, modelId);
      debugPrint("[DynamicChatService] Saved '$modelId' as the new dynamic assistant.");
    }
  }
}