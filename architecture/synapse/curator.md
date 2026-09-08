# Synapse Curator

Protected editorial/admin worker — "Main entry point for ALL admin panel data modifications". No cron; HTTP only. `wrangler.toml` binds `MODELS_JSON` + `LOCKS` and sets `FIREBASE_PROJECT_ID` for token verification.

## Routes (curator.js)

- `GET /curated` — public: returns the manual models (`getManualModels`).
- `POST /curated/update-list` — granular update of the main catalogue list; accepts a single payload or `{ batch: [...] }`; serialized through the `LOCKS` namespace so only one write runs at a time.
- `POST /curated` — create a manual model (`saveManualModel`).
- `PUT /curated/:id` — update; the model ID in the URL must match the payload ID.
- `DELETE /curated/:id` — delete a manual model.

All protected routes go through `verifyAuth` (`auth/middleware.js`); failures return 403. `sanitizePathSegment` strips unsafe characters to prevent path traversal. Every successful mutation schedules an edge-cache purge of `/models.json` so clients see the update.

## Files

- `curator.js` — entry point and routing.
- `auth/middleware.js` — `verifyAuth` Firebase token verification.
- `utils/kv.js` — `getManualModels`, `saveManualModel`, `deleteManualModel`, `updateModelsList` (locking + write serialization).
- `utils/response.js` — CORS-compliant `jsonResponse`, `errorResponse`, `handleOptions`.

Curator is the human editorial surface for manual model changes and cache purges; Syncer's `merge.js` preserves these curated fields during automated syncs.
