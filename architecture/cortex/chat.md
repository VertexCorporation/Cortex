# Chat Architecture

The active conversation pipeline. Conversation history (Axon) is summarized in `overview.md`; the model catalog is covered in `library.md`; the server side of this pipeline is covered in `../fulcrum/generation.md`.

## Pipeline

Input widgets -> InputProvider/ChatSessionProvider -> SendService -> Context/memory/PII/RAG -> ApiService proxy/SSE -> Processor/Response/media/tools -> ConversationProvider -> message tiles -> storage/history.

## State ownership (chat/providers/)

- `ConversationProvider` (conversation.dart) owns active messages and streaming flags.
- `InputProvider` (input.dart) owns drafts, attachments and feature modes (`InputAttachment`, `ChatInputMode`, `AttachmentType`).
- `ChatSessionProvider` (session.dart) owns model selection and dynamic-chat decisions.
- `UserMemoryProvider` (memory.dart) owns extracted long-term user memory.

`ChatController`/`ChatControllerState` (controller.dart) is the screen controller. `ChatView` (screen/view.dart) composes the screen: appbar (`Appbar`, login bubble, premium button, offer), default empty state (`ChatEmptyState`, `DefaultCard`), message list, and the bottom input panel.

## Send orchestration (chat/services/)

`SendService` (send.dart) is the central orchestrator for validation, context, online/offline/media generation, streaming, persistence and UI state. Entry point `sendMessage`; guest limits via `checkGuestLimit`; RAG context via `_buildRagContext`; server sends loop with `_sendServerSideMessageWithLoop`; generated media attached and persisted (`_attachGeneratedMediaToAiMessage`, `_persistGeneratedMedia`); background completion/error are persisted and notified (`_persistBackgroundCompletion`, `_persistBackgroundError`).

Sub-services under `chat/services/send/`: `CircuitBreaker` (circuit.dart), `MediaRouter`/`MediaIntent` (media.dart), `MediaSaver` (saver.dart), `StreamBuffer` (stream.dart), `BackgroundNotifier` (notify.dart).

Around it: `ContextService` (context construction), `SemanticMemoryService` (memory_store.dart), `PromptCompressionEngine` (compression.dart), `LocalPiiRedactionFilter` (pii_filter.dart), `OfflineModeratorService` (moderator.dart), `ChatLimitManager` (limit.dart), `EditService`, `RegenerateService`, `StopService`, `ReadService` (read-aloud), `ReviewService`, `ScrollService`, `SelectionService`, `ResponseService`, `MetricsTracker`/`ResponseMetrics`, `ChatFormatProcessor` (processor.dart — stream/message normalization, stop-token detection), `BackgroundTaskService` (background.dart), `ChatStorageService` (storage.dart) + `DbHelper` (database.dart).

## Online transport (chat/services/api.dart)

`ApiService` is the authenticated Dio/SSE proxy gateway to Fulcrum's `sendMessage` endpoint. It parses text, reasoning, tools, citations, search, title and media events. Also: `getCharacterResponse` (roleplay), `optimizeImagePrompt`, `generateChatTitle`, `extractUserMemory`, `getOnlineModelResponse`, `cancelRequests`. Errors: `UserCancelledException`, `ApiException`. The SSE event contract is a client compatibility contract — see `../fulcrum/generation.md` before changing it.

## Offline generation

`OfflineService` (offline.dart) runs local models with `SamplerPreset`; `SpeculativeDecodingConfig`/`SpeculativeDecodingMath` (speculative.dart) support speculative decoding. Release local model resources when `ChatController` is disposed.

## Voice, TTS and STT

Two deliberately separate speech experiences behind `SpeechService` (speech.dart) — the app's single microphone gateway; there is exactly one logical mic owner at any moment, and a new owner always stops the previous capture first:

- **Ordinary dictation** (composer mic button, `SpeechOwner.dictation`): native recognizer ONLY — the app language is mapped to an installed recognizer locale with an English fallback, and no remote speech credits are ever spent.
- **Voice Mode / Flow Mode** (`SpeechOwner.voice`/`flow`): remote-first — `RemoteSttService` (stt_remote.dart) requests Fulcrum's role-based `realtime_voice_stt` route, then executes the returned provider adapter (ElevenLabs Scribe, Deepgram, AssemblyAI, or a migration fallback) with a sticky session route. The native recognizer is the final resilience fallback for provider/transport failures only. HTTP 401/402/403 block fallback across all speech engines; only 403 `voice_daily_limit` marks the shared allowance exhausted. Token responses are read as plain text before safe object decoding, including malformed JSON and infrastructure error pages. Start/stop are serialized and epoch-guarded inside `RemoteSttService`, so no ghost recorder or socket can survive a superseded session.

`VoiceService` (voice.dart) owns the realtime session lifecycle: an explicit `VoiceState` machine (idle/connecting/listening/processing/speaking/failed), session generations (every STT result, timer, TTS completion, flow turn and reconnect is generation-guarded; stale artifacts of a stopped session can never mutate its successor), one CONTINUOUS provider session per voice session recycled at the server's reserved-window boundary (the daily pool is re-checked at every mint), amplitude+transcript barge-in while the assistant speaks, bounded reconnects (3/session), a 90s inactivity timeout, and an Android foreground-service bridge that keeps an active session alive across screen lock/background. Voice and Flow share this one core — Flow is a mode flag plus agent cycling on top of the same session.

`TtsService`/`TtsState` + `RemoteTtsService` (tts_remote.dart — ElevenLabs, proxied per sentence through Fulcrum with native flutter_tts fallback; also serves read-aloud), `VoiceCatalogProvider`/`CortexVoice` (voice_catalog.dart). Provider secrets (Deepgram, AssemblyAI, ElevenLabs) stay server-side behind Fulcrum `voice.js` endpoints.

The daily realtime Voice/Flow allowance (seconds; one shared pool for both modes) is SERVER-authoritative: Fulcrum reserves a window at every speech-token mint and reconciles at settlement; the client only mirrors `creditLimits.voiceDailySeconds` + `voiceUsage` from the user snapshot and the mint response (`SttLease`) for the countdown and early-out.

## Voice Mode presentation

`InputProvider.isVoiceModeActive` owns the composer transition: entry hides
only the center capsule and changes the visible side controls to Flow/X.
`isVoiceOverlayExpanded` controls only orb geometry and conversation presentation.
Compact and expanded Voice Mode both keep Flow/X; only X restores text input.
The 380 ms entry retains the existing composer expansion geometry, grows controls around their centers, and moves the shrinking capsule upward as the orb emerges from its collapse point. Flow always paints its frame and X retains its fixed glyph size. There is no separate transcript or rectangular dim surface above the controls.

`VoiceOrbController` keeps one continuous ticker across phases and sizes. It
integrates smoothed liquid speed, slowly interpolates internal palettes, and
paints a bounded six-second breath without changing layout or border thickness.
Remote TTS requests 16 kHz PCM, wraps it in WAV for playback, and derives a
smoothed output envelope from the exact samples being played. Microphone
amplitude remains smoothed from `SpeechService`; both envelopes feed the orb
shader independently.

The overlay uses the published allowance and terminal server limit response to
show an internal purple palette. A live reserved window is not treated as
exhausted merely because the unreserved pool is empty. Exhausted orb/Flow taps
use `UserProvider.subscription.effectiveTier` to open the next plan (Free → Plus, Plus → Pro, Pro → Ultra). Ultra remains on the exhausted visual; these taps cannot retry audio.
Plus, Pro and Ultra share the localized `benefitMoreVoiceChat` benefit.

## Tools

`CortexTool`/`ToolRegistry` (tools.dart) define and render tools; `ToolWidgetFactory` renders weather/crypto/chart cards (screen/widgets/tools.dart); `CodeExecutionWidget` (execution.dart) renders hosted execution results; `ToolStatusWidget`/`ToolActivityWidget` show live tool status; `Utils` (utils.dart) holds shared helpers.

## Message rendering (chat/messages/)

Markdown is split into `blocks.dart`/`inline.dart`/`parser.dart`/`patterns.dart` (`RegexPatterns`)/`utils.dart` (`SafeMathTex`, `MatchRange`). Tiles: `AIMessageTile` (with content, header, inline options, error, `RevealText`/`RevealTimeline` reveal animation and `ThoughtProcessWidget`), `UserMessageTile`, `CodeBlockWidget`, media viewers (`PhotoViewer`/`VideoViewer`/`AudioViewer`), `MessageListSkeleton`. Message options live in `messages/options/` (animated panel, items, manager, model selection, report dialog, text select). `Message`/`MediaGenerationType` (messages.dart) is the domain model with serialization, attachments and transient streaming/UI state.

## Input area (chat/screen/widgets/bottom/)

`ChatInputPanel` with `InputField`, attachment previews, buttons (`ModelSelectButton`, `AddPhotoButton`, `ActionButtonWidget`), `InputService`, waveform visualizer, `_RagStatusChip` (RAG status), guest-limit sheet, and feature/selection/edit/briefing panels (`AnimatedMessageOptionsPanel`, model selection sheet, `BriefingOverlay`).

Recording entry and exit share the composer’s 600 ms controller. `RecordingLayout` measures both modes and interpolates their heights; opacity and microphone width use the same progress, with the idle layout retained throughout reversal.

## Rules

- Preserve conversation-ID checks during streaming.
- Verify both `tiles.temp.dart` and `tiles_temp.dart` before removing either.
- The complete file list for every chat subdirectory is in `file-map.md`.

Generation placeholders share one bordered background card with a centered localized icon/label and distributed pulsing dots; image, video, audio and document statuses use the same presentation. Reduced-motion mode freezes the dots. Document placeholders respond to the `generating_document` stream event. Status labels use bundled Inter Regular.
