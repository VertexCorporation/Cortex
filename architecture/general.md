# Cortex System Architecture

This is the entry point for all architecture documentation. **Read this file first.** Then open only the area document that matches the problem you are solving, and from there only the source files you actually need. Do not load the whole documentation tree, and do not scan the whole repository.

## 1. Documentation map

| Document | Read when working on |
|---|---|
| `cortex/overview.md` | App startup, provider graph, layering rules, maintenance rules |
| `cortex/chat.md` | Chat pipeline: input, send orchestration, SSE streaming, rendering |
| `cortex/rag.md` | Document ingestion, BM25 retrieval, context injection |
| `cortex/library.md` | Model catalog, downloads, custom GGUF models |
| `cortex/auth.md` | Login/registration, anonymous accounts, sessions, onboarding gates |
| `cortex/payments.md` | Subscriptions, in-app purchases, credits, entitlements |
| `cortex/file-map.md` | Locating any of the 304 Dart files (declarations + responsibility) |
| `fulcrum/overview.md` | Firebase Functions backend layout and trust boundary |
| `fulcrum/generation.md` | Generation gateway, routing, provider streaming, SSE contract |
| `fulcrum/billing.md` | Accounts, entitlements, IAP verification, credit engines |
| `fulcrum/functions-map.md` | Locating any Fulcrum function (file -> exports) |
| `synapse/overview.md` | Workers control plane, KV coordination, end-to-end flows |
| `synapse/syncer.md` | Hourly provider catalog ingestion and normalization |
| `synapse/curator.md` | Protected editorial API for curated models |
| `synapse/supervisor.md` | Enrichment and maintenance worker |

### Problem routing

| Problem | Read first |
|---|---|
| Chat send/stream/render bug | `cortex/chat.md` |
| Model unreachable / SSE errors | `fulcrum/generation.md` + `cortex/chat.md` |
| RAG indexing or retrieval | `cortex/rag.md` |
| Model list wrong or missing | `synapse/syncer.md` + `cortex/library.md` |
| Login/register/anonymous upgrade | `cortex/auth.md` + `fulcrum/billing.md` |
| Purchase not granted / credits wrong | `cortex/payments.md` + `fulcrum/billing.md` |
| Startup or crash issue | `cortex/overview.md` |
| "Which file is X in?" | `cortex/file-map.md` or `fulcrum/functions-map.md` |
| Notifications/news/leaderboard features | `fulcrum/functions-map.md` |

## 2. System map

Cortex is three cooperating systems:

- **Cortex** (this repository, `lib/`) — Flutter hybrid AI client. Widgets render UI, Provider objects hold reactive state, services orchestrate I/O, repositories isolate data access. Firebase supplies auth/cloud; the Fulcrum proxy supplies online generation; local services supply offline models and document retrieval.
- **Fulcrum** (sibling repo `../Fulcrum`, deployed as Firebase Functions) — the execution backend and trust boundary: provider secrets, credit accounting, subscription verification, server-side routing.
- **Synapse** (sibling repo `../Synapse`, three Cloudflare Workers) — the model-catalog control plane that builds, curates and publishes the model list Cortex consumes.

## 3. Critical data flows

**Chat generation.** Input widgets -> `InputProvider`/`ChatSessionProvider` -> `SendService` -> context/memory/PII/RAG -> `ApiService` (Fulcrum gateway over SSE) -> processor/response/media/tools -> `ConversationProvider` -> message tiles -> storage/history. Details: `cortex/chat.md`, `fulcrum/generation.md`.

**Model catalog.** Synapse Syncer (hourly) -> provider inventories -> normalize/deduplicate/merge/policy -> `MODELS_JSON` KV -> edge cache -> Flutter `ModelRepository`/`ModelService` -> library screens and chat model selection. Details: `synapse/syncer.md`, `cortex/library.md`.

**Purchase.** Store purchase -> `FundsBackend` -> Fulcrum `verifyPurchase` / store lifecycle webhooks -> entitlement/credit mutations in Firestore -> client `CreditsManager` and UI. Details: `cortex/payments.md`, `fulcrum/billing.md`.

**Identity.** Anonymous-device registration -> optional upgrade to email/Google/Apple -> Firestore user document + callables -> `UserProvider`/session persistence. Details: `cortex/auth.md`, `fulcrum/billing.md`.

## 4. Boundaries

- **Trust boundary.** The client supplies intent and context; Fulcrum decides authorization, cost, provider and safe fallback. Firestore transactions protect balance/entitlement mutations; Cloud Tasks and Pub/Sub move retryable work off the interactive path.
- **Control plane.** Fulcrum executes user requests and protected business operations; Synapse publishes the model knowledge/control plane; Cortex consumes both through stable contracts (SSE events, `/models.json`, callable names).
- **PDF evidence boundary.** The product PDF describes hybrid orchestration, offline inference, vector databases and a roadmap. Client counterparts exist in `lib/`; claims about LLaMA.cpp/Metal/NPU, serverless workers, retention and backend routing must be verified in `android/`, `ios/`, Firebase Functions and external service repos before treating them as implemented.

## 5. Maintenance rules

- Keep widgets focused on presentation; keep network, persistence and model decisions in services.
- Preserve conversation-ID checks during streaming.
- Release local model resources when `ChatController` is disposed.
- Treat localization classes as generated outputs and edit ARB sources.
- Verify both `tiles.temp.dart` and `tiles_temp.dart` before removing either.
- Keep PDF roadmap statements separate from source-verified behavior.
