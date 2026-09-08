# Synapse Supervisor

Enrichment and maintenance worker on a 10-minute cron (`*/10 * * * *`), with HTTP routes for operational control. `wrangler.toml` binds `MODELS_JSON` + `LOCKS` and sets `OPENROUTER_REFERER`/`OPENROUTER_TITLE` for OpenRouter API calls.

The entry point `supervisor.js` delegates scheduled events to `core/main.js` (`handleScheduled`) and fetch events to `http/routes.js` (`handleFetch`).

## Roles

- Catalogue enrichment: fetching extra model metadata and translation (`api/openrouter.js`, `api/translate.js` — external API adapters with secrets from environment variables).
- Maintenance and cleanup tasks (`core/task.js`, `logic/find.js`).
- Operational HTTP handlers: status reporting and manual cleanup (`http/handlers/status.js`, `http/handlers/cleanup.js`).

KV access and locking go through `kv/data.js` and `kv/lock.js`, consistent with the shared coordination model: locks prevent concurrent writes, versions and hashes detect races (see `overview.md`).

## Files

`supervisor.js` · `core/main.js` · `core/task.js` · `http/routes.js` · `http/handlers/status.js` · `http/handlers/cleanup.js` · `api/openrouter.js` · `api/translate.js` · `config/constants.js` · `config/settings.js` · `kv/data.js` · `kv/lock.js` · `logic/find.js` · `utils/helpers.js` · `utils/logger.js`.
