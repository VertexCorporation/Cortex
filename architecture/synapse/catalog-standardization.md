# Synapse Catalog Standardization — Audit & Target Architecture

Status: **Proposed (design, not yet implemented)** — 2026-09-09
Scope: model-catalog ingestion, normalization, policy, freshness, and the `/models` contract consumed by Fulcrum/Cortex.
Governing principle: **Synapse describes reality as accurately as possible; Fulcrum makes decisions from that reality.** Synapse never picks "best" models — it publishes a trustworthy, rich, normalized catalog.

Sources of truth for this audit: live `/models` KV snapshot (970 entries: 865 models + 105 series-level enrichment objects), live OpenRouter `/api/v1/models` (431 models), live Fal `/v1/models` (page 1 of ~500+ endpoints), official API references for Groq / ElevenLabs / Deepgram / Cloudflare, and the syncer source code.

---

## 1. Map of Relevant Synapse Files (Deliverable 1)

```
Synapse/syncer/                          (Cloudflare Worker, cron "5 * * * *")
├── syncer.js                            entry: scheduled() → syncModels(), fetch() → /models
├── config.js                            endpoints, SOURCE_PRIORITY, PRODUCER_MAP (allowlist), cost limits
├── config/client-assets.js             FAMILY_ASSETS + PRODUCER_ASSETS (client image registry = curation allowlist)
├── types.js                             JSDoc types: ModelVariant, ProducersData (presentation tree)
├── core/sync.js                         orchestrator: fetch all → dedup → merge → policy → hash → KV write
├── core/serve.js                        GET /models: edge-cache-first, blacklist filter at serve time
├── kv/{data.js,lock.js}                 KV read/write, backups, distributed locks
├── processing/
│   ├── online.js                        OpenRouter processor (main LLM source)
│   ├── groq.js                          Groq processor + parseGroqModelIdentity (string heuristics)
│   ├── cloudflare.js                    CF Workers AI processor + parseCloudflareModelIdentity
│   ├── elevenlabs.js                    ElevenLabs processor (TTS/voice)
│   ├── deepgram.js                      Deepgram processor (STT + TTS)
│   ├── fal.js                           Fal processor + TRUSTED_FAL_PRODUCERS whitelist + parseFalModelIdentity
│   ├── fal-models.js                    endpoint→base-model consolidation (fal.endpoints), applyFreshFalRouting
│   ├── catalog-policy.js                matchCatalogModel / insertCatalogModel / enforceCatalogPolicy (asset allowlist)
│   ├── merge.js                         pruneStaleModels + rehydrateAndMergeProducers (mergeDeep: OLD WINS) + applyFreshOnlineTiers
│   ├── dedup.js                         cross-provider dedup by normalized ID (groq > cf > or > fal > 11l > dg)
│   ├── parser.js                        OpenRouter display-name → series/variant parsing
│   ├── manual.js                        curator-managed manual models from KV "model:*" keys
│   ├── offline.js                       offline GGUF grouping, offlineEntries, mergeOfflineModels
│   └── huggingface{,-chat,-discovery}.js on-device GGUF catalog refresh from HF Hub
├── docs/provider-catalog-results.json   audit output: 561 rows, catalog-policy match results (0 unmatched)
└── tests/                               node:test suites (catalog-policy, fal-models, huggingface)

Synapse/curator/   (Worker) admin edits: manual models, list updates, edge-cache purge — writes same MODELS_JSON KV
Synapse/supervisor/(Worker, cron */10)   enrichment: series descriptions (OpenRouter), translations — writes series_description
```

Fulcrum consumers (context, out of this repo): `functions/src/router.js` `getDynamicModels()` (fetches `/models`, flattens `producers`, filters `source === "openrouter" || "fal"` at line ~206), `stream.js`, `gateway.js`, `title.js` (hard-coded model IDs — the downstream reason this standardization exists).


---

## 2. Provider Catalog Endpoint Audit (Deliverable 2)

### 2.1 OpenRouter — `GET https://openrouter.ai/api/v1/models` (auth: Bearer)

One JSON document, no pagination. **431 models live-verified 2026-09-09.** Per-model fields:

| Field | Type | Notes |
|---|---|---|
| `id` | string | `vendor/slug` (e.g. `openai/gpt-oss-120b`) |
| `canonical_slug` | string | canonical identity; differs from id for aliases |
| `alias_target` | string? | set when id is an alias |
| `hugging_face_id` | string? | HF repo identity |
| `name` | string | display name `Vendor: Model` |
| `created` | int | unix seconds — release lifecycle |
| `description` | string | marketing description |
| `context_length` | int | provider-declared context window |
| `architecture.modality` | string | `"text->text"`, `"text->image"`, `"*->audio"` … |
| `architecture.input_modalities` / `output_modalities` | string[] | `text`, `image`, `audio`, `file`, `video` |
| `architecture.tokenizer` | string | e.g. `GPT` |
| `architecture.instruct_type` | string? | instruct format family |
| `pricing.prompt` / `completion` | string (USD/token) | |
| `pricing.request`, `pricing.image`, `pricing.web_search`, `pricing.internal_reasoning`, `pricing.input_cache_read`, … | string? | per-unit prices on relevant models |
| `top_provider.context_length` | int | best endpoint's context |
| `top_provider.max_completion_tokens` | int | provider-declared max output |
| `top_provider.is_moderated` | bool | moderation flag |
| `per_request_limits` | object? | rate metadata |
| `supported_parameters` | string[] | authoritative parameter list: `tools`, `tool_choice`, `reasoning`, `reasoning_effort`, `structured_outputs`, `response_format`, `seed`, `stop`, `max_tokens`, `temperature`, `top_p`, `top_k`, `logprobs`, `frequency_penalty`, `presence_penalty`, `modalities`, `audio`, `stream`… |
| `default_parameters` | object | default temperature/top_p etc. |
| `reasoning.mandatory` | bool | reasoning always-on |
| `reasoning.supported_efforts` | string[] | e.g. `["high","medium","low"]` |
| `reasoning.default_effort` | string | |
| `supported_voices` | array? | for audio-output models |
| `knowledge_cutoff` | date string | |
| `expiration_date` | date string? | deprecation lifecycle |
| `links.details` | string | per-model endpoints doc |
| `benchmarks.design_arena[]`, `benchmarks.artificial_analysis` | object | quality metrics (elo, intelligence index) |

**Consumed today**: id, name, description, context_length, pricing (only as a cost-threshold filter — values discarded), input/output modalities, supported_parameters (→ tools/reasoning/webSearch booleans). **Discarded**: everything else above.

Processor-side filters (policy mixed into processor): invalid shape, blacklist, `id.includes("research")` (hard skip), image-output models excluded entirely, `:free` → fallback tier, producer allowlist (`PRODUCER_MAP`), cost limits (`isTooExpensive`).

### 2.2 Groq — `GET https://api.groq.com/openai/v1/models` (auth: Bearer)

One JSON document `{object:"list", data:[…]}`. Per-model fields (official reference + live-verified):

| Field | Type | Notes |
|---|---|---|
| `id` | string | now includes org-prefixed ids: `qwen/qwen3.8-27b`, `canopylabs/orpheus-arabic-saudi`, `openai/gpt-oss-safeguard-20b` |
| `created` | int | unix seconds — available, **discarded** |
| `owned_by` | string | producer org (`"Meta"`, `"Google"`, `"OpenAI"`) |
| `active` | bool | availability |
| `context_window` | int | provider-declared context |
| `public_apps` | array/null | compound app list |
| `max_completion_tokens` | int | on Retrieve endpoint (observed on list for some models) — available, **discarded** |

No pricing, no parameter lists, no modality metadata in the API. Groq's docs pages list tool/reasoning support per model — usable only as versioned `docs` provenance, not API data.

Live-catalog evidence of parser rot: `qwen/qwen3.8-27b` style ids break `parseGroqModelIdentity` (variant keeps `/`); `gpt-oss` has no branch (falls to `owned_by` → "Openai"); `whisper-large-v3` (context 448), `canopylabs/orpheus-*` (TTS, 4000), `groq/compound-*` (web-agent systems) all pass through the generic path.

### 2.3 Cloudflare Workers AI — `GET https://api.cloudflare.com/client/v4/accounts/{id}/ai/models/search?page&per_page` (auth: Bearer)

Paginated (`result_info.total_count`). **Undocumented-but-verified query params**: `author`, `search`, `source`, `task`, `hide_experimental`, `include_deprecated` (models stay listed up to 3 months after deprecation → deprecation lifecycle exists), and **`format=openrouter`** — returns models in OpenRouter marketplace format (per CF API reference). Opportunity: if that payload matches OpenRouter's schema, Cloudflare normalization can reuse the OpenRouter normalizer and gains context/pricing/parameters for free. **Action: verify once with credentials before relying on it.**

Per-model fields (default format):

| Field | Type | Notes |
|---|---|---|
| `name` | string | `@cf/org/slug` (or `@hf/…`) |
| `description` | string | |
| `task.name`, `task.description` | string | task taxonomy: `Text Generation`, `Text-to-Image`, `Image-to-Text`, `Automatic Speech Recognition`, `Text Embeddings`, `Text Classification`, `Summarization`, `Translation`, `Text-to-Speech`, `Voice Activity Detection`, `Object Detection`… |
| `tags` | string[] | e.g. `["open-weights","onnx"]` — discarded |
| `properties` | array | `[{property_id: "max_context"|"input_size"|"output_dimension"|…, value}]` — **processor bug: read as `item.properties?.max_context` (object access on an array) → always undefined → all 35 CF models have `context: 0` in the live catalog** |
| beta/lifecycle flags | | experimental/deprecated signals (see query params) |

Live-catalog evidence of task-based capability rot: `@cf/meta/llama-3.2-11b-vision-instruct` stored with `modalities.image=false` (CF task name doesn't match the image-input heuristics); `@cf/meta/llama-guard-3-8b` (moderation) stored with `reasoning=true` because `reasoning := taskName.includes("text generation")`; `@cf/qwen/qwen3-embedding-0.6b` and `@cf/meta/m2m100-1.2b` exist as generic records with context 0.

### 2.4 ElevenLabs — `GET https://api.elevenlabs.io/v1/models` (auth: `xi-api-key`)

One JSON array. Per-model fields (official reference): `model_id`, `name`, `description`, `can_do_text_to_speech`, `can_do_voice_conversion`, `can_be_finetuned`, `can_use_style`, `can_use_speaker_boost`, `serves_pro_voices`, `token_cost_factor` (double), `requires_alpha_access` (bool — preview lifecycle), `max_characters_request_free_user`, `max_characters_request_subscribed_user`, `maximum_text_length_per_request` (input limits, not context), `languages[{language_id,name}]` (language support — critical for TTS routing), `model_rates{character_cost_multiplier, cost_discount_multiplier}` (pricing), `concurrency_group` (routing).

**Consumed**: model_id, name, description, char limits (→ `context` — semantic misuse), `can_do_voice_conversion` (→ `modalities.audio` — semantic misuse), `can_do_text_to_speech` (→ `outputs.audio`). **Discarded**: languages, model_rates, requires_alpha_access, can_be_finetuned, can_use_style, can_use_speaker_boost, serves_pro_voices, token_cost_factor, concurrency_group.

### 2.5 Deepgram — `GET https://api.deepgram.com/v1/models` (auth: `Token …`)

One JSON object `{stt:[…], tts:[…]}`. Per-model fields (official OpenAPI 3.1 spec):
- STT: `name`, `canonical_name`, `architecture` (string family), `languages[]`, `version` (discarded), `uuid`, `batch` (bool — batch API support, discarded), `streaming` (bool — **streaming support, discarded — exactly what Fulcrum needs for STT queries**), `formatted_output` (smart format).
- TTS (Aura): `name`, `canonical_name`, `architecture`, `languages[]`, `version`, `uuid`, `metadata`.

**Consumed**: canonical_name/name only. `context` hard-coded `0` (should be `null` — unknown ≠ zero). Everything else discarded.

### 2.6 Fal — `GET https://api.fal.ai/v1/models?cursor=…` (auth: optional `Key …`)

Cursor pagination (`{models, next_cursor, has_more}`); processor caps at 30 pages. Each item `{endpoint_id, metadata}`. Metadata fields (live-verified): `category` (`text-to-image`, `image-to-video`, `audio-to-text`, …), `display_name`, `description`, `date` (created — discarded), `updated_at` (discarded), `status` (lifecycle — discarded), `license_type` (discarded), `github_url`, `model_url`, `stream_url`, `duration_estimate` (latency proxy — discarded), `kind`, `pinned`, `highlighted`, `is_favorited`, `group{key,label}`, `tags[]`, `thumbnail_url`, `thumbnail_animated_url`, `training_endpoint_ids`.

No context window, no pricing. **Consumed**: endpoint_id, category, group.key, description/display_name, tags. Processor adds heavy curation: `TRUSTED_FAL_PRODUCERS` whitelist, `EXCLUDED_CATEGORIES` (llm, training, workflow…), `EXCLUDED_SUBSTRINGS`, then `consolidateFalModels` collapses task endpoints into base models (`fal.endpoints[]`, `fal.baseId`, `fal.defaultEndpoint`).


---

## 3. Provider Metadata Capability Matrix (Deliverable 3)

Statuses: **native** = provider exposes it directly · **native ✖** = provider exposes it but the current pipeline discards it · **derived** = computed deterministically from provider data · **inferred** = heuristic (name/id sniffing) · **docs** = only in provider documentation (versioned static map) · **none** = not available · **n/a** = not applicable to that provider's model kinds.

### Identity

| Field | OpenRouter | Groq | Cloudflare | ElevenLabs | Deepgram | Fal |
|---|---|---|---|---|---|---|
| provider model id | native | native | native | native | native | native |
| display name | native | none | native | native | native | native |
| producer/org | native (id prefix) | native (`owned_by`) | native (`@cf/org/`) | native | native | derived (owner key) |
| model family | native (`canonical_slug`) | inferred | inferred (slug) | native (name) | derived (nova/aura) | native (`group.key`) |
| parameter size | inferred (name) | inferred (name) | inferred (name) | n/a | n/a | n/a |
| version | none | none | none | none | **native ✖ (`version`)** | none |
| canonical ID | native (`canonical_slug`) | native | native | native | native (`canonical_name`) | derived (`falBaseId`) |
| HF identity | **native ✖ (`hugging_face_id`)** | none | none | none | none | derived ✖ (`model_url`/`github_url`) |

### Lifecycle

| Field | OpenRouter | Groq | Cloudflare | ElevenLabs | Deepgram | Fal |
|---|---|---|---|---|---|---|
| created/release | **native ✖ (`created`)** | **native ✖ (`created`)** | none | none | none | **native ✖ (`date`)** |
| last updated | none | none | none | none | none | **native ✖ (`updated_at`)** |
| deprecation | **native ✖ (`expiration_date`)** | docs | native (`include_deprecated` support) | none | none | **native ✖ (`status`)** |
| preview/beta | inferred (name) | none | native (beta / `hide_experimental`) | **native ✖ (`requires_alpha_access`)** | none | **native ✖ (`status`)** |
| knowledge cutoff | **native ✖** | none | none | n/a | n/a | n/a |

### Capabilities

| Field | OpenRouter | Groq | Cloudflare | ElevenLabs | Deepgram | Fal |
|---|---|---|---|---|---|---|
| tasks/category | derived (modality+params) | inferred (id) | **native (`task.name`)** ✖ | native (`can_do_*`) | native (stt/tts split) | **native (`category`)** |
| chat/completion | derived (params) | inferred (id) | native (task) | n/a | n/a | n/a (llm excluded) |
| tool use / tool_choice | **native (`supported_parameters`)** | docs | none | n/a | n/a | n/a |
| parallel tool calls | docs | docs | none | n/a | n/a | n/a |
| structured output | **native ✖ (`structured_outputs`)** | docs | none | n/a | n/a | n/a |
| vision (image input) | native (modalities) | inferred (name) | native (task) | n/a | n/a | native (category) |
| audio input | native (modalities) | inferred (name) | native (task) | native (`can_do_voice_conversion`) | native (inherent) | native (category) |
| image output | native (modalities) | none | native (task) | n/a | n/a | native (category) |
| audio output | native (modalities) | none | native (task) | native (`can_do_tts`) | native (inherent) | native (category) |
| video output | native (modalities) | none | native (task) | n/a | n/a | native (category) |
| embeddings / rerank | native (params) | none | native (task) | n/a | n/a | n/a |
| moderation/guard | inferred (id) | inferred (id) | native (task) | n/a | n/a | n/a |
| STT / TTS / S2S | native (modality) | native (inherent) | native (task) | native (`can_do_*`) | native (inherent) | native (category) |
| voice cloning | n/a | n/a | n/a | native (`can_do_voice_conversion`) | none | native (some categories) |
| diarization/timestamps | n/a | n/a | n/a | n/a | native (API features, docs) | n/a |
| languages | none | none | none | **native ✖ (`languages`)** | **native ✖ (`languages`)** | none |

### Limits / Reasoning / Pricing / Parameters

| Field | OpenRouter | Groq | Cloudflare | ElevenLabs | Deepgram | Fal |
|---|---|---|---|---|---|---|
| context window | native | native | **native ✖ (`properties[].max_context` — array access bug)** | n/a | n/a | n/a |
| max completion tokens | **native ✖ (`top_provider.max_completion_tokens`)** | **native ✖ (retrieve endpoint)** | none | n/a | n/a | n/a |
| max input chars | n/a | n/a | n/a | native (misused as `context`) | n/a | n/a |
| generation duration | n/a | n/a | n/a | n/a | n/a | **native ✖ (`duration_estimate`)** |
| reasoning supported | **native ✖ (`reasoning`)** | docs | none | n/a | n/a | n/a |
| reasoning mandatory | **native ✖ (`reasoning.mandatory`)** | none | none | n/a | n/a | n/a |
| effort levels / default | **native ✖ (`supported_efforts`, `default_effort`)** | none | none | n/a | n/a | n/a |
| input/output per token | **native ✖ (values dropped after cost filter)** | none | none | n/a | n/a | n/a |
| cached/request/image/websearch | **native ✖** | none | none | n/a | n/a | n/a |
| per-character / cost factor | n/a | n/a | n/a | **native ✖ (`model_rates`, `token_cost_factor`)** | none | n/a |
| parameter support list | **native ✖ (`supported_parameters`)** | none | none (`format=openrouter` may provide) | **native ✖ (style/speaker_boost)** | **native ✖ (`formatted_output`)** | none |
| default parameters | **native ✖** | none | none | none | none | none |
| streaming | native (param) | docs | none | inherent | **native ✖ (`streaming`)** | **native ✖ (`stream_url`)** |
| batching | none | docs | native (badges) | n/a | **native ✖ (`batch`)** | none |
| moderation flag | **native ✖ (`is_moderated`)** | none | none | n/a | n/a | n/a |
| endpoints / routes | native (`links.details`) | native (`public_apps`) ✖ | native (tags) ✖ | **native ✖ (`concurrency_group`)** | none | **native (`fal.endpoints`)** |
| benchmarks / quality | **native ✖ (`benchmarks`)** | none | none | none | none | native (`duration_estimate`) ✖ |

**Matrix verdict**: OpenRouter is a near-complete metadata source (only languages and tool-call reliability are missing). Cloudflare is second-richest (task taxonomy + `max_context` + lifecycle flags, possibly full OR-format via `format=openrouter`). Groq gives identity+context+release date but nothing else. ElevenLabs and Deepgram give language/limit/feature booleans that map cleanly onto capabilities. Fal gives lifecycle + category + latency but no pricing/context. The current pipeline discards more native metadata than it keeps.


---

## 4. Metadata Currently Discarded or Incorrectly Inferred (Deliverable 4)

### 4.1 Discarded native provider data (exists in API, never persisted)

1. **OpenRouter** (per model): `created`, `expiration_date`, `knowledge_cutoff`, `canonical_slug`, `hugging_face_id`, `top_provider.max_completion_tokens`, `top_provider.is_moderated`, all `pricing.*` values (only threshold-filtered), the `supported_parameters` list itself (collapsed into 3 booleans), `default_parameters`, `reasoning{mandatory, supported_efforts, default_effort}`, `supported_voices`, `per_request_limits`, `benchmarks`, `architecture.tokenizer`, `architecture.instruct_type`, `architecture.modality`, `links`.
2. **Groq**: `created`, `max_completion_tokens` (retrieve endpoint), `public_apps`.
3. **Cloudflare**: `properties[].max_context` (discarded by bug — array read as object), `task.name/description` (collapsed into booleans; taxonomy lost), `tags`, and lifecycle query params (`include_deprecated`, `hide_experimental`) never requested.
4. **ElevenLabs**: `languages[]`, `model_rates{character_cost_multiplier, cost_discount_multiplier}`, `token_cost_factor`, `requires_alpha_access`, `can_be_finetuned`, `can_use_style`, `can_use_speaker_boost`, `serves_pro_voices`, `concurrency_group`, `max_characters_request_free_user`.
5. **Deepgram**: `languages[]`, `version`, `uuid`, `batch`, `streaming`, `formatted_output`, TTS `metadata`.
6. **Fal**: `date`, `updated_at`, `status`, `license_type`, `duration_estimate`, `github_url`, `model_url`, `stream_url`, `kind`, `pinned`, `highlighted`, `group.label`.

### 4.2 Incorrectly inferred / mis-stored (worse than loss — wrong data)

1. **`reasoning: true` hard-coded for every Groq model** (groq.js:120) — includes Whisper, guard and TTS models. Must be `null` (unknown) or `docs`-provenanced.
2. **OpenRouter reasoning conflation** (online.js:120): `supportsReasoning = hasToolUse || hasReasoning` — tool-capable non-reasoning models are published as "reasoning", while the authoritative `reasoning` object is dropped.
3. **Cloudflare `reasoning := taskName.includes("text generation")`** (cloudflare.js:136) — llama-guard (moderation), m2m100 (translation) published as `reasoning: true`.
4. **Cloudflare `context` bug** (cloudflare.js:124): `item.properties?.max_context` on an array → all 35 CF models persist `context: 0` despite CF providing `max_context`.
5. **Cloudflare vision miss**: `@cf/meta/llama-3.2-11b-vision-instruct` stored with `modalities.image: false`.
6. **ElevenLabs `context` misuse** (elevenlabs.js:67): character limits stored as "context"; `modalities.audio = can_do_voice_conversion` (voice conversion ≠ audio input).
7. **`context: 0` for Deepgram/Fal/CF** — unknown stored as a fact. Unknown must be `null`.
8. **Groq identity parser rot**: no `gpt-oss` branch; new `org/model` ids (`qwen/qwen3.8-27b`, `canopylabs/orpheus-*`) leave `/` in variants; `openai/gpt-oss-safeguard-20b` hits the generic path.
9. **Stale-wins merge** (merge.js:74 + `mergeDeep`): `mergeDeep(freshProducers, prunedOld)` lets KV's old values overwrite fresh provider facts on every overlapping key (context, `description.en`, capabilities). Patches cover only `tier` (`applyFreshOnlineTiers`) and fal routing keys (`applyFreshFalRouting`).
10. **Provider-failure prune hazard**: per-provider catch blocks return `{grouped:{}}` → one failed fetch = "provider has no models" → `pruneStaleModels` deletes that provider's entire catalog presence. (OpenRouter aborts the run instead.)
11. **Dedup deletes availability**: cross-provider dedup removes losers instead of recording multi-provider routes — Fulcrum can't know "also available on Groq".
12. **Asset-allowlist pruning** (`enforceCatalogPolicy` + `FAMILY_ASSETS`): restricted-source models without a client asset are silently dropped (`@cf/moonshotai/kimi-k2.6` case — the original trigger for Fulcrum hard-codes).
13. **No lifecycle anywhere**: 0 of 865 models carry created/updated/deprecation data even where providers provide it — deprecation risk (e.g. `llama-3.1-8b-instant` at gateway.js:578) is invisible to Fulcrum.


---

## 5. Normalized Cortex Model Schema (Deliverable 5)

Design constraints: represent LLMs **and** non-LLMs; flat (producer/series nesting is a *presentation* concern); distinguish provider facts from Cortex inference; backward-compatible with the `producers` tree while giving Fulcrum a queryable structure. New top-level key in the same KV document: **`catalog: CortexModel[]`** — one record per `source:id`, all provider routes preserved (dedup no longer deletes availability).

```js
/** @typedef {Object} CortexModel — one record per (source, provider model id). */
{
  id: "openai/gpt-oss-120b",            // provider model id, verbatim
  source: "openrouter",                 // openrouter|groq|cloudflare|elevenlabs|deepgram|fal|manual|huggingface
  canonicalKey: "openai/gpt-oss-120b",  // dedup key shared across providers (normalizeModelId)
  category: "chat",                     // CATEGORY enum, below

  identity: {
    displayName: "OpenAI: gpt-oss-120b",
    producer: "OpenAI",                 // display producer
    producerSlug: "openai",              // stable machine key
    family:      { value: "gpt-oss", source: "parsed_id", confidence: 0.9 },
    series:      { value: "gpt-oss", source: "parsed_id", confidence: 0.9 },
    variant: "120b",                     // presentation label (tree projection input)
    parameterSize: { value: 120, unit: "B", source: "parsed_id", confidence: 0.7 },
    version: null,                       // e.g. Deepgram "version"
    huggingFaceId: "openai/gpt-oss-120b", // null when unknown
    baseModel: null, aliases: [],        // alias_target / :free twin ids
  },

  lifecycle: {                           // null = unknown — never invented
    createdAt: "2025-08-05T00:00:00Z",  // ISO from provider created/date
    updatedAt: null,                     // fal updated_at
    deprecated: { value: false, source: "provider", confidence: 1 },
    expiresAt: null,                     // OpenRouter expiration_date
    status: "ga",                        // ga|preview|beta|experimental|deprecated|legacy
    knowledgeCutoff: "2024-06-30",
  },

  capabilities: {                         // triplets only on inference-prone fields
    chat: true, completion: false,
    reasoning: { value: true, source: "provider", confidence: 1 },
    tools: { value: true, source: "provider", confidence: 1 },
    parallelToolCalls: null,             // docs-only today
    structuredOutput: true, jsonMode: null,
    vision: true,                        // image input
    imageInput: true, audioInput: false, videoInput: false, fileInput: false,
    textOutput: true, imageOutput: false, audioOutput: false, videoOutput: false,
    speechToText: false, textToSpeech: false, speechToSpeech: false,
    embeddings: false, reranking: false, moderation: false,
    imageGeneration: false, imageEditing: false, videoGeneration: false, videoEditing: false,
    transcription: false, translation: false, classification: false,
    diarization: null, timestamps: null, // STT features (docs provenance)
    voiceCloning: false,
    streaming: { value: true, source: "provider", confidence: 1 },
    batching: null,                       // Deepgram batch flag
    webSearch: false,
  },

```js
  modalities: {
    input: ["text", "image"],             // enum: text|image|audio|video|file
    output: ["text"],
    architectureModality: "text->text",   // provider string verbatim (OpenRouter)
  },

  limits: {
    contextTokens: 131072,                // provider value or null
    maxOutputTokens: 117964,              // top_provider / Groq retrieve or null
    maxInputTokens: null,
    maxInputCharacters: null,             // ElevenLabs char limits (NOT contextTokens)
    maxAudioSeconds: null, maxVideoSeconds: null,
    maxImageMegapixels: null, maxBatchItems: null,
    estimatedGenerationSeconds: null,     // fal duration_estimate (latency proxy)
  },

  pricing: {                              // normalized USD; null = unknown/not published
    currency: "USD",
    inputPerToken: 0.000000037, outputPerToken: 0.00000017,
    cachedInputPerToken: null, request: null, image: null, webSearch: null,
    internalReasoningPerToken: null,
    perCharacter: null,                  // ElevenLabs character_cost_multiplier
    costFactor: null,                    // ElevenLabs token_cost_factor
    free: false,                         // :free variants
  },

  reasoning: {                             // null when unknown
    supported: true, mandatory: true,
    efforts: ["low", "medium", "high"], defaultEffort: "medium",
    // budgetTokens: no provider exposes it today → omitted
  },

  routing: {
    endpointIds: [],                      // fal endpoints
    defaultEndpoint: null,
    regions: null,                        // not exposed in any model list today
    hardware: null,                       // only where provider states it; else null
    isModerated: false,                   // OpenRouter top_provider.is_moderated
    languages: ["en"],                    // ElevenLabs/Deepgram languages
    rateNotes: null,                      // per_request_limits verbatim when present
    catalogMatch: { key: "gpt", asset: "assets/producers/openai.webp" },
  },

  parameters: {                           // per-model support map; null = unknown
    temperature: true, top_p: true, top_k: false, seed: true, stop: true,
    max_tokens: true, tools: true, tool_choice: true,
    response_format: true, structured_outputs: true,
    reasoning: true, reasoning_effort: true,
    logprobs: true, frequency_penalty: true, presence_penalty: true,
    // non-LLM: ElevenLabs {style, speakerBoost, voiceConversion}, Deepgram {formattedOutput}
  },

  metadataQuality: {
    providerFields: 42, inferredFields: 3, unknownFields: 7,
    quality: "good",                      // provider|good|partial|inferred|poor
  },
  firstSeenAt: "2026-01-02T00:00:00Z",    // day precision (hash stability, §7)
  lastSeenAt:  "2026-09-09T00:00:00Z",   // updated only when record content changes
  absentStreak: 0,                        // consecutive syncs absent from fresh payload
  tier: "standard",

  raw: { /* provider object verbatim minus heavy noise: fal thumbnails,
            OpenRouter benchmarks (behind config flag), Groq public_apps */ },
}
```

**CATEGORY enum**: `chat` | `completion` | `embedding` | `reranker` | `moderation` | `stt` | `tts` | `speech2speech` | `image-gen` | `image-edit` | `video-gen` | `video-edit` | `audio-gen` | `translation` | `classification` | `summarization` | `other`.

Derivation precedence: provider-declared task (CF `task.name`, fal `category`, Deepgram stt/tts split, ElevenLabs `can_do_*`) → OpenRouter modality/parameters → id heuristics (last resort, `source: 'heuristic'`).

**Presentation tree stays**: `producers` continues to be served to the client exactly as today; over time it becomes a *projection* of the normalized records (identity.series/variant + description/tier/translations), so the two can never disagree about placement.


---

## 6. Provenance & Confidence Strategy (Deliverable 6)

**Goal**: Fulcrum must be able to distinguish "Groq says this model has 131k context" from "Cortex guessed this from the model name". Inferred metadata must never silently masquerade as provider data.

**Vocabulary** (stored as `source` inside triplets):

| Provenance | Meaning | Confidence convention |
|---|---|---|
| `provider` | read verbatim from the provider API | 1.0 (omitted from payload) |
| `derived` | deterministic computation from provider data (e.g. `tools` from `supported_parameters` ∋ `tools`) | 1.0 for exact mappings; 0.9 for composites |
| `parsed_id` | parsed from the provider model id / slug (`family`, `parameterSize`, `series`) | 0.7–0.95 depending on pattern strength |
| `docs` | curated from provider documentation, in a versioned static map in the repo (e.g. Groq tool-support table, STT diarization matrix) | 0.9 — but flagged `docs`, never `provider` |
| `heuristic` | name-based guess (vision in id, etc.) | 0.4–0.6 |
| `legacy` | value carried from old KV (pre-migration) — allowed only for enrichment keys, never for facts | n/a |
| `unknown` | could not be determined | n/a |

**Where triplets are used — deliberately minimal.** Direct provider passthroughs (id, displayName, contextTokens, pricing numbers, languages, timestamps) need **no triplet**: they are by definition `provider`, and `raw` retention makes them auditable. Triplets (`{ value, source, confidence }`) are used only for fields where Cortex can be *wrong*: `identity.family`, `identity.series`, `identity.parameterSize`, `capabilities.reasoning`, `capabilities.tools`, `capabilities.vision` (for Groq/CF where not task-native), `capabilities.streaming` (where inferred), `lifecycle.deprecated`. Booleans that are `null`-able (unknown) instead of triplet-wrapped stay plain. This keeps the payload small and the trust boundary exactly where inference happens.

**Rules**:
1. If a provider field exists, it wins over any inference — inference is only a fallback, and the record notes it.
2. Never invent: if not determinable → `null` + `metadataQuality.unknownFields++`. Zero/`false` are facts, not defaults.
3. `docs` maps live in `syncer/config/provider-docs.js` with a `docVersion` and a source URL; they are reviewed manually and changed in PRs, never silently.
4. `metadataQuality.quality` roll-up per record: `provider` (≥95% fields provider-sourced) → `good` (≥70%) → `partial` (some inference) → `inferred` (majority inferred) → `poor` (mostly unknown). Fulcrum may prefer `quality: 'provider'` records when facts matter, and may treat triplets with confidence < 0.7 as "soft" hints.
5. `raw` is the audit escape hatch: any consumer can re-derive a normalized field from the provider's own object and file a bug if it disagrees.

---

## 7. Freshness / Merge Strategy (Deliverable 7)

**Field-ownership model** — replaces the current blanket `mergeDeep(fresh, old)` where old KV wins over everything:

| Ownership class | Keys | Merge rule |
|---|---|---|
| **Provider facts** | `identity.*`, `capabilities.*`, `modalities.*`, `limits.*`, `pricing.*`, `reasoning.*`, `parameters.*`, `routing.*`, `lifecycle.createdAt/updatedAt/expiresAt/knowledgeCutoff`, `description.en` (provider text) | **Fresh always wins.** Old value survives only if fresh is absent *and* the model is in a grace period (below). |
| **Cortex bookkeeping** | `firstSeenAt`, `lastSeenAt`, `absentStreak` | persisted/merged by sync, never from provider |
| **Enrichment (Cortex-owned)** | `description.{tr,fr,zh,…}` (translations), `series_description`, `processing_status`, `hidden`, curator `tier: 'premium'`, curator `details` overrides, `imagePath`, manual-model fields | **Old wins, only if fresh is missing that key** — the *only* place old data can survive a fresh provider payload |
| **Policy** | `catalogMatch`, `tier` standard/fallback, exclusions | recomputed fresh every run |

Implementation: `processing/merge.js` gains `mergeByOwnership(freshModel, oldModel)` — an explicit per-key allowlist instead of `mergeDeep(fresh, old)`. `mergeDeep` remains only for the presentation-tree enrichment merge where it is actually intended, or is removed outright once the tree is a projection.

**Provider-failure safety (the prune hazard)**:
- Each provider fetch records a `providerHealth` entry (KV, per source): `{ ok, fetchedAt, modelCount, consecutiveFailures }`.
- A provider run that *fails* (throw / non-OK / zero models) marks `ok: false` and its models are **not pruned** — `pruneStaleModels` (or its catalog equivalent) only considers models whose provider had a healthy run.
- A provider run that succeeds but no longer lists a model increments that record's `absentStreak`; the record is removed only after `absentStreak ≥ 3` *healthy* consecutive runs (≈3 hours at current cron; aligns with the approved Fulcrum pin-grace of "consistent absence"). Until then the record stays with `lifecycle.status` untouched and `absentStreak` visible to Fulcrum.
- OpenRouter returning 0 models still aborts the whole run (existing sanity check, keep).

**Hash stability** (today's change-detection gate): `lastSeenAt` is stored at **day precision** and only rewritten when the record's content (excluding bookkeeping) changes; `firstSeenAt` never changes; `absentStreak` changes only on actual absence. This keeps the whole-document hash stable when nothing changed, so the existing write/backup/telemetry cadence is preserved.

**Migration**: on first deploy, catalog records are seeded from the fresh provider payloads (not from KV) — `firstSeenAt = now`, provenance marks nothing as legacy. The old `producers` tree keeps its current merge behavior for one transitional release, then switches to the ownership merge as well (Phase 3 below), with the curator's enrichment keys enumerated in one constant so nothing curator-owned can be lost.


---

## 8. Provider-Specific Normalization Strategy (Deliverable 8)

New module family: `syncer/processing/normalize/` — one normalizer per provider, each `raw item → CortexModel`, plus shared helpers (`normalize/schema.js`, `normalize/identity.js`, `normalize/tasks.js`). Processors (`processing/*.js`) keep only: fetch, pagination, auth, failure handling — and delegate all field mapping to the normalizer. This removes the current duplication where each processor re-implements identity parsing and capability guesses.

### 8.1 OpenRouter (`normalize/openrouter.js`)
- Map: `canonical_slug`→`canonicalKey` · producer from id prefix + `PRODUCER_MAP` · `created`→`lifecycle.createdAt` · `expiration_date`→`lifecycle.expiresAt`+`status:'deprecated'` · `knowledge_cutoff` · `pricing.*`→normalized USD per token (string→number, `null` when absent) · `top_provider.max_completion_tokens`→`limits.maxOutputTokens` · `is_moderated`→`routing` · `supported_parameters`→`parameters` map + derived booleans (`tools`, `structured_outputs`, `response_format`, `reasoning`, `reasoning_effort`) · `reasoning{mandatory, supported_efforts, default_effort}`→`reasoning` · modalities→`modalities`+capabilities · `benchmarks`→optional `quality` block (config flag, default off) · `hugging_face_id` · `per_request_limits`→`routing.rateNotes`.
- The reasoning/tool conflation is removed: `capabilities.reasoning` comes from the provider `reasoning` object; `tools` is its own field.
- `:free` twins: two records sharing `canonicalKey` (`pricing.free:true`, tier `fallback`) — both routes preserved.
- Series/variant parsing stays in `parser.js`, consuming `raw`, marked `parsed_id`.

### 8.2 Groq (`normalize/groq.js`)
- Map: `owned_by`→producer (primary; id parsing fallback) · `created`→createdAt · `context_window`→contextTokens · `active:false`→`status:'deprecated'` · `max_completion_tokens` when present on list; optionally hydrate from `/models/{id}` behind a config flag (14 req/h) · whisper/orpheus ids→category stt/tts (`parsed_id`) · `compound` ids→`chat`+`webSearch` (`docs`) · guard/safeguard ids→`moderation:true`.
- **Remove hard-coded `reasoning: true`** → `null`; populate from `config/provider-docs.js` with `source:'docs'`.
- Fix parser for new `org/model` ids (strip org, `gpt-oss` branch).

### 8.3 Cloudflare (`normalize/cloudflare.js`)
- **Fix `properties`**: build `property_id → value` map from the array (`max_context`, `input_size`, `output_dimension`…) → `limits.contextTokens` etc.
- Map `task.name`→CATEGORY (`Text Generation`→chat · `Text Embeddings`→embedding · `bge-reranker`→reranker · `ASR`→stt · `Text-to-Speech`→tts · `Image-to-Text`→chat+vision · `Text-to-Image`→image-gen · `Summarization`/`Translation`/`Classification`→respective). `capabilities.reasoning` stays `null` for CF — "task is text generation" no longer means reasoning.
- Request `include_deprecated=true`; read beta/deprecated flags where present.
- **Experiment (one-time, Phase 1):** fetch `?format=openrouter` with credentials; if it matches the OR marketplace schema, switch CF ingestion to it and reuse `normalize/openrouter.js` (gains pricing/context/parameters). Keep default format as fallback.
- `@hf/` LoRA variants: `identity.baseModel` set; category inherited from base.

### 8.4 ElevenLabs (`normalize/elevenlabs.js`)
`languages[]`→`routing.languages` · char limits→`limits.maxInputCharacters` (**not** contextTokens) · `can_do_text_to_speech`→`textToSpeech`+category `tts` · `can_do_voice_conversion`→`voiceCloning` (audio *input* stays false) · `requires_alpha_access`→`status:'preview'` · `model_rates.character_cost_multiplier`→`pricing.perCharacter` · `token_cost_factor`→`pricing.costFactor` · `can_use_style`/`can_use_speaker_boost`→`parameters` · `concurrency_group`→`routing` · `can_be_finetuned` noted. `contextTokens: null`.

### 8.5 Deepgram (`normalize/deepgram.js`)
stt list membership→category `stt`+`speechToText`+`audioInput`+`textOutput` · `streaming`/`batch`→capabilities · `formatted_output`→parameters · `languages[]`→routing (multilingual→`["multi"]`) · `version`→identity.version · `canonical_name`→id · `contextTokens: null` (never 0). Aura→category `tts`.

### 8.6 Fal (`normalize/fal.js`)
Keep endpoint consolidation; emit normalized records: `fal.endpoints`→`routing.endpointIds`+`defaultEndpoint` · endpoint `category`→modalities+capabilities (as today) **plus** `date`→createdAt · `updated_at` · `status`→lifecycle · `license_type`→raw+`identity.license` · `duration_estimate`→`limits.estimatedGenerationSeconds` · `group.key`→family (provider) · `tags` kept · `model_url`/`github_url`→raw links. `raw` = primary endpoint object.

### 8.7 Manual / HuggingFace (minimal touch)
Manual models become CortexModel records with `source:'manual'`, category from `type` (roleplay→chat), inference fields `null`, curator fields (url, size, ram, chatFormat) under a `local` block — the catalog stays complete without inventing provider facts.


---

## 9. Required Catalog-Policy Changes (Deliverable 9)

1. **Separate policy from processors.** "research" id skip, image-output exclusion, `:free` tier, cost limits (OpenRouter), `TRUSTED_FAL_PRODUCERS`, `EXCLUDED_CATEGORIES/SUBSTRINGS` move into `catalog-policy.js` as named, documented rules. Processors normalize; policy decides inclusion. Every exclusion emits a **reason code** (`excluded:research`, `excluded:cost`, `excluded:asset-missing`, `excluded:category`, `excluded:substring`) into the sync log — counts per reason, no more silent drops.
2. **Asset matching stays the gate for restricted sources** (`cloudflare`, `deepgram`, `elevenlabs`, `fal`), but: (a) any new family that fails matching is *logged as an alarm row* (id + source) instead of silently vanishing; (b) add currently missing keys (`kimi`→moonshot asset, explicit `gpt-oss`, `compound`, `orpheus`/`canopylabs`, `allam`, `prompt-guard`/`safeguard`, `m2m100`, `qwen3-embedding`) so CF/Groq families stop being pruned or mis-assorted; (c) long-term, a missing asset should degrade to a default icon at display time rather than delete a model from the catalog — requires a coordinated client change; until then the asset list remains the allowlist and must be kept complete.
3. **Dedup becomes routing, not deletion** (catalog level): records sharing `canonicalKey` keep all provider entries; `SOURCE_PRIORITY` marks one `preferred: true` route. The `producers` tree keeps today's winner-only behavior.
4. **Lifecycle-aware policy**: deprecated models stay in the catalog with `lifecycle.status:'deprecated'`; excluding them becomes a Fulcrum choice, not a Synapse deletion. Optional config: drop models whose `expiresAt` is >90 days past.
5. **Blacklist** (`model_blacklist` KV) continues to apply at ingest *and* serve time — `serveModelsJson` must also filter the new `catalog` array (it currently filters only `producers`).
6. **Size guard**: `raw` trimming rules (drop fal thumbnails, OR benchmarks behind flag, omit empty raw) + hard cap alarm if document > 8 MB (Cloudflare KV max 25 MB).

---

## 10. Edge Cases & Migration Risks (Deliverable 10)

| # | Case | Handling |
|---|---|---|
| 1 | **Provider total failure** (Groq sync dies) | `providerHealth` marks the source unhealthy → no pruning of its models; catalog keeps last known state; log + optional alarm. (Fixes current behavior where `{grouped:{}}` wipes the provider.) |
| 2 | **Provider removes a model** | `absentStreak` increments only on healthy runs; removal after 3 consecutive healthy absences. Grace window matches Fulcrum pin-invalidation. |
| 3 | **OpenRouter 0-model sanity check** | Keep current behavior: abort whole run, keep everything. |
| 4 | **Hash churn from bookkeeping** | `lastSeenAt` day-precision + content-gated updates keep the hash stable (no hourly backups/writes when nothing changed). |
| 5 | **KV document size** | `raw` trimming + benchmarks flag; monitor size; if >8 MB persistently, split `catalog` into its own KV key served at `/catalog` (Phase 5 option). |
| 6 | **Client compatibility** | `producers` tree byte-shape unchanged during Phases 1–3 (additive `catalog` key ignored by old parsers). Presentation-affecting changes (CF context fix, Groq variant cleanup) alter *values* the client renders — verified visually in Phase 3. |
| 7 | **Curator/supervisor enrichment collisions** | ownership allowlist (§7) — translations/series_description/processing_status survive; provider facts don't get frozen by old KV anymore. `applyFreshOnlineTiers`/`applyFreshFalRouting`/`migrateOfflineEnrichment` retained until the projection switch (Phase 4), then folded into `mergeByOwnership`. |
| 8 | **Duplicate display keys** (variant collisions) | existing `${variant} [${id}]` disambiguation retained in the tree; catalog is id-keyed so immune. |
| 9 | **Groq org/model id shift** (`qwen/qwen3.8-27b`) | parser fix + `canonicalKey` normalization keeps dedup stable across the id-format transition; log every id-shape change. |
| 10 | **`llama-3.1-8b-instant` deprecations** | lifecycle fields make it visible; Fulcrum's hard-codes are the mitigation until Phase (Fulcrum) lands. |
| 11 | **Fal base-id consolidation drift** | consolidation unit-tested against fixtures; `fal.baseId` kept stable; policy audit JSON (`provider-catalog-results.json`) regenerated as CI artifact. |
| 12 | **Timezone/timestamps** | all ISO 8601 UTC; provider unix seconds converted once, in the normalizer. |
| 13 | **Curator concurrent writes** | unchanged lock/version-conflict mechanism (data_write_lock + version check). |
| 14 | **`format=openrouter` drift** | if CF changes the shape, the shape-validation step (schema.js asserts required keys) falls back to default format and logs. |
| 15 | **Test/fixture staleness** | fixtures recorded from live APIs with capture dates; refresh procedure documented in `tests/fixtures/README.md`. |

**Migration risk summary**: the two behavior-changing moments are (a) the freshness fix — stale values stop winning, which *is the point* but means long-frozen wrong context/descriptions may visibly change; and (b) CF context/identity fixes. Both are phased behind shadow observation. The additive `catalog` key is zero-risk for existing consumers.


---

## Target Data Flow & Ownership (Phase 4 of the brief)

```
Provider model API
   ↓  fetch + paginate + auth + failure marking          → processing/<provider>.js (thin)
Provider-specific raw item
   ↓  raw → CortexModel mapping, provider facts only      → processing/normalize/<provider>.js
Normalization layer (schema builders + validation)        → processing/normalize/schema.js
Identity / family / series parsing (parsed_id)           → processing/normalize/identity.js + parser.js
Capability & category inference (task maps, fallbacks)    → processing/normalize/tasks.js
Pricing & lifecycle normalization (units, ISO dates)      → inside each normalizer (pure fns)
Provenance + confidence assignment + metadataQuality     → processing/normalize/schema.js
Catalog policy (allow/deny + reason codes, dedup-routes)  → processing/catalog-policy.js
Freshness merge by ownership + providerHealth + streaks   → processing/merge.js
Persisted normalized Cortex catalog (KV `list` document: catalog + producers)  → kv/data.js
Fulcrum (queries `catalog`; `producers` stays for the client)
```

Single ownership per concern: processors never parse identities; normalizers never fetch; policy never mutates records (only includes/excludes/marks); merge never decides correctness of facts (only ownership).

## 11. Phased Implementation Plan (Deliverable 11)

**Phase 0 — Groundwork (no behavior change)**
- Files: new `syncer/tests/fixtures/{openrouter,groq,cloudflare,elevenlabs,deepgram,fal}.json` (recorded live payloads, trimmed) + `tests/fixtures/README.md`; `syncer/package.json` add `"test": "node --test tests/"`.
- Also: one-time experiment script (local) for CF `?format=openrouter` — decide §8.3 path.

**Phase 1 — Normalize layer + shadow catalog (additive)**
- New: `processing/normalize/{schema.js, identity.js, tasks.js, openrouter.js, groq.js, cloudflare.js, elevenlabs.js, deepgram.js, fal.js}`.
- Modified: `core/sync.js` (build `catalog` from normalized records, apply bookkeeping, write additively), `types.js` (CortexModel typedef), `kv/data.js` (no change needed — same document), `core/serve.js` (filter `catalog` on blacklist).
- `producers` generation untouched. Observation: 1–2 days of comparing `/models` catalog content vs `raw` provider payloads (count + spot checks).

**Phase 2 — Freshness fix (behavior change, biggest win)**
- Modified: `processing/merge.js` (`mergeByOwnership`, `ENRICHMENT_KEYS` allowlist, `providerHealth`, `absentStreak` grace), `core/sync.js` (health recording).
- Watch: context/description corrections propagate; curator translations survive (supervisor logs unaffected).

**Phase 3 — Provider fact fixes (values become truthful)**
- Modified: `processing/cloudflare.js` (properties array fix, include_deprecated, task taxonomy), `processing/groq.js` (parser: gpt-oss + org/model ids; reasoning→null/docs; created), `processing/elevenlabs.js` (languages, limits, lifecycle), `processing/deepgram.js` (streaming/batch/languages/version), `processing/fal.js` (lifecycle/limits fields), `processing/online.js` (reasoning split from tools, pricing values).
- New: `config/provider-docs.js` (docs-provenanced tables with docVersion).
- Update `config/client-assets.js` missing keys (§9.2b).

**Phase 4 — Policy extraction + dedup routes**
- Modified: `processing/catalog-policy.js` (reason codes, moved rules), `processing/dedup.js` (catalog-level routes + preferred flag; tree behavior unchanged), `core/sync.js` (wire).

**Phase 5 — Serve & projection**
- Modified: `core/serve.js` (optional `GET /catalog` route or query param), `processing/*` (producers tree becomes projection of normalized records; remove `applyFreshOnlineTiers`/`applyFreshFalRouting` duplication in favor of ownership merge).
- Optional: split `catalog` to its own KV key if size demands.

**Phase 6 (Fulcrum repo — already approved plan, unchanged)**: `model-policy.js` consumes `catalog` with role resolution, pins, and retirement of hard-coded IDs (`router.js:78-81,206,321,381,518-567`, `stream.js:828,1077,1163-1209,1284`, `gateway.js:578,783,860`, `title.js:57`), including the router.js:206 filter fix (groq/cloudflare visibility).

Fulcrum queries after this lands (Phase 5 readiness):
- "Groq + chat + tools + ≥32k + reasoning" → `catalog.filter(m => m.source==='groq' && m.category==='chat' && m.capabilities.tools?.value === true && (m.limits.contextTokens ?? 0) >= 32768 && m.capabilities.reasoning?.value === true)`
- "medium-cost text + streaming + structured output + good context" → price bands from `m.pricing`, `m.capabilities.streaming.value`, `m.parameters.structured_outputs`, `m.limits.contextTokens`.
- "TTS + English + streaming + voice selection" → `m.category==='tts' && m.routing.languages.includes('en') && m.capabilities.streaming.value && m.parameters.speakerBoost !== false`.

---

## Open Questions (for review)

1. **CF `format=openrouter`**: adopt if shape-compatible? (Saves a Cloudflare-specific capability layer; adds an undocumented-API dependency.) Recommend: adopt with default-format fallback.
2. **Groq `max_completion_tokens` hydration** (14 retrieve calls/hour): worth it, or leave `null` until Groq exposes it in the list endpoint?
3. **`raw` retention granularity**: full provider object (recommended) vs curated subset — KV budget says full is fine (~2× document), but confirm.
4. **Supervisor** writes series descriptions keyed by producer/series — after Phase 4 projection, key them by `canonicalKey` instead? (Minor supervisor change, keeps enrichment stable across renames.)

*Prepared from a full audit of the Synapse syncer/curator/supervisor code, the live `/models` catalog, live OpenRouter/Fal responses, and official Groq/ElevenLabs/Deepgram/Cloudflare API references. No production code was changed.*











