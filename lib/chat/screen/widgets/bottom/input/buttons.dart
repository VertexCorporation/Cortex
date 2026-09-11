import 'package:cortex/design.dart';
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../library/backend/data/service.dart';
import '../../../../../theme.dart';
import '../../../../../main.dart';
import '../../../../services/select.dart';
import '../../../../services/speech.dart';
import '../../../../services/voice.dart';
import '../../../../services/send.dart';
import '../panels/features/sheet.dart';
import '../panels/selection/sheet.dart';

// -----------------------------------------------------------------------------
// HELPER: Standard Circular Tool Button (Ripple + Haptics)
// -----------------------------------------------------------------------------
class _ToolCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double size;
  final bool showBorder;

  const _ToolCircleButton({
    required this.onTap,
    required this.child,
    this.size = 36.0,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: AppColors.background,
        shape: CircleBorder(
          side: showBorder
              ? BorderSide(color: AppColors.border)
              : BorderSide.none,
        ),
        child: Ink(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              HapticFeedback.lightImpact();
              onTap?.call();
            },
            child: Center(child: child),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MIC BUTTON — Extracted from ActionButtonWidget for use in the central zone
// -----------------------------------------------------------------------------
class MicButton extends StatelessWidget {
  final TextEditingController controller;
  final bool isSending;
  final double? recordingProgress;

  const MicButton({
    super.key,
    required this.controller,
    required this.isSending,
    this.recordingProgress,
  });

  @override
  Widget build(BuildContext context) {
    final speechService = context.watch<SpeechService>();
    final inputProvider = context.watch<InputProvider>();

    final bool isDeviceSupported = speechService.isDeviceSupported;
    final bool isRecording = inputProvider.isVoiceRecording;

    bool showMic = isDeviceSupported &&
        !isSending &&
        (recordingProgress != null || !isRecording);

    final screenWidth = MediaQuery.sizeOf(context).width;
    final double buttonSize = (screenWidth * 0.086).clamp(32.0, 38.0);

    // The microphone is a permanent inside-the-capsule control: plain icon,
    // ripple and haptics only — never a bordered bubble.
    final mic = _ToolCircleButton(
      showBorder: false,
      size: buttonSize,
      onTap: () async {
        final localeCode =
            context.read<ChatSessionProvider>().getLocale().languageCode;
        final currentText = controller.text;

        inputProvider.setVoiceRecording(true);

        await speechService.startListening(
          locale: localeCode,
          onResult: (String text) {
            String spacer =
                (currentText.isNotEmpty && !currentText.endsWith(' '))
                    ? ' '
                    : '';
            if (currentText.isEmpty) spacer = '';
            controller.text = "$currentText$spacer$text";
            controller.selection = TextSelection.fromPosition(
              TextPosition(offset: controller.text.length),
            );
          },
        );
      },
      child: SvgPicture.asset(
        'assets/icons/microphone.svg',
        width: CortexDesign.icon,
        height: CortexDesign.icon,
        colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted, BlendMode.srcIn),
      ),
    );

    final micVisibility = 1 -
        const Interval(0, 0.4, curve: Curves.easeOut)
            .transform(recordingProgress ?? 0);
    // While dictation runs the mic stays visible but is locked and dimmed
    // like the "+", leaving Stop as the only exit from the session.
    final double micOpacity =
        isRecording ? micVisibility * 0.4 : micVisibility;

    if (recordingProgress != null) {
      return IgnorePointer(
        ignoring: isRecording || recordingProgress! > 0,
        child: ClipRect(
          child: Align(
            alignment: AlignmentDirectional.centerEnd,
            widthFactor: micVisibility,
            child: Opacity(opacity: micOpacity, child: mic),
          ),
        ),
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
      switchInCurve: Curves.easeOutQuad,
      switchOutCurve: Curves.easeInQuad,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return ClipRect(
                child: Align(
                  alignment: Alignment.centerRight,
                  widthFactor: animation.value,
                  child: child,
                ),
              );
            },
            child: child,
          ),
        );
      },
      child: showMic
          ? mic
          : const SizedBox.shrink(key: ValueKey('mic_hidden')),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. ACTION BUTTONS ROW (Left: Mic, Right: Main Action)
// -----------------------------------------------------------------------------
class ActionButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isActionPermitted;
  final bool isSending;
  final bool isTextEmpty;
  final double? recordingProgress;
  final bool isRecording; // To toggle Stop button during voice
  final VoidCallback onSend;
  final VoidCallback onStop;
  final TextEditingController controller;
  final bool includeMic;
  final double bubbleScale;

  const ActionButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isActionPermitted,
    required this.isSending,
    required this.isTextEmpty,
    this.isRecording = false,
    this.recordingProgress,
    required this.onSend,
    required this.onStop,
    required this.controller,
    this.includeMic = true,
    this.bubbleScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final speechService = context.watch<SpeechService>();
    final inputProvider = context.watch<InputProvider>();

    final screenWidth = MediaQuery.sizeOf(context).width;
    // The whole bubble grows with the capsule expansion (bubbleScale); the
    // icon and its padding are size-relative, so they scale along.
    final double buttonSize =
        (screenWidth * 0.086).clamp(32.0, 38.0) * bubbleScale;

    bool isDeviceSupported = speechService.isDeviceSupported;

    // --- LOGIC MATRIX ---
    // 1. Sending OR Recording -> STOP
    // 2. Text NOT empty OR Has Attachments -> SEND
    // 3. Empty & No Files & Supported -> VOICE CHAT
    // 4. Fallback -> DISABLED SEND

    Widget rightButton;
    Key rightButtonKey;

    final bool hasContent = !isTextEmpty || inputProvider.hasAttachments;

    if (isSending || isRecording) {
      // STATE: STOP (Used for both AI gen and Voice Recording)
      rightButtonKey = const ValueKey('stop');
      rightButton = _buildStopButton(buttonSize);
    } else if (hasContent) {
      // STATE: SEND (If user typed text OR attached a file)
      rightButtonKey = const ValueKey('send');
      rightButton = _buildSendButton(buttonSize, isEnabled, isConnected);
    } else {
      // STATE: IDLE
      if (isDeviceSupported) {
        rightButtonKey = const ValueKey('voice_chat');
        rightButton =
            _buildVoiceChatButton(context, buttonSize, isActionPermitted);
      } else {
        rightButtonKey = const ValueKey('send_disabled');
        rightButton = _buildSendButton(buttonSize, false, isConnected);
      }
    }

    final rightAction = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeOutQuad,
      switchOutCurve: Curves.easeInQuad,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: rightButtonKey,
        child: rightButton,
      ),
    );

    if (!includeMic) {
      return rightAction;
    }

    final mic = MicButton(
      controller: controller,
      isSending: isSending,
      recordingProgress: recordingProgress,
    );

    final micVisibility = 1 -
        const Interval(0, 0.4, curve: Curves.easeOut)
            .transform(recordingProgress ?? 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (recordingProgress != null)
          IgnorePointer(
            ignoring: isRecording || recordingProgress! > 0,
            child: ClipRect(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                widthFactor: micVisibility,
                child: Opacity(opacity: micVisibility, child: mic),
              ),
            ),
          )
        else
          mic,
        // MicButton no longer carries trailing padding of its own.
        const SizedBox(width: 4.0),

        // Main Action Button (Send/Stop/Voice)
        rightAction,
      ],
    );
  }

  Widget _buildStopButton(double size) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onStop();
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: AppColors.border,
            width: 1.0,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: CortexDesign.icon,
            height: CortexDesign.icon,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.inverted, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(double size, bool enabled, bool isConnected) {
    final backgroundColor = AppColors.primaryColor.inverted;
    final iconColor = AppColors.primaryColor.withValues(
        alpha: enabled ? 1 : 0.45);

    return GestureDetector(
      onTap: enabled
          ? () {
              HapticFeedback.lightImpact();
              onSend();
            }
          : null,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
              color: AppColors.primaryColor.inverted),
          shape: BoxShape.circle,
        ),
        child: Padding(
          padding: EdgeInsets.all(size * 0.22),
          child: SvgPicture.asset(
            height: CortexDesign.icon,
            width: CortexDesign.icon,
            'assets/icons/arrow.svg',
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceChatButton(
      BuildContext context, double size, bool isEnabled) {
    return GestureDetector(
      onTap: !isEnabled
          ? () {
              HapticFeedback.heavyImpact();
            }
          : () async {
              HapticFeedback.lightImpact();

              final voiceService = context.read<VoiceService>();

              // [FIX] Ensure we always start in Standard Voice Mode, not Flow Mode
              voiceService.setFlowMode(false);

              final session = context.read<ChatSessionProvider>();
              final inputProvider = context.read<InputProvider>();
              final sendService = context.read<SendService>();
              final localizations = AppLocalizations.of(context)!;
              final localeCode = session.getLocale().languageCode;
              final conversationProvider =
                  context.read<ConversationProvider>(); // Restore variable

              // [NEW] LOGIC: If chat is not empty, start a new conversation automatically
              if (conversationProvider.messages.isNotEmpty) {
                mainScreenKey.currentState
                    ?.startNewConversation(closeSidebar: false);
                // Wait a brief moment for state to reset?
                // startNewConversation is async-ish but returns void.
                // It resets providers. We should yield to event loop.
                await Future.delayed(const Duration(milliseconds: 100));
              }

              // [INTERRUPTION] Stop any active text generation
              if (conversationProvider.isWaitingForResponse) {
                conversationProvider.stopGenerating();
              }

              // [INTERRUPTION] Stop any active TTS speaking (and ensure clean slate)
              await voiceService.stopSession(resetState: true);

              if (!context.mounted) return;

              // Activate UI mode (triggers Overlay)
              inputProvider.setVoiceModeActive(true);

              // Start Voice Session
              await voiceService.startSession(
                context: context,
                locale: localeCode,
                onFinalSentence: (String text) {
                  if (!context.mounted) return;
                  if (text.trim().isNotEmpty) {
                    sendService.sendMessage(
                      context: context,
                      localizations: localizations,
                      messageText: text,
                      isHidden: voiceService.shouldNextMessageBeHidden,
                      overrideModelId: 'cortex/auto',
                      flowMode: voiceService.isFlowActive,
                    );
                  }
                },
              );
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          border: Border.all(
              color: AppColors.primaryColor.inverted),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/voice.svg',
            width: CortexDesign.icon,
            height: CortexDesign.icon,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.withValues(
                    alpha: isEnabled ? 1.0 : 0.3),
                BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// CANONICAL "+" FEATURE STATE
// -----------------------------------------------------------------------------
/// The canonical state of "the `+` bubble currently represents an actively
/// selected feature, toggle or model-implied mode".
///
/// This ONE definition is the source of truth for BOTH:
///  * the bubble's ACTIVE VISUALS (inverted border/background — the paint
///    merely reflects this state, never the reverse), and
///  * the composer capsule's EXPANSION: an active feature is meaningful input
///    state, so the capsule must stay open even when the keyboard is closed,
///    the field is unfocused, dictation is idle and the text is empty. The
///    active `+` must never collapse out from under the user.
///
/// The capsule may collapse only when this state AND every other activity
/// signal (focus, text, dictation) are all absent. Never branch on the
/// painted colors — branch on this state.
bool composerFeatureActive(
  InputProvider inputProvider,
  ModelEntity? currentModel,
) =>
    inputProvider.featureMode != ChatInputMode.none ||
    inputProvider.enableWebSearch ||
    inputProvider.ragEnabled ||
    currentModel?.type == 'offline' ||
    currentModel?.outputs['image'] == true ||
    currentModel?.outputs['audio'] == true ||
    currentModel?.outputs['video'] == true ||
    currentModel?.category == 'image' ||
    currentModel?.category == 'audio' ||
    currentModel?.category == 'video';

// -----------------------------------------------------------------------------
// 2. ADD ATTACHMENT BUTTON (Refactored for Multi-file Support)
// -----------------------------------------------------------------------------
class AddPhotoButton extends StatefulWidget {
  final bool isLimitExceeded;
  final bool isPhotoLoading;
  final AppLocalizations localizations;
  final TextEditingController controller;
  final bool hasSelectedFeature;
  final double bubbleProgress;
  final double bubbleScale;

  /// Inactive state used while dictation is running: the bubble stays
  /// visible but fades out and refuses taps so the speech session cannot
  /// be interrupted from here — Stop on the action slot is the only exit.
  final bool isDimmed;

  const AddPhotoButton({
    super.key,
    required this.isLimitExceeded,
    required this.isPhotoLoading,
    required this.localizations,
    required this.controller,
    this.hasSelectedFeature = false,
    this.bubbleProgress = 1.0,
    this.bubbleScale = 1.0,
    this.isDimmed = false,
  });

  @override
  State<AddPhotoButton> createState() => _AddPhotoButtonState();
}

class _AddPhotoButtonState extends State<AddPhotoButton> {
  bool _isOpened = false;

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final screenWidth = MediaQuery.sizeOf(context).width;

    final sessionProvider = context.watch<ChatSessionProvider>();
    final currentModel = sessionProvider.selectedModel;

    // ONE canonical definition (see [composerFeatureActive]) drives both the
    // bubble's active visuals here and the composer capsule's expansion in
    // the input row — an active feature can never paint itself active and
    // then have the capsule collapse the control away.
    final bool isFeatureActive = widget.hasSelectedFeature ||
        composerFeatureActive(inputProvider, currentModel);

    final double progress = widget.bubbleProgress.clamp(0.0, 1.0);
    final Color rawBackgroundColor = isFeatureActive
        ? AppColors.primaryColor.inverted
        : AppColors.background;
    final Color backgroundColor = rawBackgroundColor.withValues(
        alpha: rawBackgroundColor.a * progress);
    final Color rawBorderColor = isFeatureActive
        ? AppColors.primaryColor.inverted
        : AppColors.border;
    final Color borderColor =
        rawBorderColor.withValues(alpha: rawBorderColor.a * progress);
    final Color iconColor = isFeatureActive
        ? AppColors.primaryColor
        : AppColors.primaryColor.inverted;

    final bool isMaxAttachments = inputProvider.attachments.length >= 9;
    final bool buttonDisabled = widget.isLimitExceeded ||
        (widget.isPhotoLoading && isMaxAttachments) ||
        widget.isDimmed;
    // The whole bubble grows with the capsule expansion (bubbleScale); the
    // "+" glyph and padding are size-relative, so they scale along.
    final double size =
        (screenWidth * 0.086).clamp(32.0, 38.0) * widget.bubbleScale;

    final Widget bubble = GestureDetector(
      onTap: buttonDisabled || widget.isPhotoLoading
          ? () {
              HapticFeedback.heavyImpact();
            }
          : () async {
              HapticFeedback.lightImpact();
              if (mounted) setState(() => _isOpened = true);
              await showFeaturesSheet(
                  context: context, controller: widget.controller);
              if (mounted) setState(() => _isOpened = false);
            },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
            width: isFeatureActive ? 2 : 1,
          ),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: AnimatedRotation(
            turns: _isOpened ? 1.375 : 0.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOutCubic,
            child: TweenAnimationBuilder<Color?>(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              tween: ColorTween(end: iconColor),
              builder: (context, color, child) {
                return SvgPicture.asset(
                  'assets/icons/add.svg',
                  // The "+" glyph fills more of its circle so the hollow
                  // bubble reads the same size as the filled action button.
                  width: size * 0.75,
                  height: size * 0.75,
                  colorFilter:
                      ColorFilter.mode(color ?? iconColor, BlendMode.srcIn),
                );
              },
            ),
          ),
        ),
      ),
    );
    // One stable root for both states: swapping Opacity in and out on the
    // dictation toggle would destroy and rebuild the whole bubble subtree
    // (its semantics included) twice per session. Keeping the shape
    // constant and animating only the opacity value leaves the element and
    // semantics trees untouched while dimming exactly as before.
    return Opacity(
      opacity: widget.isDimmed ? 0.4 : 1.0,
      child: bubble,
    );
  }
}

// FeaturesButton removed as it's merged into AddPhotoButton
// -----------------------------------------------------------------------------
// 4. MODEL SELECT BUTTON
// -----------------------------------------------------------------------------
class ModelSelectButton extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final AppLocalizations localizations;
  final VoidCallback? onSelectionComplete;

  const ModelSelectButton({
    super.key,
    required this.screenWidth,
    required this.isTablet,
    required this.localizations,
    this.onSelectionComplete,
  });

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final bool isDynamic = sessionProvider.isDynamicChat;
    final String displayText = isDynamic
        ? localizations.dynamicChatTitle
        : (sessionProvider.modelTitle ?? localizations.modelLabel);
    final double borderRadius = 30.0;
    final double fontSize = isTablet ? screenWidth * 0.02 : 13.0;

    return Stack(
      alignment: Alignment.centerLeft,
      children: [
        Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(color: AppColors.border, width: 1.0),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(borderRadius),
              onTap: () {
                HapticFeedback.lightImpact();

                // Eagerly read from context before opening the sheet (and before it closes)
                final modelService = context.read<ModelService>();
                final selectionService = context.read<SelectionService>();
                final inputProvider = context.read<InputProvider>();
                final langCode = Localizations.localeOf(context).languageCode;

                showModelSelectionSheet(
                  context: context,
                  localizations: localizations,
                  currentModelId: sessionProvider.modelId ?? '',
                  initialModels: sessionProvider.allModels,
                  onModelSelected: (String id) {
                    // 2. Fetch Model Data
                    final model = modelService.getPreciseModelData(id,
                        langCode: langCode);

                    // 3. Select the Model
                    selectionService.switchActiveModel(model);

                    // Keep input features coherent with selected model capability.
                    if (model.type == 'offline') {
                      inputProvider.clearWebSearch();
                      inputProvider.setFeatureMode(ChatInputMode.offline);
                    } else if (model.outputs['image'] == true ||
                        model.outputs['audio'] == true) {
                      inputProvider.clearFeatureMode();
                      inputProvider.clearWebSearch();
                    } else if (inputProvider.featureMode ==
                        ChatInputMode.offline) {
                      inputProvider.clearFeatureMode();
                    }
                  },
                ).then((didSelect) {
                  if (didSelect != true) return;
                  Future.delayed(const Duration(milliseconds: 120), () {
                    onSelectionComplete?.call();
                  });
                });
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.55),
                padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16.0 : 14.0, vertical: 8.0),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          transitionBuilder:
                              (Widget child, Animation<double> animation) {
                            return FadeTransition(
                                opacity: animation, child: child);
                          },
                          child: Text(
                            displayText,
                            key: ValueKey<String>(displayText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: AppColors.primaryColor.inverted,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                          angle: -1.5708,
                          child: Icon(Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primaryColor.inverted,
                              size: CortexDesign.icon)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (isDynamic)
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(borderRadius),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.senaryColor.withValues(alpha: 0.1),
                      Colors.transparent
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
