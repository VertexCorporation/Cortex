// lib/chat/screen/widgets/bottom/input/input.dart
//
// Main InputField widget - the floating chat input bubble.
// Section widgets are in sections.dart for cleaner organization.

import 'dart:io';
import 'package:cortex/chat/providers/input.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../services/speech.dart';
import 'sections.dart';
import 'service.dart';

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
  final int totalCredits;
  final String? role;
  final bool isServerSideModel;
  final VoidCallback onStop;
  final bool canHandleImage;
  final bool isEditingMode;
  final File? preselectedPhoto;
  final bool modelMissing;
  final VoidCallback onCancelEditing;
  final ValueChanged<File?>? onPhotoSelected;

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
    this.onPhotoSelected,
    required this.canHandleImage,
    this.isEditingMode = false,
    this.preselectedPhoto,
    required this.modelMissing,
    required this.onCancelEditing,
  });

  @override
  InputFieldState createState() => InputFieldState();
}

class InputFieldState extends State<InputField> with TickerProviderStateMixin {
  final InputService _inputService = InputService();
  double _inputFieldHeight = 0.0;
  final GlobalKey _inputFieldKey = GlobalKey();

  // Master controller for Input <-> Voice transition
  late AnimationController _modeController;

  // Controller for border color animation on focus
  late AnimationController _borderController;
  late Animation<Color?> _borderColorAnimation;

  // Smooth position animation controller
  late AnimationController _positionController;
  late Animation<double> _bottomPaddingAnimation;
  double _targetBottomPadding = 0.0;
  double _currentBottomPadding = 0.0;

  late Animation<double> _inputOpacityAnim;
  late Animation<double> _waveOpacityAnim;

  // Cached references
  InputProvider? _inputProvider;
  SpeechService? _speechService;

  @override
  void initState() {
    super.initState();

    // 600ms total transition duration for voice mode
    _modeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    // Border color animation on focus (150ms for visibility)
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _borderColorAnimation = ColorTween(
      begin: AppColors.border,
      end: AppColors.primaryColor, // Full opacity for visible change
    ).animate(CurvedAnimation(
      parent: _borderController,
      curve: Curves.easeOut,
    ));

    // Smooth position transition controller
    _positionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _bottomPaddingAnimation = Tween<double>(begin: 0.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _positionController,
        curve: Curves.easeOutCubic,
      ),
    );

    widget.textFieldFocusNode.addListener(_onFocusChange);

    _inputOpacityAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
        reverseCurve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _waveOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _modeController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
        reverseCurve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    widget.controller.addListener(_onTextChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final speechService = context.read<SpeechService>();
      speechService.addListener(_onSpeechStatusChange);

      final inputProvider = context.read<InputProvider>();
      if (inputProvider.isVoiceRecording) {
        _modeController.value = 1.0;
      }

      _inputProvider = inputProvider;
      _inputProvider?.addListener(_onInputProviderChange);
    });
  }

  void _onTextChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _modeController.dispose();
    _borderController.dispose();
    _positionController.dispose();
    widget.textFieldFocusNode.removeListener(_onFocusChange);
    widget.controller.removeListener(_onTextChange);
    _speechService?.removeListener(_onSpeechStatusChange);
    _inputProvider?.removeListener(_onInputProviderChange);
    super.dispose();
  }

  void _onInputProviderChange() {
    if (!mounted) return;
    setState(() {});
  }

  void _onFocusChange() {
    if (!mounted) return;
    if (widget.textFieldFocusNode.hasFocus) {
      _borderController.forward().then((_) {
        if (mounted) _borderController.reverse();
      });
    }
  }

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
    if (_speechService != null &&
        inputProvider.isVoiceRecording &&
        !_speechService!.isListening) {
      inputProvider.setVoiceRecording(false);
    }
  }

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

  bool get isSendButtonEnabled {
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
      premiumTrialUses: widget.premiumTrialUses,
      totalCredits: widget.totalCredits,
    );
  }

  void _animateToBottomPadding(double newPadding) {
    if ((newPadding - _targetBottomPadding).abs() < 1.0) return;

    _currentBottomPadding = _bottomPaddingAnimation.value;
    _targetBottomPadding = newPadding;

    _bottomPaddingAnimation = Tween<double>(
      begin: _currentBottomPadding,
      end: _targetBottomPadding,
    ).animate(CurvedAnimation(
      parent: _positionController,
      curve: Curves.easeOutCubic,
    ));

    _positionController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final bool isTablet = screenWidth >= 600;

    // CRITICAL: When keyboard is open, viewInsets.bottom > 0 and padding.bottom becomes 0
    // When keyboard closes, padding.bottom returns to navigation bar height
    final double keyboardHeight = mediaQuery.viewInsets.bottom;
    final bool isKeyboardOpen = keyboardHeight > 0;
    // When keyboard is open, don't add safe area (keyboard covers it)
    // When keyboard is closed, use the actual safe area for navigation bar
    // Add dynamic extra padding proportional to safe area to prevent overlap with gesture navigation
    final double navBarPadding = mediaQuery.padding.bottom;
    final double safeAreaBottom = isKeyboardOpen ? 0 : (navBarPadding);

    final inputProvider = context.watch<InputProvider>();
    final bool isRecording = inputProvider.isVoiceRecording;

    _syncAnimationWithState(isRecording);

    if (!widget.isModelSelected && !widget.isDynamicChatMode) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateHeight());

        final double radius = screenWidth * (isTablet ? 0.035 : 0.05);
        final double horizontalPadding = screenWidth * (isTablet ? 0.02 : 0.03);
        final double basePadding = screenWidth * (isTablet ? 0.02 : 0.03);
        final double targetBottomPadding = basePadding + safeAreaBottom;

        // Animate bottom padding changes smoothly
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _animateToBottomPadding(targetBottomPadding);
        });

        // Initialize on first build
        if (_targetBottomPadding == 0.0 && _currentBottomPadding == 0.0) {
          _targetBottomPadding = targetBottomPadding;
          _currentBottomPadding = targetBottomPadding;
          _bottomPaddingAnimation = AlwaysStoppedAnimation(targetBottomPadding);
        }

        return RepaintBoundary(
          child: AnimatedBuilder(
            animation: Listenable.merge(
                [_borderColorAnimation, _bottomPaddingAnimation]),
            builder: (context, child) {
              return Padding(
                padding: EdgeInsets.only(
                  left: horizontalPadding,
                  right: horizontalPadding,
                  bottom: _bottomPaddingAnimation.value,
                ),
                child: Container(
                  key: _inputFieldKey,
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(
                      color: _borderColorAnimation.value ?? AppColors.border,
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(radius - 1),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AttachmentPreviewSection(
                          screenWidth: screenWidth,
                          isTablet: isTablet,
                        ),
                        AnimatedBuilder(
                          animation: _modeController,
                          builder: (context, child) {
                            final bool isForward =
                                _modeController.status ==
                                    AnimationStatus.forward ||
                                    _modeController.status ==
                                        AnimationStatus.completed;
                            final double inputCutoff = isForward ? 0.5 : 0.9;
                            final bool showInputLayout = _modeController.value <
                                inputCutoff;
                            final bool showWaveLayout = _modeController.value >
                                0.1;

                            return AnimatedSize(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutCubic,
                              alignment: Alignment.bottomCenter,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  // INPUT CONTENT
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
                                              crossAxisAlignment: CrossAxisAlignment
                                                  .end,
                                              children: [
                                                Expanded(
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize
                                                        .min,
                                                    children: [
                                                      TextFieldSection(
                                                        key: const ValueKey(
                                                            'textfield'),
                                                        controller: widget
                                                            .controller,
                                                        focusNode: widget
                                                            .textFieldFocusNode,
                                                        localizations: widget
                                                            .localizations,
                                                        screenWidth: screenWidth,
                                                        isTablet: isTablet,
                                                        showHintText: true,
                                                        onEnterPressed: () {
                                                          if (isSendButtonEnabled) {
                                                            widget.onSend();
                                                          }
                                                        },
                                                      ),
                                                      ToolsSection(
                                                        screenWidth: screenWidth,
                                                        isTablet: isTablet,
                                                        widget: widget,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Visibility(
                                                  visible: false,
                                                  maintainSize: true,
                                                  maintainAnimation: true,
                                                  maintainState: true,
                                                  child: SendButtonSection(
                                                    screenWidth: screenWidth,
                                                    isTablet: isTablet,
                                                    widget: widget,
                                                    isEnabled: isSendButtonEnabled,
                                                    controller: widget
                                                        .controller,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // WAVEFORM CONTENT
                                  Visibility(
                                    visible: showWaveLayout,
                                    maintainState: true,
                                    child: IgnorePointer(
                                      ignoring: _waveOpacityAnim.value < 0.1,
                                      child: FadeTransition(
                                        opacity: _waveOpacityAnim,
                                        child: const WaveformSection(
                                          key: ValueKey('waveform'),
                                        ),
                                      ),
                                    ),
                                  ),

                                  // MAIN ACTION BUTTON
                                  Align(
                                    alignment: AlignmentDirectional.bottomEnd,
                                    child: SendButtonSection(
                                      screenWidth: screenWidth,
                                      isTablet: isTablet,
                                      widget: widget,
                                      isEnabled: isSendButtonEnabled,
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
            },
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
