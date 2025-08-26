// select.dart

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
  /// 3. Post-update logic (like loading files) is run after the state is securely set.
  /// This guarantees that no intermediate or incorrect state is ever displayed or used.
  Future<void> selectModel(ModelInfo modelInfo, {bool resetMessages = false}) async {
    const String logPrefix = "[SelectionService.selectModel]";
    debugPrint("$logPrefix: Initiating selection for model SERIES '${modelInfo.id}'.");

    if (resetMessages) {
      await state.resetConversation();
    }

    // --- STEP 1: GATHER ALL DATA & CALCULATE FINAL VALUES (NO SETSTATE YET) ---

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

    // This is the single, authoritative calculation.
    final bool finalCanHandleImage = ModelData.hasModality(finalApiModelId, 'image');
    debugPrint("$logPrefix: Calculated definitive 'canHandleImage': $finalCanHandleImage");

    final String? finalModelPath = modelInfo.path;
    final String? finalRole = preciseModelData['role'] as String? ?? seriesData['role'] as String?;
    final bool finalIsServerSide = (preciseModelData['type'] as String?) != 'offline';
    final String? finalModelTitle = seriesData['title'] as String?;
    final String? finalModelProducer = seriesData['producer'] as String?;
    final String finalModelImagePath = ModelData.getModelImagePath(seriesData);
    final String? finalSelectedCategory = seriesData['category'] as String?;

    // --- 🕵️ LOGGING POINT #2 ---
    // Let's see what role we are about to commit to the state.
    debugPrint("✅ [LOG 2 - select.dart] PREPARING to set state. The role is: ${finalRole != null ? "'${finalRole.substring(0, (finalRole.length > 40) ? 40 : finalRole.length)}...'" : "NULL"}");
    // --- END LOGGING ---

    // --- STEP 2: PERFORM A SINGLE, ATOMIC STATE UPDATE ---
    // All values are now final. We commit them to the state in one go.
    state.setState(() {
      state.modelId = finalApiModelId;
      state.role = finalRole;
      state.modelPath = finalModelPath;
      state.isCurrentModelServerSide = finalIsServerSide;
      state.canHandleImage = finalCanHandleImage; // Commit the correct value
      state.modelTitle = finalModelTitle;
      state.modelProducer = finalModelProducer;
      state.modelImagePath = finalModelImagePath;
      state.selectedModelCategory = finalSelectedCategory;
      state.isModelSelected = true;
      state.isModelLoaded = finalIsServerSide;

      // Also mark messages as loaded here if it's a new chat.
      if (state.messages.isEmpty) {
        state.readService.markLoaded();
      }
    });

    debugPrint("$logPrefix: Atomic setState complete. Final state for 'canHandleImage' is: ${state.canHandleImage}");

    // --- STEP 3: RUN POST-UPDATE LOGIC (NOW THAT THE STATE IS SAFE) ---

    state.widget.onModelSelectionChanged?.call(true);
    debugPrint("$logPrefix: Notified parent to hide BottomAppBar.");

    state.extensions.initialize(
      mainId: modelInfo.id,
      ext: finalApiModelId,
      modelData: seriesData,
      updateCanHandleImage: (bool value) {
        // This callback remains as a safeguard for dynamic extension changes.
        if (state.mounted && state.canHandleImage != value) {
          state.setState(() => state.canHandleImage = value);
        }
      },
    );

    if (!finalIsServerSide) {
      await state.loadService.loadModel();
    }

    state.triggerDisclaimer();
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