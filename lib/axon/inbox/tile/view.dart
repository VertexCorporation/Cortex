// lib/axon/inbox/widgets/tiles/view.dart

import 'dart:async';
import 'dart:math' as math;
import 'package:cortex/axon/inbox/panel/view.dart';
import 'package:cortex/axon/inbox/panel/buttons.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/notifications/introvert.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import '../../../../main.dart';
import '../../../../theme.dart';
import '../../../app.dart';
import '../../../../chat/providers/conversation.dart';
import 'package:cortex/chat/providers/input.dart'; // [NEW]
import 'package:cortex/chat/services/voice.dart'; // [NEW]
import 'package:cortex/chat/services/background.dart';
import '../../../overflow.dart';
import '../logic/manager.dart';
import '../logic/general.dart';

import 'avatar.dart';

class AxonConversationTile extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onDelete;
  final Future<void> Function(String newTitle) onEdit;
  final VoidCallback onTogglePin;

  const AxonConversationTile({
    super.key,
    required this.manager,
    required this.onDelete,
    required this.onEdit,
    required this.onTogglePin,
  });

  @override
  State<AxonConversationTile> createState() => _AxonConversationTileState();
}

class _AxonConversationTileState extends State<AxonConversationTile>
    with SingleTickerProviderStateMixin {
  ActionPanelController? _panelController;

  // Custom Timer for faster "Long Press" detection
  Timer? _holdTimer;

  // Animation controller for the delete slide effect
  late AnimationController _deleteController;
  late Animation<double> _sizeAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _deleteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );

    _sizeAnimation = CurvedAnimation(
      parent: _deleteController,
      curve: Curves.easeInOutQuart,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _deleteController,
      curve: Curves.easeOut,
    );

    // Listen to manager changes (star, title, last message) for reactive UI.
    widget.manager.addListener(_onManagerChange);
  }

  @override
  void didUpdateWidget(covariant AxonConversationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.manager != widget.manager) {
      oldWidget.manager.removeListener(_onManagerChange);
      widget.manager.addListener(_onManagerChange);
    }
  }

  void _onManagerChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChange);
    _holdTimer?.cancel();
    _deleteController.dispose();
    super.dispose();
  }

  // --- CUSTOM GESTURE LOGIC ---

  void _onTapDown(TapDownDetails details) {
    _holdTimer?.cancel();

    final inboxViewModel = context.read<InboxViewModel>();
    if (inboxViewModel.isSelectionMode) {
      return;
    }

    // 350ms threshold for "Long Press" -> Show Context Menu
    _holdTimer = Timer(const Duration(milliseconds: 350), () {
      HapticFeedback.lightImpact();
      _showContextMenu(details.globalPosition);
    });
  }

  void _onTapUp(TapUpDetails details) {
    final inboxViewModel = context.read<InboxViewModel>();
    if (inboxViewModel.isSelectionMode) {
      HapticFeedback.lightImpact();
      inboxViewModel.toggleSelectConversation(widget.manager.conversationID);
      return;
    }

    if (_holdTimer?.isActive ?? false) {
      _holdTimer?.cancel();
      HapticFeedback.lightImpact();
      _openChat();
    }
  }

  void _onTapCancel() {
    _holdTimer?.cancel();
  }

  void _openChat() {
    // [Clean Up] Ensure Voice/Flow modes are disabled when switching chats
    // We do not await this to ensure instant UI response.
    context.read<VoiceService>().stopSession(resetState: true);
    final inputProvider = context.read<InputProvider>();
    inputProvider.setVoiceModeActive(false);
    // Only clear offline mode - reasoning and other features persist across chats
    inputProvider.clearFeatureModeIfOffline();

    if (_panelController != null) {
      _panelController!.close();
      return;
    }
    mainScreenKey.currentState?.closeAxon();
    mainScreenKey.currentState?.openConversation(widget.manager);
  }

  void _showContextMenu(Offset touchPosition) {
    final inboxViewModel = context.read<InboxViewModel>();
    final l10n = AppLocalizations.of(context)!;
    final manager = widget.manager;

    _panelController = showActionPanel(
      context: context,
      touchPosition: touchPosition,
      onClosed: () {
        _panelController = null;
      },
      buttons: [
        ActionPanelButton(
          customIcon: Icon(manager.isStarred ? Icons.star_rounded : Icons.star_outline_rounded,
                           color: manager.isStarred ? Colors.amber : AppColors.primaryColor.inverted,
                           size: 22),
          iconColor: manager.isStarred ? Colors.amber : AppColors.primaryColor.inverted,
          text: manager.isStarred ? l10n.unstarConversation : l10n.starConversation,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () async {
            _panelController?.close();
            final success = await inboxViewModel.togglePinStatus(manager.conversationID);
            if (!success && mounted) {
              final ctx = mainScreenKey.currentContext;
              if (ctx != null && ctx.mounted) {
                final notifCtx = Provider.of<IntrovertNotificationService>(ctx, listen: false);
                notifCtx.showNotification(
                   message: l10n.pinLimitReached,
                  type: NotificationType.error,
                );
              }
            }
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/edit.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: l10n.renameConversation,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            _panelController?.close();
            _showRenameDialog(manager);
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/download.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: l10n.archive,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            _panelController?.close();
            inboxViewModel.archiveConversation(manager.conversationID);
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/select.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: l10n.multiSelect,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            _panelController?.close();
            inboxViewModel.setSelectionMode(true);
            if (!inboxViewModel.selectedIDs.contains(manager.conversationID)) {
              inboxViewModel.toggleSelectConversation(manager.conversationID);
            }
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/delete.svg',
          iconColor: AppColors.septenaryColor,
          text: l10n.delete,
          textColor: AppColors.septenaryColor,
          onPressed: () {
            _panelController?.close();
            _showDeleteConfirmation(manager);
          },
        ),
      ],
    );
  }

  void _showRenameDialog(ConversationManager manager) {
    final l10n = AppLocalizations.of(context)!;
    final TextEditingController controller = TextEditingController(
      text: manager.conversationTitle,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.renameConversation),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: l10n.conversationName,
            border: const OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<InboxViewModel>().editConversation(
                    manager.conversationID,
                    value.trim(),
                  );
              Navigator.of(ctx).pop();
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) {
                context.read<InboxViewModel>().editConversation(
                      manager.conversationID,
                      value,
                    );
                Navigator.of(ctx).pop();
              }
            },
            child: Text(l10n.save),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(ConversationManager manager) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog.adaptive(
        title: Text(l10n.deleteConversation),
        content: Text(l10n.deleteConversationConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.quinaryColor,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<InboxViewModel>().deleteConversation(
                    manager.conversationID,
                  );
            },
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Wrap the entire tile content in animations for deletion
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1.0,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildTileContent(),
      ),
    );
  }

  Widget _buildTileContent() {
    // --- 1. Screen & Dynamic Sizing Logic ---

    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double screenHeight = MediaQuery.sizeOf(context).height;

    // Determine if device is tablet (standard breakpoint > 600)
    final bool isTablet = screenWidth > 600;

    // Calculate dynamic dimensions based on device type
    // We use a slightly smaller multiplier for tablets to prevent elements from looking too huge

    // Margins outside the tile
    final double outerPaddingV = screenHeight * 0.003;
    final double outerPaddingH = screenWidth * 0.01;

    // Padding inside the tile
    final double innerPaddingV =
        isTablet ? screenHeight * 0.012 : screenHeight * 0.012;
    final double innerPaddingH =
        isTablet ? screenWidth * 0.02 : screenWidth * 0.03;

    final double borderRadius =
        isTablet ? screenWidth * 0.015 : screenWidth * 0.03;

    // Avatar Size: Larger on tablet but scaled appropriately
    final double avatarSize =
        isTablet ? screenWidth * 0.045 : screenWidth * 0.072;

    // Font Size
    final double fontSize = isTablet ? screenWidth * 0.02 : screenWidth * 0.038;

    // Icon Size (Star)
    final double starIconSize =
        isTablet ? screenWidth * 0.025 : screenWidth * 0.042;

    // Spacing between elements
    final double gapAvatarText = screenWidth * 0.03;
    final double gapTextIcon = screenWidth * 0.015;

    // PERFORMANCE: Use context.select instead of context.watch to prevent
    // rebuilding ALL sidebar tiles on every stream chunk (~30fps).
    // We only need rebuilds when conversationID or selectedIndex actually changes.
    final currentConversationId =
        context.select<ConversationProvider, String?>((p) => p.conversationID);

    // [FIX] Check if we are actually on the Chat tab (index 0).
    // If user is in Library (1) or News (2), the tile should NOT be highlighted
    // even if it matches the currentConversationId.
    final inboxViewModel = context.watch<InboxViewModel>();
    final isSelectionMode = inboxViewModel.isSelectionMode;
    final isSelected =
        inboxViewModel.selectedIDs.contains(widget.manager.conversationID);

    final selectedTab =
        context.select<TabProvider, int>((p) => p.selectedIndex);
    final isActive = (selectedTab == 0) &&
        (currentConversationId == widget.manager.conversationID);
    final Color textColor = AppColors.primaryColor.inverted;

    // In selection mode, we highlight selected tiles
    final Color targetBackgroundColor = isSelectionMode
        ? (isSelected
            ? AppColors.primaryColor.inverted.withValues(alpha: 0.08)
            : Colors.transparent)
        : (isActive
            ? AppColors.primaryColor.inverted.withValues(alpha: 0.05)
            : Colors.transparent);

    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: outerPaddingV, horizontal: outerPaddingH),
      // --- 3. Animated Background Container ---
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: targetBackgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: isSelectionMode && isSelected
              ? Border.all(
                  color: AppColors.senaryColor.withValues(alpha: 0.5),
                  width: 1.0,
                )
              : null,
        ),
        // Material is transparent to allow AnimatedContainer color to show,
        // but keeps InkWell functionality for ripples.
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior:
              Clip.hardEdge, // PERFORMANCE: hardEdge avoids saveLayer overhead
          child: InkWell(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            highlightColor:
                AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: innerPaddingH, vertical: innerPaddingV),
              child: Row(
                children: [
                  if (isSelectionMode) ...[
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(right: gapAvatarText),
                      width: 20.0,
                      height: 20.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? AppColors.senaryColor
                            : Colors.transparent,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.senaryColor
                              : AppColors.border.withValues(alpha: 0.5),
                          width: 2.0,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 13.0,
                            )
                          : null,
                    ),
                  ],
                  // Dynamic Avatar
                  TileAvatar(
                    imagePath: widget.manager.modelImagePath,
                    size: avatarSize,
                  ),

                  SizedBox(width: gapAvatarText),

                  // Dynamic Text (UPDATED to use OverflowText)
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (Widget? currentChild,
                          List<Widget> previousChildren) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: OverflowText(
                        key: ValueKey<String>(widget.manager.conversationTitle),
                        text: widget.manager.conversationTitle,
                        maxLines: 1,
                        fadeLength: 8,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          color: isActive
                              ? textColor
                              : textColor.withValues(alpha: 0.85),
                          fontSize: fontSize,
                          fontWeight:
                              isActive ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(width: gapTextIcon),

                  // Dynamic progress indicator (Background Task Indicator)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOutBack,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      );
                    },
                    child: context.select<BackgroundTaskService, bool>(
                      (bg) => bg.isActive(widget.manager.conversationID),
                    )
                        ? _BackgroundProgressIndicator(
                            key: const ValueKey('background_progress'),
                            size: starIconSize * 1.08,
                          )
                        : const SizedBox.shrink(
                            key: ValueKey('no_background_progress')),
                  ),

                  if (widget.manager.isStarred) SizedBox(width: gapTextIcon),

                  // Dynamic Star Icon
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: widget.manager.isStarred
                        ? Icon(
                            Icons.star_rounded,
                            key: const ValueKey('star'),
                            size: starIconSize,
                            color: Colors.amber,
                          )
                        : SizedBox.shrink(key: const ValueKey('empty')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BackgroundProgressIndicator extends StatefulWidget {
  final double size;

  const _BackgroundProgressIndicator({super.key, required this.size});

  @override
  State<_BackgroundProgressIndicator> createState() =>
      _BackgroundProgressIndicatorState();
}

class _BackgroundProgressIndicatorState
    extends State<_BackgroundProgressIndicator> with TickerProviderStateMixin {
  late final AnimationController _outerController;
  late final AnimationController _innerController;

  @override
  void initState() {
    super.initState();
    _outerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1150),
    )..repeat();
    _innerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1750),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _outerController.dispose();
    _innerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox.square(
        dimension: widget.size,
        child: AnimatedBuilder(
          animation: Listenable.merge([_outerController, _innerController]),
          builder: (context, _) {
            return CustomPaint(
              painter: _BackgroundProgressPainter(
                outerTurns: _outerController.value,
                innerTurns: _innerController.value,
                color: AppColors.primaryColor.inverted,
                accentColor: AppColors.primaryColor,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BackgroundProgressPainter extends CustomPainter {
  final double outerTurns;
  final double innerTurns;
  final Color color;
  final Color accentColor;

  const _BackgroundProgressPainter({
    required this.outerTurns,
    required this.innerTurns,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = (size.shortestSide * 0.16).clamp(2.2, 3.2).toDouble();
    final rect = Offset.zero & size;
    final inset = stroke / 2;
    final arcRect = rect.deflate(inset);

    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = color.withValues(alpha: 0.10);

    final outerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          color.withValues(alpha: 0.18),
          color.withValues(alpha: 0.78),
          color.withValues(alpha: 0.18),
        ],
      ).createShader(arcRect);

    final innerPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * 0.72
      ..strokeCap = StrokeCap.round
      ..color = accentColor.inverted.withValues(alpha: 0.48);

    canvas.drawCircle(rect.center, arcRect.width / 2, trackPaint);

    final outerStart = -math.pi / 2 + (outerTurns * math.pi * 2);
    final innerStart = math.pi / 2 - (innerTurns * math.pi * 2);
    canvas.drawArc(arcRect, outerStart, math.pi * 1.42, false, outerPaint);
    canvas.drawArc(arcRect.deflate(stroke * 0.45), innerStart, -math.pi * 0.72,
        false, innerPaint);
  }

  @override
  bool shouldRepaint(covariant _BackgroundProgressPainter oldDelegate) {
    return oldDelegate.outerTurns != outerTurns ||
        oldDelegate.innerTurns != innerTurns ||
        oldDelegate.color != color ||
        oldDelegate.accentColor != accentColor;
  }
}
