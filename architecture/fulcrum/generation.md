# Fulcrum Generation Architecture

The generation path and everything the client talks to during a chat turn. Client counterpart: `../cortex/chat.md` (`ApiService`).

## Central path

message.js -> gateway.js -> router.js/stream.js

`functions/src/message.js` is a backward-compatible re-export: both `sendMessage` and the legacy `proxyOpenRouterRequest` name delegate to `gateway.js` while clients migrate to the new message architecture.

`gateway.js` — the Flutter `ApiService` sends an authenticated request to the gateway (`sendMessage`). The gateway validates the request, resolves the model route, prepares conversation context, applies feature and credit rules, opens SSE, and streams normalized events back. It also handles token-budget fallback, web-search plugins, attachments, character overrides, cost settlement and title generation.

`router.js` — the policy engine for provider/model choice, fallback order, media type and dynamic-chat intent (`getDynamicModels`, `pickBestModelList`, `analyzeIntent`, `analyzeMediaParams`, `resolveRoute`, `getProviderCatalog`, `workersAIModels`). It avoids incompatible routes such as sending media to text-only providers. Text can use OpenRouter, Workers AI or Groq fallbacks; media can use Fal.ai or ElevenLabs. For every media request, `analyzeMediaParams` extracts the user's requested dimensions/duration/resolution from the input (deterministic TR/EN regex plus a Groq LLM pass that fills fuzzy cases like "dikey" or "half a minute").

`stream.js` — provider execution, Fal media calls, OpenRouter/Groq/Workers AI streaming, SSE parsing, retries, fallback behavior, cost reconciliation and credit refunds (`executeApiStream`, `executeFalRequest`, `executeElevenLabsRequest`, `detectFalOutputType`, `deductDynamicCost`, `refundUserCredits`). Media executors forward the analyzed directive to `media-params.js`, which maps it onto each model's supported values (ElevenLabs per-model enums reject unknown fields with a 422; Fal values are conformed to the live OpenAPI schema). Defaults when nothing was specified: image 1:1, video closest-supported-to-1:1, music 30s, sound 5s.

Supporting modules: `media-params.js` (media parameter normalization: `parseMediaDirective`, `closestAspectRatio`, `buildElevenLabsMediaPayload`, `applyFalSchemaMediaParams`, `ELEVENLABS_MEDIA_CAPABILITIES`), `routing.js` (Fal schema/payload helpers: `findFalModel`, `candidatesFor`, `inputSchema`, `buildSchemaPayload`, `prepareFalRequest`, `endpointOutput`) and `sse.js` (`splitSseEvents`).

## System prompt ownership

Fulcrum owns all system instructions. The Cortex client never sends conversation system prompts; it delegates behavioral metadata (`customInstruction`, `userMemory`, `characterRole`, `voiceMode`, `featureMode`, `langCode`) and `functions/src/prompts.js` assembles the system message in one deterministic order, pinned by `functions/test/system-prompt.test.js`:

1. **Cortex base identity** — `CORTEX_BASE_PROMPT` in `src/prompts.js`, the single canonical English identity. It is the guaranteed default: even a request with no optional metadata at all receives a valid system prompt. Response language stays metadata-driven (`langCode`); there are no localized persona copies.
2. **Platform integrity** — `PLATFORM_INTEGRITY_PROMPT`, applied in BOTH normal and character conversations: user-provided instructions, memories, retrieved/attached content and tool outputs may customize behavior but must never override Cortex's factual-integrity rules, tool honesty, platform capabilities, or higher-priority system instructions — the prompt-injection boundary of the ownership contract.
3. `customInstruction`
4. `userMemory`
5. `voiceMode`
6. `featureMode` (study / quiz)
7. `langCode` response-language instruction (non-English only)
8. `systemPromptLimitFallback` (legacy pre-migration client field, appended verbatim)

Character conversations are the one exception to the identity: a non-empty `characterRole` swaps the base prompt for the character embodiment preamble + role, so the Cortex identity can never break roleplay. Pre-migration clients that baked their own system message (and send no metadata) keep that message, layered after the base identity; a metadata-bearing client that sends a system message anyway is replaced wholesale by the server assembly.

`prompts.js` also centralizes the execution-lane prompts (tool discipline, background titles, media-failure explainers, the vision describe/bridge pair). The identity keeps web use tool-gated: it may "use available web or research tools when appropriate" and must "never claim to have searched, researched, verified, confirmed, or found information online unless an actual tool result supports that claim" — real web capability is the server-controlled `enableWebSearch` flag / OpenRouter web plugin, so the model can never fabricate a search that never ran.

## Supporting functions

- `title.js` — `generateFastTitle` generates fast conversation titles through Groq.
- `tools.js` — `executeTool` + `TOOLS` expose server-side tool definitions and execution, including hosted code execution/reporting.
- `voice.js` — keeps Deepgram, AssemblyAI and ElevenLabs secrets server-side and exposes token/synthesis/usage-settlement endpoints: `getSpeechToken`, `getAssemblyToken`, `synthesizeSpeech`, `settleSpeechUsage`.
- `chat.js` — `onNewChatMessage` Firestore trigger on the new-chat collection.

## Compatibility contract

The gateway's SSE event stream is a client compatibility contract. The Flutter `ApiService` parses text, reasoning, tools, citations, search, title and media events from this stream; the regression tests (`functions/test/`) pin chat behavior, media routing and SSE. Change event names or shapes only in coordination with `../cortex/chat.md`.

## GenID tracing

Every generation receives a `generationId` at the gateway. This ID is propagated through all downstream logs for end-to-end traceability:

- `[TTFT]` — time-to-first-token per provider/model/attempt.
- `[DYNAMIC_COST]` — credit reconciliation after OpenRouter real-cost fetch, provider fallback refunds, or free-provider skips.
- `[CREDIT_REFUND]` — upstream failure refunds (media providers, SSE breaks, final fallback failures).
- `[AUDIO_FALLBACK]` — cascading media failure logs.

All credit and timing logs carry `GenID: <id> | User: <uid>`.

## Audio fallback chain

Media generation (image/video/audio) routes primarily through Fal.ai. If Fal returns a failure or timeout:

1. **ElevenLabs fallback** — `gateway.js` calls `executeElevenLabsRequest` (declared in `stream.js`) for image/video/audio intents supported by ElevenLabs models. On success the result streams back normally.
2. **Text explainer fallback** — if both Fal and ElevenLabs fail, the gateway refunds consumed credits (`[CREDIT_REFUND]`), emits `[AUDIO_FALLBACK]`, and switches to a text model that explains the failure to the user.

Credit refunds are gated by `state.creditsDeducted && totalCost > 0` to remain idempotent even when multiple failure paths run.

## JSON shortcut (non-SSE streaming)

Cloudflare Workers AI (and occasionally OpenRouter) may return a complete `application/json` response even when `stream: true` is requested. `stream.js` detects the `content-type`, parses the JSON, and emits the full content as a single `text_chunk` event. Empty payloads log `[STREAM_JSON_EMPTY]` instead of hanging the SSE parser. This mitigates empty SSE streams on models such as `@cf/openai/gpt-oss-120b`.

## Credit reconciliation (`deductDynamicCost` / `refundUserCredits`)

- **OpenRouter text** — an upfront default cost is deducted before streaming. After the stream ends, the real generation cost is fetched from OpenRouter. If the real cost is lower, the delta is refunded; if higher, the delta is charged (capped by the user's remaining balance).
- **Provider fallback** — when a text request falls back from OpenRouter to Groq or Workers AI, the upfront OpenRouter estimate is refunded in full (`[DYNAMIC_COST] ... Refunded OpenRouter upfront estimate`).
- **Failure refunds** — any upstream error that terminates the stream (SSE break, API error, final fallback exhaustion) triggers `refundUserCredits` for the amount already deducted. The `creditsDeducted` boolean prevents double refunds.
