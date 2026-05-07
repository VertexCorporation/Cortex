// lib/chat/screen/appbar/appbar.dart

import 'package:path/path.dart' as p;
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
import 'package:cortex/chat/screen/appbar/login.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Theme & Global Widgets
import '../../../../theme.dart';
import '../../../../main.dart';
import '../../../appbar.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  const Appbar({
    super.key,
  });

  @override
  State<Appbar> createState() => AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class AppbarState extends State<Appbar> {
  bool _isSharing = false;

  // --- LOGIC: Flux Mode Toggle ---
  void _handleFluxModeToggle(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final conversation = context.read<ConversationProvider>();

    // Toggle state
    final bool newState = !session.isFluxMode;
    session.setFluxMode(newState);
    ChatStorageService.isFluxMode = newState;

    // Logic requires clearing conversation on mode switch
    conversation.clearConversation();
  }

  // --- LOGIC: Start New Chat ---
  void _handleNewChat(BuildContext context) {
    // Calls the global key method to reset everything properly
    mainScreenKey.currentState?.startNewConversation(closeSidebar: false);
  }

  // --- LOGIC: Share Chat ---
  Future<void> _handleShare(BuildContext context) async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      final session = context.read<ChatSessionProvider>();
      final conversation = context.read<ConversationProvider>();
      final localizations = AppLocalizations.of(context)!;

      // Determine Model Name
      String headerModelName;
      try {
        if (session.isDynamicChat) {
          headerModelName = localizations.dynamicChatTitle;
        } else {
          // [FIX] Fallback to 'Cortex' immediately if null, avoiding "Unknown"
          headerModelName = session.modelTitle ?? 'Cortex';
        }
      } catch (e) {
        headerModelName = session.modelTitle ?? 'Cortex';
      }

      final String userName = session.displayName ?? 'User';
      final String botName = session.isDynamicChat ? 'Cortex' : headerModelName;
      final StringBuffer buffer = StringBuffer();

      // Build Transcript Header
      buffer.writeln('Cortex | $headerModelName');
      buffer.writeln();

      // Iterate Messages
      for (final msg in conversation.messages) {
        if (msg.isThinking) continue;

        // Skip only if text is empty AND no attachments exist
        if (msg.text
            .trim()
            .isEmpty && !msg.hasAttachments) {
          continue;
        }

        if (msg.isUserMessage) {
          buffer.writeln('👤 $userName: ${msg.text}');
          if (msg.hasAttachments) {
            for (final path in msg.attachmentPaths) {
              final filename = p.basename(path);
              buffer.writeln('📎 [Attachment: $filename]');
            }
          }
        } else {
          buffer.writeln('🤖 $botName: ${msg.text}');
          if (msg.hasAttachments) {
            for (final path in msg.attachmentPaths) {
              final filename = p.basename(path);
              buffer.writeln('🖼️ [Generated Image: $filename]');
            }
          }
        }
        buffer.writeln();
      }

      final String shareText = buffer.toString();
      const String shareSubject = 'Cortex Chat Export';

      await SharePlus.instance
          .share(ShareParams(text: shareText, subject: shareSubject));
    } catch (e) {
      debugPrint("Share Error: $e");
    } finally {
      _isSharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Providers
    final session = context.watch<ChatSessionProvider>();
    final conversation = context.watch<ConversationProvider>();
    final userProvider = context.watch<UserProvider>();
    context.watch<ThemeProvider>();

    // Responsive Calcs
    final size = MediaQuery
        .of(context)
        .size;
    final bool isTablet = size.shortestSide > 600;
    final bool isDesktop = size.width >= 800; // [NEW] Desktop breakpoint
    final double buttonSize = isTablet ? 48.0 : 42.0;
    final double iconSize = isTablet ? 26.0 : 22.0;

    // State Checks
    final bool isChatActive = conversation.messages.isNotEmpty;
    final bool isSubscribed = userProvider.isSubscriptionActive;
    final bool showCenterButton =
        (!isSubscribed || userProvider.isAnonymous) && !isChatActive;

    // --- GLOBAL APP BAR IMPLEMENTATION ---
    return CortexAppBar(
      // Hide leading button on desktop since sidebar is fixed
      leadingMode: isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,

      // 1. Left Button: Sidebar Toggle
      onLeadingPressed: () => mainScreenKey.currentState?.toggleAxon(),

      // 2. Center: Premium Button (or empty)
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: showCenterButton
            ? (userProvider.isAnonymous
            ? LoginBubbleButton(
          key: const ValueKey('LoginBtn'),
          onTap: () {
            final target = const UpgradeAccountScreen(showLoginFirst: true);
            navigateToScreen(target, direction: const Offset(0.0, 1.0));
            FocusScope.of(context).unfocus();
          },
        )
            : PremiumButton(
          key: const ValueKey('PremiumBtn'),
          onTap: () {
            final target = const FundsScreen();
            navigateToScreen(target, direction: const Offset(1.0, 0.0));
            FocusScope.of(context).unfocus();
          },
        ))
            : const SizedBox.shrink(),
      ),

      // 3. Right Action: The Dual-Action Pill
      actionButton: DualActionPill(
        size: buttonSize,
        // If chat is active, we go DUAL mode.
        // If chat is empty, we go SINGLE mode (Flux Toggle).
        isDual: isChatActive,

        // --- MAIN ICON (Right Side) ---
        // If chat active -> New Chat Icon
        // If chat empty -> Flux Icon (On/Off)
        mainIcon: isChatActive
            ? SvgPicture.asset(
          'assets/icons/new.svg',
          key: const ValueKey('new_chat_icon'),
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        )
            : SvgPicture.asset(
          session.isFluxMode
              ? 'assets/icons/on/ghost.svg'
              : 'assets/icons/off/ghost.svg',
          key: ValueKey('ghost_${session.isFluxMode}'),
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
        onMainTap: () {
          if (isChatActive) {
            _handleNewChat(context);
          } else {
            _handleFluxModeToggle(context);
          }
        },

        // --- SECONDARY ICON (Left Side) ---
        // Only visible when isDual is true (Chat Active).
        // This is the Share button.
        secondaryIcon: SvgPicture.asset(
          'assets/icons/world.svg',
          width: iconSize - 2,
          height: iconSize - 2,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
        ),
        onSecondaryTap: () => _handleShare(context),
      ),
    );
  }
}
