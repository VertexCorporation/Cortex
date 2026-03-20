// lib/chat/screen/widgets/bottom/features/sheet.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/send.dart';
import 'package:cortex/library/backend/data/entity.dart';
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

  final mediaQuery = MediaQuery.of(context);

  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxWidth: mediaQuery.size.width,
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
    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final double topRadius = mediaQuery.size.width * 0.07;
    final l10n = AppLocalizations.of(context)!;

    final catalog = context.watch<ModelCatalogProvider>();
    final inputProvider = context.watch<InputProvider>();
    final currentMode = inputProvider.featureMode;

    final imageGenModels = catalog.allModels.where((m) {
      try {
        final map = m.toMap();
        if (map['outputs'] is Map) {
          return map['outputs']['image'] == true;
        }
        return false;
      } catch (e) {
        return false;
      }
    }).toList();

    final bool canGenerateImages = imageGenModels.isNotEmpty;

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
              width: mediaQuery.size.width * 0.12,
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
                fontFamily: 'Roboto',
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
                physics: const ClampingScrollPhysics(), // Removed BouncingScrollPhysics
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).padding.bottom + 20),
                child: Column(
                  children: [
                    // 1. USE OFFLINE
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/context.svg',
                      title: l10n.useOffline,
                      description: l10n.useOfflineDescription,
                      isSelected: currentMode == ChatInputMode.offline,
                      onTap: () {
                        if (currentMode == ChatInputMode.offline) {
                            _checkAndResetOfflineMode(context);
                        } else {
                          _handleOfflineAction(context, l10n);
                        }
                        Navigator.pop(context);
                      },
                    ),

                    // 2. DEEP featureReasoning
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/memory.svg',
                      title: l10n.featureReasoning,
                      description: l10n.featureReasoningDescription,
                      isSelected: currentMode == ChatInputMode.featureReasoning,
                      onTap: () {
                        Navigator.pop(context);
                        _handleFeatureSelection(context, ChatInputMode.featureReasoning);
                      },
                    ),

                    // 3. WEB SEARCH
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/world.svg',
                      title: l10n.featureWebSearchTitle,
                      description: l10n.featureWebSearchDescription,
                      isSelected: inputProvider.enableWebSearch,
                      onTap: () {                          _checkAndResetOfflineMode(context);                        inputProvider.toggleWebSearch();
                        Navigator.pop(context);
                      },
                    ),

                    // 4. CREATE IMAGE (Make)
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/make.svg',
                      title: l10n.featureCreateImageTitle,
                      description: l10n.featureCreateImageDescription,
                      isDisabled: !canGenerateImages,
                      isSelected: false,
                      onTap: () {
                        Navigator.pop(context);
                        _handleCreateImageAction(
                            context, imageGenModels, widget.controller);
                      },
                    ),

                    // 5. STUDY & LEARN
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/study.svg',
                      title: l10n.featureStudyTitle,
                      description: l10n.featureStudyDescription,
                      isSelected: currentMode == ChatInputMode.study,
                      onTap: () {
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
                        Navigator.pop(context);
                        _handleFeatureSelection(context, ChatInputMode.quiz);
                      },
                    ),

                    // 7. EXPLORE
                    FeaturesSheetButton(
                      iconData: Icons.visibility_outlined,
                      title: l10n.explore,
                      description: l10n.featureExploreDescription,
                      onTap: () {
                        Navigator.pop(context);
                        showModelSelectionSheet(
                          context: context,
                          localizations: l10n,
                          currentModelId:
                              context.read<ChatSessionProvider>().modelId ?? '',
                          onModelSelected: (String id) {
                            final catalog =
                                context.read<ModelCatalogProvider>();
                            final model =
                                catalog.allModels.firstWhere((m) => m.id == id);
                            context.read<SelectionService>().selectModel(model);
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
    // [CHANGED] Auto-select offline feature mode
    inputProvider.setFeatureMode(ChatInputMode.offline);

    // [NEW] Auto-select the first downloaded model
    final firstModel = downloadedModels.first;
    selectionService.selectModel(firstModel);

    // Don't show sheet, just succeed silently like a boss
  } else {
    mainScreenKey.currentState?.switchToLibrary(pulse: true);
  }
}

/// Logic for "Create Image": Selects best model, sends prompt if available.
void _handleCreateImageAction(
  BuildContext context,
  List<ModelEntity> candidates,
  TextEditingController controller,
) {
  _checkAndResetOfflineMode(context); // [NEW] Reset if needed

  if (candidates.isEmpty) return;

  // Priority: Non-Premium (Free) first, otherwise Premium.
  final ModelEntity targetModel = candidates.firstWhere(
    (m) => !m.isPremium,
    orElse: () => candidates.first,
  );

  // 1. Select the model
  context.read<SelectionService>().selectModel(targetModel);

  // 2. If text exists, send it immediately
  final String currentText = controller.text.trim();
  if (currentText.isNotEmpty) {
    context.read<SendService>().sendMessage(
          context: context,
          localizations: AppLocalizations.of(context)!,
          messageText: currentText,
        );
    // Clear controller handled by SendService usually, but safe to clear here if needed logic differs
  }
}

/// Logic for "Study" & "Quizzes": Formats input with prefix and sends.
void _handleFeatureSelection(BuildContext context, ChatInputMode mode) {
  final provider = context.read<InputProvider>();

  _checkAndResetOfflineMode(context); // [NEW] Reset if needed

  // [CHANGED] Toggle logic: If already selected, clear it.
  if (provider.featureMode == mode) {
    provider.clearFeatureMode();
  } else {
    provider.setFeatureMode(mode);
  }
}

/// [NEW] Helper to switch to Dynamic Chat if Offline Mode was active
void _checkAndResetOfflineMode(BuildContext context) {
  final inputProvider = context.read<InputProvider>();
  final selectionService = context.read<SelectionService>();
  final catalog = context.read<ModelCatalogProvider>();
    final sessionProvider = context.read<ChatSessionProvider>();

    final isOfflineFeature = inputProvider.featureMode == ChatInputMode.offline;

    bool isOfflineModel = false;
    final currentModelId = sessionProvider.modelId;
    if (currentModelId != null) {
      try {
        final currentModel =
            catalog.allModels.firstWhere((m) => m.id == currentModelId);
        if (currentModel.type == 'offline') {
          isOfflineModel = true;
        }
      } catch (_) {}
    }

    if (isOfflineFeature || isOfflineModel) {
      if (isOfflineFeature) {
        inputProvider.clearFeatureMode();
      }
      try {
        final dynamicModel = catalog.allModels.firstWhere(
            (m) => m.id == 'cortex/auto',
            orElse: () =>
                catalog.allModels.firstWhere((m) => m.type != 'offline'));
        selectionService.switchActiveModel(dynamicModel, context: context);
      } catch (e) {
        // Fallback safe
      }
    }
  }
