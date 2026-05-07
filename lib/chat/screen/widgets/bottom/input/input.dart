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
import 'package:cortex/server/user.dart';
import 'package:cortex/chat/providers/session.dart';

part 'waveform.dart';
part 'attachments.dart';
part 'text_field.dart';
part 'tools.dart';
part 'send_button.dart';

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
  final int premiumTrialUses;
  final String? originalMessageText;
  final bool isStorageSufficient;
  final int? totalCredits;
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
    required this.premiumTrialUses,
    this.originalMessageText,
    required this.isStorageSufficient,
    required this.totalCredits,
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
  double _inputFieldHeight = 0.0;
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
    bool lastSendEnabled = false;
    widget.controller.addListener(() {
      if (!mounted) return;
      final nowEnabled = isSendButtonEnabled;
      if (nowEnabled != lastSendEnabled) {
        lastSendEnabled = nowEnabled;
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
    final isVideoModel = currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');
    final userTier = context.read<UserProvider>().userData?['hasCortexSubscription'] as int? ?? 0;

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
      userTier: userTier,
      premiumTrialUses: widget.premiumTrialUses,
      totalCredits: widget.totalCredits,
    );
  }

  bool get isSendButtonEnabled {
    final sessionProvider = context.read<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;
    final isVideoModel = currentModel != null &&
        (currentModel.outputs['video'] == true ||
            currentModel.category == 'video');
    final userTier = context.read<UserProvider>().userData?['hasCortexSubscription'] as int? ?? 0;

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
      userTier: userTier,
      premiumTrialUses: widget.premiumTrialUses,
      totalCredits: widget.totalCredits,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _updateHeight();
        });

        final double radius = isTablet ? screenWidth * 0.025 : 16.0;

        return Container(
          key: _inputFieldKey,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(radius),
              topRight: Radius.circular(radius),
            ),
            border:
                Border(top: BorderSide(color: AppColors.border, width: 1.0)),
          ),
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
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            _TextFieldSection(
                                              key: const ValueKey('textfield'),
                                              controller: widget.controller,
                                              focusNode:
                                                  widget.textFieldFocusNode,
                                              localizations:
                                                  widget.localizations,
                                              screenWidth: screenWidth,
                                              isTablet: isTablet,
                                              showHintText: true,
                                              onEnterPressed: () {
                                                if (isSendButtonEnabled) {
                                                  widget.onSend();
                                                }
                                              },
                                            ),
                                            _SequencedToolsTransition(
                                              isVisible: true,
                                              child: _ToolsSection(
                                                screenWidth: screenWidth,
                                                isTablet: isTablet,
                                                isActionPermitted: isActionPermitted,
                                                widget: widget,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
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
                        Align(
                          alignment: AlignmentDirectional.bottomEnd,
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
        );
      },
    );
  }

  void _updateHeight() {
    final RenderBox? renderBox =
        _inputFieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final newHeight = renderBox.size.height;
      if (newHeight != _inputFieldHeight) {
        setState(() => _inputFieldHeight = newHeight);
      }
    }
  }
}
