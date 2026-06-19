import 'package:cortex/settings/controller.dart';
// lib/chat/screen/appbar/appbar.dart

import 'package:path/path.dart' as p;
import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/offer.dart';
import 'package:cortex/chat/screen/appbar/login.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/internet.dart';
import 'package:cortex/library/providers/catalog.dart';
import 'package:cortex/library/providers/local.dart';
import 'package:cortex/server/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

// Theme & Global Widgets
import '../../../../theme.dart';
import '../../../../main.dart';
import '../../../appbar.dart';
import '../widgets/bottom/input/buttons.dart';

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

  // --- LOGIC: Offline Mode Toggle ---
  void _handleOfflineModeToggle(BuildContext context, ChatSessionProvider session) {
    final catalog = context.read<ModelCatalogProvider>();
    final local = context.read<ModelLocalStateProvider>();
    final internet = context.read<InternetProvider>();
    final l10n = AppLocalizations.of(context)!;

    final isCurrentlyOffline = session.selectedModel?.type == 'offline';

    if (isCurrentlyOffline) {
      if (!internet.isConnected) {
        // Cannot switch to online without internet
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noInternetConnection),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.septenaryColor,
          ),
        );
        return;
      }
      HapticFeedback.lightImpact();
      catalog.startChatWithModel('cortex/auto');
    } else {
      final offlineModels = catalog.allModels.where((m) => m.type == 'offline');
      final downloadedModels = offlineModels.where((m) {
        final path = local.getFilePathById(m.id);
        return local.isModelOnDisk(path);
      }).toList();

      if (downloadedModels.isEmpty) {
        HapticFeedback.lightImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Aktif indirdiğiniz model bulunmamaktadır"),
            duration: const Duration(seconds: 2),
            backgroundColor: AppColors.septenaryColor,
          ),
        );
        return;
      }

      HapticFeedback.lightImpact();
      catalog.startChatWithModel(downloadedModels.first.id);
    }
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
        if (msg.text.trim().isEmpty && !msg.hasAttachments) {
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
    final size = MediaQuery.of(context).size;
    final bool isTablet = size.shortestSide > 600;
    final bool isDesktop = size.width >= 800; // [NEW] Desktop breakpoint
    final double buttonSize = isTablet ? 48.0 : 42.0;
    final double iconSize = isTablet ? 26.0 : 22.0;

    // State Checks
    final bool isChatActive = conversation.messages.isNotEmpty;
    final bool isUserStateReady = userProvider.isUserStateReady;
    final bool isAnonymous = userProvider.isAnonymous;
    final bool isSubscribed = userProvider.isSubscriptionActive;
    final bool showCenterButton =
        isUserStateReady && !isChatActive && (isAnonymous || !isSubscribed);

    // --- GLOBAL APP BAR IMPLEMENTATION ---
    return CortexAppBar(
      // Hide leading button on desktop since sidebar is fixed
      leadingMode: isDesktop ? CortexLeadingMode.none : CortexLeadingMode.auto,

      // 1. Left Button: Sidebar Toggle
      onLeadingPressed: () => mainScreenKey.currentState?.toggleAxon(),

      // Model Selection for Premium Users
      leadingActions: isSubscribed
          ? [
              ModelSelectButton(
                screenWidth: size.width,
                isTablet: isTablet,
                localizations: AppLocalizations.of(context)!,
              )
            ]
          : null,

      // 2. Center: Premium / Claim Offer / Login Button (or empty)
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: showCenterButton
            ? (isAnonymous
                ? LoginBubbleButton(
                    key: const ValueKey('LoginBtn'),
                    onTap: () {
                      final target =
                          const UpgradeAccountScreen(showLoginFirst: true);
                      navigateToScreen(target,
                          direction: const Offset(0.0, 1.0));
                      FocusScope.of(context).unfocus();
                    },
                  )
                : _buildOfferOrPremiumButton(context))
            : const SizedBox.shrink(),
      ),

      // 3. Right Action: The Dual-Action Pill
      actions: [
            DualActionPill(
              size: buttonSize,
              isDual: true,
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
              secondaryIcon: isChatActive
                  ? SvgPicture.asset(
                      'assets/icons/world.svg',
                      width: iconSize - 2,
                      height: iconSize - 2,
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor.inverted,
                        BlendMode.srcIn,
                      ),
                    )
                  : SvgPicture.asset(
                      'assets/icons/storage.svg',
                      key: ValueKey('offline_${session.selectedModel?.type == 'offline'}'),
                      width: iconSize - 2,
                      height: iconSize - 2,
                      colorFilter: ColorFilter.mode(
                        session.selectedModel?.type == 'offline'
                            ? AppColors.primaryColor.inverted
                            : AppColors.primaryColor.inverted.withValues(alpha: 0.5),
                        BlendMode.srcIn,
                      ),
                    ),
              onSecondaryTap: () {
                if (isChatActive) {
                  _handleShare(context);
                } else {
                  _handleOfflineModeToggle(context, session);
                }
              },
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                navigateToScreen(const SettingsScreen(), direction: const Offset(1.0, 0.0));
              },
              child: Container(
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  border: Border.all(color: AppColors.border, width: 2),
                  borderRadius: BorderRadius.zero,
                ),
                child: Center(
                  child: Text(
                    userProvider.profileInitial,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Impact',
                    ),
                  ),
                ),
              ),
            ),
          ]
    );
  }

  /// Shows "Claim Offer" button for non-subscribed users.
  Widget _buildOfferOrPremiumButton(BuildContext context) {
    return ClaimOfferButton(
      key: const ValueKey('ClaimOfferBtn'),
      onTap: () {
        final target = const FundsScreen();
        navigateToScreen(target, direction: const Offset(1.0, 0.0));
        FocusScope.of(context).unfocus();
      },
    );
  }
}
