import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/chat/providers/input.dart';
import 'package:cortex/chat/providers/session.dart';

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
/// The client deliberately does NOT determine anything about the request:
/// no prefix text is prepended locally. On send, only a `generationTarget`
/// key (image/video/audio) travels to the server, which routes directly to
/// the matching model group and prepends the canonical prefix defined in
/// Fulcrum ("Create an Image:" / "Create a Video:" / "Create an Audio:").
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
  // based on the generation key, without running intent analysis.
  if (!session.isDynamicChat) {
    session.startDynamicConversation(savePreference: true);
  }
}
