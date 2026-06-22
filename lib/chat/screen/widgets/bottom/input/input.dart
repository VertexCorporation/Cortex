import 'dart:async';
import 'dart:io';
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../services/speech.dart';
import '../../wave.dart';
import 'buttons.dart';
import 'service.dart';
import '../../../../../../fog.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/widgets/bottom/panels/selection/sheet.dart';
import 'package:cortex/library/backend/data/service.dart';

part 'waveform.dart';

part 'attachments.dart';

part 'field.dart';



part 'send.dart';

class InputField extends StatefulWidget {
  final AppLocalizations localizations;
  final bool isModelSelected;
  final bool isDynamicChatMode;
  final bool isLimitExceeded;
  final TextEditingController controller;
  final FocusNode textFieldFocusNode;
  final Future<void> Function() onSend;
  final Future<void> Function() onApplyEditedMessage;
  final bool isPhotoLoading;
  final Animation<Offset> slideAnimation;
  final Animation<double> fadeAnimation;
  final bool isSending;
  final bool isPremiumModel;
  final bool isSubscribed;
  final int userTier;
  final String? originalMessageText;
  final bool isStorageSufficient;
  final int? totalCredits;
  final int? availablePredits;
  final int? availableDredits;
  final String? role;
  final bool isServerSideModel;
  final VoidCallback onStop;
  final bool canHandleImage; // Maintained for legacy check logic
  final bool isEditingMode;
  final File?
      preselectedPhoto; // Deprecated but kept for signature compatibility
  final bool modelMissing;
  final VoidCallback onCancelEditing;

  const InputField({
    super.key,
    required this.localizations,
    required this.isModelSelected,
    required this.isDynamicChatMode,
    required this.isLimitExceeded,
    required this.controller,
    required this.textFieldFocusNode,
    required this.onSend,
    required this.onApplyEditedMessage,
    required this.isPhotoLoading,
    required this.slideAnimation,
    required this.fadeAnimation,
    required this.isSending,
    required this.isPremiumModel,
    required this.isSubscribed,
    required this.userTier,
    this.originalMessageText,
    required this.isStorageSufficient,
    required this.totalCredits,
    this.availablePredits,
    this.availableDredits,
    this.role,
    required this.isServerSideModel,
    required this.onStop,
    this.onPhotoSelected, // Deprecated parameter, unused
    required this.canHandleImage,
    this.isEditingMode = false,
    this.preselectedPhoto,
    required this.modelMissing,
    required this.onCancelEditing,
  });

  // Deprecated parameter kept for signature compatibility
  final ValueChanged<File?>? onPhotoSelected;

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> with TickerProviderStateMixin {
  final InputService _inputService = InputService();
  final GlobalKey _inputFieldKey = GlobalKey();

  // Master controller for Input <-> Voice transition
  late AnimationController _modeController;

  late Animation<double> _inputOpacityAnim;
  late Animation<double> _waveOpacityAnim;

  @override
  void initState() {
    super.initState();

    // 600ms total transition duration
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // 1. Input Opacity (Fade Out 0.0 -> 0.4)
    // Reverse: Fade In (0.4 -> 0.0) -> Buttons appear last
    _inputOpacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    // 2. Wave Opacity (Fade In 0.5 -> 1.0)
    // Reverse: Fade Out (1.0 -> 0.5) -> Wave disappears first
    _waveOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // PERFORMANCE: Only rebuild when the send button enabled state actually changes,
    // not on every single keystroke. This prevents full widget tree rebuilds during typing.
    bool lastSendEnabled = isSendButtonEnabled;
    bool lastHasTypedContent = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(() {
      if (!mounted) return;
      final nowEnabled = isSendButtonEnabled;
      final nowHasTypedContent = widget.controller.text.trim().isNotEmpty;
      if (nowEnabled != lastSendEnabled ||
          nowHasTypedContent != lastHasTypedContent) {
        lastSendEnabled = nowEnabled;
        lastHasTypedContent = nowHasTypedContent;
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechService = context.read<SpeechService>();
      speechService.addListener(_onSpeechStatusChange);

      // Initialize state based on provider
      final inputProvider = context.read<InputProvider>();
      if (inputProvider.isVoiceRecording) {
        _modeController.value = 1.0;
      }
    });
  }

  @override
  void didUpdateWidget(covariant InputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSending != widget.isSending ||
        oldWidget.isLimitExceeded != widget.isLimitExceeded ||
        oldWidget.modelMissing != widget.modelMissing ||
        oldWidget.totalCredits != widget.totalCredits ||
        oldWidget.availablePredits != widget.availablePredits ||
        oldWidget.availableDredits != widget.availableDredits ||
        oldWidget.isServerSideModel != widget.isServerSideModel ||
        oldWidget.isDynamicChatMode != widget.isDynamicChatMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _modeController.dispose();
    _speechService?.removeListener(_onSpeechStatusChange);
    super.dispose();
  }

  SpeechService? _speechService;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newService = context.read<SpeechService>();
    if (_speechService != newService) {
      _speechService?.removeListener(_onSpeechStatusChange);
      _speechService = newService;
      _speechService?.addListener(_onSpeechStatusChange);
    }
  }

  void _onSpeechStatusChange() {
    if (!mounted) return;
    final inputProvider = context.read<InputProvider>();
    final speechService = _speechService;

    if (speechService == null) return;

    if (inputProvider.isVoiceRecording && !speechService.isListening) {
      inputProvider.setVoiceRecording(false);
    }
  }

  // Monitor provider state changes to drive animation
  void _syncAnimationWithState(bool isRecording) {
    if (isRecording) {
      if (_modeController.status != AnimationStatus.forward &&
          _modeController.status != AnimationStatus.completed) {
        _modeController.forward();
      }
    } else {
      if (_modeController.status != AnimationStatus.reverse &&
          _modeController.status != AnimationStatus.dismissed) {
        _modeController.reverse();
      }
    }
  }

  void clearPhotoPanel() {
    context.read<InputProvider>().clearAttachments();
  }

  bool get isActionPermitted {
    final sessionProvider = context.read<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;
    final isVideoModel = !widget.isDynamicChatMode &&
        currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');

    return _inputService.isActionPermitted(
      context: context,
      isServerSideModel: widget.isServerSideModel,
      isDynamicChatMode: widget.isDynamicChatMode,
      isLimitExceeded: widget.isLimitExceeded,
      isSending: widget.isSending,
      modelMissing: widget.modelMissing,
      isStorageSufficient: widget.isStorageSufficient,
      isPremiumModel: widget.isPremiumModel,
      isSubscribed: widget.isSubscribed,
      isVideoModel: isVideoModel,
      userTier: widget.userTier,
      totalCredits: widget.totalCredits,
      availablePredits: widget.availablePredits,
      availableDredits: widget.availableDredits,
    );
  }

  bool get isSendButtonEnabled {
    final sessionProvider = context.read<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;
    final isVideoModel = !widget.isDynamicChatMode &&
        currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');

    return _inputService.isSendButtonEnabled(
      context: context,
      controller: widget.controller,
      isServerSideModel: widget.isServerSideModel,
      isDynamicChatMode: widget.isDynamicChatMode,
      isLimitExceeded: widget.isLimitExceeded,
      isSending: widget.isSending,
      modelMissing: widget.modelMissing,
      isStorageSufficient: widget.isStorageSufficient,
      isPremiumModel: widget.isPremiumModel,
      isSubscribed: widget.isSubscribed,
      isVideoModel: isVideoModel,
      userTier: widget.userTier,
      totalCredits: widget.totalCredits,
      availablePredits: widget.availablePredits,
      availableDredits: widget.availableDredits,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isTablet = screenWidth >= 600;

    final inputProvider = context.watch<InputProvider>();
    final bool isRecording = inputProvider.isVoiceRecording;

    _syncAnimationWithState(isRecording);

    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    final double radius = isTablet ? screenWidth * 0.025 : 32.0;

    return Padding(
          padding: EdgeInsets.fromLTRB(
            screenWidth * 0.02,
            0,
            screenWidth * 0.02,
            12.0, // Daha az margin (1-2 cm aşağı çekilmiş hali)
          ),
          child: Container(
            key: _inputFieldKey,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: AppColors.currentTheme == 'light' 
                      ? Colors.black.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.6),
                  blurRadius: 15,
                  offset: const Offset(5, 5),
                ),
                BoxShadow(
                  color: AppColors.currentTheme == 'light'
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(-5, -5),
                ),
              ],
              border: Border.all(
                color: AppColors.currentTheme == 'light' 
                    ? Colors.black.withValues(alpha: 0.15)
                    : AppColors.border.withValues(alpha: 0.5),
                width: AppColors.currentTheme == 'light' ? 1.0 : 0.5,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0), // Extra padding to make it bigger
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _AttachmentPreviewSection(
                      screenWidth: screenWidth, isTablet: isTablet),

              // Main Animated Area
              AnimatedBuilder(
                animation: _modeController,
                builder: (context, child) {
                  final bool isForward =
                      _modeController.status == AnimationStatus.forward ||
                          _modeController.status == AnimationStatus.completed;
                  final double inputCutoff = isForward ? 0.5 : 0.9;

                  final bool showInputLayout =
                      _modeController.value < inputCutoff;
                  final bool showWaveLayout = _modeController.value > 0.1;

                  return AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // 1. INPUT CONTENT
                        Visibility(
                          visible: showInputLayout,
                          maintainState: true,
                          child: IgnorePointer(
                            ignoring: _inputOpacityAnim.value < 0.1,
                            child: FadeTransition(
                              opacity: _inputOpacityAnim,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: isTablet ? screenWidth * 0.02 : 8.0),
                                        child: _TextFieldSection(
                                          key: const ValueKey('textfield'),
                                          controller: widget.controller,
                                          focusNode: widget.textFieldFocusNode,
                                          localizations: widget.localizations,
                                          screenWidth: screenWidth,
                                          isTablet: isTablet,
                                          showHintText: true,
                                          onEnterPressed: () {
                                            if (isSendButtonEnabled) {
                                              widget.onSend();
                                            }
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 4.0),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsetsDirectional.only(
                                              start: isTablet ? screenWidth * 0.02 : 12.0,
                                              bottom: 4.0,
                                            ),
                                            child: AddPhotoButton(
                                              isLimitExceeded: widget.isLimitExceeded,
                                              isPhotoLoading: widget.isPhotoLoading,
                                              localizations: widget.localizations,
                                              controller: widget.controller,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          if (context.watch<ChatSessionProvider>().selectedModel != null)
                                            GestureDetector(
                                              onTap: () {
                                                final currentModelId = context.read<ChatSessionProvider>().selectedModel?.id ?? '';
                                                showModelSelectionSheet(
                                                  context: context,
                                                  localizations: widget.localizations,
                                                  currentModelId: currentModelId,
                                                  onModelSelected: (String modelId) {
                                                    final modelService = context.read<ModelService>();
                                                    final models = modelService.getCachedModelsSync();
                                                    try {
                                                      final selectedEntity = models.firstWhere((m) => m.id == modelId);
                                                      context.read<ChatSessionProvider>().selectModel(selectedEntity);
                                                    } catch (e) {
                                                      // Fallback or ignore if not found
                                                    }
                                                  },
                                                  initialModels: const [],
                                                );
                                              },
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                margin: const EdgeInsets.only(bottom: 4.0),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                                                ),
                                                child: Text(
                                                  context.watch<ChatSessionProvider>().selectedModel!.displayTitle,
                                                  style: TextStyle(
                                                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.8),
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                          const Spacer(),
                                          Visibility(
                                            visible: false,
                                            maintainSize: true,
                                            maintainAnimation: true,
                                            maintainState: true,
                                            child: _SendButtonSection(
                                              screenWidth: screenWidth,
                                              isTablet: isTablet,
                                              widget: widget,
                                              isEnabled: isSendButtonEnabled,
                                              isActionPermitted: isActionPermitted,
                                              controller: widget.controller,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // 2. WAVEFORM CONTENT
                        Visibility(
                          visible: showWaveLayout,
                          maintainState: true,
                          child: IgnorePointer(
                            ignoring: _waveOpacityAnim.value < 0.1,
                            child: FadeTransition(
                              opacity: _waveOpacityAnim,
                              child: const _WaveformSection(
                                  key: ValueKey('waveform')),
                            ),
                          ),
                        ),

                        // 3. MAIN ACTION BUTTON (PERSISTENT)
                        Positioned(
                          bottom: 4.0, // Anchor to bottom instead of stretching vertically
                          right: 0,
                          child: _SendButtonSection(
                            screenWidth: screenWidth,
                            isTablet: isTablet,
                            widget: widget,
                            isEnabled: isSendButtonEnabled,
                            isActionPermitted: isActionPermitted,
                            controller: widget.controller,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
       );
  }
}
