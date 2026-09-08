# Cortex Client Overview

App-wide structure of the Flutter client: layering, startup and cross-cutting rules. Feature areas have their own documents: `chat.md`, `rag.md`, `library.md`, `auth.md`, `payments.md`. To locate any file, use `file-map.md`.

## 1. Layering

Widgets render UI, Provider objects hold reactive state, services perform orchestration and I/O, repositories isolate data access, Firebase supplies auth/cloud capabilities, the Fulcrum proxy supplies online generation, and local services supply offline models and document retrieval.

Rules of thumb:

- Keep widgets focused on presentation; keep network, persistence and model decisions in services.
- Providers own reactive state; services never rebuild UI directly.
- Repositories are the only code that knows where model data comes from.

## 2. Startup

`main.dart` initializes Firebase, Firestore persistence, preferences, downloader, Crashlytics, FCM, orientation and providers. `AppBootstrap`/`AppGatekeeper` (main.dart) gate the first frame on bootstrap and auth; `BootstrapResult` carries readiness; `TabProvider` holds shell tab state. `AppInitializer` (initialization.dart) coordinates readiness, authentication state, onboarding and upgrade coordination (`AppStatus`, `AppUpgraderMessages`).

`app.dart` builds the `MaterialApp` (class `Cortex`) with theme, localization and analytics. `screen.dart` (`MainScreen`) is the feature shell. Navigation helpers live in `routes.dart` (`FadeRoute`, `SlideRightRoute`) and `navigation.dart`; runtime errors are caught by `ErrorBoundary` (boundary.dart). `AppLifecycleManager` (lifecycle.dart) tracks foreground/background.

## 3. Feature areas

| Area | Purpose | Document |
|---|---|---|
| `chat/` | Active conversation: input, sending, streaming, rendering | `chat.md` |
| `axon/` | Conversation history, inbox, search | `file-map.md` |
| `rag/` | Document ingestion and BM25 retrieval | `rag.md` |
| `library/` | Model catalog, downloads, custom models | `library.md` |
| `login/` | Auth flows and screens | `auth.md` |
| `funds/`, `server/` | Subscriptions, purchases, credits | `payments.md` |
| `settings/` | Profile, theme, language, account management | `file-map.md` |
| `roleplay/` | Character discovery and roleplay chat | `file-map.md` |
| `news/`, `arts/` | News feed and media gallery | `file-map.md` |
| `notifications/` | In-app (introvert) and push (extrovert) notifications | `file-map.md` |
| `l10n/` | Generated localizations (21 languages) | `file-map.md` |

## 4. Maintenance rules

- Keep widgets focused on presentation; keep network, persistence and model decisions in services.
- Preserve conversation-ID checks during streaming.
- Release local model resources when ChatController is disposed.
- Treat localization classes as generated outputs and edit ARB sources.
- Verify both `tiles.temp.dart` and `tiles_temp.dart` before removing either.
- Keep PDF roadmap statements separate from source-verified behavior.

## 5. PDF evidence boundary

The product PDF describes hybrid orchestration, dynamic model selection, offline inference, multimodal generation, privacy, RAG, an AI catalog and an 18-month roadmap. Client counterparts exist in `lib/`. Claims about LLaMA.cpp/C++/Neon/Metal/NPU, serverless workers, vector databases, retention, agents and backend routing must be checked in `android/`, `ios/`, Firebase Functions and external service repositories before treating them as implemented.
