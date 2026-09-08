# Cortex File Map

Exhaustive catalog of all 304 Dart files under `lib/`, each with its detected declarations and file responsibility.

Use this document to locate code: when you know a symbol but not its file, search here instead of scanning the repository. If you already know the file you need, skip this document. Area narratives live in the sibling documents: `overview.md`, `chat.md`, `rag.md`, `library.md`, `auth.md`, `payments.md`.

### `analytics/`

- **`lib/analytics/service.dart`** — Service implementation for the analytics area. Declarations: `AnalyticsService`.
### `app.dart/`

- **`lib/app.dart`** — Root MaterialApp: theme, localization, navigation and analytics. Declarations: `Cortex, InvertedColor`.
### `appbar.dart/`

- **`lib/appbar.dart`** — App bar UI for the  area. Declarations: `CortexAppBar, DualActionPill, _BackButton, _AxonToggleButton, _AxonToggleButtonState, _AnimatedTitleWrapper, _AnimatedTitleWrapperState, AppBarButton, CortexLeadingMode`.
### `arts/`

- **`lib/arts/provider.dart`** — Reactive Provider state for the arts area. Declarations: `ArtItem, ArtsProvider, ArtType`.
- **`lib/arts/screen.dart`** — Feature implementation for the arts area. Declarations: `ArtsScreen, _ArtsScreenState, _ArtTile`.
### `axon/`

- **`lib/axon/content.dart`** — Feature implementation for the axon area. Declarations: `AxonContent`.
- **`lib/axon/helpers.dart`** — Feature implementation for the axon area. Declarations: `AxonAvatar, _AxonAvatarState, _RightHalfRainbowPainter`.
- **`lib/axon/inbox/empty.dart`** — Feature implementation for the axon/inbox area. Declarations: `EmptyStateView`.
- **`lib/axon/inbox/logic/general.dart`** — Feature implementation for the axon/inbox/logic area. Declarations: `InboxViewModel, _SnapshotUpdate`.
- **`lib/axon/inbox/logic/manager.dart`** — Feature implementation for the axon/inbox/logic area. Declarations: `ConversationManager`.
- **`lib/axon/inbox/logic/search_hit.dart`** — Feature implementation for the axon/inbox/logic area. Declarations: `SearchHit`.
- **`lib/axon/inbox/panel/actions/edit.dart`** — Message editing flow for the axon/inbox/panel/actions area.
- **`lib/axon/inbox/panel/buttons.dart`** — Feature implementation for the axon/inbox/panel area. Declarations: `ActionPanelButton`.
- **`lib/axon/inbox/panel/view.dart`** — Screen/view composition for the axon/inbox/panel area. Declarations: `ActionPanelController, _AnimatedPanelContainer, _AnimatedPanelContainerState`.
- **`lib/axon/inbox/skeleton.dart`** — Loading skeleton UI for the axon/inbox area. Declarations: `SkeletonChatList, SkeletonChatTile`.
- **`lib/axon/inbox/tile/avatar.dart`** — Feature implementation for the axon/inbox/tile area. Declarations: `TileAvatar`.
- **`lib/axon/inbox/tile/view.dart`** — Screen/view composition for the axon/inbox/tile area. Declarations: `AxonConversationTile, _AxonConversationTileState, _BackgroundProgressIndicator, _BackgroundProgressIndicatorState, _BackgroundProgressPainter`.
- **`lib/axon/view.dart`** — Screen/view composition for the axon area. Declarations: `Axon, _AxonState`.
- **`lib/axon/widgets/header.dart`** — Header UI for the axon/widgets area. Declarations: `AxonHeader`.
- **`lib/axon/widgets/item.dart`** — Feature implementation for the axon/widgets area. Declarations: `AxonItem`.
- **`lib/axon/widgets/list.dart`** — Feature implementation for the axon/widgets area. Declarations: `AxonConversationList, _AxonConversationListState, _SkeletonTilePlain`.
- **`lib/axon/widgets/menu.dart`** — Feature implementation for the axon/widgets area. Declarations: `AxonMenu`.
- **`lib/axon/widgets/search.dart`** — Feature implementation for the axon/widgets area. Declarations: `SearchHitTile`.
### `boundary.dart/`

- **`lib/boundary.dart`** — Feature implementation for the  area. Declarations: `ErrorBoundary, _ErrorBoundaryState, ErrorWidgetBuilder, BoundaryAction`.
### `cache.dart/`

- **`lib/cache.dart`** — Feature implementation for the  area. Declarations: `AppDataState, CacheService, CacheKey`.
### `chat/`

- **`lib/chat/controller.dart`** — Controller and lifecycle/state orchestration for the chat area. Declarations: `ChatController, ChatControllerState`.
- **`lib/chat/messages/codeblocks.dart`** — Feature implementation for the chat/messages area. Declarations: `CodeBlockWidget, _CodeBlockWidgetState`.
- **`lib/chat/messages/markdown/blocks.dart`** — Block rich-text rendering for the chat/messages/markdown area.
- **`lib/chat/messages/markdown/inline.dart`** — Inline rich-text rendering for the chat/messages/markdown area.
- **`lib/chat/messages/markdown/parser.dart`** — Parser implementation for the chat/messages/markdown area.
- **`lib/chat/messages/markdown/patterns.dart`** — Parsing patterns for the chat/messages/markdown area. Declarations: `RegexPatterns`.
- **`lib/chat/messages/markdown/utils.dart`** — Shared utility functions for the chat/messages/markdown area. Declarations: `SafeMathTex, MatchRange`.
- **`lib/chat/messages/messages.dart`** — Message domain model, serialization, attachments and transient streaming/UI state. Declarations: `Message, MediaGenerationType`.
- **`lib/chat/messages/options/change.dart`** — Feature implementation for the chat/messages/options area. Declarations: `_UIFactors, _ModelSelectionDialogContent, _ModelSelectionDialogContentState`.
- **`lib/chat/messages/options/item.dart`** — Feature implementation for the chat/messages/options area. Declarations: `_UIFactors, OptionPanelItem`.
- **`lib/chat/messages/options/manager.dart`** — Feature implementation for the chat/messages/options area.
- **`lib/chat/messages/options/panel.dart`** — Feature implementation for the chat/messages/options area. Declarations: `_UIFactors, OptionsPanelViewModel, AnimatedMessageOptionsPanel, _AnimatedMessageOptionsPanelState, MessageOption`.
- **`lib/chat/messages/options/report.dart`** — Feature implementation for the chat/messages/options area. Declarations: `ReportDialog, _ReportDialogState, ReportSubject`.
- **`lib/chat/messages/options/select.dart`** — Selection flow for the chat/messages/options area. Declarations: `SelectTextScreen, SelectTextScreenState`.
- **`lib/chat/messages/skeleton.dart`** — Loading skeleton UI for the chat/messages area. Declarations: `MessageListSkeleton, _MessageListSkeletonState, _SkeletonItemData`.
- **`lib/chat/messages/tiles/ai.dart`** — Feature implementation for the chat/messages/tiles area. Declarations: `AiStreamFinishedNotification, AiMessageRevealNotification, AIMessageTile, _AIMessageTileState`.
- **`lib/chat/messages/tiles/ai/content.dart`** — Feature implementation for the chat/messages/tiles/ai area. Declarations: `_AiBodyContent, ThoughtProcessWidget, _ThoughtProcessWidgetState`.
- **`lib/chat/messages/tiles/ai/error.dart`** — Feature implementation for the chat/messages/tiles/ai area. Declarations: `_AiErrorWidget, _AiErrorWidgetState`.
- **`lib/chat/messages/tiles/ai/header.dart`** — Header UI for the chat/messages/tiles/ai area. Declarations: `_AiHeader, _SearchingLabel, _HeaderData`.
- **`lib/chat/messages/tiles/ai/options.dart`** — Message option controls for the chat/messages/tiles/ai area. Declarations: `_InlineOptionsRow, _InlineOptionsRowState`.
- **`lib/chat/messages/tiles/ai/reveal_text.dart`** — Feature implementation for the chat/messages/tiles/ai area. Declarations: `RevealText, _RevealTextState, RevealGlyph, _GlyphPaint, _RenderGlyphPaint`.
- **`lib/chat/messages/tiles/ai/reveal_timeline.dart`** — Feature implementation for the chat/messages/tiles/ai area. Declarations: `RevealTimeline`.
- **`lib/chat/messages/tiles/user.dart`** — Feature implementation for the chat/messages/tiles area. Declarations: `UserMessageTile, UserMessageTileState`.
- **`lib/chat/messages/viewer.dart`** — Feature implementation for the chat/messages area. Declarations: `PhotoViewer, PhotoViewerState, VideoViewer, _VideoViewerState, AudioViewer, _AudioViewerState`.
- **`lib/chat/providers/conversation.dart`** — Feature implementation for the chat/providers area. Declarations: `ConversationProvider`.
- **`lib/chat/providers/input.dart`** — Input UI and behavior for the chat/providers area. Declarations: `InputAttachment, InputProvider, ChatInputMode, AttachmentType`.
- **`lib/chat/providers/memory.dart`** — Feature implementation for the chat/providers area. Declarations: `UserMemoryProvider`.
- **`lib/chat/providers/session.dart`** — Feature implementation for the chat/providers area. Declarations: `ChatSessionProvider`.
- **`lib/chat/screen/appbar/appbar.dart`** — App bar UI for the chat/screen/appbar area. Declarations: `Appbar, AppbarState`.
- **`lib/chat/screen/appbar/login.dart`** — Login UI for the chat/screen/appbar area. Declarations: `LoginBubbleButton`.
- **`lib/chat/screen/appbar/offer.dart`** — Feature implementation for the chat/screen/appbar area. Declarations: `ClaimOfferButton, _ClaimOfferButtonState`.
- **`lib/chat/screen/appbar/premium.dart`** — Feature implementation for the chat/screen/appbar area. Declarations: `PremiumButton, _PremiumButtonState`.
- **`lib/chat/screen/default/cards.dart`** — Card UI for the chat/screen/default area. Declarations: `DefaultCard`.
- **`lib/chat/screen/default/view.dart`** — Screen/view composition for the chat/screen/default area. Declarations: `ChatEmptyState, _ChatEmptyStateState`.
- **`lib/chat/screen/view.dart`** — Screen/view composition for the chat/screen area. Declarations: `ChatView, ChatViewState, _BriefingOverlayWrapper`.
- **`lib/chat/screen/widgets/audio.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `AudioPlayerWidget, _AudioPlayerWidgetState`.
- **`lib/chat/screen/widgets/bottom/bottom.dart`** — Feature implementation for the chat/screen/widgets/bottom area. Declarations: `ChatInputPanel, _ChatInputPanelState`.
- **`lib/chat/screen/widgets/bottom/guest.dart`** — Feature implementation for the chat/screen/widgets/bottom area. Declarations: `_GuestLimitSheetContent, _GuestLimitSheetContentState`.
- **`lib/chat/screen/widgets/bottom/input/attachments.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_AttachmentPreviewSection, _AttachmentListWithFog, _AttachmentListWithFogState, _AttachmentItem`.
- **`lib/chat/screen/widgets/bottom/input/buttons.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_ToolCircleButton, ActionButtonWidget, AddPhotoButton, _AddPhotoButtonState, ModelSelectButton`.
- **`lib/chat/screen/widgets/bottom/input/field.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_TextFieldSection`.
- **`lib/chat/screen/widgets/bottom/input/input.dart`** — Input UI and behavior for the chat/screen/widgets/bottom/input area. Declarations: `InputField, InputFieldState`.
- **`lib/chat/screen/widgets/bottom/input/rag.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_RagStatusChip`.
- **`lib/chat/screen/widgets/bottom/input/sections.dart`** — Feature/settings sections for the chat/screen/widgets/bottom/input area. Declarations: `WaveformSection, AttachmentPreviewSection, AttachmentListWithFog, _AttachmentListWithFogState, AttachmentItem, TextFieldSection, SendButtonSection, SequencedToolsTransition, _SequencedToolsTransitionState`.
- **`lib/chat/screen/widgets/bottom/input/send.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_SendButtonSection`.
- **`lib/chat/screen/widgets/bottom/input/service.dart`** — Service implementation for the chat/screen/widgets/bottom/input area. Declarations: `InputService`.
- **`lib/chat/screen/widgets/bottom/input/waveform.dart`** — Feature implementation for the chat/screen/widgets/bottom/input area. Declarations: `_WaveformSection`.
- **`lib/chat/screen/widgets/bottom/panels/attachments/button.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/attachments area. Declarations: `AttachmentSheetButton`.
- **`lib/chat/screen/widgets/bottom/panels/attachments/sheet.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/attachments area.
- **`lib/chat/screen/widgets/bottom/panels/briefing.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels area. Declarations: `BriefingOverlay, _BriefingOverlayState, _BriefingPanelContent, _BriefingPanelContentState`.
- **`lib/chat/screen/widgets/bottom/panels/edit.dart`** — Message editing flow for the chat/screen/widgets/bottom/panels area. Declarations: `EditPanelWidget`.
- **`lib/chat/screen/widgets/bottom/panels/features/button.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/features area. Declarations: `FeaturesSheetButton`.
- **`lib/chat/screen/widgets/bottom/panels/features/sheet.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/features area. Declarations: `_FeaturesSheetContent, _FeaturesSheetContentState`.
- **`lib/chat/screen/widgets/bottom/panels/selection/cards/main.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/selection/cards area. Declarations: `ModelCard`.
- **`lib/chat/screen/widgets/bottom/panels/selection/cards/variant.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/selection/cards area. Declarations: `ModelVariantCard`.
- **`lib/chat/screen/widgets/bottom/panels/selection/sheet.dart`** — Feature implementation for the chat/screen/widgets/bottom/panels/selection area. Declarations: `_ModelSheetContent, _ModelSheetContentState, _VariantsPanel`.
- **`lib/chat/screen/widgets/bottom/panels/selection/skeleton.dart`** — Loading skeleton UI for the chat/screen/widgets/bottom/panels/selection area. Declarations: `ModelSelectionSkeleton`.
- **`lib/chat/screen/widgets/bottom/sources.dart`** — Feature implementation for the chat/screen/widgets/bottom area. Declarations: `WebSearchSourcesWidget`.
- **`lib/chat/screen/widgets/execution.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `CodeExecutionWidget, _CodeExecutionWidgetState`.
- **`lib/chat/screen/widgets/glow.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `AmbientGlow, _AmbientGlowState`.
- **`lib/chat/screen/widgets/list.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `ChatMessageList, _ChatMessageListState`.
- **`lib/chat/screen/widgets/media.dart`** — Media routing for the chat/screen/widgets area. Declarations: `MediaShimmerPlaceholder`.
- **`lib/chat/screen/widgets/player.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `TtsPlayerOverlay, _TtsPlayerOverlayState, _TtsPlayerBar`.
- **`lib/chat/screen/widgets/sources.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `Source, SourceCarousel, _SourceCard`.
- **`lib/chat/screen/widgets/status.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `ToolStatusWidget, _ToolStatusWidgetState`.
- **`lib/chat/screen/widgets/thinking.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `ThinkingWidget, _ThinkingWidgetState, ToolActivityWidget, _ToolActivityWidgetState`.
- **`lib/chat/screen/widgets/tiles.dart`** — Message tile composition for the chat/screen/widgets area. Declarations: `Tiles, _VideoAttachmentCard, _VideoAttachmentCardState`.
- **`lib/chat/screen/widgets/tiles.temp.dart`** — Feature implementation for the chat/screen/widgets area.
- **`lib/chat/screen/widgets/tiles_temp.dart`** — Feature implementation for the chat/screen/widgets area.
- **`lib/chat/screen/widgets/tools.dart`** — Tool definitions and rendering for the chat/screen/widgets area. Declarations: `ToolWidgetFactory, ToolAnimationWrapper, WeatherCard, CryptoCard, _CryptoCardState, InkWithHover, _InkWithHoverState, ChartCard, _ChartCardState, WorkInProgressWidget, _WorkInProgressWidgetState`.
- **`lib/chat/screen/widgets/voice.dart`** — Voice interaction for the chat/screen/widgets area. Declarations: `VoiceSessionOverlay, _VoiceSessionOverlayState, _ScaleButton, _ScaleButtonState, _MorphingVisualizer, _MorphingVisualizerState`.
- **`lib/chat/screen/widgets/wave.dart`** — Feature implementation for the chat/screen/widgets area. Declarations: `WaveformVisualizer, _WaveformNotifier, _WaveformVisualizerState, _ModernWavePainter, WaveOrigin`.
- **`lib/chat/services/api.dart`** — Authenticated Dio/SSE proxy gateway; parses text, reasoning, tools, citations, search, title and media events. Declarations: `UserCancelledException, ApiException, ApiService`.
- **`lib/chat/services/background.dart`** — Feature implementation for the chat/services area. Declarations: `BackgroundTaskService, _BackgroundTaskState`.
- **`lib/chat/services/compression.dart`** — Feature implementation for the chat/services area. Declarations: `PromptCompressionEngine`.
- **`lib/chat/services/context.dart`** — Conversation context construction for the chat/services area. Declarations: `ContextService`.
- **`lib/chat/services/database.dart`** — Database access for the chat/services area. Declarations: `DbHelper`.
- **`lib/chat/services/edit.dart`** — Message editing flow for the chat/services area. Declarations: `EditService`.
- **`lib/chat/services/generation.dart`** — Generation feature-mode helpers for the chat/services area.
- **`lib/chat/services/limit.dart`** — Feature implementation for the chat/services area. Declarations: `ChatLimitManager`.
- **`lib/chat/services/memory_store.dart`** — Feature implementation for the chat/services area. Declarations: `SemanticMemoryService`.
- **`lib/chat/services/metrics.dart`** — Feature implementation for the chat/services area. Declarations: `ResponseMetrics, MetricsTracker`.
- **`lib/chat/services/moderator.dart`** — Feature implementation for the chat/services area. Declarations: `OfflineModeratorService`.
- **`lib/chat/services/offline.dart`** — Offline model runtime for the chat/services area. Declarations: `SamplerPreset, OfflineService`.
- **`lib/chat/services/pii_filter.dart`** — Feature implementation for the chat/services area. Declarations: `LocalPiiRedactionFilter`.
- **`lib/chat/services/processor.dart`** — Stream/message normalization for the chat/services area. Declarations: `ChatFormatProcessor, OnStopTokenDetected`.
- **`lib/chat/services/read.dart`** — Feature implementation for the chat/services area. Declarations: `ReadService`.
- **`lib/chat/services/regenerate.dart`** — Regeneration flow for the chat/services area. Declarations: `RegenerateService`.
- **`lib/chat/services/response.dart`** — Response finalization for the chat/services area. Declarations: `ResponseService`.
- **`lib/chat/services/review.dart`** — Feature implementation for the chat/services area. Declarations: `ReviewService`.
- **`lib/chat/services/scroll.dart`** — Chat scroll coordination for the chat/services area. Declarations: `ScrollService`.
- **`lib/chat/services/select.dart`** — Selection flow for the chat/services area. Declarations: `SelectionService`.
- **`lib/chat/services/send.dart`** — Central chat orchestrator for validation, context, online/offline/media generation, streaming, persistence and UI state. Declarations: `SendService`.
- **`lib/chat/services/send/circuit.dart`** — Circuit breaker for the chat/services/send area. Declarations: `CircuitBreaker`.
- **`lib/chat/services/send/media.dart`** — Media routing for the chat/services/send area. Declarations: `MediaRouter, MediaIntent`.
- **`lib/chat/services/send/notify.dart`** — Background notification for the chat/services/send area. Declarations: `BackgroundNotifier`.
- **`lib/chat/services/send/saver.dart`** — Media saving for the chat/services/send area. Declarations: `MediaSaver`.
- **`lib/chat/services/send/stream.dart`** — Streaming buffer for the chat/services/send area. Declarations: `StreamBuffer`.
- **`lib/chat/services/speculative.dart`** — Feature implementation for the chat/services area. Declarations: `SpeculativeDecodingConfig, SpeculativeDecodingMath`.
- **`lib/chat/services/speech.dart`** — Speech interaction for the chat/services area. Declarations: `SpeechService`.
- **`lib/chat/services/stop.dart`** — Generation stop flow for the chat/services area. Declarations: `StopService`.
- **`lib/chat/services/storage.dart`** — Persistence/storage for the chat/services area. Declarations: `ChatStorageService`.
- **`lib/chat/services/stt_remote.dart`** — Feature implementation for the chat/services area. Declarations: `SttResult, _SpeechLease, RemoteSttService`.
- **`lib/chat/services/tools.dart`** — Tool definitions and rendering for the chat/services area. Declarations: `CortexTool, ToolRegistry`.
- **`lib/chat/services/tts.dart`** — Text-to-speech for the chat/services area. Declarations: `TtsService, TtsState`.
- **`lib/chat/services/tts_remote.dart`** — Feature implementation for the chat/services area. Declarations: `RemoteTtsService`.
- **`lib/chat/services/utils.dart`** — Shared utility functions for the chat/services area. Declarations: `Utils`.
- **`lib/chat/services/voice.dart`** — Voice interaction for the chat/services area. Declarations: `VoiceService, VoiceState`.
- **`lib/chat/services/voice_catalog.dart`** — Feature implementation for the chat/services area. Declarations: `CortexVoice, VoiceCatalogProvider, VoiceGender`.
### `darkener.dart/`

- **`lib/darkener.dart`** — Feature implementation for the  area. Declarations: `Darkener, RestoreCallback`.
### `design.dart/`

- **`lib/design.dart`** — Feature implementation for the  area.
### `error.dart/`

- **`lib/error.dart`** — Feature implementation for the  area. Declarations: `ErrorView`.
### `errors.dart/`

- **`lib/errors.dart`** — Feature implementation for the  area. Declarations: `ChatErrorState`.
### `fog.dart/`

- **`lib/fog.dart`** — Feature implementation for the  area. Declarations: `ScrollFog, _ScrollFogState, ScrollFogHorizontal, _ScrollFogHorizontalState`.
### `funds/`

- **`lib/funds/backend.dart`** — Backend integration for the funds area.
- **`lib/funds/backend/offer.dart`** — Feature implementation for the funds/backend area. Declarations: `FundsSpecialOffer`.
- **`lib/funds/backend/products.dart`** — Feature implementation for the funds/backend area. Declarations: `TrialInfo, FundsProducts`.
- **`lib/funds/backend/purchase.dart`** — Feature implementation for the funds/backend area. Declarations: `FundsPurchase`.
- **`lib/funds/backend/receipt.dart`** — Feature implementation for the funds/backend area. Declarations: `FundsReceipt`.
- **`lib/funds/backend/service.dart`** — Service implementation for the funds/backend area. Declarations: `FundsBackend`.
- **`lib/funds/backend/user.dart`** — Feature implementation for the funds/backend area. Declarations: `FundsUserData`.
- **`lib/funds/backend/verification.dart`** — Feature implementation for the funds/backend area. Declarations: `FundsVerification`.
- **`lib/funds/funds.dart`** — Funds/subscription feature for the funds area. Declarations: `FundsScreen, FundsScreenView, _FundsScreenViewState`.
- **`lib/funds/skeleton.dart`** — Loading skeleton UI for the funds area. Declarations: `FundsSkeletonLoader`.
- **`lib/funds/widgets/subscriptions.dart`** — Feature implementation for the funds/widgets area. Declarations: `SubscriptionContentWidget, _SubscriptionContentWidgetState, _FadingBenefitItem, _FadingBenefitItemState, StringVariant`.
### `initialization.dart/`

- **`lib/initialization.dart`** — Startup readiness, authentication state, onboarding and upgrade coordination. Declarations: `AppUpgraderMessages, AppInitializer, AppStatus`.
### `internet.dart/`

- **`lib/internet.dart`** — Feature implementation for the  area. Declarations: `InternetProvider, InternetService`.
### `invite.dart/`

- **`lib/invite.dart`** — Feature implementation for the  area. Declarations: `InviteService`.
### `l10n/`

- **`lib/l10n/app_localizations.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizations, _AppLocalizationsDelegate`.
- **`lib/l10n/app_localizations_ar.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsAr`.
- **`lib/l10n/app_localizations_az.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsAz`.
- **`lib/l10n/app_localizations_cs.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsCs`.
- **`lib/l10n/app_localizations_de.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsDe`.
- **`lib/l10n/app_localizations_en.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsEn`.
- **`lib/l10n/app_localizations_es.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsEs`.
- **`lib/l10n/app_localizations_fr.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsFr`.
- **`lib/l10n/app_localizations_hi.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsHi`.
- **`lib/l10n/app_localizations_hu.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsHu`.
- **`lib/l10n/app_localizations_id.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsId`.
- **`lib/l10n/app_localizations_it.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsIt`.
- **`lib/l10n/app_localizations_ja.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsJa`.
- **`lib/l10n/app_localizations_ko.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsKo`.
- **`lib/l10n/app_localizations_nl.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsNl`.
- **`lib/l10n/app_localizations_no.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsNo`.
- **`lib/l10n/app_localizations_pt.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsPt`.
- **`lib/l10n/app_localizations_ru.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsRu`.
- **`lib/l10n/app_localizations_sv.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsSv`.
- **`lib/l10n/app_localizations_tr.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsTr`.
- **`lib/l10n/app_localizations_zh.dart`** — Feature implementation for the l10n area. Declarations: `AppLocalizationsZh`.
### `language.dart/`

- **`lib/language.dart`** — Locale state for the  area. Declarations: `LocaleProvider`.
### `library/`

- **`lib/library/backend/data/crypto.dart`** — Feature implementation for the library/backend/data area. Declarations: `CryptoHelper`.
- **`lib/library/backend/data/database.dart`** — Database access for the library/backend/data area. Declarations: `DatabaseHelper`.
- **`lib/library/backend/data/defaults.dart`** — Feature implementation for the library/backend/data area. Declarations: `ModelDefaults`.
- **`lib/library/backend/data/entity.dart`** — Feature implementation for the library/backend/data area. Declarations: `ModelEntity`.
- **`lib/library/backend/data/format.dart`** — Formatting and token helpers for the library/backend/data area. Declarations: `ChatTokens, ChatFormat`.
- **`lib/library/backend/data/image.dart`** — Image cache/path handling for the library/backend/data area. Declarations: `ModelImageCache`.
- **`lib/library/backend/data/repository.dart`** — Feature implementation for the library/backend/data area. Declarations: `ModelRepository`.
- **`lib/library/backend/data/service.dart`** — Model business layer: repository fetch, hydration, cache, sorting and base-model validation. Declarations: `ModelService`.
- **`lib/library/backend/data/user.dart`** — Feature implementation for the library/backend/data area. Declarations: `UserModels`.
- **`lib/library/backend/download/controller.dart`** — Controller and lifecycle/state orchestration for the library/backend/download area. Declarations: `ModelDownloadController`.
- **`lib/library/backend/download/download.dart`** — Download support for the library/backend/download area. Declarations: `DownloadManager, DownloadedModelsManager, DownloadedModel, FileDownloadHelper, _DownloadTaskInfo`.
- **`lib/library/backend/remove.dart`** — Removal operations for the library/backend area. Declarations: `ModelRemoveService`.
- **`lib/library/backend/system.dart`** — System/device information for the library/backend area. Declarations: `SystemInfoProvider, SystemInfoData`.
- **`lib/library/backend/utils.dart`** — Shared utility functions for the library/backend area. Declarations: `ModelsBackendUtils, CompatibilityStatus`.
- **`lib/library/providers/catalog.dart`** — Feature implementation for the library/providers area. Declarations: `ModelCatalogProvider`.
- **`lib/library/providers/details.dart`** — Feature implementation for the library/providers area. Declarations: `ModelDetailProvider`.
- **`lib/library/providers/local.dart`** — Feature implementation for the library/providers area. Declarations: `_ProcessedStateData, ModelLocalStateProvider`.
- **`lib/library/providers/new.dart`** — Feature implementation for the library/providers area. Declarations: `ModelCreationProvider`.
- **`lib/library/screen/model/controller.dart`** — Controller and lifecycle/state orchestration for the library/screen/model area. Declarations: `ModelDetailPage, _ModelDetailViewWithTicker, __ModelDetailViewWithTickerState, ModelDetailView`.
- **`lib/library/screen/model/widgets/appbar.dart`** — App bar UI for the library/screen/model/widgets area. Declarations: `_VariantOverlayPanel, _VariantOverlayPanelState, DetailAppBar, DetailAppBarState`.
- **`lib/library/screen/model/widgets/banner.dart`** — Feature implementation for the library/screen/model/widgets area. Declarations: `WarningOverlays, _WarningOverlaysState`.
- **`lib/library/screen/model/widgets/body.dart`** — Feature implementation for the library/screen/model/widgets area. Declarations: `BodyContent, _Spacing`.
- **`lib/library/screen/model/widgets/button.dart`** — Feature implementation for the library/screen/model/widgets area. Declarations: `BottomActionButtons`.
- **`lib/library/screen/model/widgets/header.dart`** — Header UI for the library/screen/model/widgets area. Declarations: `ModelHeader, _InfoRow`.
- **`lib/library/screen/model/widgets/sections.dart`** — Feature/settings sections for the library/screen/model/widgets area. Declarations: `SectionContainer, _SectionTitle, SummarySection, DescriptionSection, _ParsedText, BaseModelSelectionSection, _BaseModelSelectionSectionState, FeaturesSection`.
- **`lib/library/screen/models/controller.dart`** — Controller and lifecycle/state orchestration for the library/screen/models area. Declarations: `LibraryScreen, LibraryScreenState, _CatalogState`.
- **`lib/library/screen/models/skeleton.dart`** — Loading skeleton UI for the library/screen/models area. Declarations: `SkeletonScreen`.
- **`lib/library/screen/models/widgets/appbar.dart`** — App bar UI for the library/screen/models/widgets area. Declarations: `ModelsAppBar`.
- **`lib/library/screen/models/widgets/badge.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `PremiumBadge, _PremiumBadgeState`.
- **`lib/library/screen/models/widgets/body.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `ModelsBody, DownloadCallback`.
- **`lib/library/screen/models/widgets/cancel.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `AnimatedCancelButton, AnimatedBorder, AnimatedBorderState, RotatingBorderPainter`.
- **`lib/library/screen/models/widgets/cards.dart`** — Card UI for the library/screen/models/widgets area. Declarations: `ModelTile, _ModelTileState`.
- **`lib/library/screen/models/widgets/category.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `ModelCategorySection, _ModelCategorySectionState`.
- **`lib/library/screen/models/widgets/chart.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `SystemInfoChart, SystemInfoChartState`.
- **`lib/library/screen/models/widgets/gradient.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `AnimatedGradientBorder, _AnimatedGradientBorderState`.
- **`lib/library/screen/models/widgets/results.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `SearchResultItem, SearchResultItemState`.
- **`lib/library/screen/models/widgets/search.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `ModelsSearchController`.
- **`lib/library/screen/models/widgets/sheet.dart`** — Feature implementation for the library/screen/models/widgets area. Declarations: `PremiumBottomSheetContent, _PremiumBottomSheetContentState`.
- **`lib/library/screen/new/add.dart`** — Feature implementation for the library/screen/new area. Declarations: `AddForm`.
- **`lib/library/screen/new/controller.dart`** — Controller and lifecycle/state orchestration for the library/screen/new area. Declarations: `ModelCreationHost, _ModelCreationHostState`.
- **`lib/library/screen/new/create.dart`** — Feature implementation for the library/screen/new area. Declarations: `CreateForm`.
- **`lib/library/screen/new/widgets/button.dart`** — Feature implementation for the library/screen/new/widgets area. Declarations: `CreationSaveButton`.
- **`lib/library/screen/new/widgets/file.dart`** — Feature implementation for the library/screen/new/widgets area. Declarations: `GgufFilePicker`.
- **`lib/library/screen/new/widgets/form.dart`** — Feature implementation for the library/screen/new/widgets area. Declarations: `CreationFormSection`.
- **`lib/library/screen/new/widgets/header.dart`** — Header UI for the library/screen/new/widgets area. Declarations: `CreationProfileHeader, _AvatarPicker, ShakeWidget`.
- **`lib/library/screen/new/widgets/selector.dart`** — Feature implementation for the library/screen/new/widgets area. Declarations: `BaseModelSelector, _BaseModelSelectorState`.
- **`lib/library/utils.dart`** — Shared utility functions for the library area. Declarations: `ModelDataUtils`.
### `lifecycle.dart/`

- **`lib/lifecycle.dart`** — Feature implementation for the  area. Declarations: `AppLifecycleManager, _AppLifecycleManagerState`.
### `login/`

- **`lib/login/anonymous.dart`** — Feature implementation for the login area. Declarations: `AnonymousDeviceEntitlement`.
- **`lib/login/backend.dart`** — Backend integration for the login area. Declarations: `LoginSuccess, LoginInvalidCredentials, LoginUserDisabled, LoginNetworkError, LoginUnknownError, RegistrationSuccess, RegistrationUsernameTaken, RegistrationEmailInUse, RegistrationWeakPassword, RegistrationNetworkError, RegistrationUnknownError, RegistrationInvalidUsername, GoogleSignInSuccess, GoogleSignInFailure, GoogleSignInCancelled, GoogleSignInNetworkError, AnonymousSignInSuccess, AnonymousSignInNetworkError, AnonymousSignInFailure, AppleSignInSuccess, AppleSignInFailure, AppleSignInCancelled, AppleSignInNetworkError, LoginBackendService, UsernameStatus`.
- **`lib/login/controller.dart`** — Controller and lifecycle/state orchestration for the login area. Declarations: `LoginController, AuthMode`.
- **`lib/login/screen.dart`** — Feature implementation for the login area. Declarations: `AuthScreen, _AuthScreenState`.
- **`lib/login/upgrade.dart`** — Feature implementation for the login area. Declarations: `UpgradeAccountScreen, _UpgradeAccountScreenState`.
- **`lib/login/verify.dart`** — Verification UI for the login area. Declarations: `EmailVerificationScreen, _EmailVerificationScreenState, AnimatedDigit, AnimatedTime`.
- **`lib/login/view/login.dart`** — Login UI for the login/view area. Declarations: `LoginForm, _LoginFormState`.
- **`lib/login/view/register.dart`** — Registration UI for the login/view area. Declarations: `RegisterForm, _RegisterFormState`.
### `main.dart/`

- **`lib/main.dart`** — Application entry point and provider graph bootstrap. Declarations: `TabProvider, BootstrapResult, AppBootstrap, AppGatekeeper`.
### `maintenance.dart/`

- **`lib/maintenance.dart`** — Feature implementation for the  area. Declarations: `MaintenanceScreen, _MaintenanceScreenState`.
### `meet.dart/`

- **`lib/meet.dart`** — Feature implementation for the  area. Declarations: `NoGoBackScrollPhysics, _OnboardingPageData, OnboardingScreen, _OnboardingScreenState, _OnboardingContentPage, _OnboardingContentPageState, _FinalOnboardingPage, _FinalOnboardingPageState`.
### `navigation.dart/`

- **`lib/navigation.dart`** — Feature implementation for the  area.
### `news/`

- **`lib/news/appbar.dart`** — App bar UI for the news area. Declarations: `NewsAppBar`.
- **`lib/news/cards.dart`** — Card UI for the news area. Declarations: `NewsArticleCard, _NewsArticleCardState`.
- **`lib/news/data.dart`** — Static/data definitions for the news area. Declarations: `NewsArticle`.
- **`lib/news/search.dart`** — Feature implementation for the news area. Declarations: `NewsSearchBar`.
- **`lib/news/service.dart`** — Service implementation for the news area. Declarations: `NewsService, NewsState`.
- **`lib/news/skeleton.dart`** — Loading skeleton UI for the news area. Declarations: `ShimmerPlaceholder, ShimmerNewsList, ShimmerNewsCard`.
- **`lib/news/view.dart`** — Screen/view composition for the news area. Declarations: `NewsScreen, _NewsScreenState, FirebaseStorageImage, _FirebaseStorageImageState, _ErrorState, NewsArticleLocalization`.
### `notifications/`

- **`lib/notifications/extrovert.dart`** — External notification for the notifications area.
- **`lib/notifications/extrovert/handlers.dart`** — Notification handlers for the notifications/extrovert area.
- **`lib/notifications/extrovert/interaction.dart`** — Feature implementation for the notifications/extrovert area. Declarations: `ExtrovertInteraction`.
- **`lib/notifications/extrovert/localization.dart`** — Notification localization for the notifications/extrovert area.
- **`lib/notifications/extrovert/scheduler.dart`** — Notification scheduling for the notifications/extrovert area. Declarations: `ExtrovertScheduler`.
- **`lib/notifications/extrovert/service.dart`** — Service implementation for the notifications/extrovert area. Declarations: `ExtrovertNotificationService`.
- **`lib/notifications/extrovert/token.dart`** — Notification token for the notifications/extrovert area. Declarations: `ExtrovertTokenManager`.
- **`lib/notifications/introvert.dart`** — In-app notification for the notifications area. Declarations: `_NotificationStyle, _ActiveNotificationHandle, IntrovertNotificationService, _AnimatedNotification, _AnimatedNotificationState, NotificationType`.
### `options.dart/`

- **`lib/options.dart`** — Message option controls for the  area. Declarations: `DefaultFirebaseOptions`.
### `overflow.dart/`

- **`lib/overflow.dart`** — Feature implementation for the  area. Declarations: `OverflowText, _OverflowTextState`.
### `rag/`

- **`lib/rag/chat.dart`** — Feature implementation for the rag area. Declarations: `RagChatService`.
- **`lib/rag/chunker.dart`** — Feature implementation for the rag area. Declarations: `DocumentChunker, _SliceResult`.
- **`lib/rag/extractors.dart`** — Feature implementation for the rag area. Declarations: `DocTextExtractor, ServerDocParser`.
- **`lib/rag/ingestion.dart`** — RAG validation, extraction, chunking and storage pipeline. Declarations: `RagIngestionService`.
- **`lib/rag/injector.dart`** — Feature implementation for the rag area. Declarations: `RagContextInjector`.
- **`lib/rag/models.dart`** — Domain models and enums for the rag area. Declarations: `RagDocument, RagChunk, RagRetrievalResult, RagDocumentStatus`.
- **`lib/rag/provider.dart`** — Reactive Provider state for the rag area. Declarations: `RagProvider`.
- **`lib/rag/retrieval.dart`** — Retrieval abstraction and local BM25 implementation over indexed chunks. Declarations: `RagTokenizer, RetrievalEngine, Bm25RetrievalEngine`.
- **`lib/rag/screens/documents.dart`** — Feature implementation for the rag/screens area. Declarations: `DocumentLibraryScreen, _DocumentLibraryScreenView, _DocumentLibraryScreenViewState, _DocumentTile, _EmptyState, _BottomBar, _StadiumButton`.
- **`lib/rag/storage.dart`** — Persistence/storage for the rag area. Declarations: `RagStorageService`.
### `recognizer.dart/`

- **`lib/recognizer.dart`** — Feature implementation for the  area. Declarations: `ShortLongPressGestureRecognizer`.
### `reconcile.dart/`

- **`lib/reconcile.dart`** — Feature implementation for the  area.
### `referral.dart/`

- **`lib/referral.dart`** — Feature implementation for the  area. Declarations: `ReferralHandler`.
### `roleplay/`

- **`lib/roleplay/data/characters.dart`** — Seed character data for the roleplay/data area.
- **`lib/roleplay/models/character.dart`** — Character domain model for the roleplay/models area. Declarations: `PersonalityTrait, RoleplayCharacter, RoleplayMessage, RoleplaySession, CharacterCategory, CharacterCategoryLabel`.
- **`lib/roleplay/provider.dart`** — Reactive Provider state for the roleplay area. Declarations: `RoleplayProvider`.
- **`lib/roleplay/screens/character.dart`** — Character domain model for the roleplay/screens area. Declarations: `CreateCharacterScreen, _CreateCharacterScreenState, _TemplateChip, _SummaryRow, _EmojiPicker, _TraitAddSheet, _TraitAddSheetState`.
- **`lib/roleplay/screens/discover.dart`** — Character discovery UI for the roleplay/screens area. Declarations: `DiscoverScreen, _DiscoverScreenState, _CharacterCard, _ShimmerCard, _ShimmerCardState, _MyBotsSheet, _UserBotTile`.
- **`lib/roleplay/screens/roleplay.dart`** — Roleplay UI for the roleplay/screens area. Declarations: `RoleplayChatScreen, _RoleplayChatScreenState, _TypingDots, _TypingDotsState, _OptionsSheet, _OptionTile, _MoodSelector`.
- **`lib/roleplay/screens/screen.dart`** — Feature implementation for the roleplay/screens area. Declarations: `CharacterProfileScreen, _CharacterProfileScreenState, _StatChip`.
- **`lib/roleplay/service.dart`** — Service implementation for the roleplay area. Declarations: `RoleplayService`.
### `routes.dart/`

- **`lib/routes.dart`** — Feature implementation for the  area. Declarations: `FadeRoute, SlideRightRoute`.
### `screen.dart/`

- **`lib/screen.dart`** — Feature implementation for the  area. Declarations: `MainScreen, MainScreenState, MainScreenView`.
### `server/`

- **`lib/server/credits.dart`** — Feature implementation for the server area. Declarations: `CreditsManager`.
- **`lib/server/user.dart`** — Feature implementation for the server area. Declarations: `UserProvider`.
### `settings/`

- **`lib/settings/controller.dart`** — Controller and lifecycle/state orchestration for the settings area. Declarations: `SettingsScreen, _SettingsScreenState, _UnverifiedAccountPanel, __UnverifiedAccountPanelState`.
- **`lib/settings/providers/actions.dart`** — Feature implementation for the settings/providers area. Declarations: `SettingsActionProvider`.
- **`lib/settings/providers/general.dart`** — Feature implementation for the settings/providers area. Declarations: `SettingsGeneralProvider`.
- **`lib/settings/sections/anonymous.dart`** — Feature implementation for the settings/sections area. Declarations: `AnonymousUpgradePanel`.
- **`lib/settings/sections/delete.dart`** — Feature implementation for the settings/sections area. Declarations: `_DeleteAllConversationsDialog, _DeleteAllConversationsDialogState, _DeleteAccountDialog, _DeleteAccountDialogState, DeleteSection`.
- **`lib/settings/sections/header.dart`** — Header UI for the settings/sections area. Declarations: `AnimatedBorderPainter, ProfileHeaderSection, _ProfileHeaderSectionState`.
- **`lib/settings/sections/language.dart`** — Locale state for the settings/sections area. Declarations: `AppLanguageSection`.
- **`lib/settings/sections/personalization.dart`** — Feature implementation for the settings/sections area. Declarations: `PersonalizationSection, _PersonalizationSectionState`.
- **`lib/settings/sections/settings.dart`** — Settings UI for the settings/sections area. Declarations: `SettingsSection, _SettingsSectionState, _PremiumButton, _PremiumButtonState`.
- **`lib/settings/sections/theme.dart`** — Theme UI for the settings/sections area. Declarations: `AppThemeSection`.
- **`lib/settings/sections/user.dart`** — Feature implementation for the settings/sections area. Declarations: `UserSection`.
- **`lib/settings/sections/user/edit.dart`** — Message editing flow for the settings/sections/user area. Declarations: `_EditProfileDialog, _EditProfileDialogState`.
- **`lib/settings/sections/user/logout.dart`** — Feature implementation for the settings/sections/user area. Declarations: `_LogoutDialog`.
- **`lib/settings/sections/user/password.dart`** — Feature implementation for the settings/sections/user area. Declarations: `_ChangePasswordDialog, _ChangePasswordDialogState`.
- **`lib/settings/sections/user/plan.dart`** — Feature implementation for the settings/sections/user area. Declarations: `_MyPlanButton, _MyPlanButtonState`.
- **`lib/settings/sections/voice.dart`** — Voice interaction for the settings/sections area. Declarations: `VoiceSection, _Entry, _VoiceSelectionDialog, _VoiceSelectionDialogState`.
- **`lib/settings/services/auth.dart`** — Feature implementation for the settings/services area. Declarations: `AuthException, AuthUnknownException, AuthService`.
- **`lib/settings/services/profile.dart`** — Feature implementation for the settings/services area. Declarations: `ProfileException, ProfileNotFoundException, ProfileUnknownException, ProfileService`.
- **`lib/settings/skeleton.dart`** — Loading skeleton UI for the settings area. Declarations: `SkeletonLoader`.
- **`lib/settings/widgets/grouped_button.dart`** — Feature implementation for the settings/widgets area. Declarations: `SettingsGroupedRow, SettingsGroupedColumn, SettingsRowPosition`.
### `shake.dart/`

- **`lib/shake.dart`** — Feature implementation for the  area. Declarations: `ShakeWidget, ShakeWidgetState`.
### `sheet.dart/`

- **`lib/sheet.dart`** — Feature implementation for the  area. Declarations: `LiquidGlassPanel, ScaledBottomSheet`.
### `stack.dart/`

- **`lib/stack.dart`** — Feature implementation for the  area. Declarations: `FadeIndexedStack`.
### `theme.dart/`

- **`lib/theme.dart`** — Theme UI for the  area. Declarations: `ThemeProvider, ThemeColors, AppColors`.
### `update.dart/`

- **`lib/update.dart`** — Feature implementation for the  area. Declarations: `UpdateRequiredScreen, _UpdateRequiredScreenState`.
### `variants.dart/`

- **`lib/variants.dart`** — Feature implementation for the  area. Declarations: `Variants, _ShineAnimationWrapper, _ShineAnimationWrapperState`.
### `webview.dart/`

- **`lib/webview.dart`** — Feature implementation for the  area. Declarations: `_WebViewModalContent, _WebViewModalContentState, _TriangleLoadingIndicator, _ErrorDisplay, _TrianglePainter`.
