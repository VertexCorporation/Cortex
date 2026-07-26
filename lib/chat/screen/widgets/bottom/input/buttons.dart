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

import '../panels/features/sheet.dart';
import '../panels/selection/sheet.dart';

// -----------------------------------------------------------------------------
// HELPER: Standard Circular Tool Button (Ripple + Haptics)
// -----------------------------------------------------------------------------
class _ToolCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final double size;

  const _ToolCircleButton({
    required this.onTap,
    required this.child,
    this.size = 36.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Opacity(
        opacity: 1.0,
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
              onTap: () {
                HapticFeedback.lightImpact();
                onTap?.call();
              },
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // UPDATED: Uses AnimatedSwitcher for Slide + Fade transition
        AnimatedSwitcher(
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
                voiceSystemPrompt: localizations.voiceSystemPrompt,
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
class AddPhotoButton extends StatefulWidget {
  final bool isLimitExceeded;
  final bool isPhotoLoading;
  final AppLocalizations localizations;
  final TextEditingController controller;

  const AddPhotoButton({
    super.key,
    required this.isLimitExceeded,
    required this.isPhotoLoading,
    required this.localizations,
    required this.controller,
  });

  @override
  State<AddPhotoButton> createState() => _AddPhotoButtonState();
}

class _AddPhotoButtonState extends State<AddPhotoButton> {
  bool _isOpened = false;

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();

    // Match the Mic/Send button styling:
    // Background: AppColors.secondaryColor.withValues(alpha: 0.5)
    // Icon: AppColors.primaryColor.inverted
    // No border.
    final Color backgroundColor = AppColors.secondaryColor;
    final Color iconColor = AppColors.primaryColor.inverted;

    final bool isMaxAttachments = inputProvider.attachments.length >= 9;
    final bool buttonDisabled =
        widget.isLimitExceeded || (widget.isPhotoLoading && isMaxAttachments);
    final double size = 36.0; // Reduced size to match the pill and Mic better

    return GestureDetector(
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
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor.withValues(alpha: buttonDisabled ? 0.3 : 0.5),
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
                  width: 26.0,
                  height: 26.0,
                  colorFilter:
                      ColorFilter.mode(color ?? iconColor, BlendMode.srcIn),
                );
              },
            ),
          ),
        ),
      ),
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
                child: ClipRect(
                  child: Container(
                    constraints: BoxConstraints(maxWidth: screenWidth * 0.50),
                    padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 16.0 : 14.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            transitionBuilder:
                                (Widget child, Animation<double> animation) {
                              return FadeTransition(
                                  opacity: animation,
                                  child: SizeTransition(
                                      sizeFactor: animation,
                                      axis: Axis.horizontal,
                                      alignment: Alignment.center,
                                      child: child));
                            },
                            child: Text(
                              displayText,
                              key: ValueKey<String>(displayText),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(
                                color: isDynamic
                                    ? AppColors.primaryColor.inverted
                                    : AppColors.primaryColor.inverted
                                        .withValues(alpha: 0.9),
                                fontSize: fontSize,
                                fontWeight: isDynamic
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4.0),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 18.0,
                          color: AppColors.primaryColor.inverted
                              .withValues(alpha: 0.6),
                        ),
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
      ),
    );
  }
}
