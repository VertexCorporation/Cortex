// lib/chat/screen/appbar/appbar.dart

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/conversation.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/screen/appbar/offer.dart';
import 'package:cortex/chat/screen/appbar/login.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/library/backend/data/service.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/navigation.dart';

import 'package:cortex/server/user.dart';
import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

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
  bool _premiumDelayed = false;
  Timer? _premiumTimer;
  String? _lastModelId;

  @override
  void initState() {
    super.initState();
    _premiumDelayed = false;
  }

  @override
  void dispose() {
    _premiumTimer?.cancel();
    super.dispose();
  }

  void _resetPremiumDelay() {
    _premiumTimer?.cancel();
    setState(() => _premiumDelayed = false);
    _premiumTimer = Timer(const Duration(seconds: 8), () {
      if (mounted) setState(() => _premiumDelayed = true);
    });
  }

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

  // --- LOGIC: Start New Chat ---
  void _handleNewChat(BuildContext context) {
    // Calls the global key method to reset everything properly
    mainScreenKey.currentState?.startNewConversation(closeSidebar: false);
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

    final modelService = context.read<ModelService>();
    final resolvedImagePath = session.selectedModel != null
        ? modelService.getModelImagePath(session.selectedModel!)
        : null;

    final currentId = session.modelId;
    if (currentId != _lastModelId) {
      _lastModelId = currentId;
      if (session.selectedModel?.type == 'offline') {
        _resetPremiumDelay();
      } else {
        _premiumTimer?.cancel();
        _premiumDelayed = true;
      }
    }

    final bool effectiveShowCenter = showCenterButton && _premiumDelayed;

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

      // 2. Center: Premium / Claim Offer / Login Button XOR Model Info
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 100),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
        child: effectiveShowCenter
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
            : _ModelInfoChip(
                key: const ValueKey('ModelInfo'),
                modelTitle: session.modelTitle,
                imagePath: resolvedImagePath,
              ),
      ),

      // 3. Right Action: The Dual-Action Pill
      actionButton: DualActionPill(
        size: buttonSize,
        // Always dual mode now.
        isDual: false,

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
      ),
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

class _ModelInfoChip extends StatelessWidget {
  final String? modelTitle;
  final String? imagePath;

  const _ModelInfoChip({
    super.key,
    this.modelTitle,
    this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    final title = modelTitle;
    if (title == null || title.isEmpty) return const SizedBox.shrink();

    context.watch<ThemeProvider>();
    final iconSize = 26.0;
    final fontSize = 15.0;

    Widget icon;
    if (imagePath != null && imagePath!.isNotEmpty) {
      final isSvg = imagePath!.toLowerCase().endsWith('.svg');
      if (isSvg) {
        icon = SvgPicture.asset(
          imagePath!,
          width: iconSize,
          height: iconSize,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted,
            BlendMode.srcIn,
          ),
          fit: BoxFit.contain,
        );
      } else {
        icon = Image.asset(
          imagePath!,
          width: iconSize,
          height: iconSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _buildLetterIcon(title, iconSize),
        );
      }
    } else {
      icon = _buildLetterIcon(title, iconSize);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon,
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor.inverted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLetterIcon(String title, double size) {
    final letter = title.isNotEmpty ? title[0].toUpperCase() : 'M';
    final hue = letter.codeUnitAt(0) * 37 % 360;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: HSLColor.fromAHSL(1, hue.toDouble(), 0.5, 0.5).toColor(),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        letter,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.55,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
