// lib/axon/content.dart

import 'dart:math' as math;
import 'package:cortex/axon/inbox/logic/general.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../banner.dart';
import '../app.dart';
import '../chat/providers/session.dart';
import '../chat/services/storage.dart';
import '../fog.dart';
import '../l10n/app_localizations.dart';
import '../notifications/introvert.dart';
import '../server/user.dart';
import '../../chat/providers/conversation.dart';
import 'inbox/empty.dart';
import 'inbox/tile/view.dart';
import 'item.dart';

class AxonContent extends StatelessWidget {
  final double referenceWidth;
  final ScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final bool isSearchActive;
  final VoidCallback onNewChatTap;
  final VoidCallback onLibraryTap;
  final VoidCallback onNewsTap;
  final VoidCallback onSettingsTap;
  final VoidCallback onExitSearchTap;
  final ValueChanged<String> onSearchChanged;
  final int activeTab;
  final BannerService bannerService;

  const AxonContent({
    super.key,
    required this.referenceWidth,
    required this.scrollController,
    required this.searchController,
    required this.searchFocusNode,
    required this.isSearchActive,
    required this.onNewChatTap,
    required this.onLibraryTap,
    required this.onNewsTap,
    required this.onSettingsTap,
    required this.onExitSearchTap,
    required this.onSearchChanged,
    required this.activeTab,
    required this.bannerService,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final inboxViewModel = context.watch<InboxViewModel>();

    final conversationProvider = context.watch<ConversationProvider>();
    final String? currentConversationId = conversationProvider.conversationID;

    // Logic: Active Tab is Chat (0) AND no conversation loaded
    final bool isNewChatActive = (activeTab == 0) &&
        (currentConversationId == null || currentConversationId.isEmpty);

    final mediaQuery = MediaQuery.of(context);
    final screenHeight = mediaQuery.size.height;
    final double refWidth = referenceWidth;

    final double horizontalPadding = refWidth * 0.05;
    final double verticalSpacing = screenHeight * 0.005;
    final double searchBarHeight = screenHeight * 0.050;
    final double searchIconSize = refWidth * 0.06;
    final double brandIconHeight = screenHeight * 0.035;
    final double fontSizeBody = refWidth * 0.045;

    final bool isDarkMode = Theme
        .of(context)
        .brightness == Brightness.dark;
    final ColorFilter? smartCortexFilter = isDarkMode
        ? const ColorFilter.matrix([
      -1, 0, 0, 0, 255,
      0, -1, 0, 0, 255,
      0, 0, -1, 0, 255,
      0, 0, 0, 1, 0,
    ])
        : null;

    final List<String> displayConversations = inboxViewModel.conversations;
    final bool isEmpty = displayConversations.isEmpty;
    final bool hasSearchText = searchController.text
        .trim()
        .isNotEmpty;
    final bool showNoResults = isSearchActive && hasSearchText && isEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- 1. Header (Search + Brand) ---
        Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            screenHeight * 0.025,
            horizontalPadding * 1.5,
            screenHeight * 0.015,
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  height: searchBarHeight,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(refWidth * 0.06),
                    border: Border.all(
                      color: isSearchActive
                          ? AppColors.primaryColor.inverted
                          : AppColors.border.withValues(alpha: 0.3),
                      width: isSearchActive ? 1.0 : 0.5,
                    ),
                  ),
                  child: Center(
                    child: TextField(
                      controller: searchController,
                      focusNode: searchFocusNode,
                      style: TextStyle(
                        color: AppColors.primaryColor.inverted,
                        fontSize: fontSizeBody,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: localizations.searchHint,
                        hintStyle: TextStyle(
                          color: AppColors.tertiaryColor,
                          fontSize: fontSizeBody,
                        ),
                        prefixIcon: GestureDetector(
                          onTap: isSearchActive ? onExitSearchTap : null,
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            switchInCurve: Curves.easeOutBack,
                            switchOutCurve: Curves.easeIn,
                            transitionBuilder: (child, anim) {
                              return ScaleTransition(scale: anim, child: child);
                            },
                            child: isSearchActive
                                ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Transform.rotate(
                                angle: math.pi / 2,
                                child: SvgPicture.asset(
                                  'assets/icons/arrov.svg',
                                  key: const ValueKey('arrow'),
                                  width: searchIconSize,
                                  height: searchIconSize,
                                  colorFilter: ColorFilter.mode(
                                    AppColors.primaryColor.inverted,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                            )
                                : Icon(
                              Icons.search,
                              key: const ValueKey('search'),
                              size: searchIconSize,
                              color: AppColors.tertiaryColor,
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: onSearchChanged,
                    ),
                  ),
                ),
              ),

              // Brand Icon
              AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOutCubic,
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: isSearchActive ? 0 : null,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isSearchActive ? 0.0 : 1.0,
                    child: Row(
                      children: [
                        SizedBox(width: refWidth * 0.03),
                        SvgPicture.asset(
                          'assets/cortex.svg',
                          height: brandIconHeight,
                          colorFilter: smartCortexFilter,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // --- 2. Static Menu Items ---
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          reverseDuration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOutBack,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return SizeTransition(
              sizeFactor: animation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          child: isSearchActive
              ? const SizedBox.shrink()
              : Padding(
            padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding * 0.8),
            child: Column(
              children: [
                // --- NEW CHAT ---
                AxonItem(
                  label: localizations.newChat,
                  iconPath: 'assets/icons/chat.svg',
                  onTap: () {
                    FocusScope.of(context).unfocus();

                    final conversation = context.read<ConversationProvider>();
                    if (conversation.messages.isNotEmpty) {
                      context.read<ChatSessionProvider>().setFluxMode(false);
                      ChatStorageService.isFluxMode = false;
                    }
                    onNewChatTap();
                  },
                  screenHeight: screenHeight,
                  referenceWidth: refWidth,
                  reduceIconSize: true,
                  isActive: isNewChatActive,
                ),
                SizedBox(height: verticalSpacing),

                // --- LIBRARY ---
                AxonItem(
                  label: localizations.library,
                  iconPath: 'assets/icons/library.svg',
                  onTap: onLibraryTap,
                  screenHeight: screenHeight,
                  referenceWidth: refWidth,
                  reduceIconSize: true,
                  isActive: activeTab == 1,
                ),
                SizedBox(height: verticalSpacing),

                // --- NEWS ---
                AxonItem(
                  label: localizations.news,
                  iconPath: 'assets/icons/news.svg',
                  onTap: onNewsTap,
                  screenHeight: screenHeight,
                  referenceWidth: refWidth,
                  reduceIconSize: true,
                  isActive: activeTab == 2,
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),

        // --- 3. Chats Header ---
        if (!isSearchActive)
          Padding(
            padding: EdgeInsets.only(
              left: horizontalPadding * 1.5,
              right: horizontalPadding,
              top: 0,
              bottom: screenHeight * 0.008,
            ),
            child: Row(
              children: [
                Text(
                  localizations.chats,
                  style: GoogleFonts.roboto(
                    color: AppColors.tertiaryColor,
                    fontSize: fontSizeBody * 0.85,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(width: refWidth * 0.04),
                Expanded(
                  child: Container(
                    height: 0.8,
                    margin: EdgeInsets.only(right: horizontalPadding * 0.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333),
                      borderRadius: BorderRadius.circular(2.0),
                    ),
                  ),
                ),
              ],
            ),
          ),

// --- 4 & 5. Chat List & Floating Banner (OVERLAY FIX) ---
        Expanded(
          child: Stack(
            children: [
              // 4. CHAT LIST
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 150),
                  layoutBuilder:
                      (Widget? currentChild, List<Widget> previousChildren) {
                    return Stack(
                      alignment: Alignment.topCenter,
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
                  child: _buildContentBody(
                    inboxViewModel: inboxViewModel,
                    isEmpty: isEmpty,
                    showNoResults: showNoResults,
                    localizations: localizations,
                    refWidth: refWidth,
                    screenHeight: screenHeight,
                    scrollController: scrollController,
                    horizontalPadding: horizontalPadding,
                  ),
                ),
              ),

              // Fade Gradient
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: refWidth * 0.1,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.background.withValues(alpha: 0.0),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 5. INVITE BANNER
              Positioned(
                bottom: 0,
                left: horizontalPadding * 0.5,
                right: horizontalPadding * 0.5,
                child: ValueListenableBuilder<bool>(
                  valueListenable: bannerService.showInviteBannerNotifier,
                  builder: (context, showBanner, child) {
                    return FloatingInfoBanner(
                      bannerType: BannerType.inviteCredits,
                      isEmbedded: true,
                      referenceWidth: refWidth,
                      onDismissed: () {
                        bannerService.startCooldown();
                      },
                      onTap: () {
                        bannerService.generateAndShareInviteLink(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        // --- 6. Settings Footer ---
        _buildSettingsFooter(
          context,
          horizontalPadding,
          fontSizeBody,
          refWidth,
        ),
      ],
    );
  }

  Widget _buildContentBody({
    required InboxViewModel inboxViewModel,
    required bool isEmpty,
    required bool showNoResults,
    required AppLocalizations localizations,
    required double refWidth,
    required double screenHeight,
    required ScrollController scrollController,
    required double horizontalPadding,
  }) {
    if (inboxViewModel.isLoading) {
      return Center(
        key: const ValueKey('loading'),
        child: CircularProgressIndicator(
          strokeWidth: refWidth * 0.005,
          color: Colors.white30,
        ),
      );
    }

    if (isEmpty) {
      if (showNoResults) {
        return Padding(
          key: const ValueKey('no_results'),
          padding: EdgeInsets.only(top: screenHeight * 0.05),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/warning.svg',
                width: refWidth * 0.12,
                height: refWidth * 0.12,
                colorFilter: ColorFilter.mode(
                  AppColors.tertiaryColor.withValues(alpha: 0.4),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Text(
                localizations.noFoundTitle,
                style: GoogleFonts.roboto(
                  color: AppColors.primaryColor.inverted,
                  fontSize: refWidth * 0.045,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenHeight * 0.008),
              Text(
                localizations.noFoundMessage,
                style: GoogleFonts.roboto(
                  color: AppColors.tertiaryColor,
                  fontSize: refWidth * 0.038,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        return Center(
          key: const ValueKey('empty_state'),
          child: const EmptyStateView(isForStarred: false),
        );
      }
    }

    return ScrollFog(
      key: const ValueKey('list'),
      scrollController: scrollController,
      fogColor: AppColors.background,
      topFogHeight: 15,
      bottomFogHeight: 30,
      showTop: true,
      showBottom: true,
      child: ListView.builder(
        controller: scrollController,
        padding: EdgeInsets.fromLTRB(
          horizontalPadding * 0.5,
          screenHeight * 0.005,
          horizontalPadding * 0.5,
          screenHeight * 0.1,
        ),
        itemCount: inboxViewModel.conversations.length,
        itemBuilder: (context, index) {
          final id = inboxViewModel.conversations[index];
          final manager = inboxViewModel.conversationManagers[id];

          if (manager == null) return const SizedBox.shrink();

          return AxonConversationTile(
            key: ValueKey(id),
            manager: manager,
            onDelete: () {
              inboxViewModel.deleteConversation(id);
              Provider.of<IntrovertNotificationService>(context, listen: false)
                  .showNotification(
                message: localizations.conversationDeleted,
                type: NotificationType.success,
                isAxonMode: true,
                axonWidth: refWidth,
              );
            },
            onEdit: (newTitle) => inboxViewModel.editConversation(id, newTitle),
            onTogglePin: () => inboxViewModel.togglePinStatus(id),
          );
        },
      ),
    );
  }

  Widget _buildSettingsFooter(BuildContext context, double hPadding,
      double fontSize, double refWidth) {
    final userProvider = context.watch<UserProvider>();
    // Access ChatSessionProvider to check for active subscription
    final sessionProvider = context.watch<ChatSessionProvider>();
    final bool isUserSubscribed = sessionProvider.isUserSubscribed;

    final String name = userProvider.username;
    final String settingsText = AppLocalizations.of(context)!.settings;
    final localizations = AppLocalizations.of(context)!;

    // --- LOGIC: Initial for Anonymous User ---
    String initials;
    if (userProvider.isAnonymous) {
      // Get the localized "Anonymous" string and take the first letter
      final String anonString = localizations.anonymousEntity;
      initials = anonString.isNotEmpty ? anonString[0].toUpperCase() : '?';
    } else {
      initials = userProvider.profileInitial;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: hPadding * 0.8,
        vertical: 16.0,
      ),
      child: InkWell(
        onTap: onSettingsTap,
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.primaryColor.inverted.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.inverted.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              // --- UPDATED AVATAR WITH ANIMATION ---
              _AxonAvatar(
                initials: initials,
                isSubscribed: isUserSubscribed,
                size: refWidth * 0.11,
                fontSize: fontSize,
              ),
              SizedBox(width: refWidth * 0.04),
              Column(
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
                  SizedBox(height: 2),
                  Text(
                    settingsText,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: fontSize * 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- NEW WIDGET: Animated Avatar for Axon ---
class _AxonAvatar extends StatefulWidget {
  final String initials;
  final bool isSubscribed;
  final double size;
  final double fontSize;

  const _AxonAvatar({
    required this.initials,
    required this.isSubscribed,
    required this.size,
    required this.fontSize,
  });

  @override
  State<_AxonAvatar> createState() => _AxonAvatarState();
}

class _AxonAvatarState extends State<_AxonAvatar>
    with SingleTickerProviderStateMixin {
  late AnimationController _borderController;
  late Animation<double> _borderAnimation;

  @override
  void initState() {
    super.initState();
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _borderAnimation =
        Tween<double>(begin: 0, end: 2 * math.pi).animate(_borderController);

    if (widget.isSubscribed) {
      _borderController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant _AxonAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSubscribed && !oldWidget.isSubscribed) {
      _borderController.repeat();
    } else if (!widget.isSubscribed && oldWidget.isSubscribed) {
      _borderController.stop();
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget core = Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.quaternaryColor,
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
          width: 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        widget.initials,
        style: TextStyle(
          fontSize: widget.fontSize * 1.0,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryColor.inverted,
        ),
      ),
    );

    if (widget.isSubscribed) {
      return AnimatedBuilder(
        animation: _borderAnimation,
        builder: (context, child) {
          return CustomPaint(
            painter:
            AnimatedBorderPainter(animationValue: _borderAnimation.value),
            child: Padding(
              padding: const EdgeInsets.all(3.0), // Space for border
              child: child,
            ),
          );
        },
        child: core,
      );
    }

    return core;
  }
}

// --- PAINTER: Reused from Appbar ---
class AnimatedBorderPainter extends CustomPainter {
  final double animationValue;

  AnimatedBorderPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 2.0;
    final Rect rect = Offset.zero & size;
    final double radius = size.width / 2;

    // Gradient colors matching the Appbar implementation
    final List<Color> colors = [
      Colors.cyanAccent,
      Colors.purpleAccent,
      Colors.orangeAccent,
      Colors.cyanAccent,
    ];

    final Paint paint = Paint()
      ..shader = SweepGradient(
        colors: colors,
        startAngle: 0.0,
        endAngle: 2 * math.pi,
        transform: GradientRotation(animationValue),
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(Offset(radius, radius), radius - strokeWidth / 2, paint);
  }

  @override
  bool shouldRepaint(covariant AnimatedBorderPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}