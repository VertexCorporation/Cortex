import 'package:flutter/material.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// The stable identities used by Flow Mode.  The order is part of the
/// protocol: every round is Blue → Red → Green → Yellow.
enum FlowParticipant { blue, red, green, yellow }

extension FlowParticipantMetadata on FlowParticipant {
  String get key => name;

  String get displayName => switch (this) {
    FlowParticipant.blue => 'Blue',
    FlowParticipant.red => 'Red',
    FlowParticipant.green => 'Green',
    FlowParticipant.yellow => 'Yellow',
  };

  /// Localized user-facing label. The enum key remains stable for persistence
  /// and orchestration.
  String localizedName(AppLocalizations l10n) => switch (this) {
    FlowParticipant.blue => l10n.agentBlue,
    FlowParticipant.red => l10n.agentRed,
    FlowParticipant.green => l10n.agentGreen,
    FlowParticipant.yellow => l10n.agentYellow,
  };

  Color get color => switch (this) {
    FlowParticipant.blue => const Color(0xFFA6B9F2),
    FlowParticipant.red => const Color(0xFFEFA8A6),
    FlowParticipant.green => const Color(0xFFA8D9B4),
    FlowParticipant.yellow => const Color(0xFFF2DDA0),
  };

  static FlowParticipant? fromKey(String? value) {
    switch (value?.trim().toLowerCase()) {
      case 'blue':
        return FlowParticipant.blue;
      case 'red':
        return FlowParticipant.red;
      case 'green':
        return FlowParticipant.green;
      case 'yellow':
        return FlowParticipant.yellow;
      default:
        return null;
    }
  }
}

enum FlowPhase {
  idle,
  userSpeaking,
  thinking,
  aiSpeaking,
  interRoundPause,
  stopped,
}

/// Small deterministic state machine for the first Flow implementation.
/// VoiceService owns I/O and generation guards; this class only decides which
/// participant may speak next.
class FlowOrchestrator {
  FlowPhase phase = FlowPhase.idle;
  FlowParticipant currentParticipant = FlowParticipant.blue;
  int round = 0;
  int generation = 0;

  bool get isRunning => phase != FlowPhase.idle && phase != FlowPhase.stopped;

  int begin({int? newGeneration}) {
    generation = newGeneration ?? generation + 1;
    round = 0;
    currentParticipant = FlowParticipant.blue;
    phase = FlowPhase.thinking;
    return generation;
  }

  void beginUserTurn() {
    currentParticipant = FlowParticipant.blue;
    phase = FlowPhase.userSpeaking;
  }

  void beginAiTurn(FlowParticipant participant) {
    currentParticipant = participant;
    phase = FlowPhase.thinking;
  }

  void markAiSpeaking() {
    phase = FlowPhase.aiSpeaking;
  }

  FlowParticipant? completeAi({required int expectedGeneration}) {
    if (expectedGeneration != generation || !isRunning) return null;
    if (currentParticipant == FlowParticipant.yellow) {
      phase = FlowPhase.interRoundPause;
      return null;
    }
    final nextIndex = currentParticipant.index + 1;
    final next = FlowParticipant.values[nextIndex];
    currentParticipant = next;
    phase = FlowPhase.thinking;
    return next;
  }

  FlowParticipant beginNextRound({required int expectedGeneration}) {
    if (expectedGeneration != generation) return currentParticipant;
    round++;
    currentParticipant = FlowParticipant.blue;
    phase = FlowPhase.thinking;
    return currentParticipant;
  }

  void interruptForUser() {
    generation++;
    currentParticipant = FlowParticipant.blue;
    phase = FlowPhase.userSpeaking;
  }

  void stop() {
    generation++;
    phase = FlowPhase.stopped;
  }
}
