// lib/axon/inbox/widgets/tiles/view.dart

import 'dart:async';
import 'package:cortex/axon/inbox/panel/view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../theme.dart';
import '../../../app.dart';
import '../../../../chat/providers/conversation.dart';
import '../../../overflow.dart';
import '../logic/manager.dart';

// Ensure this path matches where you placed the edit.dart file
import '../panel/actions/edit.dart';
import '../panel/buttons.dart';
import 'avatar.dart';

class AxonConversationTile extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;
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

  // Store touch position for panel positioning
  Offset? _tapPosition;

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
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _deleteController.dispose();
    super.dispose();
  }

  void _handleDelete() {
    _panelController?.close();
    _deleteController.reverse().then((_) {
      if (mounted) {
        widget.onDelete();
      }
    });
  }

  void _showActionPanel() {
    if (_panelController != null) {
      _panelController!.close();
      _panelController = null;
      return;
    }

    final Offset position = _tapPosition ?? Offset.zero;
    final localizations = AppLocalizations.of(context)!;
    final manager = widget.manager;

    _panelController = showActionPanel(
      context: context,
      touchPosition: position,
      onClosed: () => _panelController = null,
      buttons: [
        // --- 1. Edit Button ---
        ActionPanelButton(
          iconAsset: 'assets/icons/edit.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: localizations.editConversationTitle,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () async {
            _panelController?.close();
            // Call the dialog to get the new title
            final newTitle = await showEditTitleDialog(
              context: context,
              initialTitle: manager.conversationTitle,
            );
            // If result is not null and component is still mounted, update it
            if (newTitle != null && mounted) {
              widget.onEdit(newTitle);
            }
          },
        ),
        // --- 2. Star/Pin Button ---
        ActionPanelButton(
          iconAsset: manager.isStarred
              ? 'assets/icons/on/star.svg'
              : 'assets/icons/off/star.svg',
          iconColor: manager.isStarred
              ? Colors.amber
              : AppColors.primaryColor.inverted,
          text: manager.isStarred
              ? localizations.unstarConversation
              : localizations.starConversation,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            _panelController?.close();
            widget.onTogglePin();
          },
        ),
        // --- 3. Delete Button ---
        ActionPanelButton(
          iconAsset: 'assets/icons/delete.svg',
          iconColor: Colors.redAccent,
          text: localizations.remove,
          textColor: Colors.redAccent,
          onPressed: _handleDelete,
        ),
      ],
    );
  }

  // --- CUSTOM GESTURE LOGIC ---

  void _onTapDown(TapDownDetails details) {
    _tapPosition = details.globalPosition;
    _holdTimer?.cancel();
    // 350ms threshold for "Long Press"
    _holdTimer = Timer(const Duration(milliseconds: 350), () {
      HapticFeedback.lightImpact();
      _showActionPanel();
    });
  }

  void _onTapUp(TapUpDetails details) {
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
    if (_panelController != null) {
      // Panel was open, we already hapticed on opening.
      // Closing it might deserve a light impact?
      // "click anywhere to close" logic in panel/view.dart has it.
      // _panelController.close() is just a manual call.
      _panelController!.close();
      return;
    }
    mainScreenKey.currentState?.closeAxon();
    mainScreenKey.currentState?.openConversation(widget.manager);
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
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final double screenHeight = mediaQuery.size.height;

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

    // --- 2. State & Colors ---
    final currentConversationId =
        context.watch<ConversationProvider>().conversationID;
    final isActive = currentConversationId == widget.manager.conversationID;
    final Color textColor = AppColors.primaryColor.inverted;

    // The animated background color target (Transparent vs Highlighted)
    final Color targetBackgroundColor = isActive
        ? AppColors.primaryColor.inverted.withValues(alpha: 0.05)
        : Colors.transparent;

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
        ),
        // Material is transparent to allow AnimatedContainer color to show,
        // but keeps InkWell functionality for ripples.
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          clipBehavior: Clip.antiAlias,
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
                        style: GoogleFonts.roboto(
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
