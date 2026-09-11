import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';

const List<String> _musicGenerationTerms = [
  'music',
  'muzik',
  'song',
  'sarki',
  'melody',
  'melodi',
  'instrumental',
  'beat',
  'beste',
  'jingle',
  'soundtrack',
  'lofi',
  'lo fi',
  'background music',
  'arka plan muzigi',
  'tema muzigi',
  'parca',
  'bpm',
  'chord',
  'akor',
  'tempo',
  'lyrics',
  'vokal',
];

String _normalizeGenerationIntent(String text) {
  return text
      .toLowerCase()
      .replaceAll('ç', 'c')
      .replaceAll('ğ', 'g')
      .replaceAll('ı', 'i')
      .replaceAll('ö', 'o')
      .replaceAll('ş', 's')
      .replaceAll('ü', 'u')
      .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Returns true when an Audio-generation prompt is explicitly musical.
///
/// Matching is token/phrase based rather than substring based so requests
/// such as "heartbeat sound effect" do not accidentally match `beat`.
bool isMusicGenerationPrompt(String text) {
  final normalized = _normalizeGenerationIntent(text);
  if (normalized.isEmpty) return false;
  final padded = ' $normalized ';
  return _musicGenerationTerms.any((term) => padded.contains(' $term '));
}

/// Resolves the explicit server generation target for a feature-mode send.
///
/// Audio is intentionally split here: Fulcrum has separate music and
/// speech/sound routes, costs and media defaults. Musical prompts go to
/// `music`; voice, narration and sound effects keep using `audio`.
String? generationTargetForMode(ChatInputMode mode, String userText) {
  return switch (mode) {
    ChatInputMode.imageGeneration => 'image',
    ChatInputMode.videoGeneration => 'video',
    ChatInputMode.audioGeneration =>
      isMusicGenerationPrompt(userText) ? 'music' : 'audio',
    _ => null,
  };
}

/// Maps a transport target onto Fulcrum's published credit operation lane.
/// The `audio` generation target is billed through the `speech` lane.
String? generationCreditLaneForTarget(String? target) {
  return switch (target) {
    'image' => 'image',
    'video' => 'video',
    'music' => 'music',
    'audio' => 'speech',
    _ => null,
  };
}

/// Maps a generation target type to its input feature mode.
ChatInputMode? generationModeForTarget(String targetType) {
  return switch (targetType) {
    'image' => ChatInputMode.imageGeneration,
    'video' => ChatInputMode.videoGeneration,
    'audio' => ChatInputMode.audioGeneration,
    _ => null,
  };
}

/// Logic for the "Create Image/Video/Audio" buttons: instead of sending
/// anything, this activates the matching input feature (exactly like
/// selecting a feature from the Features sheet), which highlights the "+"
/// button of the input field until the user sends their prompt.
///
/// The client never prepends a hidden prompt. On send, the selected feature
/// is converted to an explicit `generationTarget`. Audio prompts are split
/// into `music` versus `audio` so Fulcrum can use its distinct music and
/// speech/sound routes, costs and duration defaults.
void setGenerationFeatureMode(
  BuildContext context, {
  required String targetType,
}) {
  final mode = generationModeForTarget(targetType);
  if (mode == null) return;

  final inputProvider = context.read<InputProvider>();
  final session = context.read<ChatSessionProvider>();

  // Generation targets are mutually exclusive with web search.
  inputProvider.clearWebSearch();

  // Toggle off when tapped again, mirroring the Features sheet behaviour.
  if (inputProvider.featureMode == mode) {
    inputProvider.clearFeatureMode();
  } else {
    inputProvider.setFeatureMode(mode);
  }

  // Always hand off to dynamic chat; the server-side router picks the model
  // from the resolved generation target, without a client-side model pin.
  if (!session.isDynamicChat) {
    session.startDynamicConversation(savePreference: true);
  }
}
