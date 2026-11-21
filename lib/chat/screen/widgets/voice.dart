// lib/chat/screen/widgets/voice.dart
//
// VOICE MODE V2 — the orb experience.
//
// Compact mode: a small shader orb floats just ABOVE the composer, anchored
// to its top edge (attachments/edit growing the panel push the orb up;
// briefing visibility does not affect it). Voice is autonomous — there is no
// center microphone button; the user simply speaks, and genuine speech can
// interrupt the assistant (the barge-in detector).
//
// Voice entry transforms the composer into Flow/X immediately. Compact and
// expanded presentations share those controls; only X restores text input.
// Orb taps change geometry without affecting composer state.
//
// No transcript or countdown is overlaid on the stage. A compact status and
// live level meter make capture, thinking and playback visible while Voice
// Mode V2 rides the NORMAL chat pipeline — STT
// commits a real user bubble, the AI reply lands as a normal message
// and TTS speaks it — so the conversation behind the dim IS the
// transcript. Fullscreen keeps only the orb; tapping the orb again
// collapses back to compact; X exits Voice Mode entirely.
//
// The old center-microphone / waveform overlay is intentionally GONE — the
// GPU orb (see voice_orb.dart + shaders/voice_orb.frag) is the primary
// experience now.

import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/services/flow.dart';
import 'package:cortex/chat/services/tts_remote.dart';
import 'package:cortex/chat/screen/widgets/voice_orb.dart';
import 'package:cortex/funds/funds.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:cortex/navigation.dart';
import 'package:cortex/server/subscription.dart';
import 'package:cortex/server/user.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

/// Palette per Flow participant. The product's four model identities —
/// red, blue, green, yellow — as SOFT pastel base palettes: the same sealed
/// liquid-sphere style stays, never a flat identity disc. The flow loop
/// cycles `currentFlowAgentIndex` (see VoiceService's
/// `setAiGenerationComplete`); the clamp + %-friendly length keep the
/// mapping stable as the participant set grows, and active-model changes
/// glide through the controller's palette interpolation.
List<Color> flowAgentPalettes() {
  return FlowParticipant.values
      .map((participant) => participant.color)
      .toList(growable: false);
}

/// The normal Voice Mode orb interior — the product reference palette: a
/// sealed soft pastel liquid sphere. Lavender, powder blue and blush pink
/// blend as the base fields; the pale-cyan vein and the warm cream breath
/// live inside the shader itself.
const Color voicePastelLavender = Color(0xFFC9B6F2);
const Color voicePastelPowderBlue = Color(0xFFAEC8F5);
const Color voicePastelBlushPink = Color(0xFFF3C3D9);

/// The server's terminal response wins. A healthy reserved window may keep
/// running even when the user snapshot shows no unreserved seconds left.
bool voiceAllowanceExhausted(VoiceService voice, UserProvider? user) {
  final allowance = user?.creditLimits.voiceDailySeconds;
  return voice.voiceLimitReached ||
      (!voice.isSessionActive &&
          allowance != null &&
          user!.voiceUsage.remainingToday(allowance) <= 0);
}

/// The plan the exhausted-allowance sheet pre-selects for this tier —
/// always the NEXT one up: Free → Plus, Plus → Pro, Pro → Ultra. Ultra has
/// nothing above it: null means the sheet must not open at all; the
/// exhausted orb's purple visual IS the affordance, and redirecting an
/// Ultra user to the funds screen would only re-sell the plan they
/// already hold.
String? voiceUpgradePlanType(SubscriptionTier tier) {
  switch (tier) {
    case SubscriptionTier.free:
      return 'plus';
    case SubscriptionTier.plus:
      return 'pro';
    case SubscriptionTier.pro:
      return 'ultra';
    case SubscriptionTier.ultra:
      return null;
  }
}

/// Opens the funds sheet on the plan the exhausted user should upgrade to
/// (see [voiceUpgradePlanType]). A null plan type — Ultra, which has
/// nothing above it — opens nothing at all.
void openVoiceUpgrade({required SubscriptionTier tier}) {
  final planType = voiceUpgradePlanType(tier);
  if (planType == null) return;
  navigateToScreen(
    FundsScreen(initialPlanType: planType),
    direction: const Offset(0, 1),
  );
}

class VoiceSessionOverlay extends StatefulWidget {
  const VoiceSessionOverlay({
    super.key,
    required this.active,
    required this.panelHeight,
    required this.bottomSafe,
    required this.onExited,
  });

  /// Whether Voice Mode is currently active (false while the exit
  /// animation is still playing).
  final bool active;

  /// The composer panel's live height — the orb anchors to the panel's top
  /// edge so attachments/edit growth pushes it up in real time.
  final ValueListenable<double> panelHeight;

  /// Bottom safe-area inset (the panel height excludes it).
  final double bottomSafe;

  /// Fired when the exit animation has fully faded the overlay away — the
  /// host then unmounts it.
  final VoidCallback onExited;

  @override
  State<VoiceSessionOverlay> createState() => _VoiceSessionOverlayState();
}

class _VoiceSessionOverlayState extends State<VoiceSessionOverlay>
    with TickerProviderStateMixin {
  /// Compact -> fullscreen expansion. Drives the orb geometry AND the
  /// shader's internal energy (uExpand) — one clock for both.
  late final AnimationController _expandController;

  /// Entry/exit presence: the orb scales up + fades in above the composer,
  /// and reverses on exit.
  late final AnimationController _presenceController;

  late final VoiceOrbController _orb;

  /// Mic-level feed: raw SoundService notifications are pushed straight
  /// into the controller (no setState, no widget rebuilds at frame rate).
  SpeechService? _speechService;
  final RemoteTtsService _tts = RemoteTtsService.instance;
  bool _disposed = false;

  static const double _compactOrbSize = 64.0;
  static const double _orbGapAboveComposer = 10.0;

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    )..addListener(_syncExpandToShader);
    _presenceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _orb = VoiceOrbController(vsync: this);
    _tts.outputLevel.addListener(_onOutputLevel);
    _orb.load();
    if (widget.active) {
      _presenceController.forward();
    } else {
      _presenceController.value = 1;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final speech = _speechService;
    if (speech != null) return;
    final attached = Provider.of<SpeechService>(context, listen: false);
    _speechService = attached;
    attached.addListener(_onSpeechLevel);
  }

  void _onSpeechLevel() {
    if (_disposed) return;
    final speech = _speechService;
    if (speech == null) return;
    // Only the user's microphone drives the mic uniform; while the
    // assistant speaks the level is dominated by speaker bleed and the
    // shader's speaking envelope is the signal instead.
    if (_orb.phase == VoiceOrbPhase.listening) {
      _orb.setMicLevel(speech.soundLevel);
    } else {
      _orb.setMicLevel(0);
    }
  }

  void _onOutputLevel() {
    if (_disposed) return;
    // Output samples are meaningful only once the voice pipeline has entered
    // the speaking state.  Startup must remain visually dormant even if a
    // stale player callback arrives while the socket is connecting.
    _orb.setOutputLevel(
      _orb.phase == VoiceOrbPhase.speaking ? _tts.outputLevel.value : 0,
    );
  }

  @override
  void didUpdateWidget(VoiceSessionOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _presenceController.forward();
    } else {
      _presenceController.reverse().whenCompleteOrCancel(() {
        if (mounted) widget.onExited();
      });
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _speechService?.removeListener(_onSpeechLevel);
    _tts.outputLevel.removeListener(_onOutputLevel);
    _expandController.dispose();
    _presenceController.dispose();
    _orb.dispose();
    super.dispose();
  }

  void _syncExpandToShader() {
    _orb.setExpandProgress(
      Curves.easeInOutCubic.transform(_expandController.value),
    );
  }

  void _toggleFullscreen() {
    HapticFeedback.lightImpact();
    final voice = context.read<VoiceService>();
    final user = context.read<UserProvider?>();
    if (voiceAllowanceExhausted(voice, user)) {
      // Tier-correct routing: Free → Plus, Plus → Pro, Pro → Ultra. An
      // Ultra user is already at the top — openVoiceUpgrade no-ops and the
      // tap stays on the exhausted orb instead of re-selling their own
      // plan.
      openVoiceUpgrade(
        tier: user?.subscription.effectiveTier ?? SubscriptionTier.free,
      );
      return;
    }
    if (voice.state == VoiceState.failed) {
      // The failed orb is the retry affordance: tapping it reopens the
      // session (no separate center microphone button exists in V2).
      voice.startListening(context: context);
      return;
    }
    final input = context.read<InputProvider>();
    final goingFullscreen = !input.isVoiceOverlayExpanded;
    if (goingFullscreen) {
      _expandController.forward();
      input.setVoiceOverlayExpanded(true);
    } else {
      _expandController.reverse();
      input.setVoiceOverlayExpanded(false);
    }
  }

  /// Maps the voice session state onto the orb's visual phase + palette.
  /// Controller setters are idempotent and do not notify, so calling them
  /// from build is cheap; the palette glide happens on the controller's
  /// own ticker.
  void _syncOrbInputs(VoiceService voiceService) {
    final state = voiceService.state;
    final isFlow = voiceService.isFlowActive;

    VoiceOrbPhase phase;
    var intensity = 1.0;
    var multicolor = 0.0;

    if (isFlow) {
      // Flow: the AI-to-AI loop. The active model identity recolors the
      // BASE INTERNAL palette — the soft liquid-sphere style itself never
      // changes, so the orb is never a flat red/blue/green/yellow disc
      // (see flowAgentPalettes; active-model transitions glide through
      // the controller's interpolation).
      final palettes = flowAgentPalettes();
      final agent = voiceService.currentFlowAgentIndex.clamp(
        0,
        palettes.length - 1,
      );
      final activeColor = palettes[agent];
      _orb.setPalette(
        primary: activeColor,
        secondary: voicePastelLavender,
        accent: voicePastelBlushPink,
      );
      switch (state) {
        case VoiceState.listening:
          // Flow's listening window is the interruption slot: translucent,
          // multicolor, alive — but never a plain "listening" look.
          phase = VoiceOrbPhase.flow;
          multicolor = 1.0;
          intensity = 0.9;
          _orb.setPalette(
            primary: FlowParticipant.blue.color,
            secondary: Color.lerp(
              FlowParticipant.red.color,
              FlowParticipant.yellow.color,
              0.5,
            )!,
            accent: FlowParticipant.green.color,
          );
        case VoiceState.processing:
          phase = VoiceOrbPhase.flow;
          intensity = 0.85;
        case VoiceState.speaking:
          phase = VoiceOrbPhase.speaking;
        case VoiceState.connecting:
          phase = VoiceOrbPhase.connecting;
          intensity = 0.16;
        case VoiceState.failed:
          phase = VoiceOrbPhase.subdued;
          intensity = 0.35;
        case VoiceState.idle:
          phase = VoiceOrbPhase.subdued;
          intensity = 0.5;
      }
    } else {
      // The reference look: a soft pastel liquid sphere — lavender, powder
      // blue and blush pink fields blending inside the sealed circle.
      _orb.setPalette(
        primary: voicePastelLavender,
        secondary: voicePastelPowderBlue,
        accent: voicePastelBlushPink,
      );
      switch (state) {
        case VoiceState.listening:
          phase = VoiceOrbPhase.listening;
        case VoiceState.processing:
          phase = VoiceOrbPhase.thinking;
          intensity = 0.85;
        case VoiceState.speaking:
          phase = VoiceOrbPhase.speaking;
        case VoiceState.connecting:
          phase = VoiceOrbPhase.connecting;
          intensity = 0.45;
        case VoiceState.failed:
          phase = VoiceOrbPhase.subdued;
          intensity = 0.35;
        case VoiceState.idle:
          phase = VoiceOrbPhase.subdued;
          intensity = 0.5;
      }
    }

    if (phase == VoiceOrbPhase.connecting) {
      // Keep the startup orb recognizably Cortex while it wakes, but strongly
      // desaturate it and avoid implying that the microphone is ready.
      _orb.setPalette(
        primary: Color.lerp(voicePastelLavender, AppColors.border, 0.68)!,
        secondary: Color.lerp(voicePastelPowderBlue, AppColors.border, 0.68)!,
        accent: Color.lerp(voicePastelBlushPink, AppColors.border, 0.72)!,
      );
    }

    if (voiceAllowanceExhausted(voiceService, context.read<UserProvider?>())) {
      _orb.setPalette(
        primary: const Color(0xFFAB7BE3),
        secondary: const Color(0xFFC3A0ED),
        accent: const Color(0xFFD8B5F2),
      );
      phase = VoiceOrbPhase.subdued;
      intensity = 1.0;
      multicolor = 0.0;
    }
    _orb.setPhase(phase);
    _orb.setIntensity(intensity);
    _orb.setMulticolor(multicolor);
  }

  @override
  Widget build(BuildContext context) {
    context.watch<UserProvider?>();
    final voiceService = context.watch<VoiceService>();
    _syncOrbInputs(voiceService);

    final safeTop = MediaQuery.paddingOf(context).top;
    // The host shrinks while the keyboard closes. Use its actual bounds so
    // the capsule and orb share coordinates throughout focused entry.
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        final usableHeight = (size.height - safeTop - widget.bottomSafe).clamp(
          0.0,
          double.infinity,
        );
        final textScale = MediaQuery.textScalerOf(context).scale(1.0);
        final estimatedStatusHeight = 36 * textScale + 18;
        // In a short landscape viewport, treat the status and orb as one
        // centered stack and reserve room for both plus their spacing.
        final desiredOrbSize = math.min(
          224.0,
          math.min(size.width * 0.70, usableHeight * 0.78),
        );
        final shortStage =
            usableHeight < desiredOrbSize + estimatedStatusHeight + 28;
        final fullOrbSize = shortStage
            ? math.min(
                desiredOrbSize,
                math.max(0.0, usableHeight - estimatedStatusHeight - 28),
              )
            : desiredOrbSize;

        return AnimatedBuilder(
          animation: Listenable.merge([
            _presenceController,
            _expandController,
            widget.panelHeight,
          ]),
          builder: (context, _) {
            // SCALE keeps the playful easeOutBack overshoot (~1.05x near the
            // end of the animation). Every OPACITY must use a monotonic 0..1
            // curve instead: easeOutBack overshoots past 1.0 and `Opacity`
            // asserts [0.0, 1.0], which crashed the overlay mid-entry AND
            // mid-exit on device (entry and exit both pass through the
            // overshoot region). Fullscreen's `expandT * presence` product
            // stays <= 1.0 for the same reason — both factors monotonic.
            final presenceScale = Curves.easeOutBack.transform(
              _presenceController.value,
            );
            final presence = Curves.easeOutCubic.transform(
              _presenceController.value,
            );
            final expandT = Curves.easeInOutCubic.transform(
              _expandController.value,
            );
            final orbSize = lerpDouble(_compactOrbSize, fullOrbSize, expandT)!;

            // COMPACT anchor: the composer panel's top edge. Live height means
            // attachments/edit growth pushes the orb upward frame-accurately;
            // briefing visibility is not part of the equation at all.
            final composerTop =
                size.height - widget.bottomSafe - widget.panelHeight.value;
            final compactCenter = Offset(
              size.width / 2,
              composerTop - _orbGapAboveComposer - orbSize / 2,
            );
            // FULLSCREEN anchor: the true vertical center of the SafeArea —
            // notch-aware via MediaQuery top, home-indicator-aware via the
            // same bottomSafe inset that anchors compact mode — so the orb
            // never rides high under the notch the way the old raw
            // 0.40·height fraction did.
            final fullCenter = Offset(
              size.width / 2,
              shortStage
                  ? safeTop + 8 + estimatedStatusHeight + 12 + fullOrbSize / 2
                  : safeTop + (size.height - safeTop - widget.bottomSafe) / 2,
            );
            final collapseOrigin = Offset(
              size.width / 2,
              composerTop + widget.panelHeight.value / 2 - 18,
            );
            final entryCenter = Offset.lerp(
              collapseOrigin,
              compactCenter,
              presence,
            )!;
            final center = Offset.lerp(entryCenter, fullCenter, expandT)!;
            // The status stays above the orb throughout the geometry
            // transition, so it moves continuously without changing sides.
            final statusTop = math.max(
              safeTop + 8,
              center.dy - orbSize / 2 - estimatedStatusHeight - 12,
            );

            return IgnorePointer(
              // The overlay owns no interaction while it has fully faded out.
              ignoring: _presenceController.isDismissed,
              child: Stack(
                children: [
                  // The orb: one widget instance from compact through fullscreen
                  // — the controller keeps shader phase/state continuity while
                  // only its geometry lerps.
                  Positioned(
                    left: center.dx - orbSize / 2,
                    top: center.dy - orbSize / 2,
                    child: Transform.scale(
                      // Scale is the one place the easeOutBack overshoot is
                      // welcome (a slight 1.05x pop as the orb settles in).
                      scale: 0.15 + 0.85 * presenceScale,
                      child: Opacity(
                        opacity: presence,
                        child: VoiceOrb(
                          controller: _orb,
                          size: orbSize,
                          onTap: _toggleFullscreen,
                        ),
                      ),
                    ),
                  ),
                  if (voiceService.state != VoiceState.idle)
                    Positioned(
                      left: 0,
                      right: 0,
                      top: statusTop,
                      child: IgnorePointer(
                        child: Opacity(
                          opacity: presence,
                          child: Center(
                            child: _VoiceStatusIndicator(
                              controller: _orb,
                              state: voiceService.state,
                              voiceLimitReached: voiceService.voiceLimitReached,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

/// A clear, live status for the shared iOS/Android voice surface. The meter
/// listens directly to the orb's smoothed microphone/output envelope, so it
/// animates without rebuilding the rest of the chat screen.
class _VoiceStatusIndicator extends StatelessWidget {
  const _VoiceStatusIndicator({
    required this.controller,
    required this.state,
    required this.voiceLimitReached,
  });

  final VoiceOrbController controller;
  final VoiceState state;
  final bool voiceLimitReached;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final label = switch (state) {
      VoiceState.connecting => l10n.voiceConnecting,
      VoiceState.listening => l10n.listening,
      VoiceState.processing => l10n.thinking,
      VoiceState.speaking => l10n.voiceSpeaking,
      VoiceState.failed =>
        voiceLimitReached ? l10n.voiceDailyLimitReached : l10n.voiceUnavailable,
      VoiceState.idle => '',
    };
    // The voice capsule is deliberately pure Cortex monochrome in every
    // theme: black glass, white content, neutral border. The liquid orb can
    // remain expressive without making the controls look like a foreign UI.
    const foreground = Color(0xFFF4F4F4);
    const capsuleBackground = Color(0xFF090909);
    const capsuleBorder = Color(0xFF2C2C2C);

    return Semantics(
      container: true,
      excludeSemantics: true,
      liveRegion: true,
      label: label,
      child: ConstrainedBox(
        key: const ValueKey('voice_live_status'),
        constraints: BoxConstraints(
          maxWidth: math.max(0.0, MediaQuery.sizeOf(context).width - 24),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 9),
          decoration: BoxDecoration(
            color: capsuleBackground.withValues(alpha: 0.97),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: capsuleBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxLabelWidth = math.max(48.0, constraints.maxWidth - 90);
              final icon = state == VoiceState.listening
                  ? Icon(Icons.mic_rounded, size: 17, color: foreground)
                  : state == VoiceState.speaking
                  ? Icon(Icons.volume_up_rounded, size: 17, color: foreground)
                  : SizedBox(
                      width: 17,
                      height: 17,
                      child: state == VoiceState.failed
                          ? Icon(
                              Icons.mic_off_rounded,
                              size: 17,
                              color: foreground,
                            )
                          : CircularProgressIndicator(
                              strokeWidth: 2,
                              color: foreground,
                            ),
                    );
              return Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 10,
                runSpacing: 4,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      icon,
                      const SizedBox(width: 8),
                      ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxLabelWidth),
                        child: Text(
                          label,
                          maxLines: 2,
                          softWrap: true,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: foreground,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                  _VoiceActivityBars(controller: controller, color: foreground),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _VoiceActivityBars extends StatelessWidget {
  const _VoiceActivityBars({required this.controller, required this.color});

  final VoiceOrbController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const ValueKey('voice_activity_bars'),
      width: 42,
      height: 20,
      child: CustomPaint(painter: _VoiceActivityPainter(controller, color)),
    );
  }
}

class _VoiceActivityPainter extends CustomPainter {
  _VoiceActivityPainter(this.controller, this.color)
    : super(repaint: controller);

  final VoiceOrbController controller;
  final Color color;
  static const _weights = [0.50, 0.76, 1.0, 0.76, 0.50];

  @override
  void paint(Canvas canvas, Size size) {
    final phase = controller.phase;
    final envelope = switch (phase) {
      VoiceOrbPhase.listening || VoiceOrbPhase.flow => controller.micSmooth,
      VoiceOrbPhase.speaking => controller.ttsSmooth,
      _ => 0.0,
    }.clamp(0.0, 1.0);
    final active =
        phase == VoiceOrbPhase.listening ||
        phase == VoiceOrbPhase.flow ||
        phase == VoiceOrbPhase.speaking;
    final paint = Paint()
      ..color = color.withValues(alpha: active ? 0.9 : 0.42)
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    final gap = 5.5;
    final barWidth = 2.4;
    final totalWidth = _weights.length * barWidth + (_weights.length - 1) * gap;
    final startX = (size.width - totalWidth) / 2 + barWidth / 2;

    for (var i = 0; i < _weights.length; i++) {
      final idleWave = 0.5 + 0.5 * math.sin(controller.timeSec * 5 + i * 0.9);
      final base = active ? 3.5 + idleWave * 2.5 : 3.5;
      final height = (base + envelope * 11 * _weights[i]).clamp(3.5, 17.0);
      final x = startX + i * (barWidth + gap);
      canvas.drawLine(
        Offset(x, (size.height - height) / 2),
        Offset(x, (size.height + height) / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _VoiceActivityPainter oldDelegate) =>
      oldDelegate.controller != controller || oldDelegate.color != color;
}
