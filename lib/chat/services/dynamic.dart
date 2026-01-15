// lib/chat/services/dynamic.dart

import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/variants.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../library/backend/data/entity.dart';
import '../../library/backend/data/service.dart';

/// A dedicated service class to handle all logic related to the Dynamic Chat feature.
class DynamicChatService {
  final ChatSessionProvider _sessionProvider;

  static const String dynamicAssistantKey = 'dynamic_chat_assistant_id';

  DynamicChatService(this._sessionProvider);

  /// Loads the user's preferred dynamic assistant from SharedPreferences.
  Future<void> loadDynamicAssistantPreference({
    required String langCode,
    required ModelService modelService,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final assistantId = prefs.getString(dynamicAssistantKey);

    if (assistantId == null || assistantId.isEmpty) {
      if (_sessionProvider.isDynamicChat && _sessionProvider.modelId != null) {
        _sessionProvider.unpinDynamicAssistant();
      }
      return;
    }

    final model = modelService.getPreciseModelData(assistantId, langCode: langCode);
    final bool isValid = model.displayTitle != 'Unknown Model';

    if (isValid) {
      _sessionProvider.pinDynamicAssistant(assistantId);
    } else {
      await _saveDynamicAssistantPreference(null);
      _sessionProvider.unpinDynamicAssistant();
    }
  }

  /// Displays the overlay panel for the user to select their default dynamic assistant.
  ///
  /// [anchorContext]: The BuildContext of the widget (usually the AppBar title)
  /// under which the panel should appear.
  void showDynamicAssistantPanel({
    required BuildContext context,
    required BuildContext anchorContext, // Changed: We now pass the specific context
  }) {
    debugPrint("[DynamicChatService] Attempting to show dynamic assistant panel.");

    final RenderBox? renderBox = anchorContext.findRenderObject() as RenderBox?;
    if (renderBox == null) {
      debugPrint("[DynamicChatService] CRITICAL: Could not find renderBox for anchor. Panel cannot be shown.");
      return;
    }

    final modelService = context.read<ModelService>();
    final allOptions = _buildDynamicAssistantOptions(context, modelService: modelService);

    final currentlySelectedId = (_sessionProvider.isDynamicChat && _sessionProvider.modelId == null)
        ? '--dynamic--'
        : _sessionProvider.modelId;

    OverlayEntry? overlayEntry;
    final overlay = Overlay.of(context);

    // Calculate position: Just below the anchor widget with a small gap
    final Offset offset = renderBox.localToGlobal(Offset(0, renderBox.size.height + 12));

    bool isPanelClosing = false;

    overlayEntry = OverlayEntry(builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final panelWidth = screenWidth * 0.9;
      final horizontalMargin = (screenWidth - panelWidth) / 2;

      return StatefulBuilder(builder: (context, setModalState) {
        return Stack(
          children: [
            // Transparent detector to close panel
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: () => setModalState(() => isPanelClosing = true),
                child: Container(color: Colors.transparent),
              ),
            ),
            // The Panel
            Positioned(
              top: offset.dy,
              left: horizontalMargin,
              right: horizontalMargin,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(
                    begin: isPanelClosing ? 1.0 : 0.4,
                    end: isPanelClosing ? 0.4 : 1.0
                ),
                duration: const Duration(milliseconds: 150),
                curve: Curves.easeOutCubic,
                onEnd: () {
                  if (isPanelClosing) {
                    overlayEntry?.remove();
                    overlayEntry = null;
                  }
                },
                builder: (context, scale, child) {
                  return Transform.scale(
                    scale: scale,
                    alignment: Alignment.topCenter,
                    child: Opacity(
                        opacity: (scale - 0.4) / (1.0 - 0.4),
                        child: child
                    ),
                  );
                },
                child: Variants.buildVariantPanelWidget(
                  context: context,
                  options: allOptions,
                  selectedVariant: currentlySelectedId ?? '--dynamic--',
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

    overlay.insert(overlayEntry!);
  }

  List<Map<String, dynamic>> _buildDynamicAssistantOptions(
      BuildContext context, {
        required ModelService modelService,
      }) {
    final localizations = AppLocalizations.of(context)!;
    final langCode = Localizations.localeOf(context).languageCode;
    final allModelEntities = _sessionProvider.allModels;

    final List<ModelEntity> offlineOptions = [];
    final List<ModelEntity> characterOptions = [];
    final List<ModelEntity> selfOptions = [];
    final Map<String, List<ModelEntity>> onlineSeriesMap = {};

    for (final model in allModelEntities) {
      if (!model.isServerSide) {
        offlineOptions.add(model);
      } else if (model.category == 'roleplay') {
        characterOptions.add(model);
      } else if (model.category == 'self') {
        selfOptions.add(model);
      } else {
        final seriesTitle = model.displayTitle;
        onlineSeriesMap.putIfAbsent(seriesTitle, () => []);

        if (model.variants != null && model.variants!.isNotEmpty) {
          for (final extId in model.variants!.keys) {
            onlineSeriesMap[seriesTitle]!.add(modelService.getPreciseModelData(extId, langCode: langCode));
          }
        } else {
          onlineSeriesMap[seriesTitle]!.add(model);
        }
      }
    }

    final List<ModelEntity> onlineOptions = [];
    int sorter(ModelEntity a, ModelEntity b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase());

    final sortedSeriesTitles = onlineSeriesMap.keys.toList()..sort();
    for (final seriesTitle in sortedSeriesTitles) {
      final variantsInSeries = onlineSeriesMap[seriesTitle]!;
      if (variantsInSeries.isEmpty) continue;
      variantsInSeries.sort(sorter);
      onlineOptions.addAll(variantsInSeries);
    }

    offlineOptions.sort(sorter);
    characterOptions.sort(sorter);
    selfOptions.sort(sorter);

    final List<Map<String, dynamic>> finalOptions = [
      {'id': '--dynamic--', 'title': localizations.dynamicChatTitle, 'tier': 'free'},
      ...onlineOptions.map((m) => {'id': m.id, 'title': m.displayTitle, 'tier': m.tier}),
      ...offlineOptions.map((m) => {'id': m.id, 'title': m.displayTitle, 'tier': m.tier}),
      ...characterOptions.map((m) => {'id': m.id, 'title': m.displayTitle, 'tier': m.tier}),
      ...selfOptions.map((m) => {'id': m.id, 'title': m.displayTitle, 'tier': m.tier}),
    ];

    return finalOptions;
  }

  Future<void> _handleDynamicAssistantSelection(String selectedId) async {
    if (selectedId == '--dynamic--') {
      await _saveDynamicAssistantPreference(null);
      _sessionProvider.unpinDynamicAssistant();
    } else {
      await _saveDynamicAssistantPreference(selectedId);
      _sessionProvider.pinDynamicAssistant(selectedId);
    }
  }

  Future<void> _saveDynamicAssistantPreference(String? modelId) async {
    final prefs = await SharedPreferences.getInstance();
    if (modelId == null) {
      await prefs.remove(dynamicAssistantKey);
    } else {
      await prefs.setString(dynamicAssistantKey, modelId);
    }
  }
}