// lib/inbox/widgets/tiles/tile.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../app.dart';
import '../../../main.dart';
import '../../manager.dart';
import '../../../theme.dart';
import 'actions/buttons.dart';
import 'actions/edit.dart';
import 'actions/panel.dart';
import 'avatar.dart';
import 'content.dart';

/// A widget that represents a single conversation in the inbox list.
///
/// This widget acts as a high-level assembler, composing specialized child widgets
/// like [TileAvatar] and [TileContent] to build its UI. It handles user interactions
/// such as taps and long-press-to-open-menu, and delegates complex UI tasks like
/// showing dialogs and action panels to dedicated utility functions.
class ConversationTile extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;
  final VoidCallback onToggleStar;

  const ConversationTile({
    super.key,
    required this.manager,
    required this.onDelete,
    required this.onEdit,
    required this.onToggleStar,
  });

  @override
  State<ConversationTile> createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  final GlobalKey _actionButtonKey = GlobalKey();
  ActionPanelController? _panelController;

  Timer? _longPressTimer;
  bool _isLongPress = false;

  /// Tracks which tile currently owns an open action panel.
  static _ConversationTileState? _currentlyOpenTileState;

  void _navigateToChatScreen() {
    mainScreenKey.currentState?.openConversation(widget.manager);
  }

  /// Resets the local + global references to this tile's panel.
  /// This is safe to call multiple times.
  void _resetPanelState() {
    if (_panelController == null) return;
    _panelController = null;
    if (_currentlyOpenTileState == this) {
      _currentlyOpenTileState = null;
    }
  }

  /// Programmatically closes this tile's panel (if any), with animation.
  void _closePanel() {
    final controller = _panelController;
    if (controller == null) return;

    // Reset ownership first; the overlay will animate out and then remove itself.
    _resetPanelState();
    controller.close();
  }

  /// Opens this tile's panel.
  ///
  /// - If another tile has a panel open, it is closed first.
  /// - If this tile already owns an open panel, it does nothing.
  void _openPanel() {
    // Close any other tile's panel first.
    if (_currentlyOpenTileState != null && _currentlyOpenTileState != this) {
      _currentlyOpenTileState!._closePanel();
    }

    // If this tile already has a panel open, do not recreate it.
    if (_panelController != null) return;

    final localizations = AppLocalizations.of(context)!;
    final manager = widget.manager;

    _panelController = showActionPanel(
      context: context,
      anchorKey: _actionButtonKey,
      buttons: [
        ActionPanelButton(
          iconAsset: manager.isStarred
              ? 'assets/icons/star.svg'
              : 'assets/icons/starBordered.svg',
          iconColor:
          manager.isStarred ? Colors.amber : AppColors.primaryColor.inverted,
          text: localizations.starConversation,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            final controller = _panelController;
            _resetPanelState();
            controller?.close().then((_) {
              if (mounted) {
                widget.onToggleStar();
              }
            });
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/edit.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: localizations.editConversationTitle,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            final controller = _panelController;
            _resetPanelState();
            controller?.close().then((_) {
              if (mounted) {
                _showEditDialog();
              }
            });
          },
        ),
        ActionPanelButton(
          iconAsset: 'assets/icons/delete.svg',
          iconColor: Colors.red,
          text: localizations.remove,
          textColor: Colors.red,
          onPressed: () {
            final controller = _panelController;
            _resetPanelState();
            controller?.close().then((_) {
              if (mounted) {
                widget.onDelete();
              }
            });
          },
        ),
      ],
      // Called whenever the panel is fully dismissed (tap outside, drag, etc.).
      onClosed: _resetPanelState,
    );

    _currentlyOpenTileState = this;
  }

  /// Toggles this tile's panel.
  ///
  /// - If this tile's panel is open → closes it.
  /// - If it is closed → opens it (closing any other open panel first).
  void _togglePanel() {
    if (_panelController != null) {
      _closePanel();
    } else {
      _openPanel();
    }
  }

  Future<void> _showEditDialog() async {
    final newTitle = await showEditTitleDialog(
      context: context,
      initialTitle: widget.manager.conversationTitle,
    );

    if (newTitle != null && mounted) {
      widget.onEdit(newTitle);
    }
  }

  @override
  void dispose() {
    _longPressTimer?.cancel();
    _closePanel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTapDown: (_) {
        _longPressTimer?.cancel();
        _isLongPress = false;

        // Quick long-press detection (matching the original behavior).
        _longPressTimer = Timer(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          _isLongPress = true;
          _togglePanel();
        });
      },
      onTapUp: (_) {
        _longPressTimer?.cancel();
      },
      onTapCancel: () {
        _longPressTimer?.cancel();
      },
      onTap: () {
        // If this tap was actually part of a long-press sequence,
        // we do nothing extra here.
        if (_isLongPress) {
          _isLongPress = false;
          return;
        }

        // If the panel is open, a normal tap on the tile closes it
        // instead of navigating.
        if (_panelController != null) {
          _closePanel();
          return;
        }

        // Otherwise, navigate to the conversation.
        _navigateToChatScreen();
      },
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.03,
          vertical: screenHeight * 0.008,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(screenWidth * 0.03),
          border: Border.all(
            color: AppColors.border,
            width: 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TileAvatar(
              imagePath: widget.manager.modelImagePath,
              size: screenWidth * 0.16,
            ),
            SizedBox(width: screenWidth * 0.03),
            // The TileContent needs the GlobalKey to anchor the panel.
            TileContent(
              manager: widget.manager,
              actionButtonKey: _actionButtonKey,
              onShowActionsPressed: _togglePanel,
            ),
          ],
        ),
      ),
    );
  }
}