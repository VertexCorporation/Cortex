// lib/chat/screen/selected/widgets/input/buttons.dart

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
import '../../../../../library/providers/catalog.dart';
import '../../../../../theme.dart';
import '../../../../services/select.dart';
import '../panels/features/sheet.dart';
import '../panels/selection/sheet.dart';
import 'service.dart';

// -----------------------------------------------------------------------------
// HELPER: Standard Circular Tool Button (Ripple + Haptics)
// -----------------------------------------------------------------------------
class _ToolCircleButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  final bool disabled;

  const _ToolCircleButton({
    required this.onTap,
    required this.child,
    this.disabled = false,
  });

  @override
  Widget build(BuildContext context) {
    const double size = 36.0;

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
// 1. MAIN ACTION BUTTON (Send / Stop)
// -----------------------------------------------------------------------------
class ActionButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isSending;
  final VoidCallback onSend;
  final VoidCallback onStop;

  const ActionButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isSending,
    required this.onSend,
    required this.onStop,
  });

  @override
  Widget build(BuildContext context) {
    final bool isConnected = context
        .watch<InternetProvider>()
        .isConnected;

    const double buttonSize = 36.0;
    const double sendIconSize = 20.0;
    const double stopIconSize = 14.0;
    const double stopBorderRadius = buttonSize / 2;

    final Duration currentDuration = isEnabled
        ? const Duration(milliseconds: 100)
        : const Duration(milliseconds: 200);

    Color backgroundColor;
    if (isSending || isEnabled) {
      backgroundColor = AppColors.primaryColor.inverted;
    } else if (!isConnected) {
      backgroundColor = AppColors.primaryColor.inverted.withValues(alpha: 0.1);
    } else {
      backgroundColor = AppColors.primaryColor.inverted.withValues(alpha: 0.06);
    }

    Color iconColor = (isSending || isEnabled)
        ? AppColors.primaryColor
        : AppColors.tertiaryColor;

    Widget sendButton = GestureDetector(
      key: const ValueKey('sendButton'),
      onTap: isEnabled
          ? () {
        HapticFeedback.lightImpact();
        onSend();
      }
          : null,
      child: AnimatedContainer(
        duration: currentDuration,
        curve: Curves.easeOut,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        child: AnimatedOpacity(
          duration: currentDuration,
          opacity: (isSending || isEnabled) ? 1.0 : 0.5,
          curve: Curves.easeInOut,
          child: Icon(
            Icons.arrow_upward_rounded,
            color: iconColor,
            size: sendIconSize,
          ),
        ),
      ),
    );

    Widget stopButton = GestureDetector(
      key: const ValueKey('stopButton'),
      onTap: () {
        HapticFeedback.lightImpact();
        onStop();
      },
      child: AnimatedContainer(
        duration: currentDuration,
        curve: Curves.easeOut,
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          borderRadius: BorderRadius.circular(stopBorderRadius),
          border: Border.all(color: AppColors.border, width: 1.0),
        ),
        child: Center(
          child: SvgPicture.asset(
            'assets/icons/stop.svg',
            width: stopIconSize,
            height: stopIconSize,
            colorFilter:
            ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
          ),
        ),
      ),
    );

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: isSending ? stopButton : sendButton,
    );
  }
}

// -----------------------------------------------------------------------------
// 2. ADD PHOTO BUTTON
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
    final bool hasPhoto = inputProvider.selectedPhoto != null;
    final bool buttonDisabled = isLimitExceeded || hasPhoto;

    return _ToolCircleButton(
      disabled: isPhotoLoading && buttonDisabled,
      onTap: isPhotoLoading
          ? null
          : () {
        if (hasPhoto) {
          Provider.of<IntrovertNotificationService>(context,
              listen: false)
              .showNotification(
            message: localizations.photoLimitReachedMessage,
            type: NotificationType.error,
            bottomOffset: 0.22,
            fontSize: 0.032,
          );
        } else {
          InputService().pickPhoto(context, onPhotoSelected: () {});
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
// 3. FEATURES BUTTON (Transforming Logic with Safety Constraints)
// -----------------------------------------------------------------------------
class FeaturesButton extends StatelessWidget {
  final TextEditingController controller;

  const FeaturesButton({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final inputProvider = context.watch<InputProvider>();
    final featureMode = inputProvider.featureMode;
    final l10n = AppLocalizations.of(context)!;

    // Calculate max width based on screen to prevent overflow
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final maxAllowedWidth = screenWidth * 0.35;

    final bool isActive = featureMode != ChatInputMode.none;

    // Determine content based on mode
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

    // Standard Size (Circle)
    const double height = 36.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        if (isActive) {
          // If active, tap cancels the mode
          inputProvider.clearFeatureMode();
        } else {
          // If inactive, show the sheet
          showFeaturesSheet(context: context, controller: controller);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: height,
        // Apply constraints to prevent overflow
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
          // Important: Clip content during size animation to avoid visual overflow
          clipBehavior: Clip.hardEdge,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              SvgPicture.asset(
                iconPath,
                width: 18.0,
                height: 18.0,
                colorFilter: ColorFilter.mode(contentColor, BlendMode.srcIn),
              ),
              // Text (Only visible when active)
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
                // "X" icon
                Icon(
                  Icons.close_rounded,
                  size: 14,
                  color: contentColor.withValues(alpha: 0.7),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// 4. MODEL SELECT BUTTON (Standard - Always shows model name)
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
          // Material for Ripple + Border
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
                  // Always open model selector, regardless of feature mode
                  showModelSelectionSheet(
                    context: context,
                    localizations: localizations,
                    currentModelId: sessionProvider.modelId ?? '',
                    onModelSelected: (String id) {
                      final catalog = context.read<ModelCatalogProvider>();
                      final model =
                      catalog.allModels.firstWhere((m) => m.id == id);
                      context.read<SelectionService>().selectModel(model);
                    },
                  );
                },
                child: Container(
                  constraints: BoxConstraints(maxWidth: screenWidth * 0.55),
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 16.0 : 14.0,
                    vertical: 8.0,
                  ),
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
                                child: child,
                              ),
                            );
                          },
                          child: Text(
                            displayText,
                            key: ValueKey<String>(displayText),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted,
                              fontSize: fontSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Transform.rotate(
                        angle: -1.5708,
                        child: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.primaryColor.inverted,
                          size: fontSize * 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Dynamic Chat Overlay (Visual Only)
          if (isDynamic)
            Positioned.fill(
              child: IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(borderRadius),
                    gradient: LinearGradient(
                      colors: [
                        AppColors.senaryColor.withValues(alpha: 0.1),
                        Colors.transparent,
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