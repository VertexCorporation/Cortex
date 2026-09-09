# Fulcrum Generation Architecture

The generation path and everything the client talks to during a chat turn. Client counterpart: `../cortex/chat.md` (`ApiService`).

## Central path

message.js -> gateway.js -> router.js/stream.js

`functions/src/message.js` is a backward-compatible re-export: both `sendMessage` and the legacy `proxyOpenRouterRequest` name delegate to `gateway.js` while clients migrate to the new message architecture.

`gateway.js` — the Flutter `ApiService` sends an authenticated request to the gateway (`sendMessage`). The gateway validates the request, resolves the model route, prepares conversation context, applies feature and credit rules, opens SSE, and streams normalized events back. It also handles token-budget fallback, web-search plugins, attachments, character overrides, cost settlement and title generation.

`router.js` — the policy engine for provider/model choice, fallback order, media type and dynamic-chat intent (`getDynamicModels`, `pickBestModelList`, `analyzeIntent`, `analyzeMediaParams`, `resolveRoute`, `getProviderCatalog`, `workersAIModels`). It avoids incompatible routes such as sending media to text-only providers. Text can use OpenRouter, Workers AI or Groq fallbacks; media can use Fal.ai or ElevenLabs. For every media request, `analyzeMediaParams` extracts the user's requested dimensions/duration/resolution from the input (deterministic TR/EN regex plus a Groq LLM pass that fills fuzzy cases like "dikey" or "half a minute").

`stream.js` — provider execution, Fal media calls, OpenRouter/Groq/Workers AI streaming, SSE parsing, retries, fallback behavior and cost reconciliation (`executeApiStream`, `executeFalRequest`, `executeElevenLabsRequest`, `detectFalOutputType`, `deductDynamicCost`, `refundUserCredits`). Media executors forward the analyzed directive to `media-params.js`, which maps it onto each model's supported values (ElevenLabs per-model enums reject unknown fields with a 422; Fal values are conformed to the live OpenAPI schema). Defaults when nothing was specified: image 1:1, video closest-supported-to-1:1, music 30s, sound 5s.

Supporting modules: `media-params.js` (media parameter normalization: `parseMediaDirective`, `closestAspectRatio`, `buildElevenLabsMediaPayload`, `applyFalSchemaMediaParams`, `ELEVENLABS_MEDIA_CAPABILITIES`), `routing.js` (Fal schema/payload helpers: `findFalModel`, `candidatesFor`, `inputSchema`, `buildSchemaPayload`, `prepareFalRequest`, `endpointOutput`) and `sse.js` (`splitSseEvents`).

## Supporting functions

- `title.js` — `generateFastTitle` generates fast conversation titles through Groq.
- `tools.js` — `executeTool` + `TOOLS` expose server-side tool definitions and execution, including hosted code execution/reporting.
- `voice.js` — keeps Deepgram, AssemblyAI and ElevenLabs secrets server-side and exposes token/synthesis/usage-settlement endpoints: `getSpeechToken`, `getAssemblyToken`, `synthesizeSpeech`, `settleSpeechUsage`.
- `chat.js` — `onNewChatMessage` Firestore trigger on the new-chat collection.

## Compatibility contract

The gateway's SSE event stream is a client compatibility contract. The Flutter `ApiService` parses text, reasoning, tools, citations, search, title and media events from this stream; the regression tests (`functions/test/`) pin chat behavior, media routing and SSE. Change event names or shapes only in coordination with `../cortex/chat.md`.
