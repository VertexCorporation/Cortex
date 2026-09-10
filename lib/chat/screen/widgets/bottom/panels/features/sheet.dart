// lib/chat/screen/widgets/bottom/panels/features/sheet.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/select.dart';
import 'package:cortex/chat/services/generation.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/main.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/rag/screens/documents.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/funds/funds.dart';

import '../../../../../providers/input.dart';
import '../selection/sheet.dart';
import 'button.dart';
import '../../../../../../fog.dart';
import 'package:cortex/sheet.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:camera/camera.dart';
import '../../input/service.dart';
import '../attachments/button.dart';

Future<void> showFeaturesSheet({
  required BuildContext context,
  required TextEditingController controller,
}) async {
  FocusScope.of(context).unfocus();

  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: BoxConstraints(
      maxWidth: MediaQuery.sizeOf(context).width,
    ),
    builder: (BuildContext modalContext) {
      return ScaledBottomSheet(
        child: _FeaturesSheetContent(
          controller: controller,
          parentContext: context,
        ),
      );
    },
  );
}

class _FeaturesSheetContent extends StatefulWidget {
  final TextEditingController controller;
  final BuildContext parentContext;

  const _FeaturesSheetContent({
    required this.controller,
    required this.parentContext,
  });

  @override
  State<_FeaturesSheetContent> createState() => _FeaturesSheetContentState();
}

class _FeaturesSheetContentState extends State<_FeaturesSheetContent> {
  final ScrollController _scrollController = ScrollController();

  /// Camera availability is probed ONCE per sheet presentation. Creating the
  /// future inline in build() re-probes the camera subsystem on every
  /// rebuild (locale change, provider updates), which can flip the
  /// attachments row back to the shimmer state mid-interaction.
  late final Future<List<CameraDescription>> _camerasFuture =
      availableCameras();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final double topRadius = screenWidth * 0.07;
    final double contentHorizontalPadding = screenWidth * 0.05;
    final double itemGap = screenWidth * 0.03;
    final l10n = AppLocalizations.of(context)!;
    final inputService = InputService();
    final userProvider = context.watch<UserProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final inputProvider = context.watch<InputProvider>();
    final currentMode = inputProvider.featureMode;
    final currentModel = sessionProvider.selectedModel;
    final bool isOfflineModelSelected = currentModel?.type == 'offline';
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.55,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(topRadius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: EdgeInsets.symmetric(vertical: screenHeight * 0.012),
              width: MediaQuery.sizeOf(context).width * 0.12,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.86),
                borderRadius: BorderRadius.circular(10),
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
                    bottom: MediaQuery.of(context).padding.bottom + 16.0),
                child: Column(
                  children: [
                    // --- ATTACHMENTS SECTION (File, Camera, Gallery) ---
                    FutureBuilder<List<CameraDescription>>(
                      future: _camerasFuture,
                      builder: (futureContext, snapshot) {
                        // Show the Camera action on mobile even when the
                        // camera probe fails or is still inconclusive: the
                        // picker surfaces the real device state when tapped.
                        // Previously a failed/empty availableCameras() probe
                        // silently removed Camera from the sheet — the
                        // reported "Camera exists in code but is not visible
                        // in the actual + sheet" bug. Only a successful empty
                        // probe (web/desktop) hides the entry.
                        final bool hasCamera = kIsWeb
                            ? (snapshot.hasData &&
                                snapshot.data!.isNotEmpty)
                            : !snapshot.hasData ||
                                snapshot.data!.isNotEmpty;
                        final bool canHandleImages =
                            sessionProvider.isDynamicChat
                                ? true
                                : sessionProvider.canHandleImage;
                        final bool canHandleVideo =
                            sessionProvider.isDynamicChat
                                ? true
                                : sessionProvider.canHandleVideo;
                        final bool canHandleAudio =
                            sessionProvider.isDynamicChat
                                ? true
                                : sessionProvider.canHandleAudio;

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          final double itemWidth = (screenWidth * 0.85) / 3;
                          final double borderRadius = screenWidth * 0.04;

                          return Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: contentHorizontalPadding),
                            child: Shimmer.fromColors(
                              baseColor: AppColors.shimmerBase,
                              highlightColor: AppColors.shimmerHighlight,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: List.generate(3, (index) {
                                  return Container(
                                    width: itemWidth,
                                    height: itemWidth,
                                    decoration: BoxDecoration(
                                      color: AppColors.shimmerBase,
                                      borderRadius:
                                          BorderRadius.circular(borderRadius),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: contentHorizontalPadding),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. File — always available
                              Expanded(
                                child: AttachmentSheetButton(
                                  iconPath: 'assets/icons/attachment.svg',
                                  label: l10n.actionFile,
                                  onTap: () {
                                    Navigator.pop(context);
                                    inputService.pickFile(
                                      context,
                                      canHandleAudio: canHandleAudio,
                                      canHandleVideo: canHandleVideo,
                                    );
                                  },
                                ),
                              ),
                              // 2. Camera (Conditional) — sits between File
                              //    and Gallery, wired to the same normal
                              //    attachment pipeline as the Gallery picker.
                              if (hasCamera &&
                                  (canHandleImages || canHandleVideo)) ...[
                                SizedBox(width: itemGap),
                                Expanded(
                                  child: AttachmentSheetButton(
                                    iconPath: 'assets/icons/camera.svg',
                                    label: l10n.actionCamera,
                                    onTap: () {
                                      Navigator.pop(context);
                                      inputService.pickMediaAction(
                                        context,
                                        source: ImageSource.camera,
                                        supportImage: canHandleImages,
                                        supportVideo: canHandleVideo,
                                        onSelectionComplete: () {},
                                      );
                                    },
                                  ),
                                ),
                              ],
                              // 3. Gallery (Conditional)
                              if (canHandleImages || canHandleVideo) ...[
                                SizedBox(width: itemGap),
                                Expanded(
                                  child: AttachmentSheetButton(
                                    iconPath: 'assets/icons/gallery.svg',
                                    label: l10n.actionGallery,
                                    onTap: () {
                                      Navigator.pop(context);
                                      inputService.pickMediaAction(
                                        context,
                                        source: ImageSource.gallery,
                                        supportImage: canHandleImages,
                                        supportVideo: canHandleVideo,
                                        onSelectionComplete: () {},
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                    // --- DIVIDER between Attachments and Features ---
                    Padding(
                      padding: EdgeInsets.fromLTRB(contentHorizontalPadding,
                          20.0, contentHorizontalPadding, 4.0),
                      child: Row(
                        children: [
                          Expanded(
                              child: Divider(
                                  color: AppColors.border, thickness: 0.8)),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              l10n.featuresTitle,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12.0,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryColor.inverted
                                    .withValues(alpha: 0.4),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          Expanded(
                              child: Divider(
                                  color: AppColors.border, thickness: 0.8)),
                        ],
                      ),
                    ),
                    // --- /ATTACHMENTS ---

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

                    // 3.5 DOCUMENT CHAT (RAG)
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/attachment.svg',
                      title: l10n.ragFeatureTitle,
                      description: l10n.ragFeatureDescription,
                      isSelected: inputProvider.ragEnabled,
                      onTap: () {
                        Navigator.pop(context);
                        navigateToScreen(
                          const DocumentLibraryScreen(),
                          direction: const Offset(1.0, 0.0),
                        );
                      },
                    ),

                    // 4. CREATE IMAGE (Make)
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/make.svg',
                      title: l10n.featureCreateImageTitle,
                      description: l10n.featureCreateImageDescription,
                      isSelected:
                          currentMode == ChatInputMode.imageGeneration,
                      isDisabled: false,
                      onTap: () {
                        Navigator.pop(context);
                        setGenerationFeatureMode(
                          widget.parentContext,
                          targetType: 'image',
                        );
                      },
                    ),

                    // 4. CREATE AUDIO
                    FeaturesSheetButton(
                      iconPath: 'assets/icons/voice.svg',
                      title: l10n.featureCreateAudioTitle,
                      description: l10n.featureCreateAudioDescription,
                      isSelected:
                          currentMode == ChatInputMode.audioGeneration,
                      isDisabled: false,
                      onTap: () {
                        Navigator.pop(context);
                        setGenerationFeatureMode(
                          widget.parentContext,
                          targetType: 'audio',
                        );
                      },
                    ),

                    // 4.5. CREATE VIDEO
                    Builder(
                      builder: (context) {
                        final subscription = userProvider.subscription;
                        final bool isUltra = subscription.isActive &&
                            (subscription.tier == SubscriptionTier.ultra ||
                                subscription.mode ==
                                    SubscriptionMode.lifetime);
                        return FeaturesSheetButton(
                          iconPath: 'assets/icons/transition.svg',
                          title: l10n.featureCreateVideoTitle,
                          description: l10n.featureCreateVideoDescription,
                          isSelected:
                              currentMode == ChatInputMode.videoGeneration,
                          isDisabled: false,
                          onTap: () {
                            Navigator.pop(context);
                            if (isUltra) {
                              setGenerationFeatureMode(
                                widget.parentContext,
                                targetType: 'video',
                              );
                            } else {
                              navigateToScreen(
                                const FundsScreen(initialPlanType: 'ultra'),
                                direction: const Offset(1.0, 0.0),
                              );
                            }
                          },
                        );
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
                    if (userProvider.subscription.isActive)
                      FeaturesSheetButton(
                        iconData: Icons.visibility,
                        title: l10n.explore,
                        description: l10n.featureExploreDescription,
                        onTap: () {
                          Navigator.pop(context);
                          showModelSelectionSheet(
                            context: widget.parentContext,
                            localizations: l10n,
                            currentModelId: widget.parentContext
                                    .read<ChatSessionProvider>()
                                    .modelId ??
                                '',
                            initialModels: widget.parentContext
                                .read<ChatSessionProvider>()
                                .allModels,
                            onModelSelected: (String id) {
                              final modelService =
                                  widget.parentContext.read<ModelService>();
                              final selectionService =
                                  widget.parentContext.read<SelectionService>();
                              final langCode =
                                  Localizations.localeOf(widget.parentContext)
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
