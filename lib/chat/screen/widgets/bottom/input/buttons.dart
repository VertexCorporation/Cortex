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
  final bool isActionPermitted;
  final bool isSending;
  final bool isTextEmpty;
  final bool isRecording; // To toggle Stop button during voice
  final VoidCallback onSend;
  final VoidCallback onStop;
  final TextEditingController controller;

  const ActionButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isActionPermitted,
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

    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;
    final double buttonSize = isTablet ? 40.0 : 36.0;

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
        child: Padding(
          padding: EdgeInsets.all(size * 0.22),
          child: SvgPicture.asset(
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
              final conversationProvider = context
                  .read<ConversationProvider>(); // [FIX] Restore variable

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
                    localizations.flowModeContextParams(
                        agentName, previousResponse),
                onFinalSentence: (String text) {
                  if (!context.mounted) return;
                  if (text.trim().isNotEmpty) {
                    sendService.sendMessage(
                      context: context,
                      localizations: localizations,
                      messageText: text,
                      isHidden: voiceService.shouldNextMessageBeHidden,
                      overrideModelId: 'cortex/auto',
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
          color: AppColors.primaryColor.inverted
              .withValues(alpha: isEnabled ? 1.0 : 0.3),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/voice.svg',
            width: size * 0.55,
            height: size * 0.55,
            colorFilter: ColorFilter.mode(
                AppColors.primaryColor.withValues(alpha: isEnabled ? 1.0 : 0.3),
                BlendMode.srcIn),
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
    required this.isLimitExceeded, // Refers to Chat History Limit (e.g. Free Tier)
    required this.isPhotoLoading,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();

    // Check if we have reached the 9 file limit
    final bool isMaxAttachments = inputProvider.attachments.length >= 9;

    // Disable if loading or if main chat limit reached (but not just because we have 1 photo)
    final bool buttonDisabled = isLimitExceeded;

    return _ToolCircleButton(
      disabled: (isPhotoLoading && buttonDisabled) || isMaxAttachments,
      onTap: isPhotoLoading
          ? null
          : () {
              // Priority 1: Check Chat History Limit
              if (isLimitExceeded) {
                // The InputField usually handles this by disabling interaction,
                // but if tapped, we can show a specific upgrade prompt here if needed.
              }
              // Priority 2: Open Sheet
              // Priority 2: Open Sheet
              else {
                final session = context.read<ChatSessionProvider>();
                showAttachmentSheet(
                  context: context,
                  canHandleImages:
                      session.isDynamicChat ? true : session.canHandleImage,
                  canHandleVideo:
                      session.isDynamicChat ? true : session.canHandleVideo,
                  canHandleAudio:
                      session.isDynamicChat ? true : session.canHandleAudio,
                );
              }
            },
      child: SvgPicture.asset(
        'assets/icons/add.svg',
        width: 24.0,
        height: 24.0,
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
  final bool isLimitExceeded;
  final bool isActionPermitted;

  const FeaturesButton({
    super.key,
    required this.controller,
    required this.isLimitExceeded,
    required this.isActionPermitted,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final featureMode = inputProvider.featureMode;
    final currentModel = sessionProvider.selectedModel;
    final bool isOfflineFocused = currentModel?.type == 'offline';
    final bool isImageFocused = currentModel?.outputs['image'] == true ||
        currentModel?.category == 'image';
    final bool isVideoFocused = currentModel?.outputs['video'] == true ||
        currentModel?.category == 'video';
    final bool isAudioFocused = currentModel?.outputs['audio'] == true ||
        currentModel?.category == 'audio';

    final bool isActive = featureMode != ChatInputMode.none ||
        inputProvider.enableWebSearch ||
        isOfflineFocused ||
        isImageFocused ||
        isVideoFocused ||
        isAudioFocused;

    // Visual Configuration
    // Active:   Bg = Inverted (Black), Icon = Background (White)
    // Inactive: Bg = Background (White), Icon = Inverted (Black)
    final Color backgroundColor =
        isActive ? AppColors.primaryColor.inverted : AppColors.background;

    final Color iconColor =
        isActive ? AppColors.background : AppColors.primaryColor.inverted;

    // Border is visible only when inactive.
    // Transitioning to transparent makes it fade out smoothly.
    final Color borderColor = isActive ? Colors.transparent : AppColors.border;

    const double size = 36.0;
    const Duration animDuration = Duration(milliseconds: 200);
    const Curve animCurve = Curves.easeInOut;

    // Is the user functionally out of limits? Disable the button block.
    final bool buttonDisabled = isLimitExceeded || !isActionPermitted;

    return GestureDetector(
      onTap: buttonDisabled
          ? () {
              HapticFeedback.heavyImpact();
            }
          : () {
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
          color: backgroundColor.withValues(alpha: buttonDisabled ? 0.3 : 1.0),
          shape: BoxShape.circle,
          border: Border.all(
              color: borderColor.withValues(alpha: buttonDisabled ? 0.3 : 1.0),
              width: 1.0),
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
                width: 18.0,
                height: 18.0,
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
        : (sessionProvider.modelTitle ?? "Model");
    final double borderRadius = 30.0;
    final double fontSize = isTablet ? screenWidth * 0.02 : 13.0;

    return Flexible(
      fit: FlexFit.loose,
      child: Stack(
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
                              size: fontSize * 1.2)),
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
      ),
    );
  }
}
