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
            bottom: MediaQuery.of(context).padding.bottom + 32,
            left: 24,
            right: 24,
            child: FadeTransition(
              opacity: _entranceController,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // LEFT BUTTON: Flow (Placeholder)
                 /* _buildCircleButton(
                    iconPath: 'assets/icons/flow.svg',
                    onTap: () {
                      HapticFeedback.selectionClick();
                      // Currently no function
                    },
                    isSecondary: true,
                  ),*/

                  // CENTER BUTTON: Mic / Stop
                  // If AI speaking -> Stop icon (interrupt)
                  // If User speaking -> Stop icon (manual send) OR Mic icon?
                  // Requirement: "ortadaki buton mikrofon butonu model konuşurken buna basılırsa otomatik modelin konuşmasını durdurcak... KİŞİNİN KENDİSİ KONUŞURKEN BU LOGONUN İKONU STOP.SVG OLCAK"
                  _buildCenterButton(
                    isUserSpeaking: isUserSpeaking,
                    isAiSpeaking: isAiSpeaking,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      if (isUserSpeaking) {
                        // User is speaking, stop listening and send
                        voiceService.manualSubmit();
                      } else if (isAiSpeaking) {
                        // AI is speaking, stop playback
                        voiceService.stopSpeaking();
                      } else {
                        // IDLE state (mic timed out or manual stop)
                        // Restart listening
                        debugPrint("Restarting voice session from idle...");
                        voiceService.startListening();
                      }
                    },
                  ),

                  // RIGHT BUTTON: Exit (Arrow)
                  _buildCircleButton(
                    iconPath: 'assets/icons/arrov.svg', // Uses arrov.svg
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      voiceService.stopSession();
                      inputProvider.setVoiceModeActive(false);
                    },
                    isSecondary: true,
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
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isSecondary ? AppColors.background : AppColors.primaryColor,
          shape: BoxShape.circle,
          border: isSecondary
              ? Border.all(color: AppColors.border, width: 1.5)
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: SvgPicture.asset(
          iconPath,
          colorFilter: ColorFilter.mode(
            isSecondary ? AppColors.primaryColor.inverted : Colors.white,
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  // Center button is larger and changes appearance
  Widget _buildCenterButton({
    required bool isUserSpeaking,
    required bool isAiSpeaking,
    required VoidCallback onTap,
  }) {
    // Icon logic:
    // User Speaking -> STOP
    // Model Speaking -> STOP
    // Idle -> MIC

    final bool showStop = isUserSpeaking || isAiSpeaking;
    final String iconPath =
        showStop ? 'assets/icons/stop.svg' : 'assets/icons/microphone.svg';

    return _ScaleButton(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(22),
        // Use AnimatedSwitcher for smooth fade transition
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(opacity: animation, child: child);
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
    );
  }
}

class _ScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ScaleButton({required this.child, required this.onTap});

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

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scale,
        child: widget.child,
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
  // Controller for smoothing out level changes (0.1s duration as requested)
  // "dışardan içeriye doğru yavaşça büyüyecek 0.1 saniyede falan"
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
        double t = _morphController.value;
        _smoothLevel = _levelSmoother.value;

        // STAGE 1: Dot to Thread (0.0 to 0.3)
        // STAGE 2: Thread Stretch (0.3 to 0.7)
        // STAGE 3: Grow to Wave (0.7 to 1.0)

        // BASE SIZE: "ses dinlenmiyoken şimdiki halinden 2 kat büyük olması lazım"
        // Previous base was 48.0. New base = 96.0.
        // EXPANSION: "2 katın 1.5 katına kadar da genişleyebilmesi lazım"
        // Max size = 96.0 * 1.5 = 144.0.
        // Logic: 96 + (level * (144 - 96)) => 96 + (level * 48)

        double effectiveLevel = _smoothLevel;
        if (effectiveLevel < 0.0) effectiveLevel = 0.0;

        double baseSize = 96.0;
        double maxExtra = 48.0;

        double dotSize = baseSize + (effectiveLevel * maxExtra);
        // Cap just in case
        if (dotSize > (baseSize + maxExtra)) dotSize = baseSize + maxExtra;

        // Freeze dot size during morph to avoid jitter
        if (t > 0.1) dotSize = baseSize; // Reset to base during transition

        double currentWidth;
        double currentHeight;
        double borderRadius;
        double opacityWave = 0.0;

        if (t < 0.3) {
          // PHASE 1: SQUASH (0.0 -> 0.3)
          // Height: dotSize -> 4.0
          // Width: dotSize -> dotSize
          double localT = t / 0.3;
          currentWidth = dotSize;
          currentHeight = dotSize + (4.0 - dotSize) * localT;
          borderRadius = currentHeight / 2;
        } else if (t < 0.7) {
          // PHASE 2: STRETCH (0.3 -> 0.7)
          // Height: 4.0 -> 4.0
          // Width: dotSize -> ScreenWidth
          double localT = (t - 0.3) / 0.4;
          currentHeight = 4.0;
          double screenWidth = MediaQuery.of(context).size.width;
          currentWidth = dotSize + (screenWidth - dotSize) * localT;
          borderRadius = 2.0; // Slightly rounded thread ends
        } else {
          // PHASE 3: GROW TO WAVE (0.7 -> 1.0)
          // Height: 4.0 -> 150.0
          // Width: ScreenWidth
          // Wave fades in
          double localT = (t - 0.7) / 0.3;
          currentHeight = 4.0 + (150.0 - 4.0) * localT;
          currentWidth = MediaQuery.of(context).size.width;
          borderRadius = 0.0;
          opacityWave = localT;
        }

        return Center(
          child: Container(
            width: currentWidth,
            height: currentHeight,
            decoration: BoxDecoration(
              color: widget.isFluxMode
                  ? AppColors.background
                  : AppColors.primaryColor.inverted,
              borderRadius: BorderRadius.circular(borderRadius),
              border: widget.isFluxMode
                  ? Border.all(color: AppColors.border, width: 2)
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (opacityWave > 0.01)
                  Opacity(
                    opacity: opacityWave,
                    child: const WaveformVisualizer(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
