// lib/inbox/widgets/tiles/context_menu.dart

import 'dart:ui';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';

import '../app.dart';

// Changed 'pin' to 'star'
enum TileAction { rename, archive, star, delete }

Future<TileAction?> showCustomContextMenu({
  required BuildContext context,
  required Offset position,
  required bool isStarred, // Renamed from isPinned
  required AppLocalizations localizations,
}) {
  return showGeneralDialog<TileAction>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: Colors.black.withValues(alpha: 0.4), // Dim background
    transitionDuration: const Duration(milliseconds: 250),
    pageBuilder: (context, animation, secondaryAnimation) {
      return Stack(
        children: [
          // Backdrop Blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Menu Position Logic
          Positioned(
            top: position.dy + 10, // Just below tap
            left: position.dx > MediaQuery.of(context).size.width / 2
                ? position.dx - 180 // Align right if tapped on right
                : position.dx,      // Align left if tapped on left
            child: _AnimatedMenu(
              isStarred: isStarred, // Pass starred state
              localizations: localizations,
            ),
          ),
        ],
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      // Bouncy Scale Animation
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        alignment: Alignment.topLeft,
        child: child,
      );
    },
  );
}

class _AnimatedMenu extends StatelessWidget {
  final bool isStarred;
  final AppLocalizations localizations;

  const _AnimatedMenu({required this.isStarred, required this.localizations});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildItem(context, TileAction.rename, Icons.edit_outlined, localizations.editConversationTitle),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),

            // --- STAR ITEM ---
            _buildItem(
                context,
                TileAction.star,
                isStarred ? Icons.star : Icons.star_border, // Filled star if starred
                isStarred ? localizations.remove : localizations.starConversation,
                iconColor: isStarred ? Colors.amber : null // Gold color if active
            ),

            Divider(height: 1, color: AppColors.border.withValues(alpha: 0.3)),

            _buildItem(
                context,
                TileAction.delete,
                Icons.delete_outline,
                localizations.remove,
                isDestructive: true
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, TileAction action, IconData icon, String text, {bool isDestructive = false, Color? iconColor}) {
    final Color textColor = isDestructive ? Colors.redAccent : AppColors.primaryColor.inverted;
    // Use custom icon color if provided (e.g. Amber for star), otherwise default
    final Color finalIconColor = iconColor ?? textColor;

    return InkWell(
      onTap: () => Navigator.pop(context, action),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, size: 20, color: finalIconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}