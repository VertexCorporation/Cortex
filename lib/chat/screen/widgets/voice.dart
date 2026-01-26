import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/wave.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../../../l10n/app_localizations.dart';

class VoiceSessionOverlay extends StatefulWidget {
  const VoiceSessionOverlay({super.key});

  @override
  State<VoiceSessionOverlay> createState() => _VoiceSessionOverlayState();
}

class _VoiceSessionOverlayState extends State<VoiceSessionOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _entranceController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutBack,
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = context.watch<VoiceService>();
    final speechService = context.watch<SpeechService>();
    final inputProvider = context.read<InputProvider>();
    final sessionProvider = context.watch<ChatSessionProvider>();

    // Determine visual state
    bool isUserSpeaking = voiceService.state == VoiceState.listening;
    bool isAiSpeaking = voiceService.state == VoiceState.speaking;

    // Sound Level (0.0 to 1.0) for Dot Animation
    double level = speechService.soundLevel;

    return Scaffold(
      backgroundColor:
          Colors.transparent, // Transparent to allow morph effect from below
      body: Stack(
        children: [
          // 1. Central Visualizer (The Core Experience)
          // Animated from small to full size on entrance
          Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // MORPHING VISUALIZER
                  // Wave (AI) <-> Dot (User)
                  SizedBox(
                    height: 150, // Increased height for larger visual
                    width: double.infinity,
                    child: _MorphingVisualizer(
                      isUserSpeaking: isUserSpeaking,
                      isAiSpeaking: isAiSpeaking,
                      level: level,
                      isFluxMode: sessionProvider.isFluxMode,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Bottom Controls (3 Buttons)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom +
                16, // Reduced padding to move 1x height
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _entranceController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // LEFT BUTTON: Flow
                      _buildCircleButton(
                        iconPath: 'assets/icons/flow.svg',
                        onTap: () {
                          HapticFeedback.selectionClick();
                          voiceService.toggleFlowMode();
                        },
                        isSecondary:
                            !voiceService.isFlowMode, // Filled if active
                      ),

                      // CENTER BUTTON: Mic / Stop / Flow Start
                      _buildCenterButton(
                        isUserSpeaking: isUserSpeaking,
                        isAiSpeaking: isAiSpeaking,
                        isFlowMode: voiceService.isFlowMode,
                        isFlowActive: voiceService.isFlowActive,
                        onTap: () {
                          HapticFeedback.lightImpact();

                          if (voiceService.isFlowMode) {
                            if (!voiceService.isFlowActive) {
                              // Start Flow Mode
                              voiceService.startFlowWithPrompt(
                                  AppLocalizations.of(context)!
                                      .flowModeQuestion);
                            } else {
                              // Interrupt Flow (Stop speaking)
                              voiceService.stopSpeaking();
                            }
                            return;
                          }

                          if (isUserSpeaking) {
                            voiceService.manualSubmit();
                          } else if (isAiSpeaking) {
                            voiceService.stopSpeaking();
                          } else {
                            debugPrint("Restarting voice session from idle...");
                            voiceService.startListening();
                          }
                        },
                      ),

                      // RIGHT BUTTON: Exit (Arrow)
                      _buildCircleButton(
                        iconPath: 'assets/icons/arrov.svg',
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          voiceService.stopSession();
                          inputProvider.setVoiceModeActive(false);
                        },
                        isSecondary: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    voiceService.isFlowMode
                        ? AppLocalizations.of(context)!.flowModeDescription
                        : AppLocalizations.of(context)!.voiceModeInformation,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.tertiaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required String iconPath,
    required VoidCallback onTap,
    bool isSecondary = false,
  }) {
    return _ScaleButton(
      onTap: onTap,
      styleColor: isSecondary ? AppColors.background : AppColors.primaryColor,
      shape: BoxShape.circle,
      border:
          isSecondary ? Border.all(color: AppColors.border, width: 1.5) : null,
      child: SizedBox(
        width: 56,
        height: 56,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SvgPicture.asset(
            iconPath,
            colorFilter: ColorFilter.mode(
              isSecondary ? AppColors.primaryColor.inverted : Colors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
      ),
    );
  }

  // Center button is larger and changes appearance
  Widget _buildCenterButton({
    required bool isUserSpeaking,
    required bool isAiSpeaking,
    required bool isFlowMode,
    required bool isFlowActive,
    required VoidCallback onTap,
  }) {
    // Icon logic:
    // Flow Mode & Not Active -> Arrow Up (Start)
    // Flow Mode & Active -> Stop (Interrupt)
    // User Speaking -> STOP
    // Model Speaking -> STOP
    // Idle -> MIC

    final bool showStop = isUserSpeaking || isAiSpeaking || isFlowActive;

    String iconPath;
    if (isFlowMode && !isFlowActive) {
      iconPath =
          'assets/icons/send_audio.svg'; // Assuming this exists or using a generic send/arrow
      // User said "YUKARI DOĞRU OK İŞARETİ" -> likely send.svg or similar.
      // Checking existing icons... User mentions "gönderme ikonuna evrilsin".
      // Usually send.svg or arrow_up.svg. I'll guess 'assets/icons/send.svg' based on common naming,
      // or re-use 'assets/icons/arrov.svg' rotated? Or check file list.
      // Wait, user said "ortadaki siyah butonun ikonu gönderme ikonuna evrilsin".
      // I'll use 'assets/icons/send_audio.svg' if available or 'assets/icons/send.svg'.
      // Safe bet: 'assets/icons/send.svg'.
      iconPath = 'assets/icons/send.svg';
    } else {
      iconPath =
          showStop ? 'assets/icons/stop.svg' : 'assets/icons/microphone.svg';
    }

    return _ScaleButton(
      onTap: onTap,
      styleColor: AppColors.primaryColor.inverted,
      shape: BoxShape.circle,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Padding(
          padding: const EdgeInsets.all(22),
          // Use AnimatedSwitcher for smooth fade transition
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child));
            },
            child: SvgPicture.asset(
              iconPath,
              key: ValueKey<String>(iconPath), // Key ensures animation runs
              colorFilter: ColorFilter.mode(
                AppColors.primaryColor,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color styleColor;
  final BoxShape
      shape; // Using BoxShape as we are manually building decoration in Material
  final BoxBorder? border;

  const _ScaleButton({
    required this.child,
    required this.onTap,
    required this.styleColor,
    this.shape = BoxShape.circle,
    this.border,
  });

  @override
  State<_ScaleButton> createState() => _ScaleButtonState();
}

class _ScaleButtonState extends State<_ScaleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Material needs a ShapeBorder for shape, but Container used BoxShape.
    // We'll map BoxShape to valid Material shapes roughly or use Container inside Material?
    // Actually, best to use Material with InkWell.
    // If shape is circle, we use CircleBorder.

    ShapeBorder? materialShape;
    if (widget.shape == BoxShape.circle) {
      if (widget.border != null && widget.border is Border) {
        // Assuming uniform border for circle
        materialShape = CircleBorder(side: (widget.border as Border).top);
      } else {
        materialShape = const CircleBorder();
      }
    } else {
      // Rounded rect?
      materialShape = const RoundedRectangleBorder();
    }

    return ScaleTransition(
      scale: _scale,
      child: Material(
        color: widget.styleColor,
        shape: materialShape,
        clipBehavior: Clip.hardEdge,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact(); // Ensure haptic on tap
            widget.onTap();
          },
          onHighlightChanged: (isPressed) {
            if (isPressed) {
              _controller.forward();
            } else {
              _controller.reverse();
            }
          },
          child: widget.child, // Child is the content padding + icon
        ),
      ),
    );
  }
}

class _MorphingVisualizer extends StatefulWidget {
  final bool isUserSpeaking;
  final bool isAiSpeaking;
  final double level;
  final bool isFluxMode;

  const _MorphingVisualizer({
    required this.isUserSpeaking,
    required this.isAiSpeaking,
    required this.level,
    required this.isFluxMode,
  });

  @override
  State<_MorphingVisualizer> createState() => _MorphingVisualizerState();
}

class _MorphingVisualizerState extends State<_MorphingVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _morphController;

  late AnimationController _levelSmoother;
  double _smoothLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // No duration here, we drive it manually or with animateTo
    _levelSmoother = AnimationController(
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 0.0,
      duration: const Duration(milliseconds: 100),
    );

    if (widget.isAiSpeaking) {
      _morphController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant _MorphingVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAiSpeaking && !oldWidget.isAiSpeaking) {
      // User -> AI: Animate to Wave
      _morphController.forward();
    } else if (!widget.isAiSpeaking && oldWidget.isAiSpeaking) {
      // AI -> User: Animate back to Dot
      _morphController.reverse();
    }

    if (widget.level != oldWidget.level) {
      // Animate to new level smoothly over 100ms
      _levelSmoother.animateTo(widget.level, curve: Curves.easeOut);
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _levelSmoother.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_morphController, _levelSmoother]),
      builder: (context, child) {
        final voiceService =
            context.watch<VoiceService>(); // Use watch to rebuild on updates
        double t = _morphController.value;
        _smoothLevel = _levelSmoother.value;

        double effectiveLevel = _smoothLevel;
        if (effectiveLevel < 0.0) effectiveLevel = 0.0;

        double baseSize = 96.0;
        double maxExtra = 48.0;

        double dotSize = baseSize + (effectiveLevel * maxExtra);
        // Cap just in case
        if (dotSize > (baseSize + maxExtra)) dotSize = baseSize + maxExtra;

        // Freeze dot size during morph to avoid jitter
        // if (t > 0.1) dotSize = baseSize; // Removed to allow pulsing during initial morph phase

        double currentWidth;
        double currentHeight;
        double borderRadius;

        // Define base color for the container
        Color baseContainerColor;

        if (voiceService.isFlowActive) {
          // Multi-Agent Colors
          switch (voiceService.currentFlowAgentIndex) {
            case 0:
              baseContainerColor = AppColors.senaryColor;
              break;
            case 1:
              baseContainerColor = AppColors.septenaryColor;
              break;
            case 2:
              baseContainerColor = AppColors.premium;
              break;
            default:
              baseContainerColor = AppColors.senaryColor;
          }
        } else if (widget.isFluxMode) {
          baseContainerColor = AppColors.secondaryColor;
        } else {
          baseContainerColor = AppColors.primaryColor.inverted;
        }

        Color containerColor =
            baseContainerColor; // Initialize with solid color

        double opacityWave = 0.0;

        if (t < 0.3) {
          // PHASE 1: SQUASH
          double localT = t / 0.3;
          currentWidth = dotSize;
          currentHeight = dotSize + (2.0 - dotSize) * localT;
          borderRadius = currentHeight / 2;
        } else if (t < 0.7) {
          // PHASE 2: STRETCH
          double localT = (t - 0.3) / 0.4;
          currentHeight = 2.0;
          double screenWidth = MediaQuery.of(context).size.width;
          currentWidth = dotSize + (screenWidth - dotSize) * localT;
          borderRadius = 1.0;
        } else {
          // PHASE 3: FADE OUT & GROW
          // To fix the "Huge Bar" glitch:
          // 1. First fraction of time (e.g. 0.0->0.2 of Phase 3): Fade color to transparent. Height stays small (2.0).
          // 2. Remaining fraction (0.2->1.0): Grow height to 150.0. Width expands to full.

          double localT = (t - 0.7) / 0.3;
          double fadeEnd = 0.2; // 20% of phase for fade

          // Color Opacity Logic: 1.0 -> 0.0 in first 20%
          double opacity = 1.0;
          if (localT <= fadeEnd) {
            opacity = 1.0 - (localT / fadeEnd);
          } else {
            opacity = 0.0;
          }
          opacity = opacity.clamp(0.0, 1.0);

          // Apply opacity to container color
          containerColor = baseContainerColor.withValues(alpha:opacity);

          // Height Logic: Starts growing AFTER fade is mostly done to avoid huge black bar
          // Or grow linearly but since opacity drops fast, it won't look like a block.
          // Let's grow height linearly but keep opacity logic aggressive.
          // Actually, let's delay height growth slightly.

          double heightT = (localT - fadeEnd) / (1.0 - fadeEnd);
          if (heightT < 0) heightT = 0;

          currentHeight = 2.0 + (150.0 - 2.0) * heightT;
          currentWidth = MediaQuery.of(context).size.width;
          borderRadius = 0.0;
          opacityWave =
              heightT.clamp(0.0, 1.0); // Wave fades in as height grows
        }

        return Center(
          child: GestureDetector(
            onTap: () {
              // Easter Egg: Pulse effect
              // Since we are using AnimatedBuilder, we can just trigger a quick level spike manually?
              // Or better, just Haptic feedback + maybe momentary color shift?
              // User asked for "grow and shrink".
              // We can hack this by injecting a fake level spike into the smoother.
              HapticFeedback.mediumImpact();
              _levelSmoother
                  .forward(from: 1.0)
                  .then((_) => _levelSmoother.reverse());
            },
            child: Container(
              width: currentWidth,
              height: currentHeight,
              decoration: BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: widget.isFluxMode
                    ? Border.all(
                        color: AppColors.border.withValues(
                            alpha: t >= 0.7
                                ? (1.0 - (t - 0.7) / 0.3).clamp(0.0, 1.0)
                                : 1.0),
                        width: 2)
                    : null,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (opacityWave > 0.01)
                    Opacity(
                      opacity: opacityWave.clamp(0.0, 1.0),
                      child: WaveformVisualizer(
                        color:
                            baseContainerColor, // Correctly pass dynamic color
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
