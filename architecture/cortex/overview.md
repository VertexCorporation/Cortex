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

### App Check rollout

`AppBootstrap.init` activates `firebase_app_check` immediately after the existing
Firebase initialization, before Firestore configuration and the auth/provider
graph. Debug builds use Android/Apple debug providers; profile and release builds
use Play Integrity on Android and App Attest with DeviceCheck fallback on iOS.
The resolved FlutterFire 0.4.3 fallback is OS-version based, not a retry after
failed attestation (Cortex targets iOS 15). SDK token caching and automatic refresh
are left enabled. Provider-installation exceptions are caught without logging
tokens or preventing the remaining bootstrap. No forced token fetch is awaited.

The FCM background isolate only renders local notifications from its payload and
does not access protected Firebase resources; it has no second App Check path.
Web has placeholder Firebase options and no configured reCAPTCHA provider, and
desktop has no app target here; neither gets a speculative provider.
There are no Realtime Database or Storage SDK dependencies. Storage-backed image
URLs and Fulcrum generation/media requests use direct HTTP. The shared
`network/fulcrum_http.dart` factory now installs one App Check interceptor on the
global, chat/SSE, title, tool, document fallback, STT and TTS Dio clients. It adds
`X-Firebase-AppCheck` only for the exact HTTPS Fulcrum origins in its allowlist.
Concurrent lookups share in-flight work; `FirebaseAppCheck.instance.getToken()`
uses the SDK cache, without forced refresh or a separate token cache. Null tokens,
SDK errors and a 500 ms lookup timeout all continue without the header.

The redirect adapter prevents native automatic redirects from leaking this
custom header outside Fulcrum. It preserves native GET/HEAD and POST-to-GET 303
redirect behavior, does not replay upload bodies, and leaves the final SSE stream
unbuffered. Original Authorization, request headers, timeouts and cancellation
remain intact on the initial request.

Coverage includes sendMessage (chat, roleplay, memory, prompt optimization and
image/audio/video generation), generateFastTitle, executeTool (including document
payloads), getSpeechToken, getAssemblyToken, settleSpeechUsage, synthesizeSpeech,
and the direct HTTP callable requests getNewsCacheUrl/getCoverDownloadUrl.
Firebase callable SDK operations use SDK App Check propagation. Signed Storage/CDN transfers, model downloads, native media
viewers, external speech WebSockets and the Synapse catalogue intentionally
receive no App Check token. No current Fulcrum API call bypasses the configured
clients; new backend origins must be explicitly added to the allowlist. Web
propagation remains disabled with its placeholder Firebase configuration.

Fulcrum's shared `functions/src/https.js` wrappers now cover Cortex-facing HTTP
and callable endpoints. HTTP uses Admin verification concurrently with the original
handler; callables reuse Firebase's existing verification without a second SDK
call. Observation is deduplicated per raw request and attached as
`appCheckObservation.classification`. Verified, legacy/missing and invalid all
continue; logs contain classifications only. Webhooks, Cloud Tasks and background
triggers are excluded. Enforcement and replay protection remain disabled.

Before publishing:

- Keep enforcement disabled. Monitor adoption before a separate enforcement rollout.
- Android `com.vertex.cortex` is already registered for Play Integrity. Verify
  the Firebase registration uses the Google Play **app-signing** SHA-256
  certificate and Play Integrity is linked to the same Firebase/Cloud project.
  Test a release installed through a Play internal testing track and inspect
  verified requests in Firebase App Check metrics.
- Register the actual iOS app from `ios/GoogleService-Info.plist` for App Attest
  and DeviceCheck in Firebase, with the correct Apple team and DeviceCheck key.
  Enable App Attest for the Apple app identifier and refresh provisioning
  profiles as needed. The shared Runner entitlement uses the required
  `production` App Attest environment. Verify a signed physical-device/TestFlight
  build and its App Check metrics; the placeholder `lib/options.dart` is unused.
- For local `flutter run`, register the SDK-generated debug token privately in
  Firebase App Check's debug-token allowlist. Never commit tokens or logs
  containing them. Profile/release builds deliberately use real attestation;
  use debug builds for simulators and routine local development.
- Smoke-test cold/offline startup, existing authenticated and anonymous sessions,
  Firestore reads, and callable functions. Client activation alone cannot prove
  valid attestation or correct console/signing configuration.

References: [Flutter initialization](https://firebase.google.com/docs/app-check/flutter/default-providers),
[Play Integrity setup](https://firebase.google.com/docs/app-check/android/play-integrity-provider),
[App Attest setup](https://firebase.google.com/docs/app-check/ios/app-attest-provider).

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
