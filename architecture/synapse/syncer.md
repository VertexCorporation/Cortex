# Synapse Syncer

Ingestion/normalization worker. `wrangler.toml` configures the cron `5 * * * *` (hourly) and the `MODELS_JSON` + `LOCKS` KV bindings. The entry point `syncer.js` routes scheduled events to `core/sync.js` (`syncModels`) and serves `/models` and `/models.json` through `core/serve.js` (`serveModelsJson`).

## Sync pipeline (core/sync.js)

Validates bindings, acquires a distributed lock, reads the current KV document and blacklist, then fetches provider inventories concurrently with `Promise.allSettled`. Processors cover OpenRouter, Fal.ai, ElevenLabs, Deepgram, Cloudflare Workers AI, Groq, manual KV models and Hugging Face/offline models (`processing/*`).

Processors normalize provider-specific metadata into producer -> series -> variant:

- `config.js` defines provider allowlists, display names, cost limits, timeouts, TTLs, discovery bounds and source priority.
- `parser.js` converts inconsistent provider names into stable series/variant labels.
- `dedup.js` normalizes equivalent IDs and applies provider priority.
- Offline/manual/Hugging Face processing keeps GGUF entries safe from online pruning.
- `merge.js` removes genuinely stale entries while preserving curator translations, descriptions and editorial fields.
- `catalog-policy.js` applies final visibility and tier rules.

The syncer refreshes Hugging Face metadata, hashes the final data, skips unchanged writes, checks optimistic version conflicts, creates backups and writes list/hash/version to KV.

## Serving (core/serve.js)

Serves cache hits first, falls back to KV, filters blacklisted models, adds ETag/cache headers and repopulates the Cloudflare edge cache.

## Files

`syncer.js` · `core/sync.js` · `core/serve.js` · `config.js` (+ `config/client-assets.js`) · `types.js` · `processing/` (`catalog-policy`, `cloudflare`, `dedup`, `deepgram`, `elevenlabs`, `fal-models`, `fal`, `groq`, `huggingface-chat`, `huggingface-discovery`, `huggingface`, `manual`, `merge`, `offline`, `online`, `parser`) · `kv/` (`data`, `lock`) · `utils/` (`api`, `helpers`). Tests: `tests/` (catalog-policy, fal-models, huggingface).

Client counterpart: `../cortex/library.md` (`ModelRepository` consumes `/models.json`).
