from pathlib import Path
import subprocess


def main_file(path: str) -> str:
    return subprocess.check_output(
        ['git', 'show', f'origin/main:{path}'], text=True
    )


def replace_once(path: str, old: str, new: str) -> None:
    p = Path(path)
    text = p.read_text()
    count = text.count(old)
    if count != 1:
        raise SystemExit(
            f"{path}: expected one match, found {count}: {old[:100]!r}"
        )
    p.write_text(text.replace(old, new, 1))


# Reset the two large files to main so this cleanup removes dart-format-only
# churn from the previous validated commit. Re-apply only the semantic edits.
for path in ['lib/chat/services/send.dart', 'lib/chat/services/send/media.dart']:
    Path(path).write_text(main_file(path))

replace_once(
    'lib/chat/services/send.dart',
    "import 'package:cortex/chat/services/context.dart';\n",
    "import 'package:cortex/chat/services/context.dart';\n"
    "import 'package:cortex/chat/services/generation.dart';\n",
)
replace_once(
    'lib/chat/services/send.dart',
    "    // Generation lane ('image' | 'video' | 'audio') and conversation\n",
    "    // Generation lane ('image' | 'video' | 'audio' | 'music') and conversation\n",
)
replace_once(
    'lib/chat/services/send.dart',
    """      // Generation feature modes (Create Image/Video/Audio) do NOT modify
      // the text on the client. Only a generation key is sent to the server,
      // which routes directly to the matching model group and prepends the
      // canonical prefix itself (see Fulcrum's gateway/router).
      // Hoisted above the try (see the target state block) so the catch can
      // tell which operation the refused request was attempting.
      generationTarget = switch (activeMode) {
        ChatInputMode.imageGeneration => 'image',
        ChatInputMode.videoGeneration => 'video',
        ChatInputMode.audioGeneration => 'audio',
        _ => null,
      };
""",
    """      // Generation feature modes never rewrite the user's prompt. Resolve
      // the explicit transport target here. Audio is split into music versus
      // speech/sound so Fulcrum can use the correct model group, pricing lane
      // and media-duration defaults.
      generationTarget = generationTargetForMode(activeMode, text);
""",
)
replace_once(
    'lib/chat/services/send.dart',
    """      final creditsManager = context.read<CreditsManager>();
      final hasInternet = await InternetConnection().hasInternetAccess;
""",
    """      final creditsManager = context.read<CreditsManager>();

      // The Features sheet can only gate the generic Audio button against the
      // cheap speech lane before a prompt exists. Once the prompt is known,
      // enforce the actual resolved lane as well — especially music, which has
      // its own published cost. The server still remains the final authority.
      final generationCreditLane =
          generationCreditLaneForTarget(generationTarget);
      if (generationCreditLane != null &&
          !creditsManager.canGenerate(generationCreditLane)) {
        throw ApiException(
          localizations.errorReachedLimit,
          code: 'LIMIT_MEDIA_INSUFFICIENT',
        );
      }

      final hasInternet = await InternetConnection().hasInternetAccess;
""",
)

replace_once(
    'lib/chat/services/send/media.dart',
    "import '../../../../library/backend/data/service.dart';\n",
    "import '../../../../library/backend/data/service.dart';\n"
    "import '../generation.dart';\n",
)
replace_once(
    'lib/chat/services/send/media.dart',
    """  generateVideo,
  generateAudio,
}
""",
    """  generateVideo,
  generateAudio,
  generateMusic,
}
""",
)
replace_once(
    'lib/chat/services/send/media.dart',
    "    const audioTerms = ['audio', 'voice', 'sound', 'music', 'ses', 'muzik'];\n",
    """    const audioTerms = [
      'audio',
      'voice',
      'sound',
      'speech',
      'ses',
      'konusma',
      'anlatim'
    ];
""",
)
replace_once(
    'lib/chat/services/send/media.dart',
    """    final mentionsAudio = _containsAny(normalized, audioTerms);

    if (hasImage && !hasVideo && mentionsVideo && (edits || generates)) {
""",
    """    final mentionsAudio = _containsAny(normalized, audioTerms);
    final mentionsMusic = isMusicGenerationPrompt(text);

    if (hasImage && !hasVideo && mentionsVideo && (edits || generates)) {
""",
)
replace_once(
    'lib/chat/services/send/media.dart',
    "                (mentionsImage || !mentionsVideo && !mentionsAudio)))) {\n",
    """                (mentionsImage ||
                    !mentionsVideo && !mentionsAudio && !mentionsMusic)))) {
""",
)
replace_once(
    'lib/chat/services/send/media.dart',
    """    if (generates && mentionsVideo) return MediaIntent.generateVideo;
    if (generates && mentionsAudio) return MediaIntent.generateAudio;
""",
    """    if (generates && mentionsVideo) return MediaIntent.generateVideo;
    if (generates && mentionsMusic) return MediaIntent.generateMusic;
    if (generates && mentionsAudio) return MediaIntent.generateAudio;
""",
)
replace_once(
    'lib/chat/services/send/media.dart',
    """      case MediaIntent.generateAudio:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case MediaIntent.understand:
""",
    """      case MediaIntent.generateAudio:
        routed = findFalMediaModel(
          langCode: langCode,
          isUserSubscribed: isUserSubscribed,
          outputType: 'audio',
          requiredInputType: hasAudio ? 'audio' : null,
        );
        break;
      case MediaIntent.generateMusic:
        // A generic audio model can be a speech/SFX model. Do not pin a
        // musical request to the first audio-capable FAL model; leave it on
        // Cortex Dynamic Chat so Fulcrum can select its dedicated music route.
        routed = null;
        break;
      case MediaIntent.understand:
""",
)
