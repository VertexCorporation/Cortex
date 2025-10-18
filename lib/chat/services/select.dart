// lib/chat/services/select.dart

import 'package:flutter/cupertino.dart';
import '../../extensions.dart';
import '../../models/backend/data.dart';
import '../chat.dart';

class SelectionService {
  final ChatScreenState state;

  SelectionService({required this.state});

  /// This function now operates in a clear, sequential manner to prevent race conditions.
  /// 1. All data is gathered and all final values are calculated first.
  /// 2. A single, atomic `setState` call is made with all the final values.
  /// 3. Post-update logic, including a robust focus request, is run after the state is set.
  Future<void> selectModel(ModelInfo modelInfo, {bool resetMessages = false}) async {
    const String logPrefix = "[SelectionService.selectModel]";
    debugPrint("$logPrefix: Initiating selection for model SERIES '${modelInfo.id}'.");

    if (resetMessages) {
      await state.resetConversation();
    }

    // --- STEP 1: GATHER ALL DATA & CALCULATE FINAL VALUES ---
    final Map<String, dynamic> seriesData = ModelData.getPreciseModelData(modelInfo.id);

    String finalApiModelId;
    final extensionsMap = seriesData['extensions'] as Map<String, dynamic>?;

    if (extensionsMap != null && extensionsMap.isNotEmpty) {
      String lastUsedApiId = await Extensions.getLastSelectedExtension(modelInfo.id);
      finalApiModelId = (lastUsedApiId.isNotEmpty && extensionsMap.containsKey(lastUsedApiId))
          ? lastUsedApiId
          : extensionsMap.keys.first;
    } else {
      finalApiModelId = modelInfo.id;
    }
    debugPrint("$logPrefix: Determined final API model ID: '$finalApiModelId'");

    final Map<String, dynamic> preciseModelData = ModelData.getPreciseModelData(finalApiModelId);
    final bool finalCanHandleImage = ModelData.hasModality(finalApiModelId, 'image');
    debugPrint("$logPrefix: Calculated definitive 'canHandleImage': $finalCanHandleImage");

    final String? finalModelPath = modelInfo.path;
    final String? finalRole = preciseModelData['role'] as String? ?? seriesData['role'] as String?;
    final bool finalIsServerSide = (preciseModelData['type'] as String?) != 'offline';
    final String? finalModelTitle = seriesData['title'] as String?;
    final String? finalModelProducer = seriesData['producer'] as String?;
    final String finalModelImagePath = ModelData.getModelImagePath(seriesData);
    final String? category = seriesData['category'] as String?;
    final bool hasExtensions = (seriesData['extensions'] as Map<String, dynamic>? ?? {}).isNotEmpty;
    bool isPremium;

    if (category == 'self' || category == 'roleplay') {
      final String? baseModelId = preciseModelData['baseModelId'] as String?;
      if (baseModelId != null && baseModelId.isNotEmpty) {
        final Map<String, dynamic> baseModelData = ModelData.getPreciseModelData(baseModelId);
        isPremium = (baseModelData['tier'] as String? ?? 'free') == 'premium';
        debugPrint("$logPrefix: Character model detected. Premium status based on base model '$baseModelId': $isPremium");
      } else {
        isPremium = false;
      }
    } else {
      isPremium = (preciseModelData['tier'] as String? ?? 'free') == 'premium';
      debugPrint("$logPrefix: Standard model detected. Premium status: $isPremium");
    }

    debugPrint("✅ [LOG 2 - select.dart] PREPARING to set state. The role is: ${finalRole != null ? "'${finalRole.substring(0, (finalRole.length > 40) ? 40 : finalRole.length)}...'" : "NULL"}");

    // --- STEP 2: PERFORM A SINGLE, ATOMIC STATE UPDATE ---
    state.setState(() {
      state.appBarModeNotifier.value = AppBarMode.modelSelected;
      state.modelId = finalApiModelId;
      state.role = finalRole;
      state.modelPath = finalModelPath;
      state.isCurrentModelServerSide = finalIsServerSide;
      state.canHandleImage = finalCanHandleImage;
      state.modelTitle = finalModelTitle;
      state.modelProducer = finalModelProducer;
      state.modelImagePath = finalModelImagePath;
      state.selectedModelCategory = category;
      state.isModelSelected = true;
      state.isModelLoaded = finalIsServerSide;
      state.showPremiumBriefing = isPremium;

      if (state.messages.isEmpty) {
        state.readService.markLoaded();
      }
    });

    debugPrint("$logPrefix: Atomic setState complete. Final state for 'canHandleImage' is: ${state.canHandleImage}");

    // --- STEP 3: RUN POST-UPDATE LOGIC ---
    state.widget.onModelSelectionChanged?.call(true);
    debugPrint("$logPrefix: Notified parent to hide BottomAppBar.");

    state.extensions.initialize(
      mainId: modelInfo.id,
      ext: finalApiModelId,
      modelData: seriesData,
      updateCanHandleImage: (bool value) {
        if (state.mounted && state.canHandleImage != value) {
          state.setState(() => state.canHandleImage = value);
        }
      },
    );

    if (!finalIsServerSide) {
      await state.loadService.loadModel();
    }

    state.triggerDisclaimer();


    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!state.mounted) return;

      bool panelWasRequested = false;
      if (hasExtensions) {
        debugPrint("$logPrefix: Model has extensions. Triggering info panel check.");
        panelWasRequested = await state.chatTitleKey.currentState?.triggerExtensionInfoPanelIfNeeded() ?? false;
      }

      if (!panelWasRequested) {
        debugPrint("$logPrefix: Info panel was not shown. Requesting focus for text field immediately.");
        state.textFieldFocusNode.requestFocus();
      } else {
        debugPrint("$logPrefix: Info panel was shown. Keyboard focus is deferred until panel dismissal.");
      }
    });

    debugPrint("$logPrefix: Model selection process fully complete.");
  }

  void clearModelSelection() {
    state.setState(() {
      state.isModelSelected = false;
      state.modelTitle = null;
      state.modelDescription = null;
      state.modelImagePath = null;
      state.modelProducer = null;
      state.modelPath = null;
      state.role = null;
      state.isModelLoaded = false;
    });
  }
}