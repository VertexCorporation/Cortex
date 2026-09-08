# Fulcrum Overview

Fulcrum is the Node.js 22 Firebase Functions backend of Cortex (sibling repository, `functions/` directory). It is the server side of every authenticated operation: generation routing, provider secrets, credit accounting, subscription verification and identity.

## Layout and deployment

`functions/index.js` initializes the Firebase Admin SDK (storage bucket `vertex-ai-1618.firebasestorage.app`), calls `setGlobalOptions({ maxInstances: 10 })` — mandatory before any function definition, because ~70 functions at the default 100 instances/function exceeded the region's Cloud Run CPU quota (20 vCPU) and failed deploys — imports each function family from `src/` and spreads them into one flat namespace. The flat namespace preserves stable callable names for the Flutter client and older clients (e.g. `createCustomModel`, not `models-createCustomModel`).

Function types:

- HTTPS callable (`onCall`) — authenticated app operations.
- HTTPS request (`onRequest`) — streaming, uploads, webhooks.
- Firestore, Pub/Sub and scheduler triggers — asynchronous work.

Areas:

- Generation (`gateway.js -> router.js -> stream.js`, plus title/tools/voice/chat) — see `generation.md`.
- Identity, entitlements, IAP, credits (`user.js`, `helpers.js`, `iap.js`, lifecycles, `scheduled.js`) — see `billing.md`.
- Content and operations (`models.js`, `news.js`, `notifications.js`, `config.js`, `partner.js`, `contributors.js`, `leaderboard/*`) — catalogued in `functions-map.md`.

Tests live in `functions/test/` (chat-regression, fal-routing, media-routing, sse) and cover chat regressions, media routing and SSE behavior because this gateway is a client compatibility contract.

## Trust boundary

Fulcrum is the trust boundary for provider secrets, Firebase Admin access, credit accounting, subscription verification and server-side routing. The client supplies intent and context; Fulcrum decides authorization, cost, provider and safe fallback. Firestore transactions protect balance/entitlement mutations, while Cloud Tasks and Pub/Sub move retryable work away from interactive requests.
