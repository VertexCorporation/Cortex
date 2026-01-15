// lib/chat/screen/appbar/appbar.dart

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/premium.dart';
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
import '../../../../theme.dart';
import '../../../../main.dart';
import 'button.dart';

class Appbar extends StatefulWidget implements PreferredSizeWidget {
  final GlobalKey exitButtonKey;
  final VoidCallback onTitleTap;
  final String appTitle;
  final GlobalKey accountButtonKey;

  const Appbar({
    super.key,
    required this.exitButtonKey,
    required this.accountButtonKey,
    required this.onTitleTap,
    required this.appTitle,
  });

  @override
  State<Appbar> createState() => AppbarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 10);
}

class AppbarState extends State<Appbar> {
  bool _isSharing = false;

  void _handleFluxModeToggle(BuildContext context) {
    final session = context.read<ChatSessionProvider>();
    final conversation = context.read<ConversationProvider>();
    final bool newState = !session.isFluxMode;
    session.setFluxMode(newState);
    ChatStorageService.isFluxMode = newState;
    conversation.clearConversation();
  }

  Future<void> _handleShare(BuildContext context) async {
    if (_isSharing) return;
    _isSharing = true;
    try {
      final session = context.read<ChatSessionProvider>();
      final conversation = context.read<ConversationProvider>();
      final localizations = AppLocalizations.of(context)!;
      String headerModelName;
      try {
        headerModelName = session.isDynamicChat
            ? (localizations.dynamicChatTitle)
            : (session.modelTitle ?? 'AI');
      } catch (e) {
        headerModelName = session.modelTitle ?? 'Cortex';
      }
      final String userName = session.displayName ?? 'User';
      final String botName = session.isDynamicChat ? 'Cortex' : headerModelName;
      final StringBuffer buffer = StringBuffer();
      buffer.writeln('Cortex | $headerModelName');
      buffer.writeln();
      for (final msg in conversation.messages) {
        if (msg.isThinking) continue;
        if (msg.text
            .trim()
            .isEmpty && msg.photoPath == null) {
          continue;
        }
        if (msg.isUserMessage) {
          buffer.writeln('👤 $userName: ${msg.text}');
          if (msg.photoPath != null) buffer.writeln('📷 [Image]');
        } else {
          buffer.writeln('🤖 $botName: ${msg.text}');
        }
        buffer.writeln();
      }
      final String shareText = buffer.toString();
      const String shareSubject = 'Cortex';
      await SharePlus.instance.share(
          ShareParams(text: shareText, subject: shareSubject));
    } catch (e) {
      debugPrint("Share Error: $e");
    } finally {
      _isSharing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ChatSessionProvider>();
    final conversation = context.watch<ConversationProvider>();
    final userProvider = context.watch<UserProvider>();
    context.watch<ThemeProvider>();

    final size = MediaQuery
        .of(context)
        .size;
    final bool isTablet = size.shortestSide > 600;

    final double horizontalPadding = size.width * 0.045;
    final bool isChatActive = conversation.messages.isNotEmpty;
    final double iconSize = isTablet ? 26.0 : 22.0;

    // --- DECISION LOGIC ---
    final bool isSubscribed = userProvider.isSubscriptionActive;

    final bool shouldShowBanner = session.showPremiumBanner ||
        userProvider.isAnonymous;

    final bool showPremiumButton = !isSubscribed && shouldShowBanner;

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background,
              AppColors.background.withValues(alpha: 0.0),
            ],
            stops: const [0.2, 1.0],
          ),
        ),
      ),
      centerTitle: true,
      automaticallyImplyLeading: false,
      titleSpacing: 0,
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. LEFT BUTTON (Sidebar)
            AppBarButton(
              key: widget.exitButtonKey,
              onTap: () => mainScreenKey.currentState?.toggleAxon(),
              child: SvgPicture.asset(
                'assets/icons/sidebar.svg',
                width: iconSize,
                height: iconSize,
                colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted, BlendMode.srcIn),
              ),
            ),

            // 2. CENTER (Premium Button OR Title)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (Widget child,
                      Animation<double> animation) {
                    return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child));
                  },
                  child: showPremiumButton
                      ? PremiumButton(
                    key: const ValueKey('PremiumBtn'),
                    onTap: () {
                      final isAnonymous = context
                          .read<UserProvider>()
                          .isAnonymous;
                      final target = isAnonymous
                          ? const UpgradeAccountScreen()
                          : const FundsScreen();
                      navigateToScreen(target,
                          direction: const Offset(0.0, 1.0));
                      FocusScope.of(context).unfocus();
                    },
                  )
                      : const SizedBox.shrink(),
                ),
              ),
            ),

            // 3. RIGHT BUTTON (Action)
            AppBarButton(
              onTap: () {
                if (isChatActive) {
                  _handleShare(context);
                } else {
                  _handleFluxModeToggle(context);
                }
              },
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                switchInCurve: Curves.easeInOutBack,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return ScaleTransition(
                      scale: animation,
                      child: FadeTransition(opacity: animation, child: child));
                },
                child: isChatActive
                    ? SvgPicture.asset(
                  'assets/icons/share.svg',
                  key: const ValueKey('share'),
                  width: iconSize - size.width * 0.01,
                  height: iconSize - size.width * 0.01,
                  colorFilter: ColorFilter.mode(
                    AppColors.primaryColor.inverted,
                    BlendMode.srcIn,
                  ),
                )
                    : SvgPicture.asset(
                  session.isFluxMode
                      ? 'assets/icons/ghost.svg'
                      : 'assets/icons/ghostBordered.svg',
                  key: ValueKey('ghost_${session.isFluxMode}'),
                  width: iconSize,
                  height: iconSize,
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}