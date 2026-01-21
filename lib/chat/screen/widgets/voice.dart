import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VoiceSessionOverlay extends StatefulWidget {
  const VoiceSessionOverlay({super.key});

  @override
  State<VoiceSessionOverlay> createState() => _VoiceSessionOverlayState();
}

class _VoiceSessionOverlayState extends State<VoiceSessionOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final voiceService = context.watch<VoiceService>();
    final speechService = context.watch<SpeechService>();
    final inputProvider = context.read<InputProvider>();

    // Auto-Close Logic:
    // If VoiceService becomes idle, close the overlay.
    if (voiceService.state == VoiceState.idle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (inputProvider.isVoiceModeActive) {
          inputProvider.setVoiceModeActive(false);
        }
      });
    }

    // Determine visual state
    bool isUserSpeaking = voiceService.state == VoiceState.listening;
    bool isAiSpeaking = voiceService.state == VoiceState.speaking;
    bool isProcessing = voiceService.state == VoiceState.processing;

    // Sound Level (0.0 to 1.0)
    double level = speechService.soundLevel;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Close Button (Top Right)
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              icon: Icon(Icons.close, color: AppColors.primaryColor.inverted),
              onPressed: () {
                voiceService.stopSession(); // Stops logic
                inputProvider.setVoiceModeActive(false); // Closes UI
              },
            ),
          ),

          // 2. Central Visualizer
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Text
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    isUserSpeaking
                        ? "Listening..."
                        : isAiSpeaking
                            ? "Speaking..."
                            : isProcessing
                                ? "Thinking..."
                                : "Connecting...",
                    key: ValueKey(voiceService.state),
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted.withOpacity(0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Converting Lines <-> Circle
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: isAiSpeaking
                      ? _AiSpeakingVisualizer() // Circle pulsing
                      : _UserListeningVisualizer(level: level), // Waveform
                ),
              ],
            ),
          ),

          // 3. Bottom Controls (Stop Button)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 48,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // If listening, stop and process.
                  if (isUserSpeaking) {
                    voiceService.manualSubmit();
                  } else if (isAiSpeaking) {
                    voiceService.stopSpeaking(); // Interrupt
                  }
                },
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor, // Redish usually
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUserSpeaking ? Icons.check : Icons.stop,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _UserListeningVisualizer extends StatelessWidget {
  final double level;
  const _UserListeningVisualizer({required this.level});

  @override
  Widget build(BuildContext context) {
    // "Famous Lines" - classic Siri-like waveform
    return CustomPaint(
      painter:
          _WavePainter(level: level, color: AppColors.primaryColor.inverted),
      child: Container(height: 100, width: double.infinity),
    );
  }
}

class _AiSpeakingVisualizer extends StatefulWidget {
  @override
  State<_AiSpeakingVisualizer> createState() => _AiSpeakingVisualizerState();
}

class _AiSpeakingVisualizerState extends State<_AiSpeakingVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Pulsing Circle
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 100 + (_controller.value * 20),
          height: 100 + (_controller.value * 20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                AppColors.primaryColor.inverted.withOpacity(0.2), // Outer glow
          ),
          child: Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryColor.inverted,
              ),
            ),
          ),
        );
      },
    );
  }
}

// Simple wave painter
class _WavePainter extends CustomPainter {
  final double level;
  final Color color;
  _WavePainter({required this.level, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    final midY = height / 2;

    // Draw 5 lines representing the wave
    for (int i = 0; i < 5; i++) {
      double offset = (i - 2) * 20.0;
      // Sensitivity adjustment for visuals
      double sensitiveLevel = level;
      if (sensitiveLevel < 0.05) sensitiveLevel = 0.02; // Noise floor

      double amp = sensitiveLevel *
          80 *
          (1.0 - (i - 2).abs() * 0.2); // Center line tall, sides short
      if (amp < 2) amp = 2; // Min height

      canvas.drawLine(
        Offset(width / 2 + offset, midY - amp),
        Offset(width / 2 + offset, midY + amp),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.level != level;
}
