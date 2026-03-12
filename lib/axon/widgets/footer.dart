// lib/axon/widgets/footer.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

// Logic & Theme
import 'package:cortex/theme.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/navigation.dart';

// Helpers (Contains Avatar & Hexagon Button)
import '../../app.dart';
import '../../settings/controller.dart';
import '../helpers.dart';

class AxonFooter extends StatelessWidget {
  final double referenceWidth;
  final bool isSearchActive;

  // We keep this in case the parent needs to do something else,
  // but we will primarily handle navigation internally to prevent "closing" lag.
  final VoidCallback? onSettingsTap;

  const AxonFooter({
    super.key,
    required this.referenceWidth,
    required this.isSearchActive,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    // --- Data Providers ---
    final userProvider = context.watch<UserProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();
    final localizations = AppLocalizations.of(context)!;

    // --- State Variables ---
    final bool isUserSubscribed = sessionProvider.isUserSubscribed;
    final String name = userProvider.username;
    final String settingsText = localizations.settings;

    // Calculate Font Size based on width
    final double fontSize = referenceWidth * 0.045;
    final double horizontalPadding = referenceWidth * 0.05;

    // --- Initials Logic ---
    String initials;
    if (userProvider.isAnonymous) {
      final String anonString = localizations.anonymousEntity;
      initials = anonString.isNotEmpty ? anonString[0].toUpperCase() : '?';
    } else {
      initials = userProvider.profileInitial;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SETTINGS / USER TILE ---
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding * 0.8,
            vertical: 12.0,
          ),
          child: InkWell(
            onTap: () {
              HapticFeedback.lightImpact();
              if (onSettingsTap != null) {
                onSettingsTap!();
              } else {
                navigateToScreen(
                  const SettingsScreen(),
                  direction: const Offset(1.0, 0.0), // Slides from Right
                );
              }
              FocusScope.of(context).unfocus();
            },
            borderRadius: BorderRadius.circular(12),
            splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
            highlightColor:
            AppColors.primaryColor.inverted.withValues(alpha: 0.05),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // --- Avatar (from helpers.dart) ---
                  AxonAvatar(
                    initials: initials,
                    isSubscribed: isUserSubscribed,
                    size: referenceWidth * 0.11,
                    fontSize: fontSize,
                  ),

                  SizedBox(width: referenceWidth * 0.04),

                  // --- Name & Settings Text ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: TextStyle(
                            color: AppColors.primaryColor.inverted,
                            fontSize: fontSize * 0.95,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          settingsText,
                          style: TextStyle(
                            color: AppColors.tertiaryColor,
                            fontSize: fontSize * 0.8,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
