import 'package:cortex/chat/services/speech.dart';
import 'package:cortex/chat/services/voice.dart';
import 'package:cortex/l10n/app_localizations.dart'; // [NEW]
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:math' as math;

class VoiceOverlay extends StatelessWidget {
  const VoiceOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final voiceService = context.watch<VoiceService>();
    final speechService = context.watch<SpeechService>();
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context)!; // [NEW]
    // invertedColor removed.

    return Container(
      height: 250, // Arbitrary height for the bottom sheet area
      padding: const EdgeInsets.only(bottom: 20),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Visualizer Area
          Positioned(
            top: 40,
            child: _VoiceVisualizer(
              state: voiceService.state,
              soundLevel: speechService.soundLevel,
            ),
          ),

          // Controls
          Positioned(
            bottom: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Microphone / Stop Button
                FloatingActionButton(
                  onPressed: () {
                    if (voiceService.state == VoiceState.speaking) {
                      // Interrupt
                      voiceService.stopSpeaking();
                    } else if (voiceService.state == VoiceState.listening) {
                      // Manual submit? or Stop?
                      // If already listening, maybe do nothing or stop?
                      // Let's assume it forces a "I'm done" signal if pressed while listening?
                      voiceService.manualSubmit();
                    } else {
                      // Idle? Start listening.
                      // We need a way to restart session if idle.
                      // voiceService.startListening(); // Assume existing session
                    }
                  },
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(
                    voiceService.state == VoiceState.speaking
                        ? Icons.stop
                        : Icons.mic,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),

          // Close Button (Bottom Right)
          Positioned(
            bottom: 20,
            right: 20,
            child: IconButton(
              onPressed: () {
                // Close overlay
                // We need to access InputProvider to toggle state
                // AND stop voice service.
                context.read<VoiceService>().stopSession();
                // The InputProvider toggle will be handled by the parent widget based on state,
                // or we can call it here.
                // Ideally parent listens to 'idle' state, but let's be explicit.
                // context.read<InputProvider>().setVoiceModeActive(false);
                // We'll let the parent handle the "Close" logic via a callback or provider.
              },
              icon: Transform.rotate(
                angle: math.pi, // 180 degrees
                child: SvgPicture.asset(
                  'assets/icons/arrow.svg',
                  // Assuming this asset exists as per user request
                  colorFilter: ColorFilter.mode(
                      theme.colorScheme.onSurface, BlendMode.srcIn),
                  width: 24,
                ),
              ),
            ),
          ),

          // Status Text
          Positioned(
            top: 10,
            child: Text(
              _getStatusText(voiceService.state, localizations),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(VoiceState state, AppLocalizations localizations) {
    switch (state) {
      case VoiceState.listening:
        return localizations.listening;
      case VoiceState.processing:
        return "Thinking..."; // Consider generalizing this later
      case VoiceState.speaking:
        return "Speaking..."; // Consider generalizing this later
      default:
        return "Ready";
    }
  }
}

class _VoiceVisualizer extends StatefulWidget {
  final VoiceState state;
  final double soundLevel; // 0.0 to 1.0

  const _VoiceVisualizer({
    required this.state,
    required this.soundLevel,
  });

  @override
  State<_VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<_VoiceVisualizer>
    with TickerProviderStateMixin {
  // Dot animations will be complex.
  // We can use AnimatedContainer for simplicity or CustomPainter for performance/smoothness.
  // User wants:
  // Listening: 4 dots merge to 1 big dot. Grows with volume.
  // Speaking: 4 dots separate. Grow/shrink.

  // Let's use AnimatedAlign + AnimatedContainer for the merge/split effect.

  @override
  Widget build(BuildContext context) {
    final bool isMerged = widget.state == VoiceState.listening ||
        widget.state == VoiceState.processing; // Processing also merged?
    // So Listening = Merged.

    // Calculate size based on volume
    // Base size + (volume * multiplier)
    double vol = widget.soundLevel;

    // Allow volume simulation if Speaking (since we don't always get mic audio when TTS talks)
    // Actually, FlutterTts doesn't expose audio visualization data easily on all platforms.
    // We might need to fake the visualizer for TTS Output or use a randomizer/sine wave if state is Speaking.
    if (widget.state == VoiceState.speaking) {
      // Simulate checks
      vol = (math.Random().nextDouble() * 0.5) + 0.3; // Random flutter
    }

    return SizedBox(
      width: 200,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dot 1
          _AnimatedDot(
            isMerged: isMerged,
            index: 0,
            volume: vol,
          ),
          _AnimatedDot(
            isMerged: isMerged,
            index: 1,
            volume: vol,
          ),
          _AnimatedDot(
            isMerged: isMerged,
            index: 2,
            volume: vol,
          ),
          _AnimatedDot(
            isMerged: isMerged,
            index: 3,
            volume: vol,
          ),
        ],
      ),
    );
  }
}

class _AnimatedDot extends StatelessWidget {
  final bool isMerged;
  final int index;
  final double volume;

  const _AnimatedDot({
    required this.isMerged,
    required this.index,
    required this.volume,
  });

  @override
  Widget build(BuildContext context) {
    // Layout:
    // 0 1 2 3 (Horizontal line)
    // Merged: All at center.

    // Positions (x from -3 to 3)
    final double spreadPositions = (index - 1.5) * 30.0; // -45, -15, 15, 45

    final double targetX = isMerged ? 0 : spreadPositions;

    // Size logic
    // Merged: Big base (20) + volume * 50
    // Separate: Small base (10) + volume * 20
    final double size = isMerged
        ? (30.0 + (volume * 40.0))
        : (12.0 + (volume * 20.0)); // Individual dots react nicely

    // Color logic
    final theme = Theme.of(context);
    final color = isMerged
        ? theme.primaryColor
        : theme.primaryColor.withValues(alpha: 0.7); // Maybe vary opacity?

    return AnimatedAlign(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: Alignment(targetX / 100.0, 0), // Simple mapping
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100), // Fast response to volume
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: isMerged
              ? [
            BoxShadow(
              color: color.withValues(alpha: 0.4),
              blurRadius: 20 + (volume * 20),
              spreadRadius: 5 + (volume * 10),
            )
          ]
              : [],
        ),
      ),
    );
  }
}
