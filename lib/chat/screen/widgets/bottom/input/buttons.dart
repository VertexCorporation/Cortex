import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/providers/conversation.dart'; // [NEW]
import 'package:cortex/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../library/backend/data/service.dart';
import '../../../../../theme.dart';
import '../../../../../main.dart'; // [FIX] Import main.dart for mainScreenKey

import '../../../../services/select.dart';
import '../../../../services/speech.dart';
import '../../../../services/voice.dart'; // [NEW]
import '../../../../services/send.dart'; // [NEW]

import '../panels/attachments/sheet.dart';
import '../panels/features/sheet.dart';
import '../panels/selection/sheet.dart';

// -----------------------------------------------------------------------------
// HELPER: Standard Circular Tool Button (Ripple + Haptics)
// -----------------------------------------------------------------------------
class _ToolCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final bool disabled;
  final double size;

  const _ToolCircleButton({
    required this.onTap,
    required this.child,
    this.disabled = false,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1.0,
      child: Material(
        color: AppColors.background,
        shape: const CircleBorder(),
        child: Ink(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: disabled
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onTap?.call();
                  },
            child: SizedBox(
              width: size,
              height: size,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 1. ACTION BUTTONS ROW (Left: Mic, Right: Main Action)
// -----------------------------------------------------------------------------
class ActionButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isSending;
  final bool isTextEmpty;
  final bool isRecording; // To toggle Stop button during voice
  final VoidCallback onSend;
  final VoidCallback onStop;
  final TextEditingController controller;

  const ActionButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isSending,
    required this.isTextEmpty,
    this.isRecording = false,
    required this.onSend,
    required this.onStop,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context.watch<InternetProvider>().isConnected;
    final speechService = context.watch<SpeechService>();
    final inputProvider = context.watch<InputProvider>();

    final screenWidth = MediaQuery.of(context).size.width;
    // Dynamic button size: ~8% of screen width, with min/max bounds
    final double buttonSize = (screenWidth * 0.08).clamp(30.0, 38.0);

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
        rightButton = _buildVoiceChatButton(context, buttonSize);
      } else {
        rightButtonKey = const ValueKey('send_disabled');
        rightButton = _buildSendButton(buttonSize, false, isConnected);
      }
    }

    // Only show Mic if device supported AND we are not currently busy
    bool showMic = isDeviceSupported && !isSending && !isRecording;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // UPDATED: Uses AnimatedSwitcher for Slide + Fade transition
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          reverseDuration: const Duration(milliseconds: 200),
          switchInCurve: Curves.easeOutQuad,
          switchOutCurve: Curves.easeInQuad,
          transitionBuilder: (Widget child, Animation<double> animation) {
            // Combines opacity and width expansion (sliding effect)
            return FadeTransition(
              opacity: animation,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: 1.0, // Anchors to the right, expands left
                child: child,
              ),
            );
          },
          child: showMic
              ? Padding(
                  key: const ValueKey('mic_visible'),
                  padding: const EdgeInsetsDirectional.only(end: 8.0),
                  child: _ToolCircleButton(
                    size: buttonSize,
                    onTap: () async {
                      final localeCode = context
                          .read<ChatSessionProvider>()
                          .getLocale()
                          .languageCode;
                      final currentText = controller.text;

                      inputProvider.setVoiceRecording(true);

                      await speechService.startListening(
                        locale: localeCode,
                        onResult: (String text) {
                          String spacer = (currentText.isNotEmpty &&
                                  !currentText.endsWith(' '))
                              ? ' '
                              : '';
                          if (currentText.isEmpty) spacer = '';
                          controller.text = "$currentText$spacer$text";
                          controller.selection = TextSelection.fromPosition(
                              TextPosition(offset: controller.text.length));
                        },
                      );
                    },
                    child: SvgPicture.asset(
                      'assets/icons/microphone.svg',
                      width: buttonSize * 0.55,
                      height: buttonSize * 0.55,
                      colorFilter: ColorFilter.mode(
                          AppColors.primaryColor.inverted, BlendMode.srcIn),
                    ),
                  ),
                )
              : const SizedBox.shrink(key: ValueKey('mic_hidden')),
        ),

        // Main Action Button (Send/Stop/Voice)
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutQuad,
          switchOutCurve: Curves.easeInQuad,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: KeyedSubtree(
            key: rightButtonKey,
            child: rightButton,
          ),
        ),
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
          color: AppColors.primaryColor.inverted,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: size * 0.4,
            height: size * 0.4,
            colorFilter:
                ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(double size, bool enabled, bool isConnected) {
    Color backgroundColor;
    Color iconColor;

    if (enabled) {
      backgroundColor = AppColors.primaryColor.inverted;
      iconColor = AppColors.primaryColor;
    } else {
      backgroundColor = isConnected
          ? AppColors.primaryColor.inverted.withValues(alpha: 0.1)
          : AppColors.primaryColor.inverted.withValues(alpha: 0.06);
      iconColor = AppColors.tertiaryColor;
    }

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
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.arrow_upward_rounded,
          color: iconColor,
          size: size * 0.55,
        ),
      ),
    );
  }

  Widget _buildVoiceChatButton(BuildContext context, double size) {
    return GestureDetector(
      onTap: () async {
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
            context.read<ConversationProvider>(); // [FIX] Restore variable

        // [NEW] LOGIC: If chat is not empty, start a new conversation automatically
        if (conversationProvider.messages.isNotEmpty) {
          mainScreenKey.currentState?.startNewConversation(closeSidebar: false);
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

        // Set Localized Agent Names
        voiceService.setAgentNames([
          localizations.agentRed,
          localizations.agentBlue,
          localizations.agentPurple
        ]);

        // Start Voice Session
        await voiceService.startSession(
          context: context,
          locale: localeCode,
          voiceSystemPromptSuffix: localizations.voiceSystemPromptSuffix,
          flowPromptBuilder: (agentName, previousResponse) =>
              localizations.flowModeContextParams(agentName, previousResponse),
          onFinalSentence: (String text) {
            if (!context.mounted) return;
            if (text.trim().isNotEmpty) {
              sendService.sendMessage(
                context: context,
                localizations: localizations,
                messageText: text,
                isHidden: voiceService.shouldNextMessageBeHidden,
                overrideModelId: 'cortex/auto',
                voiceSystemPrompt: voiceService.voiceSystemPrompt,
              );
            }
          },
        );
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/voice.svg',
            width: size * 0.55,
            height: size * 0.55,
            colorFilter:
                ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 2. ADD ATTACHMENT BUTTON (Refactored for Multi-file Support)
// -----------------------------------------------------------------------------
class AddPhotoButton extends StatelessWidget {
  final bool isLimitExceeded;
  final bool isPhotoLoading;
  final AppLocalizations localizations;

  const AddPhotoButton({
    super.key,
    required this.isLimitExceeded,
    required this.isPhotoLoading,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();

    // Check if we have reached the 9 file limit
    final bool isMaxAttachments = inputProvider.attachments.length >= 9;

    // Disable if loading or if main chat limit reached
    final bool buttonDisabled = isLimitExceeded;

    // Dynamic size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final double buttonSize = (screenWidth * 0.085).clamp(28.0, 36.0);
    final double iconSize = buttonSize * 0.65;

    return _ToolCircleButton(
      size: buttonSize,
      disabled: (isPhotoLoading && buttonDisabled) || isMaxAttachments,
      onTap: isPhotoLoading
          ? null
          : () {
              if (isLimitExceeded) {
                // Show upgrade prompt if needed
              } else {
                final session = context.read<ChatSessionProvider>();
                showAttachmentSheet(
                  context: context,
                  canHandleImages:
                      session.isDynamicChat ? true : session.canHandleImage,
                );
              }
            },
      child: SvgPicture.asset(
        'assets/icons/add.svg',
        width: iconSize,
        height: iconSize,
        colorFilter:
            ColorFilter.mode(AppColors.primaryColor.inverted, BlendMode.srcIn),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 3. FEATURES BUTTON (Updated: Fully Animated Colors including Icon)
// -----------------------------------------------------------------------------
class FeaturesButton extends StatelessWidget {
  final TextEditingController controller;

  const FeaturesButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final featureMode = inputProvider.featureMode;

    // Check if any mode is active
    final bool isActive = featureMode != ChatInputMode.none;

    // Visual Configuration
    final Color backgroundColor =
        isActive ? AppColors.primaryColor.inverted : AppColors.background;
    final Color iconColor =
        isActive ? AppColors.background : AppColors.primaryColor.inverted;
    final Color borderColor = isActive ? Colors.transparent : AppColors.border;

    // Dynamic size based on screen width
    final screenWidth = MediaQuery.of(context).size.width;
    final double size = (screenWidth * 0.085).clamp(28.0, 36.0);
    final double iconSize = size * 0.5;
    const Duration animDuration = Duration(milliseconds: 200);
    const Curve animCurve = Curves.easeInOut;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        showFeaturesSheet(context: context, controller: controller);
      },
      // 1. ANIMATED CONTAINER: Handles Background & Border Fade
      child: AnimatedContainer(
        duration: animDuration,
        curve: animCurve,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: Center(
          // 2. TWEEN ANIMATION BUILDER: Handles Icon Color Fade
          // This ensures the icon color changes smoothly (interpolates)
          // alongside the background instead of snapping instantly.
          child: TweenAnimationBuilder<Color?>(
            duration: animDuration,
            curve: animCurve,
            tween: ColorTween(end: iconColor),
            builder: (context, color, child) {
              return SvgPicture.asset(
                'assets/icons/features.svg',
                width: iconSize,
                height: iconSize,
                colorFilter:
                    ColorFilter.mode(color ?? iconColor, BlendMode.srcIn),
              );
            },
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. MODEL SELECT BUTTON
// -----------------------------------------------------------------------------
class ModelSelectButton extends StatelessWidget {
  final double screenWidth;
  final bool isTablet;
  final AppLocalizations localizations;

  const ModelSelectButton({
    super.key,
    required this.screenWidth,
    required this.isTablet,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final bool isDynamic = sessionProvider.isDynamicChat;
    final bool isDesktop = screenWidth >= 800;
    final String displayText = isDynamic
        ? localizations.dynamicChatTitle
        : (sessionProvider.modelTitle ?? "Model");
    final double borderRadius = isDesktop ? 24.0 : screenWidth * 0.075;
    final double fontSize =
        isDesktop ? 14.0 : screenWidth * (isTablet ? 0.02 : 0.032);
    final double verticalPadding = isDesktop ? 10.0 : screenWidth * 0.02;
    final double horizontalPadding =
        isDesktop ? 16.0 : screenWidth * (isTablet ? 0.04 : 0.035);

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
                showModelSelectionSheet(
                  context: context,
                  localizations: localizations,
                  currentModelId: sessionProvider.modelId ?? '',
                  onModelSelected: (String id) {
                    final modelService = context.read<ModelService>();
                    final selectionService = context.read<SelectionService>();
                    final inputProvider = context.read<InputProvider>();
                    final langCode =
                        Localizations.localeOf(context).languageCode;

                    final model = modelService.getPreciseModelData(id,
                        langCode: langCode);
                    selectionService.switchActiveModel(model);

                    if (model.type == 'offline') {
                      inputProvider.setFeatureMode(ChatInputMode.offline);
                    } else if (inputProvider.featureMode ==
                        ChatInputMode.offline) {
                      inputProvider.clearFeatureMode();
                    }
                  },
                );
              },
              child: Container(
                constraints: BoxConstraints(maxWidth: screenWidth * 0.55),
                padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding, vertical: verticalPadding),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        transitionBuilder:
                            (Widget child, Animation<double> animation) {
                          return FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                  sizeFactor: animation,
                                  axis: Axis.horizontal,
                                  axisAlignment: -1.0,
                                  child: child));
                        },
                        child: FittedBox(
                          key: ValueKey<String>(displayText),
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: Text(
                            displayText,
                            maxLines: 1,
                            style: TextStyle(
                                color: AppColors.primaryColor.inverted,
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Transform.rotate(
                        angle: -1.5708,
                        child: SvgPicture.asset(
                          'assets/icons/arrov.svg',
                          width: fontSize * 1.1,
                          height: fontSize * 1.1,
                          colorFilter: ColorFilter.mode(
                            AppColors.primaryColor.inverted,
                            BlendMode.srcIn,
                          ),
                        )),
                  ],
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
