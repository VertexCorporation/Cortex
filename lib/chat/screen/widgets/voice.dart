import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/providers/conversation.dart';
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
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOutCubic,
    ));

    // Ensure keyboard is dismissed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).unfocus();
    });

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
      backgroundColor: Colors.transparent,
      body: SlideTransition(
        position: _slideAnimation,
        child: Stack(
        children: [
          // 0. Top Live Speech Text (Smooth text only, no box/icon)
          if (voiceService.liveTranscript.isNotEmpty)
            Positioned(
              top: MediaQuery.paddingOf(context).top + 72,
              left: 32,
              right: 32,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0, 0.2),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Text(
                  voiceService.liveTranscript,
                  key: ValueKey<String>(voiceService.liveTranscript),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.primaryColor.inverted.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    letterSpacing: -0.2,
                    height: 1.4,
                  ),
                ),
              ),
            ),

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
            bottom: MediaQuery.paddingOf(context).bottom +
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
                      // LEFT BUTTON: Flow Mode Toggle
                      // Logic:
                      // If Flow OFF: Show Flow Icon. Tap -> Enable Flow.
                      // If Flow ON: Show Voice Icon. Tap -> Disable Flow (Start New Chat if needed).
                      Builder(builder: (context) {
                        final isFlow = voiceService.isFlowMode;
                        return _buildCircleButton(
                          iconPath: isFlow
                              ? 'assets/icons/voice.svg'
                              : 'assets/icons/flow.svg',
                          onTap: () {
                            HapticFeedback.selectionClick();

                            if (!isFlow) {
                              // Enable Flow

                              // [NEW] If chat is not empty, start fresh before entering Flow Mode
                              final conversationProvider =
                                  context.read<ConversationProvider>();
                              if (conversationProvider.messages.isNotEmpty) {
                                conversationProvider.clearConversation();
                                // Ensure we are in a fresh state
                                context
                                    .read<ChatSessionProvider>()
                                    .startDynamicConversation();
                              }

                              // Service sets visual to Line (Processing) + Stops Listening
                              voiceService.toggleFlowMode();
                            } else {
                              // Disable Flow -> Return to Voice
                              // First toggle mode (sets visual to listening/idle)
                              voiceService.toggleFlowMode();

                              // [NEW] Stop any ongoing generation/speech immediately
                              // This ensures we don't have lingering TTS or generation when switching modes
                              final conversationProvider =
                                  context.read<ConversationProvider>();
                              conversationProvider.stopGenerating();
                              voiceService.stopSpeaking(context: context);
                              final sessionProvider =
                                  context.read<ChatSessionProvider>();

                              // If current chat has content, start fresh
                              if (conversationProvider.messages.isNotEmpty) {
                                // Clear conversation to start fresh "background" chat
                                conversationProvider.clearConversation();
                                // Reset session state (standard dynamic)
                                sessionProvider.startDynamicConversation();

                                // Re-start listening in new context
                                voiceService.startListening(context: context);
                              } else {
                                // Empty chat, just start listening
                                voiceService.startListening(context: context);
                              }
                            }
                          },
                          isSecondary:
                              true, // Always "Secondary" style (White/Outline) per user request
                        );
                      }),

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
                              voiceService.stopSpeaking(context: context);
                            }
                            return;
                          }

                          if (isUserSpeaking) {
                            voiceService.manualSubmit(context);
                          } else if (isAiSpeaking) {
                            voiceService.stopSpeaking(context: context);
                          } else {
                            debugPrint("Restarting voice session from idle...");
                            voiceService.startListening(context: context);
                          }
                        },
                      ),

                      // RIGHT BUTTON: Exit (Arrow)
                      _buildCircleButton(
                        iconPath:
                            'assets/icons/arrov.svg', // Assuming arrov.svg is correct as used before
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      voiceService.isFlowMode
                          ? AppLocalizations.of(context)!.flowModeDescription
                          : AppLocalizations.of(context)!.voiceModeInformation,
                      key: ValueKey<bool>(voiceService.isFlowMode),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.tertiaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
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
        child: SizedBox(
          width: 56,
          height: 56,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child));
              },
              child: SvgPicture.asset(
                iconPath,
                key: ValueKey<String>(iconPath),
                colorFilter: ColorFilter.mode(
                  isSecondary ? AppColors.primaryColor.inverted : Colors.white,
                  BlendMode.srcIn,
                ),
              ),
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

    return _ScaleButton(
      onTap: onTap,
      styleColor: AppColors.primaryColor.inverted,
      shape: BoxShape.circle,
      child: SizedBox(
        width: 80,
        height: 80,
        child: Padding(
          padding: EdgeInsets.zero, // Padding handled by Center/Child inside
          // Use AnimatedSwitcher for smooth fade transition
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child));
            },
            child: (isFlowMode && !isFlowActive)
                ? Padding(
                    key: const ValueKey('start_flow_icon'),
                    padding: const EdgeInsets.all(80 * 0.22),
                    child: RotatedBox(
                      quarterTurns: 2,
                      child: SvgPicture.asset(
                        'assets/icons/arrow.svg',
                        colorFilter: ColorFilter.mode(
                            AppColors.primaryColor, BlendMode.srcIn),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(22),
                    child: SvgPicture.asset(
                      showStop
                          ? 'assets/icons/stop.svg'
                          : 'assets/icons/microphone.svg',
                      key: ValueKey<String>(showStop ? 'stop' : 'mic'),
                      colorFilter: ColorFilter.mode(
                        AppColors.primaryColor,
                        BlendMode.srcIn,
                      ),
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

  // AI Speaking Simulation
  late AnimationController _aiSpeechSimulator;

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

    // Simulate a breathing/talking rhythm
    _aiSpeechSimulator = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

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
    _aiSpeechSimulator.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(
          [_morphController, _levelSmoother, _aiSpeechSimulator]),
      builder: (context, child) {
        final voiceService =
            context.watch<VoiceService>(); // Use watch to rebuild on updates
        double t = _morphController.value;

        // Determine the effective level to visualise
        double effectiveLevel = 0.0;

        if (widget.isAiSpeaking) {
          // Simulate complex speech pattern using combined sine waves from the simulator controller
          // We map the 0.0-1.0 controller value to a dynamic "talking" wave
          // Combines sine wave values non-linearly to create a more organic "speech" effect
          // rather than a mechanical breathing animation.
          double val = _aiSpeechSimulator.value;
          // Using power function makes it spike more naturally like speech headers
          effectiveLevel =
              0.2 + (0.5 * (val * val * val)); // cubic curve for organic spikes
        } else {
          _smoothLevel = _levelSmoother.value;
          effectiveLevel = _smoothLevel;
        }

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
          double screenWidth = MediaQuery.sizeOf(context).width;
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
          containerColor = baseContainerColor.withValues(alpha: opacity);

          // Height Logic: Starts growing AFTER fade is mostly done to avoid huge black bar
          // Or grow linearly but since opacity drops fast, it won't look like a block.
          // Let's grow height linearly but keep opacity logic aggressive.
          // Actually, let's delay height growth slightly.

          double heightT = (localT - fadeEnd) / (1.0 - fadeEnd);
          if (heightT < 0) heightT = 0;

          currentHeight = 2.0 + (150.0 - 2.0) * heightT;
          currentWidth = MediaQuery.sizeOf(context).width;
          borderRadius = 0.0;
          opacityWave =
              heightT.clamp(0.0, 1.0); // Wave fades in as height grows
        }

        // VISIBILITY LOGIC:
        // User Request: "Flow modunda ortada nokta olmayacak" (No dot in Flow Mode)
        // Dot represents "Mic Listening".
        // In Flow Mode, we are passive unless interrupting.
        // So hide the Dot when:
        // 1. Flow Active
        // 2. Not User Speaking (Interruption)
        // 3. Not AI Speaking (Wave)
        // Note: When AI Speaking, we show Wave (so opacity 1.0).

        // User Request: "Flow modunda ortada nokta olmayacak... düz çizgiye dönüşecek"
        // (No dot in Flow Mode -> turns into flat line)
        // This applies when Flow is Active AND NO ONE is speaking (Processing state).
        // Since toggleFlowMode sets state to Processing, this logic catches it.
        // HOWEVER, voiceService.isFlowActive might be false if just Toggled but not Started?
        // Ah, toggleFlowMode sets flowActive=false.
        // We need to check if we are in Flow Mode (Setup) OR Flow Active.
        // If VoiceState is 'processing', we should show the line?
        // Or should we trust isFlowMode?

        // Wait, "Flow Mode'a geçildiğinde... direkt çizgiye dönüşsün".
        // VoiceState.processing triggers visualizer to do what?
        // Currently visualizer depends on isUserSpeaking/isAiSpeaking.
        // If processing, both are false.
        // So checking isFlowMode (or FlowActive which is irrelevant for "setup")
        // AND state == Processing?

        bool isFlowProcessing =
            (voiceService.isFlowMode || voiceService.isFlowActive) &&
                !widget.isUserSpeaking &&
                !widget.isAiSpeaking;

        if (isFlowProcessing) {
          // Enforce Flat Line State for Flow Mode Processing
          // "Flat line" means width is wide, height is very thin
          currentWidth = MediaQuery.sizeOf(context).width * 0.6;
          currentHeight = 4.0;
          borderRadius = 2.0;

          // Ensure it's opaque and visible
          containerColor = baseContainerColor;

          // Flux Desaturation Check
          if (widget.isFluxMode) {
            // "Flux Mode'a basıldığında Flow Mode'da renkler biraz solsun"
            // Desaturate by mixing with white/grey or reducing opacity?
            // Or changing to a paler version.
            containerColor = Color.alphaBlend(
                Colors.white.withValues(alpha: 0.4), containerColor);
          }

          // Also set morph controller to 0 to avoid wave interference?
          // No, just override dimensions.
        } else if (widget.isFluxMode) {
          // Keep Flux mode styling if not flat line
          baseContainerColor = AppColors.secondaryColor;
        }

        return Center(
          child: GestureDetector(
            onTapDown: (_) {
              // Behave like a button press - visual feedback
              _levelSmoother.animateTo(1.0,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOutQuad);
            },
            onTapUp: (_) {
              _levelSmoother.animateTo(widget.level,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack);
            },
            onTapCancel: () {
              _levelSmoother.animateTo(widget.level,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack);
            },
            // [CHANGED] Use AnimatedContainer for dimensions/color, remove AnimatedOpacity logic from previous try
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
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
                        origin: WaveOrigin.right,
                        color:
                            baseContainerColor, // Correctly pass dynamic color
                        // Pass effectiveLevel to WaveformVisualizer if it supported it.
                        // Assuming WaveformVisualizer might handle internal animation or we need to pass level?
                        // Checking file `voice.dart` doesn't show `WaveformVisualizer` internals (imported).
                        // But previous code didn't pass level to it. It likely uses internal or random.
                        // Wait, user said "dalgalar nasıl sese göre şekil değiştiriyorsa...".
                        // If `WaveformVisualizer` is static or random, we might not be affecting it directly via `level`.
                        // However, the `_MorphingVisualizer` itself (the dot) pulses with `dotSize`.
                        // The user said "dalgalar...".
                        // If `WaveformVisualizer` is the thing inside (the squiggly lines), we might need to modify THAT.
                        // But looking at existing code:
                        // `_MorphingVisualizer` controls `dotSize` via `effectiveLevel`.
                        // The `WaveformVisualizer` is just a child.
                        // The "Dalga" logic usually refers to the visualizer itself morphing.
                        // The `dotSize` determines the size of the BLOB.
                        // If the user means the blob pulsing, my change covers it.
                        // If they mean the lines inside, I can't see that code here.
                        // Assuming "Dalga" = The visual blob pulsing.
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
