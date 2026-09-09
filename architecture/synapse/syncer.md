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

## Execution-mode classification

Synapse normalization schema v7 writes `executionModes` as a triplet with `source` and `confidence`:

- `supportsInteractive` — `true` / `false` / `null`
- `supportsBatch` — `true` / `false` / `null`
- Each field carries `source` (e.g. `"openrouter"` or `"heuristic"`) and `confidence` (`0..1`).

Batch-only classification lives in `processing/normalize/openrouter.js`. The heuristic detects `:batch` suffixes or explicit `batch_only` flags from the provider. The resulting record marks `supportsInteractive: false` with `confidence: 0.85` (heuristic) or `1` (explicit flag). Fulcrum does **not** duplicate this heuristic; it trusts the catalog field and filters via `queryModels(..., { supportsInteractive: true })`.

As of the latest backfill, all **721** catalog records include `executionModes`; **0** are currently batch-only.

## Files

`syncer.js` · `core/sync.js` · `core/serve.js` · `config.js` (+ `config/client-assets.js`) · `types.js` · `processing/` (`catalog-policy`, `cloudflare`, `dedup`, `deepgram`, `elevenlabs`, `fal-models`, `fal`, `groq`, `huggingface-chat`, `huggingface-discovery`, `huggingface`, `manual`, `merge`, `offline`, `online`, `parser`) · `kv/` (`data`, `lock`) · `utils/` (`api`, `helpers`). Tests: `tests/` (catalog-policy, fal-models, huggingface).

Client counterpart: `../cortex/library.md` (`ModelRepository` consumes `/models.json`).

## Curated family policy and offline presentation

`config/client-assets.js` explicitly names approved online series (`FAMILY_NAMES`); producer assets are logos, not authorization. `catalog-policy.js` validates OpenRouter (including free fallback), Groq, Fal, Cloudflare, Deepgram, ElevenLabs and approved manual online records, then canonicalizes family names. Unknown series are excluded. Checks run before deduplication, after merge, and when serving old KV documents; the serving policy header bypasses obsolete edge responses while retaining the normal cache purge key.

`offline.js` groups by base family, keeping version, size and quantization in variant labels. The recovered May 17 source documents the Next family contract; the current file-level IDs, shard exclusions, URL/size refresh and outage handling remain in place. HF discovery accepts known offline families. Next 1B/4B and different quants stay distinct variants under Next. Cortex splits online/offline variants before using family cards and filters size/RAM per variant rather than dropping a family based on its first entry.

Offline publication selects one download per full model name (generation and parameter size remain part of that name). Manual choices take precedence; otherwise Q4_K_M is preferred with deterministic fallbacks and ID tie-breaking. Quantization/recipe duplicates are removed after enrichment and when serving retained KV data. Selected download IDs, URLs and sizes remain unchanged; identity titles are repaired without replacing translated descriptions.
