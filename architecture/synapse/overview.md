# Synapse Overview

Synapse is the Cloudflare Worker ecosystem (sibling repository) that maintains and serves the model catalogue. Three workers coordinate through two KV namespaces:

| Worker | Trigger | Role | Document |
|---|---|---|---|
| syncer | cron `5 * * * *` (hourly) + HTTP | ingestion/normalization; serves `/models` and `/models.json` | `syncer.md` |
| curator | HTTP only (no cron) | protected editorial/admin API for curated model data | `curator.md` |
| supervisor | cron `*/10 * * * *` + HTTP | enrichment and maintenance | `supervisor.md` |

Shared bindings (all three workers):

- `MODELS_JSON` — the catalogue KV document (list, hash, version, backups, blacklist, manual models).
- `LOCKS` — distributed locks preventing concurrent writes.

Coordination model: locks prevent concurrent writes; versions and hashes detect races; backups preserve previous catalogue snapshots; cache invalidation (edge-cache purge of `/models.json`) makes updates visible to clients quickly.

## Complete server flow

1. Cortex -> Fulcrum gateway -> router -> provider stream -> SSE -> Cortex UI (generation).
2. In parallel, Synapse Syncer -> provider catalogues + Hugging Face + manual KV -> normalize/deduplicate/merge/policy -> `MODELS_JSON` KV -> edge cache -> Flutter `ModelRepository`/`ModelService` (catalogue).
3. Curator applies manual editorial changes and purges the edge cache; Supervisor enriches and maintains the catalogue every 10 minutes.

## Architectural boundary

Fulcrum executes user requests and protected business operations; Synapse publishes the model knowledge/control plane; Cortex consumes both through stable contracts (SSE events, `/models.json`, callable names).
