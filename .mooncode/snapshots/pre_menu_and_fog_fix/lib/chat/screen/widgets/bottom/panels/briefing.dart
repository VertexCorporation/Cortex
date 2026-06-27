// lib/chat/screen/selected/widgets/input/panels/briefing.dart

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/navigation.dart';
import 'package:provider/provider.dart';
import 'package:cortex/login/upgrade.dart';
import 'package:cortex/server/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../../theme.dart';

class BriefingOverlay extends StatefulWidget {
  final int? availableCredits;
  final int? availablePredits;
  final int? availableDredits;
  final bool photoSelected;
  final bool isOfflineModel;
  final bool modelMissing;
  final bool inappropriate;
  final bool limitReached;
  final bool isStorageSufficient;
  final bool isPremiumModel;
  final bool isSubscribed;
  final bool isDynamicChat;
  final bool isSearchEnabled;
  final bool isFalOffline;
  final bool isUserStateReady;
  final String? conversationId;

  final ValueChanged<double>? onVisibleHeightChanged;

  final bool isVideoModel;
  final int userTier;

  const BriefingOverlay({
    super.key,
    required this.availableCredits,
    required this.availablePredits,
    required this.availableDredits,
    required this.photoSelected,
    required this.isOfflineModel,
    required this.modelMissing,
    required this.inappropriate,
    required this.limitReached,
    required this.isStorageSufficient,
    required this.isPremiumModel,
    required this.isVideoModel,
    required this.isSubscribed,
    required this.userTier,
    required this.isDynamicChat,
    required this.isSearchEnabled,
    required this.isFalOffline,
    required this.isUserStateReady,
    required this.conversationId,
    this.onVisibleHeightChanged,
  });

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  String? _currentMessageText;
  bool _dynamicPreditsBriefingPrefsLoaded = false;
  bool _hasShownInitialDynamicPreditsBriefing = false;
  bool _shouldShowDynamicPreditsBriefing = false;
  int _dynamicChatEntriesSincePreditsBriefing = 0;
  String? _lastCountedDynamicPreditsConversationId;

  final GlobalKey _panelKey = GlobalKey();
  double _measuredPanelHeight = 0.0;
  double _lastReportedVisibleHeight = -1.0;
  double? _pendingVisibleHeight;
  bool _isVisibleHeightReportQueued = false;

  static const Duration _animationDuration = Duration(milliseconds: 300);

  bool get _isPremiumUpgradeMessage {
    if (widget.isDynamicChat) return false;
    if (widget.isSubscribed || !widget.isPremiumModel) return false;
    // Free user using a premium model requires at least 10 predits
    return (widget.availablePredits ?? 0) < 10;
  }

  bool get _isDynamicPreditsUpgradeMessage {
    if (widget.isSubscribed || !widget.isDynamicChat) return false;
    final predits = widget.availablePredits;
    if (predits == null) return false;
    return predits <= 0;
  }

  static const String _dynamicPreditsInitialShownKey =
      'dynamic_predits_upgrade_initial_shown';
  static const String _dynamicPreditsEntryCountKey =
      'dynamic_predits_upgrade_entry_count';
  static const String _dynamicPreditsLastConversationKey =
      'dynamic_predits_upgrade_last_conversation';

  @override
  void initState() {
    super.initState();

    _slideController =
        AnimationController(vsync: this, duration: _animationDuration);

    final curvedAnimation =
        CurvedAnimation(parent: _slideController, curve: Curves.easeOut);

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(curvedAnimation);

    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(curvedAnimation);

    _slideController.addListener(_reportVisibleHeightThrottled);

    unawaited(_loadDynamicPreditsBriefingPrefs());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _evaluateAndAnimate();
        _measurePanelHeightAndReport();
      }
    });
  }

  @override
  void didUpdateWidget(covariant BriefingOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.conversationId != oldWidget.conversationId) {
      // Force re-evaluation and replay animation for new chats
      _currentMessageText = null;
      _slideController.value = 0.0;
    }
    if (widget.conversationId != oldWidget.conversationId ||
        widget.isUserStateReady != oldWidget.isUserStateReady ||
        widget.isDynamicChat != oldWidget.isDynamicChat ||
        widget.isSubscribed != oldWidget.isSubscribed ||
        widget.availablePredits != oldWidget.availablePredits) {
      unawaited(_updateDynamicPreditsBriefingGate());
    }
    _evaluateAndAnimate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measurePanelHeightAndReport();
    });
  }

  Future<void> _loadDynamicPreditsBriefingPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    _hasShownInitialDynamicPreditsBriefing =
        prefs.getBool(_dynamicPreditsInitialShownKey) ?? false;
    _dynamicChatEntriesSincePreditsBriefing =
        prefs.getInt(_dynamicPreditsEntryCountKey) ?? 0;
    _lastCountedDynamicPreditsConversationId =
        prefs.getString(_dynamicPreditsLastConversationKey);

    setState(() => _dynamicPreditsBriefingPrefsLoaded = true);
    await _updateDynamicPreditsBriefingGate();
  }

  bool get _isDynamicPreditsBriefingEligible {
    if (!widget.isUserStateReady) return false;
    if (!_dynamicPreditsBriefingPrefsLoaded) return false;
    if (widget.isSubscribed || !widget.isDynamicChat) return false;
    final predits = widget.availablePredits;
    return predits != null && predits <= 0;
  }

  Future<void> _resetDynamicPreditsBriefingAfterRecovery() async {
    if (!_dynamicPreditsBriefingPrefsLoaded) return;
    final predits = widget.availablePredits;
    if (widget.isSubscribed || predits == null || predits <= 0) return;
    if (!_hasShownInitialDynamicPreditsBriefing &&
        _dynamicChatEntriesSincePreditsBriefing == 0 &&
        _lastCountedDynamicPreditsConversationId == null &&
        !_shouldShowDynamicPreditsBriefing) {
      return;
    }

    _hasShownInitialDynamicPreditsBriefing = false;
    _dynamicChatEntriesSincePreditsBriefing = 0;
    _lastCountedDynamicPreditsConversationId = null;
    _shouldShowDynamicPreditsBriefing = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicPreditsInitialShownKey, false);
    await prefs.setInt(_dynamicPreditsEntryCountKey, 0);
    await prefs.remove(_dynamicPreditsLastConversationKey);
  }

  Future<void> _updateDynamicPreditsBriefingGate() async {
    if (!_dynamicPreditsBriefingPrefsLoaded || !mounted) return;

    if (!_isDynamicPreditsBriefingEligible) {
      await _resetDynamicPreditsBriefingAfterRecovery();
      if (!mounted) return;
      if (_shouldShowDynamicPreditsBriefing) {
        setState(() => _shouldShowDynamicPreditsBriefing = false);
        _evaluateAndAnimate();
      }
      return;
    }

    final conversationKey = widget.conversationId?.isNotEmpty == true
        ? widget.conversationId!
        : 'dynamic-new-chat';
    if (conversationKey == _lastCountedDynamicPreditsConversationId) {
      return;
    }

    bool shouldShowNow = false;
    if (!_hasShownInitialDynamicPreditsBriefing) {
      _hasShownInitialDynamicPreditsBriefing = true;
      _dynamicChatEntriesSincePreditsBriefing = 0;
      shouldShowNow = true;
    } else {
      _dynamicChatEntriesSincePreditsBriefing += 1;
      if (_dynamicChatEntriesSincePreditsBriefing >= 3) {
        _dynamicChatEntriesSincePreditsBriefing = 0;
        shouldShowNow = true;
      }
    }
    _lastCountedDynamicPreditsConversationId = conversationKey;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(
        _dynamicPreditsInitialShownKey, _hasShownInitialDynamicPreditsBriefing);
    await prefs.setInt(
        _dynamicPreditsEntryCountKey, _dynamicChatEntriesSincePreditsBriefing);
    await prefs.setString(_dynamicPreditsLastConversationKey, conversationKey);

    if (!mounted) return;
    setState(() => _shouldShowDynamicPreditsBriefing = shouldShowNow);
    _evaluateAndAnimate();
  }

  @override
  void dispose() {
    _slideController.removeListener(_reportVisibleHeightThrottled);
    _slideController.dispose();
    super.dispose();
  }

  String? _evaluateMessageText(AppLocalizations loc) {
    if (!widget.isUserStateReady) return null;

    if (widget.isDynamicChat) {
      if (widget.availableDredits != null && widget.availableDredits! < 1) {
        return loc.reachedLimit;
      }
      if (_isDynamicPreditsUpgradeMessage &&
          _shouldShowDynamicPreditsBriefing) {
        return loc.dynamicPreditsUpgradeMessage;
      }
      if (widget.limitReached) return loc.chatLengthLimitExceeded;
      return null;
    }

    if (widget.isVideoModel && widget.userTier != 3 && widget.userTier != 6) {
      return loc.videoPremiumWarning;
    }
    if (_isPremiumUpgradeMessage) return loc.premiumTrialExhaustedMessage;
    if (widget.inappropriate) return loc.inappropriateContentDetected;
    if (widget.limitReached) return loc.chatLengthLimitExceeded;
    if (!widget.isStorageSufficient) return loc.notEnoughStorage;
    if (widget.modelMissing) return loc.offlineModelNotInstalled;
    if (widget.isFalOffline) return loc.falOfflineMessage;

    if (widget.availableCredits != null &&
        _requiredCredits() > widget.availableCredits!) {
      return loc.reachedLimit;
    }
    return null;
  }

  void _evaluateAndAnimate() {
    if (!mounted) return;
    if (!widget.isUserStateReady) {
      if (_currentMessageText != null) {
        setState(() => _currentMessageText = null);
      }
      if (_slideController.value > 0.0) {
        _slideController.reverse().then((_) {
          if (mounted) _reportVisibleHeight();
        });
      } else {
        _scheduleVisibleHeightReport(0.0);
      }
      return;
    }

    final loc = AppLocalizations.of(context)!;
    final nextMessageText = _evaluateMessageText(loc);

    if (nextMessageText == _currentMessageText && _slideController.value > 0) {
      return;
    }

    if (nextMessageText != _currentMessageText) {
      final bool isShowingMessage = _slideController.value > 0.0;
      final bool hasNewMessage = nextMessageText?.trim().isNotEmpty == true;

      if (isShowingMessage) {
        _slideController.reverse().then((_) {
          if (!mounted) return;

          if (hasNewMessage) {
            setState(() {
              _currentMessageText = nextMessageText;
            });
            _slideController.forward(from: 0.0);
          } else {
            setState(() => _currentMessageText = null);
          }
          _measurePanelHeightAndReport();
        });
      } else if (hasNewMessage) {
        setState(() {
          _currentMessageText = nextMessageText;
        });
        _slideController.forward(from: 0.0);
        _measurePanelHeightAndReport();
      } else {
        setState(() {
          _currentMessageText = null;
        });
        _measurePanelHeightAndReport();
      }
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! > 0) {
      _handleDismiss();
    }
  }

  void _handleDismiss() {
    if (_slideController.isCompleted) {
      _slideController.reverse().then((_) {
        if (!mounted) return;
        setState(() {});
        _reportVisibleHeight();
      });
    }
  }

  void _measurePanelHeightAndReport() {
    final RenderBox? box =
        _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final newHeight = box?.size.height ?? 0.0;
    if (newHeight != _measuredPanelHeight) {
      _measuredPanelHeight = newHeight;
    }
    _reportVisibleHeight();
  }

  void _reportVisibleHeightThrottled() {
    _reportVisibleHeight();
  }

  void _reportVisibleHeight() {
    if (!mounted) return;
    final double base = _measuredPanelHeight;
    final double slideT = _slideController.value.clamp(0.0, 1.0);
    double visible = base * slideT;

    if (visible < 0.5) visible = 0.0;
    _scheduleVisibleHeightReport(visible);
  }

  void _scheduleVisibleHeightReport(double visible) {
    if (!mounted) return;
    if (_lastReportedVisibleHeight == visible &&
        _pendingVisibleHeight == null) {
      return;
    }

    _pendingVisibleHeight = visible;
    if (_isVisibleHeightReportQueued) return;
    _isVisibleHeightReportQueued = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isVisibleHeightReportQueued = false;
      if (!mounted) return;

      final double? pending = _pendingVisibleHeight;
      _pendingVisibleHeight = null;
      if (pending == null || pending == _lastReportedVisibleHeight) return;

      _lastReportedVisibleHeight = pending;
      widget.onVisibleHeightChanged?.call(pending);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isUserStateReady) {
      _scheduleVisibleHeightReport(0.0);
      return const SizedBox.shrink();
    }

    if (_currentMessageText == null ||
        _currentMessageText!.trim().isEmpty ||
        (_currentMessageText != null && _slideController.isDismissed)) {
      if (_measuredPanelHeight != 0 && _slideController.isDismissed) {
        _scheduleVisibleHeightReport(0.0);
      }
      if (_slideController.isDismissed) return const SizedBox.shrink();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.primaryDelta! > 0) {
              if (_measuredPanelHeight <= 0) return;
              final double nextValue = (_slideController.value -
                      (details.primaryDelta! / _measuredPanelHeight))
                  .clamp(0.0, 1.0);
              _slideController.value = nextValue;
            }
          },
          onVerticalDragEnd: _handlePanEnd,
          onTap: _handleDismiss,
          child: Builder(builder: (context) {
            final loc = AppLocalizations.of(context)!;
            final bool usesPremiumUpgradeVisuals =
                _isPremiumUpgradeMessage || _isDynamicPreditsUpgradeMessage;
            final bool isPremiumMessage =
                _currentMessageText == loc.videoPremiumWarning ||
                    _currentMessageText == loc.premiumTrialExhaustedMessage ||
                    _currentMessageText == loc.reachedLimit ||
                    _currentMessageText == loc.dynamicPreditsUpgradeMessage;
            return _BriefingPanelContent(
              key: _panelKey,
              message: _currentMessageText ?? "",
              isPremiumUpgradeMessage: usesPremiumUpgradeVisuals,
              isPremiumStyling: !widget.isSubscribed && isPremiumMessage,
            );
          }),
        ),
      ),
    );
  }

  int _requiredCredits() {
    if (widget.isOfflineModel || widget.isDynamicChat) {
      return 0; // Dynamic chat uses dredits
    }

    // Wait, is it Fal.ai? Currently we only know via photoSelected = true?
    // Actually, we don't have the model category here directly, but photoSelected gives a hint.
    // Fal default cut is 100.
    if (widget.photoSelected) {
      return 100;
    }

    int base = 20; // Default for text models (Premium or not)
    if (widget.isSearchEnabled) base += 5;
    return base;
  }
}

class _BriefingPanelContent extends StatefulWidget {
  final String message;
  final bool isPremiumUpgradeMessage;
  final bool isPremiumStyling;

  const _BriefingPanelContent({
    super.key,
    required this.message,
    required this.isPremiumUpgradeMessage,
    required this.isPremiumStyling,
  });

  @override
  State<_BriefingPanelContent> createState() => _BriefingPanelContentState();
}

class _BriefingPanelContentState extends State<_BriefingPanelContent>
    with SingleTickerProviderStateMixin {
  late final AnimationController _shineController;
  late final Animation<double> _shineAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _shineController, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) _shineController.forward(from: 0.0);
    });

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        _shineController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _shineController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  List<TextSpan> _parseMessage(String message, TextStyle defaultStyle) {
    final List<TextSpan> spans = [];
    final RegExp exp = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;
    for (final match in exp.allMatches(message)) {
      if (match.start > start) {
        spans.add(TextSpan(
            text: message.substring(start, match.start), style: defaultStyle));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: defaultStyle.copyWith(fontWeight: FontWeight.bold),
      ));
      start = match.end;
    }
    if (start < message.length) {
      spans.add(TextSpan(text: message.substring(start), style: defaultStyle));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool isTablet = screenWidth >= 600;
    final message = widget.message.trim();

    if (message.isEmpty) {
      return const SizedBox.shrink();
    }

    final double fontSize = isTablet ? screenWidth * 0.022 : 14.0;
    final double iconSize = isTablet ? screenWidth * 0.035 : 24.0;
    final double paddingHorizontal = isTablet ? screenWidth * 0.03 : 20.0;
    final double paddingVertical = isTablet ? screenWidth * 0.02 : 12.0;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 12.0;

    // The user requested that if the user is NOT subscribed, the briefing ALWAYS gets premium styling and is clickable.
    final bool showPremiumStyling = widget.isPremiumStyling;

    final Color baseColor = AppColors.premium.withValues(alpha: 0.15);
    final Color backgroundColor =
        Color.alphaBlend(baseColor, AppColors.background);
    final Color contentColor = AppColors.premium;
    final Color borderColor = baseColor.withValues(alpha: 0.8);

    final boxDecoration = BoxDecoration(
      color: showPremiumStyling ? backgroundColor : AppColors.background,
      border: Border.fromBorderSide(BorderSide(
          color: showPremiumStyling ? borderColor : AppColors.border)),
      borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );

    final textStyle = TextStyle(
      fontSize: fontSize,
      color:
          showPremiumStyling ? contentColor : AppColors.primaryColor.inverted,
    );

    // Use sparkle icon for premium upgrades or video block, otherwise warning
    final bool useSparkleIcon = widget.isPremiumUpgradeMessage ||
        widget.message == AppLocalizations.of(context)!.videoPremiumWarning;

    Widget innerContent = Container(
      padding: EdgeInsets.symmetric(
          vertical: paddingVertical, horizontal: paddingHorizontal),
      child: Row(
        children: [
          SvgPicture.asset(
            useSparkleIcon
                ? 'assets/icons/sparkle.svg'
                : 'assets/icons/warning.svg',
            colorFilter: ColorFilter.mode(
              showPremiumStyling
                  ? contentColor
                  : AppColors.primaryColor.inverted,
              BlendMode.srcIn,
            ),
            width: iconSize,
            height: iconSize,
          ),
          SizedBox(width: isTablet ? screenWidth * 0.02 : 12.0),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: _parseMessage(message, textStyle),
              ),
            ),
          ),
        ],
      ),
    );

    Widget content;

    if (showPremiumStyling) {
      content = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final userProvider = context.read<UserProvider>();
            if (userProvider.isAnonymous) {
              navigateToScreen(const UpgradeAccountScreen(showLoginFirst: true),
                  direction: const Offset(0, 1));
            } else {
              navigateToScreen(const FundsScreen(),
                  direction: const Offset(1.0, 0.0));
            }
            FocusScope.of(context).unfocus();
          },
          borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
          splashColor: contentColor.withValues(alpha: 0.1),
          highlightColor: contentColor.withValues(alpha: 0.05),
          child: Stack(
            children: [
              Ink(
                decoration: boxDecoration,
                child: innerContent,
              ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(borderRadius),
                  child: AnimatedBuilder(
                    animation: _shineAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset:
                            Offset(screenWidth * _shineAnimation.value, 0.0),
                        child: child,
                      );
                    },
                    child: Container(
                      width: screenWidth * 0.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                          stops: const [0.1, 0.5, 0.9],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      content = Container(
        decoration: boxDecoration,
        child: innerContent,
      );
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: content,
    );
  }
}
