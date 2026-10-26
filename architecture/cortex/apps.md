# Cortex Apps (connected third-party apps)

> **Hidden:** `kAppsEnabled` in `lib/apps/feature.dart` is `false` until Fulcrum's integration endpoints are deployed. It hides the sidebar entry and the chat tools; set it to `true` to ship Apps.

Users connect services such as Gmail, Google Calendar, Notion, GitHub or Slack so the assistant can read and act in them from chat. Connections, OAuth and tool execution run through Composio, but **only Fulcrum talks to Composio**; Cortex sends the Firebase ID token and never sees the Composio key.

## Client (`lib/apps/`)

| File | Responsibility |
|---|---|
| `models.dart` | `CortexApp`, `AppCategory`, `AppAction`, `AppPermission` (`ask`, `allow`, `read_only`, `off`). |
| `service.dart` | `AppsService`: Dio client for the Fulcrum integration endpoints (App Check via `createFulcrumHttp`). |
| `controller.dart` | `AppsController` singleton: catalog, connections, per-app permissions. Persists connected apps and permission choices in `SharedPreferences` (`cortex_apps_state_v1`) so chat can decide synchronously which tools to offer and enforce permissions on the device. |
| `screen.dart` | `AppsScreen` (Installed / Popular / category shelves / All apps, bottom search) and `AppsListScreen`. Opened from the sidebar (`AxonMenu` → `MainScreenState._openApps`). |
| `detail.dart` | Bottom sheet: connect/disconnect and the four permission choices. |
| `logo.dart` | `AppLogo`: sniffs SVG vs raster bytes, memory + disk cache, monogram fallback. |
| `categories.dart` | `AppGroup`: maps free-form Composio categories to localized shelves. |
| `widgets.dart` | Row, section header, top bar and search field. |
| `chat_tools.dart` | `AppChatTools`: `find_app_actions` / `run_app_action` chat tools and the approval dialog. |

Connecting opens the Composio-hosted sign-in page in the external browser; `AppsScreen` refreshes the catalog when the app resumes.

All UI strings are `apps*` keys in every ARB file. App descriptions are translated server-side (see below).

## Chat flow

`ToolRegistry.getLocalizedToolsJson` appends `AppChatTools.toolsJson()` only while at least one connected app is not `off`. `SendService` calls `AppChatTools.beginTurn()` per reply, so all actions in one reply share one Fulcrum daily-quota turn.

1. `find_app_actions(query, app?)` → `discoverIntegrationTools`; actions blocked by the app's permission are filtered out.
2. `run_app_action(action, arguments)` → permission check → `executeIntegrationTool`.
   - `ask`: approval dialog (Deny / Always allow / Allow once) on `navigatorKey`; times out as deny.
   - `allow`: runs directly. `read_only`: only actions classified read-only. `off`: never.

Tool results go through the prompt firewall like every other tool output.

## Fulcrum (`functions/src/integrations.js`, `integrationPolicy.js`)

`getIntegrations` (catalog + connection + `permission`, `lang` for translated descriptions via Google Cloud Translation with an in-memory cache), `setIntegrationPermission` (stores `users/{uid}/integrationPermissions/{slug}.mode`), `startIntegrationConnection`, `disconnectIntegration`, `discoverIntegrationTools`, `getIntegrationTool`, `executeIntegrationTool`. Discovery hides `off` apps; inspect/execute reject `off` (`integration_disabled`) and non-read actions for `read_only` (`integration_read_only`). Read-only classification prefers Composio `readOnlyHint`/`destructiveHint` tags, then action verbs; unknown verbs count as writes. Daily action quotas per tier live in `INTEGRATION_DAILY_LIMITS`.

If the deployed Fulcrum predates `setIntegrationPermission`, the client keeps the permission locally (404 is tolerated) and still enforces it on the device.
