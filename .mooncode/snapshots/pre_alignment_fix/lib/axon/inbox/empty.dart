// lib/axon/inbox/widgets/empty.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:cortex/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../app.dart';
import '../../../theme.dart';

/// A compact empty state widget designed specifically for the Axon Sidebar.
class EmptyStateView extends StatelessWidget {
  final bool isForStarred;
  final VoidCallback? onGoToAllChats;

  const EmptyStateView({
    super.key,
    required this.isForStarred,
    this.onGoToAllChats,
  });

  @override
  Widget build(BuildContext context) {
    // Rebuild when theme changes
    context.watch<ThemeProvider>();
    final localizations = AppLocalizations.of(context)!;

    // Logic for text content
    final String title =
        isForStarred ? localizations.noStarredChats : localizations.noChats;

    final String message = isForStarred
        ? localizations.noStarredChatsMessage
        : localizations.noConversationsMessage;

    return TweenAnimationBuilder<double>(
      key: ValueKey(isForStarred ? 'empty_starred' : 'empty_all'),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      builder: (context, opacity, child) {
        return Opacity(opacity: opacity, child: child);
      },
      child: Center(
        child: Padding(
          // Fixed padding suitable for sidebar column
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. Icon (SVG for Inbox, Icon for Starred)
              isForStarred
                  ? Icon(
                      Icons.star_rounded,
                      size: 48,
                      color: AppColors.tertiaryColor.withValues(alpha: 0.4),
                    )
                  : SvgPicture.asset(
                      'assets/icons/inbox.svg',
                      width: 48,
                      height: 48,
                      colorFilter: ColorFilter.mode(
                        AppColors.tertiaryColor.withValues(alpha: 0.4),
                        BlendMode.srcIn,
                      ),
                    ),
              const SizedBox(height: 18),

              // 2. Title (Increased size: 16 -> 18)
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.primaryColor.inverted,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // 3. Message (Increased size: 13 -> 14.5)
              Text(
                message,
                style: TextStyle(
                  fontFamily: 'Inter',
                  color: AppColors.tertiaryColor,
                  fontSize: 14.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
