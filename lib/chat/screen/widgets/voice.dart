import 'package:cortex/app.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/chat/screen/widgets/wave.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class VoiceSessionOverlay extends StatelessWidget {
  const VoiceSessionOverlay({super.key});

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

    // Sound Level (0.0 to 1.0) for Dot Animation
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

          // 2. Central Visualizer (The Core Experience)
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
                      color: AppColors.primaryColor.inverted
                          .withValues(alpha: 0.7),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 64),

                // MORPHING VISUALIZER
                // Wave (AI) <-> Dot (User)
                SizedBox(
                  height: 120, // Check wave height compatibility
                  width: double.infinity,
                  child: _MorphingVisualizer(
                    isUserSpeaking: isUserSpeaking,
                    isAiSpeaking: isAiSpeaking,
                    level: level,
                  ),
                ),
              ],
            ),
          ),

          // 3. Bottom Controls (Stop/Submit Button)
          Positioned(
            bottom: MediaQuery.of(context).padding.bottom + 48,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  // Manual interactions
                  if (isUserSpeaking) {
                    voiceService.manualSubmit();
                  } else if (isAiSpeaking) {
                    voiceService.stopSpeaking(); // Interrupt
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: isUserSpeaking
                        ? AppColors.primaryColor.inverted
                        : AppColors.secondaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUserSpeaking ? Icons.arrow_upward : Icons.stop,
                    color:
                        isUserSpeaking ? AppColors.primaryColor : Colors.white,
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

class _MorphingVisualizer extends StatelessWidget {
  final bool isUserSpeaking;
  final bool isAiSpeaking;
  final double level;

  const _MorphingVisualizer({
    required this.isUserSpeaking,
    required this.isAiSpeaking,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    // LAYOUT LOGIC:
    // AI Speaking -> Full Width Wave
    // User Speaking -> Small Center Dot
    // We animate the Container's width constraint to achieve the "merge" effect.

    // If User Speaking, width is small (Dot size + padding).
    // If AI Speaking (or others), width is max.
    final double targetWidth =
        isUserSpeaking ? 80.0 : MediaQuery.of(context).size.width;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic, // Smooth merge
        width: targetWidth,
        height: 100,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          // We cross-fade between the Dot and the Wave
          child: isUserSpeaking
              ? _ListeningDotVisualizer(level: level)
              : const WaveformVisualizer(),
        ),
      ),
    );
  }
}

class _ListeningDotVisualizer extends StatelessWidget {
  final double level; // 0.0 to 1.0

  const _ListeningDotVisualizer({required this.level});

  @override
  Widget build(BuildContext context) {
    // Base size 24, max size 72.
    // Level is usually low, so we pump it up a bit if above noise floor.
    double effectiveLevel = level;
    if (effectiveLevel < 0.02) effectiveLevel = 0.02; // Min pulse

    double size = 24.0 + (effectiveLevel * 100);
    if (size > 80) size = 80; // Cap max size

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // Fast reaction to voice
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primaryColor.inverted,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
