import 'package:cortex/design.dart';
// lib/chat/screen/selected/widgets/input/panels/briefing.dart

import 'dart:async';

import 'package:cortex/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/credits.dart';
import '../../../../../../theme.dart';

/// The logical identity of a briefing. Dismissal is tracked per kind, not
/// per rendered string: a ticking `{renewalTime}` countdown changes the text
/// but never the kind, so a dismissed briefing stays dead while its state
/// holds, while crossing into another band surfaces the new briefing.
/// Dismissed credit briefings additionally sit out a two-hour,
/// app-session-wide cooldown owned by the credit engine
/// (`CreditsManager.dismissCreditBriefing`), which survives every widget
/// lifecycle.
enum _BriefingKind {
  freeDeclining,
  paidUpgrade,
  ultraLow,
  exhausted,
  ultraExhausted,
  usageLimitReached,
  chatLengthLimit,
  videoPremium,
  premiumTrial,
  inappropriate,
  storage,
  modelMissing,
  falOffline,
}

class _BriefingResolution {
  const _BriefingResolution(this.kind, this.text);

  final _BriefingKind kind;
  final String text;
}

/// The credit briefings: the five kinds that render the live
/// `{renewalTime}` countdown. Dismissing one of them starts the
/// app-session-wide cooldown in `CreditsManager`; they also decide whether
/// the countdown timer runs.
const Set<_BriefingKind> _creditBriefingKinds = {
  _BriefingKind.freeDeclining,
  _BriefingKind.paidUpgrade,
  _BriefingKind.ultraLow,
  _BriefingKind.exhausted,
  _BriefingKind.ultraExhausted,
};

class BriefingOverlay extends StatefulWidget {
  final int? availableCredits;

  /// Server-published debt floor for the user's tier (`creditLimits.debtFloor`
  /// on the user doc, cached by `CreditsManager`). At or below it nothing is
  /// sendable; between it and zero only degraded Dynamic Chat remains.
  final int debtFloor;

  /// Instant of the next daily credit renewal, from
  /// `CreditsManager.nextDailyRenewal` (mirrors the server's cron). Rendered
  /// as the human-readable `{renewalTime}` countdown in credit briefings.
  final DateTime renewalAt;
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
  final SubscriptionTier userTier;

  const BriefingOverlay({
    super.key,
    required this.availableCredits,
    required this.debtFloor,
    required this.renewalAt,
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

  // Credit briefing dismissal cooldowns live in `CreditsManager` (the
  // engine owns the app-session-wide records); the tests drive them
  // through its debug hooks directly.

  @override
  State<BriefingOverlay> createState() => _BriefingOverlayState();
}

class _BriefingOverlayState extends State<BriefingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _slideController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  String? _currentMessageText;
  _BriefingKind? _currentKind;

  /// The non-credit kind the user dismissed (tap or downward swipe). It
  /// stays hidden across rebuilds and conversation switches until the
  /// underlying state resolves to a different kind. Credit briefings sit
  /// out the app-session-wide cooldown in `CreditsManager` instead: they
  /// become eligible again two hours after dismissal.
  _BriefingKind? _dismissedKind;

  /// Refreshes the visible `{renewalTime}` countdown without replaying the
  /// slide/fade. Runs only while a credit briefing is on screen; stopped
  /// as soon as it is dismissed, so a cooling briefing has no timer left
  /// that could pop it back open.
  Timer? _countdownTimer;

  final GlobalKey _panelKey = GlobalKey();
  double _measuredPanelHeight = 0.0;
  double _lastReportedVisibleHeight = -1.0;
  double? _pendingVisibleHeight;
  bool _isVisibleHeightReportQueued = false;

  static const Duration _animationDuration = Duration(milliseconds: 300);

  bool get _isPremiumUpgradeMessage {
    if (widget.isDynamicChat) return false;
    if (widget.isSubscribed || !widget.isPremiumModel) return false;
    // Free user using a premium model requires at least 10 credits
    return (widget.availableCredits ?? 0) < 10;
  }

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
      // Force re-evaluation and replay animation for new chats. Dismissed
      // messages stay dismissed: the state that produced them did not change.
      _currentMessageText = null;
      _currentKind = null;
      _slideController.value = 0.0;
    }
    _evaluateAndAnimate();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _measurePanelHeightAndReport();
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _slideController.removeListener(_reportVisibleHeightThrottled);
    _slideController.dispose();
    super.dispose();
  }

  _BriefingResolution? _resolveBriefing(AppLocalizations loc) {
    if (!widget.isUserStateReady) return null;

    final credits = widget.availableCredits;

    // At or below the debt floor nothing is sendable at all: the exhausted
    // briefing preempts every other consideration in both chat modes.
    if (credits != null && credits <= widget.debtFloor) {
      return _exhaustedBriefing(loc);
    }

    if (widget.isDynamicChat) {
      // Zero or negative but above the floor: Dynamic Chat stays open, the
      // server caps the lanes, and the tier decides the wording.
      if (credits != null && credits < 1) {
        return _decliningBriefing(loc);
      }
      if (widget.limitReached) {
        return _BriefingResolution(
            _BriefingKind.chatLengthLimit, loc.chatLengthLimitExceeded);
      }
      return null;
    }

    if (widget.isVideoModel && widget.userTier != SubscriptionTier.ultra) {
      return _BriefingResolution(
          _BriefingKind.videoPremium, loc.videoPremiumWarning);
    }
    if (_isPremiumUpgradeMessage) {
      return _BriefingResolution(
          _BriefingKind.premiumTrial, loc.premiumTrialExhaustedMessage);
    }
    if (widget.inappropriate) {
      return _BriefingResolution(
          _BriefingKind.inappropriate, loc.inappropriateContentDetected);
    }
    if (widget.limitReached) {
      return _BriefingResolution(
          _BriefingKind.chatLengthLimit, loc.chatLengthLimitExceeded);
    }
    if (!widget.isStorageSufficient) {
      return _BriefingResolution(
          _BriefingKind.storage, loc.notEnoughStorage);
    }
    if (widget.modelMissing) {
      return _BriefingResolution(
          _BriefingKind.modelMissing, loc.offlineModelNotInstalled);
    }
    if (widget.isFalOffline) {
      return _BriefingResolution(
          _BriefingKind.falOffline, loc.falOfflineMessage);
    }

    // Same credit bands as Dynamic Chat for manual models.
    if (credits != null && credits < 1) {
      return _decliningBriefing(loc);
    }
    if (credits != null && _requiredCredits() > credits) {
      return _BriefingResolution(
          _BriefingKind.usageLimitReached, loc.reachedLimit);
    }
    return null;
  }

  /// Full exhaustion: nothing is sendable until renewal. Ultra has no higher
  /// plan to sell, so its copy carries no upgrade nudge.
  _BriefingResolution _exhaustedBriefing(AppLocalizations loc) {
    final renewal = formatRenewalRemainingLocalized(
        widget.renewalAt.difference(DateTime.now()), loc);
    if (widget.userTier == SubscriptionTier.ultra) {
      return _BriefingResolution(_BriefingKind.ultraExhausted,
          loc.creditWarningUltraExhaustedMessage(renewal));
    }
    return _BriefingResolution(_BriefingKind.exhausted,
        loc.creditWarningExhaustedMessage(renewal));
  }

  /// Below zero but above the debt floor: intelligence is degraded but the
  /// conversation continues. Free, Plus and Pro see an upgrade nudge, Ultra
  /// gets the plain low-usage warning.
  _BriefingResolution _decliningBriefing(AppLocalizations loc) {
    final renewal = formatRenewalRemainingLocalized(
        widget.renewalAt.difference(DateTime.now()), loc);
    switch (widget.userTier) {
      case SubscriptionTier.free:
        return _BriefingResolution(_BriefingKind.freeDeclining,
            loc.creditWarningFreeDecliningMessage(renewal));
      case SubscriptionTier.plus:
      case SubscriptionTier.pro:
        return _BriefingResolution(_BriefingKind.paidUpgrade,
            loc.creditWarningPaidUpgradeMessage(renewal));
      case SubscriptionTier.ultra:
        return _BriefingResolution(
            _BriefingKind.ultraLow, loc.creditWarningUltraMessage(renewal));
    }
  }

  /// Whether a resolved briefing [kind] is currently hidden by a dismissal.
  /// Credit kinds sit out the app-session-wide two-hour window owned by the
  /// credit engine — no rebuild, input focus, chat switch or countdown tick
  /// can bypass it; every other kind keeps the widget-local
  /// hide-until-the-condition-changes behavior. Identity is the logical
  /// kind, never the rendered message, so the ticking countdown text cannot
  /// dodge a dismissal.
  bool _isSuppressed(_BriefingKind kind) {
    if (_creditBriefingKinds.contains(kind)) {
      return CreditsManager.instance.isCreditBriefingSuppressed(kind.name);
    }
    return kind == _dismissedKind;
  }

  void _evaluateAndAnimate() {
    if (!mounted) return;
    if (!widget.isUserStateReady) {
      _syncCountdownTimer(null);
      if (_currentMessageText != null || _currentKind != null) {
        setState(() {
          _currentMessageText = null;
          _currentKind = null;
        });
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
    final next = _resolveBriefing(loc);

    // Report the observed balance to the credit engine, which owns the
    // briefing cooldowns: only a *known healthy* balance clears dismissal
    // records there. A transient snapshot gap (unknown balance), a loading
    // state or a chat that resolves no briefing never does — this widget no
    // longer mutates any dismissal state itself.
    CreditsManager.instance.observeCreditBriefingState(
      credits: widget.availableCredits,
      debtFloor: widget.debtFloor,
    );

    // A dismissed briefing stays hidden: credit kinds sit out the
    // app-session-wide two-hour cooldown — input focus, rebuilds, chat
    // switches and countdown ticks re-run this evaluation but never bypass
    // it — while every other kind waits until its underlying state resolves
    // to something else. The ticking countdown text never resurrects either.
    if (next != null && _isSuppressed(next.kind)) {
      _syncCountdownTimer(null);
      if (_currentMessageText != null || _currentKind != null) {
        setState(() {
          _currentMessageText = null;
          _currentKind = null;
        });
      }
      if (_slideController.value > 0.0) {
        _slideController.reverse().then((_) {
          if (mounted) _reportVisibleHeight();
        });
      } else if (_measuredPanelHeight != 0.0) {
        _scheduleVisibleHeightReport(0.0);
      }
      return;
    }
    _dismissedKind = null;

    // Keep the visible countdown ticking while a credit briefing is shown.
    _syncCountdownTimer(next?.kind);

    // Same kind already on screen: refresh only the countdown text, never
    // replay the slide/fade — a minute tick is not a new briefing.
    if (next != null &&
        next.kind == _currentKind &&
        _slideController.value > 0.0) {
      if (next.text != _currentMessageText) {
        setState(() => _currentMessageText = next.text);
        _measurePanelHeightAndReport();
      }
      return;
    }

    // Nothing to show and nothing on screen: no transition needed.
    if (next == null && _currentKind == null) {
      return;
    }

    final bool isShowingMessage = _slideController.value > 0.0;
    final bool hasNewMessage = next?.text.trim().isNotEmpty == true;

    if (isShowingMessage) {
      _slideController.reverse().then((_) {
        if (!mounted) return;

        if (hasNewMessage) {
          setState(() {
            _currentMessageText = next!.text;
            _currentKind = next.kind;
          });
          _slideController.forward(from: 0.0);
        } else {
          setState(() {
            _currentMessageText = null;
            _currentKind = null;
          });
        }
        _measurePanelHeightAndReport();
      });
    } else if (hasNewMessage) {
      setState(() {
        _currentMessageText = next!.text;
        _currentKind = next.kind;
      });
      _slideController.forward(from: 0.0);
      _measurePanelHeightAndReport();
    } else {
      setState(() {
        _currentMessageText = null;
        _currentKind = null;
      });
      _measurePanelHeightAndReport();
    }
  }

  void _syncCountdownTimer(_BriefingKind? kind) {
    final needed = kind != null && _creditBriefingKinds.contains(kind);
    if (needed) {
      _countdownTimer ??= Timer.periodic(const Duration(seconds: 30), (_) {
        if (mounted) _evaluateAndAnimate();
      });
    } else {
      _countdownTimer?.cancel();
      _countdownTimer = null;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity ?? 0.0;
    if (velocity > 0.0) {
      // Fling down: dismiss, wherever the drag left the panel.
      _handleDismiss();
    } else if (velocity < 0.0) {
      _slideController.forward();
    } else if (_slideController.value < 0.5) {
      // Released below the halfway point: treat it as a dismissal.
      _handleDismiss();
    } else if (!_slideController.isCompleted) {
      _slideController.forward();
    }
  }

  void _handleDismiss() {
    if (_slideController.isDismissed) return;
    final kind = _currentKind;
    // Remember the dismissal, keyed to the logical kind so the ticking
    // countdown text never counts as a change. Credit briefings enter the
    // app-session-wide two-hour cooldown owned by the credit engine, which
    // survives every chat switch and overlay remount; every other kind
    // keeps the widget-local hide-until-the-condition-changes behavior.
    if (kind != null && _creditBriefingKinds.contains(kind)) {
      CreditsManager.instance.dismissCreditBriefing(kind.name);
    } else {
      _dismissedKind = kind;
    }
    // The panel is leaving the screen: its countdown timer goes with it.
    _syncCountdownTimer(null);
    _slideController.reverse().then((_) {
      if (!mounted) return;
      setState(() {});
      _reportVisibleHeight();
    });
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
            final bool usesPremiumUpgradeVisuals = _isPremiumUpgradeMessage;
            final bool isPremiumMessage = _currentKind != null &&
                switch (_currentKind!) {
                  _BriefingKind.videoPremium ||
                  _BriefingKind.premiumTrial ||
                  _BriefingKind.usageLimitReached ||
                  _BriefingKind.freeDeclining ||
                  _BriefingKind.paidUpgrade ||
                  _BriefingKind.ultraLow ||
                  _BriefingKind.exhausted ||
                  _BriefingKind.ultraExhausted =>
                    true,
                  _ => false,
                };
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
      return 0;
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
  Timer? _shineStartTimer;
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

    _shineStartTimer = Timer(const Duration(seconds: 1), () {
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
    _shineStartTimer?.cancel();
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
    final double paddingHorizontal = isTablet ? screenWidth * 0.03 : 20.0;
    final double paddingVertical = isTablet ? screenWidth * 0.02 : 12.0;
    final double borderRadius = isTablet ? screenWidth * 0.015 : 12.0;

    // The user requested that if the user is NOT subscribed, the briefing
    // ALWAYS gets premium styling. Tapping anywhere dismisses the panel.
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
            width: CortexDesign.icon,
            height: CortexDesign.icon,
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

    // The whole panel is dismissible via the enclosing GestureDetector;
    // tapping it never navigates, it fades the briefing away.
    Widget content;

    if (showPremiumStyling) {
      content = Stack(
        children: [
          Container(
            decoration: boxDecoration,
            child: innerContent,
          ),
          Positioned.fill(
            child: IgnorePointer(
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
          ),
        ],
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
