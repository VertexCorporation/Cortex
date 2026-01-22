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

// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as p;

import '../../../library/backend/data/service.dart';
import '../../../library/utils.dart';
import '../../../notifications/introvert.dart';
import 'change.dart';
import 'item.dart';

enum MessageOption { copy, report, regenerate, select, stop, changeModel, edit }

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

  OptionsPanelViewModel({
    required this.session,
    required this.conversation,
    required this.internet,
    required this.message,
    required this.modelService,
  });

  List<MessageOption> get _baseOptions {
    if (message.isUserMessage) {
      return [MessageOption.copy, MessageOption.edit, MessageOption.select];
    } else {
      final options = [MessageOption.copy, MessageOption.select];
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

    // LOGIC UPDATE: Iterate attachments to find images.
    final bool conversationHasImages = conversation.messages.any((m) {
      return m.attachmentPaths.any((path) => _isImageFile(path));
    });

    final modelSeriesData = ModelDataUtils.findParentSeriesData(currentModelId,
        langCode: langCode, modelService: modelService);
    final currentModel =
        modelService.getPreciseModelData(currentModelId, langCode: langCode);

    final isDynamicContext = session.isDynamicChat;
    final isOfflineModel = modelSeriesData?.isServerSide == false;

    final currentModelCanHandleImages = modelService.hasModality(currentModelId,
        langCode: langCode, modality: 'image');
    final hasPremiumAccess =
        session.isUserSubscribed || session.premiumTrialUses < 3;
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

      if (option == MessageOption.regenerate) {
        if (isCurrentModelPremium && !hasPremiumAccess) return false;
        if (!isOfflineModel && !internet.isConnected) return false;
      }

      // LOGIC UPDATE: Only restrict model ops if chat has IMAGES and model CAN'T handle them.
      // (Text files are safe for any model).
      if (conversationHasImages && !currentModelCanHandleImages) {
        if (option == MessageOption.regenerate ||
            option == MessageOption.edit ||
            option == MessageOption.changeModel) {
          return false;
        }
      }

      if (option == MessageOption.changeModel) {
        if (!isDynamicContext && modelSeriesData != null) {
          final int validExtCount =
              ModelDataUtils.validVariantCountForChangingModel(
            parentSeries: modelSeriesData,
            conversationHasPhoto:
                conversationHasImages, // Renamed in utility call logic if needed, or pass boolean
          );
          if (validExtCount <= 1) return false;
        } else if (modelSeriesData == null) {
          return false;
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
    Navigator.of(context).push(PageRouteBuilder(
      pageBuilder: (_, __, ___) => screen,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ));
  }

  void _onCopyTapped() {
    final localizations = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: widget.message.text));
    Provider.of<IntrovertNotificationService>(context, listen: false)
        .showNotification(
            message: localizations.messageCopied,
            type: NotificationType.success,
            bottomOffset: 0.07,
            isChatMode: true);
    _dismissPanel();
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

  @override
  Widget build(BuildContext context) {
    final sessionProvider = context.watch<ChatSessionProvider>();
    final conversationProvider = context.watch<ConversationProvider>();
    final internetProvider = context.watch<InternetProvider>();
    final localizations = AppLocalizations.of(context)!;
    final modelService = context.read<ModelService>();

    final viewModel = OptionsPanelViewModel(
      session: sessionProvider,
      conversation: conversationProvider,
      internet: internetProvider,
      message: widget.message,
      modelService: modelService,
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
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(borderRadius),
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
