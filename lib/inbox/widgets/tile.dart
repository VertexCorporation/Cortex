// lib/inbox/widgets/tiles/tile.dart

import 'package:cortex/inbox/widgets/panel.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cortex/l10n/app_localizations.dart';
import '../../../main.dart';
import '../../../theme.dart';
import '../../app.dart';
import '../../../chat/providers/conversation.dart';
import '../manager.dart';
import 'avatar.dart';
import 'buttons.dart';
import 'actions/edit.dart';

class SidebarConversationTile extends StatefulWidget {
  final ConversationManager manager;
  final VoidCallback onDelete;
  final ValueChanged<String> onEdit;
  final VoidCallback onTogglePin;

  const SidebarConversationTile({
    super.key,
    required this.manager,
    required this.onDelete,
    required this.onEdit,
    required this.onTogglePin,
  });

  @override
  State<SidebarConversationTile> createState() => _SidebarConversationTileState();
}

class _SidebarConversationTileState extends State<SidebarConversationTile> {
  final GlobalKey _tileKey = GlobalKey();

  ActionPanelController? _panelController;

  void _showActionPanel() {
    if (_panelController != null) {
      _panelController!.close();
      _panelController = null;
      return;
    }

    final localizations = AppLocalizations.of(context)!;
    final manager = widget.manager;

    _panelController = showActionPanel(
      context: context,
      anchorKey: _tileKey,
      onClosed: () => _panelController = null,
      buttons: [
        // RENAME
        ActionPanelButton(
          iconAsset: 'assets/icons/edit.svg',
          iconColor: AppColors.primaryColor.inverted,
          text: localizations.editConversationTitle,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () async {
            _panelController?.close();
            final newTitle = await showEditTitleDialog(
              context: context,
              initialTitle: manager.conversationTitle,
            );
            if (newTitle != null) widget.onEdit(newTitle);
          },
        ),

        // STAR / UNSTAR
        ActionPanelButton(
          iconAsset: manager.isStarred ? 'assets/icons/star.svg' : 'assets/icons/starBordered.svg',
          iconColor: manager.isStarred ? Colors.amber : AppColors.primaryColor.inverted,
          text: manager.isStarred ? localizations.unstarConversation : localizations.starConversation,
          textColor: AppColors.primaryColor.inverted,
          onPressed: () {
            _panelController?.close();
            widget.onTogglePin();
          },
        ),

        // DELETE
        ActionPanelButton(
          iconAsset: 'assets/icons/delete.svg',
          iconColor: Colors.redAccent,
          text: localizations.remove,
          textColor: Colors.redAccent,
          onPressed: () {
            _panelController?.close();
            widget.onDelete();
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentConversationId = context.watch<ConversationProvider>().conversationID;
    final isActive = currentConversationId == widget.manager.conversationID;

    // Dynamic text color based on theme background
    final Color textColor = AppColors.primaryColor.inverted;

    return Padding(
      // Add subtle vertical margin for separation
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
      child: Material(
        key: _tileKey,
        color: isActive
            ? AppColors.secondaryColor.withValues(alpha: 0.3) // Highlight active chat
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12), // Rounded corners for the tile
        clipBehavior: Clip.antiAlias, // Ensures ink splash respects radius
        child: InkWell(
          onLongPress: _showActionPanel,
          onTap: () {
            if (_panelController != null) {
              _panelController!.close();
              return;
            }
            mainScreenKey.currentState?.closeSidebar();
            mainScreenKey.currentState?.openConversation(widget.manager);
          },
          splashColor: AppColors.secondaryColor.withValues(alpha: 0.2), // Custom splash color
          highlightColor: AppColors.secondaryColor.withValues(alpha: 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Row(
              children: [
                // --- AVATAR ---
                TileAvatar(
                  imagePath: widget.manager.modelImagePath,
                  size: 28,
                ),

                const SizedBox(width: 12),

                // --- TITLE ---
                Expanded(
                  child: Text(
                    widget.manager.conversationTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.roboto(
                      color: isActive
                          ? textColor
                          : textColor.withValues(alpha: 0.85),
                      fontSize: 14, // Readable size
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),

                // --- STAR ICON (If starred) ---
                if (widget.manager.isStarred) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: Colors.amber, // Gold star
                  ),
                ]
              ],
            ),
          ),
        ),
      ),
    );
  }
}