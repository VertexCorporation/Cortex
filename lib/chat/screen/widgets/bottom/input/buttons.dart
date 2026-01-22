// lib/chat/screen/selected/widgets/input/bottom/actions.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/introvert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../../../../internet.dart';
import '../../../../../library/backend/data/service.dart';
import '../../../../../theme.dart';
import '../../../../services/select.dart';
import '../../../../services/speech.dart';
import '../../../../services/send.dart';
import '../../../../services/voice.dart';
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
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: showMic
              ? Padding(
                  padding: const EdgeInsets.only(right: 8.0),
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
              : const SizedBox.shrink(),
        ),
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
        final session = context.read<ChatSessionProvider>();
        final inputProvider = context.read<InputProvider>();
        final sendService = context.read<SendService>();
        final localizations = AppLocalizations.of(context)!;
        final localeCode = session.getLocale().languageCode;

        // Activate UI mode
        inputProvider.setVoiceModeActive(true);

        // Start Voice Session
        await voiceService.startSession(
          locale: localeCode,
          onFinalSentence: (String text) {
            if (text.trim().isNotEmpty) {
              sendService.sendMessage(
                context: context,
                localizations: localizations,
                messageText: text,
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
    required this.isLimitExceeded, // Refers to Chat History Limit (e.g. Free Tier)
    required this.isPhotoLoading,
    required this.localizations,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();

    // Check if we have reached the 4 file limit
    final bool isMaxAttachments = inputProvider.attachments.length >= 4;

    // Disable if loading or if main chat limit reached (but not just because we have 1 photo)
    final bool buttonDisabled = isLimitExceeded;

    return _ToolCircleButton(
      disabled: isPhotoLoading && buttonDisabled,
      onTap: isPhotoLoading
          ? null
          : () {
              // Priority 1: Check Attachment Limit
              if (isMaxAttachments) {
                Provider.of<IntrovertNotificationService>(context,
                        listen: false)
                    .showNotification(
                  message: localizations.photoLimitReachedMessage,
                  // You might want to rename this key in l10n to 'attachmentLimitReached'
                  type: NotificationType.error,
                  bottomOffset: 0.22,
                  fontSize: 0.032,
                  isChatMode: true,
                );
              }
              // Priority 2: Check Chat History Limit
              else if (isLimitExceeded) {
                // The InputField usually handles this by disabling interaction,
                // but if tapped, we can show a specific upgrade prompt here if needed.
              }
              // Priority 3: Open Sheet
              else {
                showAttachmentSheet(context: context);
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
// 3. FEATURES BUTTON (Unchanged)
// -----------------------------------------------------------------------------
class FeaturesButton extends StatelessWidget {
  final TextEditingController controller;

  const FeaturesButton({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final featureMode = inputProvider.featureMode;
    final l10n = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxAllowedWidth = screenWidth * 0.35;
    final bool isActive = featureMode != ChatInputMode.none;

    String text = '';
    String iconPath = 'assets/icons/features.svg';
    Color contentColor = AppColors.primaryColor.inverted;
    Color borderColor = AppColors.border;
    Color backgroundColor = AppColors.background;

    if (isActive) {
      contentColor = AppColors.senaryColor;
      borderColor = AppColors.senaryColor;
      backgroundColor = AppColors.senaryColor.withValues(alpha: 0.15);
      switch (featureMode) {
        case ChatInputMode.study:
          text = l10n.featureStudyTitle;
          iconPath = 'assets/icons/study.svg';
          break;
        case ChatInputMode.quiz:
          text = l10n.featureQuizzesTitle;
          iconPath = 'assets/icons/test.svg';
          break;
        case ChatInputMode.offline:
          text = l10n.useOffline;
          iconPath = 'assets/icons/context.svg';
          break;
        default:
          break;
      }
    }

    const double height = 36.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isActive) {
          inputProvider.clearFeatureMode();
        } else {
          showFeaturesSheet(context: context, controller: controller);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: height,
        constraints: BoxConstraints(
          minWidth: height,
          maxWidth: isActive ? maxAllowedWidth : height,
        ),
        padding: isActive
            ? const EdgeInsets.symmetric(horizontal: 12)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(height / 2),
          border: Border.all(color: borderColor, width: 1.0),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                iconPath,
                width: 18.0,
                height: 18.0,
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              ),
              if (isActive) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: FittedBox(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: contentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(Icons.close_rounded,
                    size: 14, color: contentColor.withValues(alpha: 0.7)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. MODEL SELECT BUTTON (Unchanged)
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
                  showModelSelectionSheet(
                    context: context,
                    localizations: localizations,
                    currentModelId: sessionProvider.modelId ?? '',
                    onModelSelected: (String id) {
                      final modelService = context.read<ModelService>();
                      final langCode =
                          Localizations.localeOf(context).languageCode;
                      final model = modelService.getPreciseModelData(id,
                          langCode: langCode);
                      context.read<SelectionService>().selectModel(model);
                    },
                  );
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
