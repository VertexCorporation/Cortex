// lib/chat/widgets/options/panel.dart

import 'dart:ui' as ui;
import 'package:cortex/chat/messages/messages.dart';
import 'package:cortex/chat/messages/options/select.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/credits.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:pasteboard/pasteboard.dart';

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import '../../../library/backend/data/service.dart';
import '../../../library/utils.dart';
import '../../../notifications/introvert.dart';
import 'change.dart';
import 'item.dart';

enum MessageOption {
  copy,
  report,
  regenerate,
  select,
  stop,
  changeModel,
  edit,
  speak,
  delete,
  branch,
}

const Duration _kShortAnimationDuration = Duration(milliseconds: 100);
const Duration _kLongAnimationDuration = Duration(milliseconds: 200);

class _UIFactors {
  static const double panelWidthFactor = 0.4;
  static const double optionHeightFactor = 0.06;
  static const double marginFactor = 0.04;
  static const double borderRadiusFactor = 0.02;
  static const double horizontalPaddingFactor = 0.04;
  static const double changeModelVerticalPaddingFactor = 0.012;
}

// ===========================================================================
// SECTION: VIEWMODEL LOGIC
// ===========================================================================

class OptionsPanelViewModel {
  final ChatSessionProvider session;
  final ConversationProvider conversation;
  final InternetProvider internet;
  final Message message;
  final ModelService modelService;
  final int totalCredits;

  OptionsPanelViewModel({
    required this.session,
    required this.conversation,
    required this.internet,
    required this.message,
    required this.modelService,
    required this.totalCredits,
  });

  List<MessageOption> get _baseOptions {
    if (message.isUserMessage) {
      return [
        MessageOption.copy,
        MessageOption.edit,
        MessageOption.select,
        MessageOption.speak,
      ];
    } else {
      final options = [
        MessageOption.copy,
        MessageOption.speak,
      ];
      if (!message.isError) {
        options.addAll([MessageOption.regenerate, MessageOption.changeModel]);
        if (!message.isReported) {
          options.add(MessageOption.report);
        }
      } else {
        options.add(MessageOption.regenerate);
      }
      return options;
    }
  }

  List<MessageOption> getVisibleOptions(BuildContext context) {
    final langCode = Localizations.localeOf(context).languageCode;
    final currentModelId = message.model ?? '';

    // LOGIC UPDATE: Iterate attachments to find user images only.
    final bool conversationHasUserImages = conversation.messages.any((m) {
      return m.isUserMessage &&
          m.attachmentPaths.any((path) => _isImageFile(path));
    });

    final modelSeriesData = ModelDataUtils.findParentSeriesData(currentModelId,
        langCode: langCode, modelService: modelService);
    final currentModel =
        modelService.getPreciseModelData(currentModelId, langCode: langCode);

    final isDynamicContext = session.isDynamicChat;
    final isOfflineModel = modelSeriesData?.isServerSide == false;

    // We check predits from the viewmodel directly
    final hasPreditsForPremium = session.isUserSubscribed ||
        (context.read<CreditsManager>().preditsNotifier.value ?? 0) > 0;

    final isCurrentModelPremium = currentModel.isPremium;

    return _baseOptions.where((option) {
      if (conversation.isWaitingForResponse &&
          (option == MessageOption.regenerate ||
              option == MessageOption.changeModel ||
              option == MessageOption.edit)) {
        return false;
      }
      if (option == MessageOption.stop && !message.isThinking) {
        return false;
      }

      if (option == MessageOption.speak) {
        if (message.hasAttachments && message.displayableText.trim().isEmpty) {
          return false;
        }
      }

      if (option == MessageOption.regenerate) {
        if (!isDynamicContext) {
          if (isCurrentModelPremium && !hasPreditsForPremium) return false;
        }
        if (!isOfflineModel && !internet.isConnected) return false;
        if (!isOfflineModel && totalCredits <= 0) return false;
      }

      if (option == MessageOption.changeModel) {
        if (!isOfflineModel && totalCredits <= 0) return false;
        if (!isDynamicContext) {
          if (modelSeriesData != null) {
            final int validExtCount =
                ModelDataUtils.validVariantCountForChangingModel(
              parentSeries: modelSeriesData,
              conversationHasPhoto: conversationHasUserImages,
            );
            if (validExtCount <= 1) return false;
          } else {
            return false;
          }
        }
      }
      return true;
    }).toList();
  }

  bool _isImageFile(String path) {
    final ext = p.extension(path).toLowerCase().replaceAll('.', '');
    return ['jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic'].contains(ext);
  }
}

// ===========================================================================
// SECTION: UI WIDGET (Unchanged)
// ===========================================================================

class AnimatedMessageOptionsPanel extends StatefulWidget {
  final Message message;
  final Offset position;
  final VoidCallback onDismiss;
  final ValueNotifier<String> messageNotifier;
  final VoidCallback? onReport;
  final void Function({String? newModelId})? onRegenerate;
  final VoidCallback? onStop;
  final VoidCallback? onEdit;
  final VoidCallback? onSpeak;

  const AnimatedMessageOptionsPanel({
    super.key,
    required this.message,
    required this.position,
    required this.onDismiss,
    required this.messageNotifier,
    this.onReport,
    this.onRegenerate,
    this.onStop,
    this.onEdit,
    this.onSpeak,
  });

  @override
  State<AnimatedMessageOptionsPanel> createState() =>
      _AnimatedMessageOptionsPanelState();
}

class _AnimatedMessageOptionsPanelState
    extends State<AnimatedMessageOptionsPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(duration: _kShortAnimationDuration, vsync: this);
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
            parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _dismissPanel() {
    if (!mounted) return;
    if (_animationController.status == AnimationStatus.forward ||
        _animationController.status == AnimationStatus.completed) {
      _animationController.reverse().then((_) {
        if (mounted) widget.onDismiss();
      });
    }
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    navigateToScreen(screen, direction: const Offset(1.0, 0.0));
  }

  void _onCopyTapped() async {
    final localizations = AppLocalizations.of(context)!;
    final message = widget.message;

    // Smart copy: if the message is media-only, try to copy the image file.
    // If copying fails (e.g. unsupported platform), fallback to saving to gallery.
    final bool isMediaOnly =
        message.hasAttachments && message.displayableText.trim().isEmpty;

    if (isMediaOnly) {
      _dismissPanel();
      try {
        final path = message.attachmentPaths.first;
        final success = await Pasteboard.writeFiles([path]);
        if (success) {
          if (!mounted) return;
          Provider.of<IntrovertNotificationService>(context, listen: false)
              .showNotification(
                  message: localizations.messageCopied,
                  type: NotificationType.success,
                  bottomOffset: 0.07,
                  isChatMode: true);
        } else {
          _saveFirstMediaToGallery(message, localizations);
        }
      } catch (e) {
        _saveFirstMediaToGallery(message, localizations);
      }
      return;
    }

    Clipboard.setData(ClipboardData(text: message.displayableText));
    Provider.of<IntrovertNotificationService>(context, listen: false)
        .showNotification(
            message: localizations.messageCopied,
            type: NotificationType.success,
            bottomOffset: 0.07,
            isChatMode: true);
    _dismissPanel();
  }

  Future<void> _saveFirstMediaToGallery(
      Message message, AppLocalizations localizations) async {
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
    try {
      final firstPath = message.attachmentPaths.first;
      final ext = p.extension(firstPath).toLowerCase();
      final isVideo = ['.mp4', '.mov', '.avi', '.mkv', '.webm'].contains(ext);

      bool? success;
      if (isVideo) {
        success = await GallerySaver.saveVideo(firstPath);
      } else {
        success = await GallerySaver.saveImage(firstPath);
      }

      notificationService.showNotification(
        message: success == true
            ? localizations.downloadSuccess
            : localizations.downloadFailed,
        type:
            success == true ? NotificationType.success : NotificationType.error,
        bottomOffset: 0.07,
        isChatMode: true,
      );
    } catch (_) {
      notificationService.showNotification(
        message: localizations.downloadFailed,
        type: NotificationType.error,
        bottomOffset: 0.07,
        isChatMode: true,
      );
    }
  }

  void _onSelectTapped() {
    _dismissPanel();
    _navigateToScreen(
        context, SelectTextScreen(messageNotifier: widget.messageNotifier));
  }

  void _onChangeModelTapped() {
    _dismissPanel();
    showModelSelectionDialog(
      context: context,
      currentModelId: widget.message.model ?? '',
      onRegenerate: widget.onRegenerate,
    );
  }

  void _onDeleteTapped() {
    _dismissPanel();
    final conv = context.read<ConversationProvider>();
    final idx = conv.messages.indexWhere((m) => m.id == widget.message.id);
    if (idx >= 0) {
      conv.removeMessageAtIndex(idx);
    }
  }

  void _onBranchTapped() {
    _dismissPanel();
    final conv = context.read<ConversationProvider>();
    final idx = conv.messages.indexWhere((m) => m.id == widget.message.id);
    if (idx >= 0 && widget.onRegenerate != null) {
      final removeFrom = widget.message.isUserMessage ? idx + 1 : idx;
      conv.removeMessagesAfter(removeFrom);
      widget.onRegenerate!();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final internetProvider = context.watch<InternetProvider>();
    final localizations = AppLocalizations.of(context)!;
    final modelService = context.read<ModelService>();
    final totalCredits =
        context.watch<CreditsManager>().totalCreditsNotifier.value ?? 0;

    final viewModel = OptionsPanelViewModel(
      session: sessionProvider,
      conversation: conversationProvider,
      internet: internetProvider,
      message: widget.message,
      modelService: modelService,
      totalCredits: totalCredits,
    );

    final List<MessageOption> visibleOptions =
        viewModel.getVisibleOptions(context);

    if (visibleOptions.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _dismissPanel());
      return const SizedBox.shrink();
    }

    final screenSize = MediaQuery.of(context).size;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final panelWidth = screenSize.width * _UIFactors.panelWidthFactor;
    final optionHeight = screenSize.height * _UIFactors.optionHeightFactor;
    final borderRadius = screenSize.width * _UIFactors.borderRadiusFactor;
    final margin = screenSize.width * _UIFactors.marginFactor;

    final double estimatedPanelHeight = visibleOptions.fold(0.0, (sum, opt) {
      if (opt == MessageOption.changeModel) {
        return sum +
            (optionHeight +
                (screenSize.height *
                    _UIFactors.changeModelVerticalPaddingFactor *
                    2));
      }
      return sum + optionHeight;
    });

    double targetLeft = widget.position.dx;
    double targetTop = widget.position.dy;

    if (targetLeft + panelWidth > screenSize.width - margin) {
      targetLeft = widget.position.dx - panelWidth;
      if (targetLeft < margin) targetLeft = margin;
    }
    if (targetTop + estimatedPanelHeight >
        screenSize.height - margin - keyboardHeight) {
      targetTop = widget.position.dy - estimatedPanelHeight;
      if (targetTop < margin) targetTop = margin;
    }

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _dismissPanel,
              behavior: HitTestBehavior.opaque,
              child: Container(color: Colors.transparent),
            ),
          ),
          AnimatedPositioned(
            duration: _kLongAnimationDuration,
            curve: Curves.easeOut,
            left: targetLeft,
            top: targetTop,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(borderRadius),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    width: panelWidth,
                    decoration: BoxDecoration(
                      color: widget.message.isUserMessage
                          ? AppColors.secondaryColor
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(borderRadius),
                      border: Border.all(
                        color: AppColors.border,
                        width: 0.8,
                      ),
                      boxShadow: const [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: visibleOptions.map((option) {
                        switch (option) {
                          case MessageOption.copy:
                            return OptionPanelItem(
                                label: localizations.copy,
                                iconAsset: 'assets/icons/copy.svg',
                                onTap: _onCopyTapped,
                                borderRadius: borderRadius);
                          case MessageOption.report:
                            return OptionPanelItem(
                                label: localizations.report,
                                iconAsset: 'assets/icons/warning.svg',
                                onTap: () {
                                  _dismissPanel();
                                  widget.onReport?.call();
                                },
                                borderRadius: borderRadius);
                          case MessageOption.regenerate:
                            return OptionPanelItem(
                                label: localizations.regenerate,
                                iconAsset: 'assets/icons/regenerate.svg',
                                onTap: () {
                                  _dismissPanel();
                                  widget.onRegenerate?.call();
                                },
                                borderRadius: borderRadius);
                          case MessageOption.select:
                            return OptionPanelItem(
                                label: localizations.selectText,
                                iconAsset: 'assets/icons/select.svg',
                                onTap: _onSelectTapped,
                                borderRadius: borderRadius);
                          case MessageOption.changeModel:
                            return OptionPanelItem(
                              label: localizations.changeModel,
                              iconAsset: 'assets/icons/variant.svg',
                              onTap: _onChangeModelTapped,
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.width *
                                    _UIFactors.horizontalPaddingFactor,
                                vertical: screenSize.height *
                                    _UIFactors.changeModelVerticalPaddingFactor,
                              ),
                              borderRadius: borderRadius,
                            );
                          case MessageOption.stop:
                            return OptionPanelItem(
                                label: localizations.stop,
                                iconAsset: 'assets/icons/stop.svg',
                                onTap: () {
                                  _dismissPanel();
                                  widget.onStop?.call();
                                },
                                borderRadius: borderRadius);
                          case MessageOption.edit:
                            return OptionPanelItem(
                                label: localizations.edit,
                                iconAsset: 'assets/icons/edit.svg',
                                onTap: () {
                                  _dismissPanel();
                                  widget.onEdit?.call();
                                },
                                borderRadius: borderRadius);
                          case MessageOption.speak:
                            return OptionPanelItem(
                                label: localizations.speakTheMessage,
                                iconAsset: 'assets/icons/voice.svg',
                                onTap: () {
                                  _dismissPanel();
                                  widget.onSpeak?.call();
                                },
                                borderRadius: borderRadius);
                          case MessageOption.delete:
                            return OptionPanelItem(
                                label: localizations.delete,
                                iconAsset: 'assets/icons/delete.svg',
                                onTap: _onDeleteTapped,
                                borderRadius: borderRadius);
                          case MessageOption.branch:
                            return OptionPanelItem(
                                label: localizations.branch,
                                iconAsset: 'assets/icons/flow.svg',
                                onTap: _onBranchTapped,
                                borderRadius: borderRadius);
                        }
                      }).toList(),
                    ),
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
