// lib/chat/screen/widgets/bottom/features/sheet.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/main.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../../../../../providers/input.dart';
import '../selection/sheet.dart';
import 'button.dart';
import '../../../../../../fog.dart';

void showFeaturesSheet({
  required BuildContext context,
  required TextEditingController controller,
}) {
  FocusScope.of(context).unfocus();

  

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width,
    ),
    builder: (BuildContext modalContext) {
      return _FeaturesSheetContent(controller: controller);
    },
  );
}

class _FeaturesSheetContent extends StatefulWidget {
  final TextEditingController controller;

  const _FeaturesSheetContent({required this.controller});

  @override
  State<_FeaturesSheetContent> createState() => _FeaturesSheetContentState();
}

class _FeaturesSheetContentState extends State<_FeaturesSheetContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final screenHeight = MediaQuery.sizeOf(context).height;
    final double topRadius = MediaQuery.sizeOf(context).width * 0.07;
    final l10n = AppLocalizations.of(context)!;

    final catalog = context.watch<ModelCatalogProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final inputProvider = context.watch<InputProvider>();
    final currentMode = inputProvider.featureMode;
    final currentModel = sessionProvider.selectedModel;
    final bool isOfflineModelSelected = currentModel?.type == 'offline';
    final bool isCurrentImageModel = currentModel?.outputs['image'] == true || currentModel?.category == 'image';
    final bool isCurrentAudioModel = currentModel?.outputs['audio'] == true || currentModel?.category == 'audio';
    final bool isCurrentVideoModel = currentModel?.outputs['video'] == true || currentModel?.category == 'video';

    final imageGenModels = catalog.allModels.where((m) =>
    m.outputs['image'] == true || m.category == 'image').toList();
    final audioGenModels = catalog.allModels.where((m) =>
    m.outputs['audio'] == true || m.category == 'audio').toList();
    final videoGenModels = catalog.allModels.where((m) =>
    m.outputs['video'] == true || m.category == 'video').toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
            child: Container(
              width: MediaQuery.sizeOf(context).width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Title
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Text(
              l10n.featuresTitle,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryColor.inverted,
              ),
            ),
          ),

          // Features List Wrapped with Fog!
          Flexible(
            child: ScrollFog(
              scrollController: _scrollController,
              topFogHeight: 20,
              bottomFogHeight: 40,
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const ClampingScrollPhysics(),
                // Removed BouncingScrollPhysics
                padding: EdgeInsets.only(
                    bottom: MediaQuery
                        .of(context)
                        .padding
                        .bottom + 20),
                child: Column(
                  children: [
                    // 1. USE OFFLINE
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/context.svg',
                      title: l10n.useOffline,
                      description: l10n.useOfflineDescription,
                      isSelected: currentMode == ChatInputMode.offline ||
                          isOfflineModelSelected,
                      onTap: () {
                        if (currentMode == ChatInputMode.offline ||
                            isOfflineModelSelected) {
                          _selectDynamicModel(context);
                        } else {
                          _handleOfflineAction(context, l10n);
                        }
                        Navigator.pop(context);
                      },
                    ),

                    // 2. DEEP featureReasoning
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/intelligence.svg',
                      title: l10n.featureReasoning,
                      description: l10n.featureReasoningDescription,
                      isSelected: currentMode == ChatInputMode.featureReasoning,
                      onTap: () {
                        _prepareForTextFeature(context);
                        Navigator.pop(context);
                        _handleFeatureSelection(
                            context, ChatInputMode.featureReasoning);
                      },
                    ),

                    // 3. WEB SEARCH
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/world.svg',
                      title: l10n.featureWebSearchTitle,
                      description: l10n.featureWebSearchDescription,
                      isSelected: inputProvider.enableWebSearch,
                      onTap: () {
                        _prepareForTextFeature(context);
                        inputProvider.toggleWebSearch();
                        Navigator.pop(context);
                      },
                    ),

                    // 4. CREATE IMAGE (Make)
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/make.svg',
                      title: l10n.featureCreateImageTitle,
                      description: l10n.featureCreateImageDescription,
                      isDisabled: imageGenModels.isEmpty,
                      isSelected: isCurrentImageModel,
                      onTap: () {
                        Navigator.pop(context);
                        if (isCurrentImageModel) {
                          _selectDynamicModel(context);
                        } else {
                          _handleGenerationFeatureAction(
                            context,
                            imageGenModels,
                            widget.controller,
                            targetType: 'image',
                          );
                        }
                      },
                    ),

                    // 4. CREATE AUDIO
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/voice.svg',
                      title: l10n.featureCreateAudioTitle,
                      description: l10n.featureCreateAudioDescription,
                      isDisabled: audioGenModels.isEmpty,
                      isSelected: isCurrentAudioModel,
                      onTap: () {
                        Navigator.pop(context);
                        if (isCurrentAudioModel) {
                          _selectDynamicModel(context);
                        } else {
                          _handleGenerationFeatureAction(
                            context,
                            audioGenModels,
                            widget.controller,
                            targetType: 'audio',
                          );
                        }
                      },
                    ),

                    // 4.5. CREATE VIDEO
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/transition.svg',
                      title: l10n.featureCreateVideoTitle,
                      description: l10n.featureCreateVideoDescription,
                      isDisabled: videoGenModels.isEmpty,
                      isSelected: isCurrentVideoModel,
                      onTap: () {
                        Navigator.pop(context);
                        if (isCurrentVideoModel) {
                          _selectDynamicModel(context);
                        } else {
                          _handleGenerationFeatureAction(
                            context,
                            videoGenModels,
                            widget.controller,
                            targetType: 'video',
                          );
                        }
                      },
                    ),

                    // 5. STUDY & LEARN
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/study.svg',
                      title: l10n.featureStudyTitle,
                      description: l10n.featureStudyDescription,
                      isSelected: currentMode == ChatInputMode.study,
                      onTap: () {
                        _prepareForTextFeature(context);
                        Navigator.pop(context);
                        _handleFeatureSelection(context, ChatInputMode.study);
                      },
                    ),

                    // 6. QUIZZES
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/test.svg',
                      title: l10n.featureQuizzesTitle,
                      description: l10n.featureQuizzesDescription,
                      isSelected: currentMode == ChatInputMode.quiz,
                      onTap: () {
                        _prepareForTextFeature(context);
                        Navigator.pop(context);
                        _handleFeatureSelection(context, ChatInputMode.quiz);
                      },
                    ),

                    // 7. EXPLORE
                    FeaturesSheetButton(
                      iconData: Icons.visibility,
                      title: l10n.explore,
                      description: l10n.featureExploreDescription,
                      onTap: () {
                        Navigator.pop(context);
                        showModelSelectionSheet(
                          context: context,
                          localizations: l10n,
                          currentModelId:
                          context
                              .read<ChatSessionProvider>()
                              .modelId ?? '',
                          onModelSelected: (String id) {
                            final modelService = context.read<ModelService>();
                            final selectionService =
                            context.read<SelectionService>();
                            final langCode =
                                Localizations
                                    .localeOf(context)
                                    .languageCode;
                            final model = modelService.getPreciseModelData(
                              id,
                              langCode: langCode,
                            );
                            selectionService.switchActiveModel(model);
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- LOGIC HELPERS ---

/// Logic for "Use Offline": Checks downloaded models, opens selector or library.
void _handleOfflineAction(BuildContext context, AppLocalizations l10n) {
  final catalog = context.read<ModelCatalogProvider>();
  final local = context.read<ModelLocalStateProvider>();
  final selectionService = context.read<SelectionService>();
  final inputProvider = context.read<InputProvider>();

  // Find all offline models
  final offlineModels = catalog.allModels.where((m) => m.type == 'offline');

  // Find which ones are actually downloaded
  final downloadedModels = offlineModels.where((m) {
    final path = local.getFilePathById(m.id);
    return local.isModelOnDisk(path);
  }).toList();

  if (downloadedModels.isNotEmpty) {
    // Offline focus must be singular.
    inputProvider.clearWebSearch();
    inputProvider.setFeatureMode(ChatInputMode.offline);

    // Auto-select an available offline model.
    final firstModel = downloadedModels.first;
    selectionService.switchActiveModel(firstModel, context: context);
  } else {
    mainScreenKey.currentState?.switchToLibrary(pulse: true);
  }
}

/// Logic for "Create Image/Audio": selects a suitable generation model and keeps
/// feature states coherent (single feature rule).
void _handleGenerationFeatureAction(BuildContext context,
    List<ModelEntity> candidates, TextEditingController controller,
    {required String targetType}) {
  if (candidates.isEmpty) return;

  final inputProvider = context.read<InputProvider>();
  final selectionService = context.read<SelectionService>();
  final session = context.read<ChatSessionProvider>();

  // Image/Audio/Video focus bypasses text features.
  inputProvider.clearFeatureMode();
  inputProvider.clearWebSearch();

  final currentModel = session.selectedModel;
  final bool currentSupportsTarget = currentModel != null &&
      (currentModel.outputs[targetType] == true ||
          currentModel.category == targetType);

  // Priority: Non-Premium (Free) first, otherwise Premium.
  final ModelEntity targetModel = candidates.firstWhere(
        (m) => !m.isPremium,
    orElse: () => candidates.first,
  );

  // Select only if current model does not already support this generation type.
  if (!currentSupportsTarget) {
    selectionService.switchActiveModel(targetModel, context: context);
  }

  // If text exists, send it immediately.
  final String currentText = controller.text.trim();
  if (currentText.isNotEmpty) {
    context.read<SendService>().sendMessage(
      context: context,
      localizations: AppLocalizations.of(context)!,
      messageText: currentText,
    );
  }
}

/// Logic for "Study" & "Quizzes": Formats input with prefix and sends.
void _handleFeatureSelection(BuildContext context, ChatInputMode mode) {
  final provider = context.read<InputProvider>();
  provider.clearWebSearch();

  // [CHANGED] Toggle logic: If already selected, clear it.
  if (provider.featureMode == mode) {
    provider.clearFeatureMode();
  } else {
    provider.setFeatureMode(mode);
  }
}

/// Ensures text-only features run on a compatible text model.
/// If current model is offline or generation-focused, switch back to dynamic chat.
void _prepareForTextFeature(BuildContext context) {
  final inputProvider = context.read<InputProvider>();
  final sessionProvider = context.read<ChatSessionProvider>();
  final currentModel = sessionProvider.selectedModel;

  final bool isOfflineModel = currentModel?.type == 'offline';
  final bool isGenerationFocused = currentModel?.outputs['image'] == true ||
      currentModel?.outputs['audio'] == true ||
      currentModel?.outputs['video'] == true ||
      currentModel?.category == 'image' ||
      currentModel?.category == 'audio' ||
      currentModel?.category == 'video';
  final bool isOfflineFeature =
      inputProvider.featureMode == ChatInputMode.offline;

  if (isOfflineFeature) {
    inputProvider.clearFeatureMode();
  }

  if (isOfflineModel || isGenerationFocused) {
    _selectDynamicModel(context);
  }
}

void _selectDynamicModel(BuildContext context) {
  final inputProvider = context.read<InputProvider>();
  final sessionProvider = context.read<ChatSessionProvider>();

  if (inputProvider.featureMode == ChatInputMode.offline) {
    inputProvider.clearFeatureMode();
  }

  // Dynamic chat is provider-native; do not fallback to arbitrary models (e.g. neuro).
  sessionProvider.startDynamicConversation(savePreference: true);
}
