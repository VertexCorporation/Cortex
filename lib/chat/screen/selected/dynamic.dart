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
  void showDynamicAssistantPanel() {
    debugPrint("[DynamicChatService] Attempting to show dynamic assistant panel.");
    final context = _state.context; // Get context from the state.
    final RenderBox? renderBox = _state.chatTitleKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("[DynamicChatService] CRITICAL: Could not find renderBox for chatTitleKey. Panel cannot be shown.");
      return;
    }

    final allOptions = _buildDynamicAssistantOptions();
    final currentlySelectedId = _state.isPersistentlyDynamic ? '--dynamic--' : _state.modelId;

    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));
    bool isPanelClosing = false;

    overlayEntry = OverlayEntry(builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      return StatefulBuilder(builder: (context, setModalState) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setModalState(() => isPanelClosing = true),
                child: Container(color: Colors.transparent),
              ),
            ),
            Positioned(
              top: offset.dy,
              left: horizontalMargin,
              right: horizontalMargin,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: isPanelClosing ? 1.0 : 0.4, end: isPanelClosing ? 0.4 : 1.0),
                duration: const Duration(milliseconds: 50),
                curve: Curves.easeOut,
                onEnd: () {
                  if (isPanelClosing) overlayEntry?.remove();
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: child,
                  );
                },
                child: Extensions.buildExtensionPanelWidget(
                  context: context,
                  options: allOptions,
                  selectedExtension: currentlySelectedId ?? '--dynamic--',
                  modelTitle: AppLocalizations.of(context)!.dynamicChatTitle,
                  onDismiss: () => setModalState(() => isPanelClosing = true),
                  onSelect: (selectedOption) {
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

    overlay.insert(overlayEntry);
  }

  /// Gathers and flattens all usable models into a sorted and categorized list
  /// for the assistant panel. This logic is now centralized here.
  List<Map<String, dynamic>> _buildDynamicAssistantOptions() {
    final localizations = AppLocalizations.of(_state.context)!;
    final allModelInfos = _state.loadService.allModels;

    final List<Map<String, dynamic>> onlineOptions = [];
    final List<Map<String, dynamic>> offlineOptions = [];
    final List<Map<String, dynamic>> characterOptions = [];
    final List<Map<String, dynamic>> selfOptions = [];

    for (final modelInfo in allModelInfos) {
      final preciseData = ModelData.getPreciseModelData(modelInfo.id);
      final String category = preciseData['category'] as String? ?? 'online';
      final String type = preciseData['type'] as String? ?? 'online';

      if (category == 'roleplay') {
        characterOptions.add(preciseData);
      } else if (category == 'self') {
        selfOptions.add(preciseData);
      } else if (type == 'offline') {
        if (1 == 1) { // Placeholder for isDownloaded check
          offlineOptions.add(preciseData);
        }
      } else if (type == 'online') {
        final extensions = preciseData['extensions'] as Map<String, dynamic>?;
        if (extensions != null && extensions.isNotEmpty) {
          for (final extId in extensions.keys) {
            onlineOptions.add(ModelData.getPreciseModelData(extId));
          }
        } else {
          onlineOptions.add(preciseData);
        }
      }
    }

    final sorter = (Map<String, dynamic> a, Map<String, dynamic> b) =>
        (a['title'] as String).toLowerCase().compareTo((b['title'] as String).toLowerCase());

    onlineOptions.sort(sorter);
    offlineOptions.sort(sorter);
    characterOptions.sort(sorter);
    selfOptions.sort(sorter);

    final List<Map<String, dynamic>> finalOptions = [];
    finalOptions.add({'id': '--dynamic--', 'title': localizations.dynamicChatTitle, 'tier': 'free'});
    finalOptions.addAll(onlineOptions);
    finalOptions.addAll(offlineOptions);
    finalOptions.addAll(characterOptions);
    finalOptions.addAll(selfOptions);

    debugPrint("[DynamicChatService] Built dynamic assistant panel with ${finalOptions.length} options.");
    return finalOptions;
  }

  /// Handles the state update logic after a user selects an assistant from the panel.
  Future<void> _handleDynamicAssistantSelection(String selectedId) async {
    if (selectedId == '--dynamic--') {
      await _saveDynamicAssistantPreference(null);
      _state.setState(() {
        _state.isPersistentlyDynamic = true;
        _state.modelId = null;
        _state.role = null;
        _state.canHandleImage = true; // Revert to assuming image capability for dynamic mode
      });
    } else {
      await _saveDynamicAssistantPreference(selectedId);
      final preciseData = ModelData.getPreciseModelData(selectedId);
      _state.setState(() {
        _state.isPersistentlyDynamic = false;
        _state.modelId = selectedId;
        _state.role = preciseData['role'] as String?;
        _state.canHandleImage = ModelData.hasModality(selectedId, 'image');
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