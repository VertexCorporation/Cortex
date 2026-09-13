# Model Library Architecture

Chain: repository -> typed ModelEntity -> ModelService cache/business rules -> providers -> screens/download/offline runtime. The catalog JSON is published by Synapse (see `../synapse/syncer.md`) and consumed here; custom models are created and verified through Fulcrum `models.js` callables.

## Data layer (library/backend/data/)

- `ModelRepository` (repository.dart) — the only code that knows where model data comes from: `getAllModels`, server sync (`_syncWithServer`, `_fetchAndStorePublicModels`), stale-model pruning (`_cleanupStaleModels`, preserving models that are curated or downloaded; valid-ID lists are applied in chunks because old Android system SQLite caps bind variables at 999), per-language sync state, and image sync (`_syncModelImages`).
- `ModelEntity` (entity.dart) — the typed model record; `supportsOutput` includes variant capabilities for mixed-media family filtering. The client does **not** yet enforce `executionModes` policy locally; interactive eligibility filtering happens server-side in Fulcrum `queryModels(..., { supportsInteractive: true })`. Explicit `supportsInteractive: false` (batch-only) is rejected by the backend; `null` or missing values are accepted for backward compatibility during catalog backfill.
- `ModelDefaults` (defaults.dart) — client presentation-family normalization at hydration time: the repository persists one row per wire variant and `normalizeModelFamilies` rebuilds family containers on every read (DB load, per-language cache rebuild, legacy disk-cache reads). Uses the approved online-family list to exclude unknown/provider buckets, merges aliases, and groups offline variants by base family; preserves variant IDs, providers, sources and capabilities. Family containers have presentation IDs; chat uses the selected variant ID. Family assets override stale provider images.
- `ModelService` (service.dart) — ChangeNotifier business layer: `getModels(langCode)` with per-language caching (`_ensureCachedLanguage`, `clearAllCache`), base-model validation (`_validateAndAssignDefaultBaseModels`), cache mutations for custom-model changes (`addModelToEntityCache`, `removeModelFromEntityCache`, `updateCachedEntity`), and `updateBaseModel`.
- Support: `DatabaseHelper` (database.dart), `ModelDefaults` (defaults.dart), `ChatFormat`/`ChatTokens` (format.dart), `ModelImageCache` (image.dart), `CryptoHelper` (crypto.dart), `UserModels` (user.dart).

### Catalog persistence (schema v2)

`cortex_models_v2.db` stores one row per wire variant entry (plus one row per user-created model). v1 persisted whole family containers whose `raw_json` embedded every variant of the family; large families (Qwen, ChatGPT, Bria, MiniMax) exceeded Android's 2 MB CursorWindow, which crashed `getAllModels` — and with it every read and even the sync path that would have healed the data. The v2 upgrade drops legacy catalog rows (the catalog is server-derived and re-fetched on the next sync; user-created `self_`/`local_` models are preserved) and vacuums the file. Family containers are never persisted: `ModelDefaults.normalizeModelFamilies` rebuilds them at read time from the variant rows, so `getAllModels` streams many small rows and the service/UI contract is unchanged.

### Image path cache

`ModelImageCache` holds the newest model-cover path map in memory and persists it in SharedPreferences. Individual cover downloads are replaceable cache mutations, so path writes use a short write-behind window: a burst of additions serializes the newest map rather than rewriting the entire JSON map for every intermediate state. `savePaths` and destructive `remove` operations still flush durably. A pending newest snapshot remains readable even if the normal in-memory map is invalidated while persistence is in flight.

Frequently rebuilt image widgets should not issue a storage syscall on every build. `FileProbeCache` (`performance/file_probe_cache.dart`) provides a short-lived synchronous file existence/stat fast path with explicit invalidation hooks. This is a presentation optimization only; missing/expired probes fall back to the filesystem and image widgets retain their normal error fallbacks.

The repository's network image synchronization policy itself remains in `ModelRepository._syncModelImages`; this runtime change does not make image downloads unbounded or move I/O into widgets.

## Downloads and offline runtime

`ModelDownloadController` (download/controller.dart) and `DownloadManager`/`DownloadedModelsManager`/`DownloadedModel`/`FileDownloadHelper` (download/download.dart) manage GGUF downloads. `ModelRemoveService` (backend/remove.dart) removes models. `SystemInfoProvider`/`SystemInfoData` (system.dart) expose device capabilities. `ModelsBackendUtils`/`CompatibilityStatus` (utils.dart) hold compatibility rules; `ModelDataUtils` (library/utils.dart) formats model data.

## Providers (library/providers/)

`ModelCatalogProvider` (catalog.dart), `ModelDetailProvider` (details.dart), `ModelLocalStateProvider` (local.dart — download/local state) and `ModelCreationProvider` (new.dart — custom model creation).

## Screens (library/screen/)

- `LibraryScreen` (models/controller.dart) + catalog widgets (appbar, tiles, categories, search, system-info chart, animated borders, premium sheet).
- `ModelDetailPage`/`ModelDetailContent`/`ModelDetailView` (model/controller.dart) + detail widgets (header, sections, banner overlays, bottom action buttons, variant overlay).
- `ModelCreationHost` + `AddForm`/`CreateForm` (new/) with `GgufFilePicker`, `BaseModelSelector`, `CreationProfileHeader`, `CreationFormSection`, `CreationSaveButton` — the custom GGUF model flow.

Category carousel layout invariant: each `PageView` page in `ModelCategorySection` stacks three `ModelTile`s inside a fixed-height box from `ModelsBackendUtils.calculateCategoryHeight`. That budget is width-proportional *plus a fixed-pixel floor* (48 px action button, width-relative framed-image padding), because a purely proportional estimate underestimates the real tile below ~399 px logical width (Poco F7 ≈ 394 px) and the column overflowed. Tile text scaling is clamped to 1.3×, and the page column is wrapped in a clip-on-overflow safety net so exotic OEM fonts can never throw. `test/category_section_fit_test.dart` guards the floor, the clamp and the net (it fails with a 44 px overflow on the old layout).

The complete widget list is in `file-map.md`.

Variant selection fades out current detail values before committing the latest requested variant, then fades in (300 ms total). One scroll controller survives the transition; `ScrollFog` handles both edges and content-size changes.

The parser exposes `parseServerModels` for wire-contract regression tests, while persistence uses the finer-grained `parseServerModelRows`: one record per wire variant entry, series-level scalar metadata merged in, sibling variant maps excluded (duplicating them is what made legacy rows grow quadratically with the variant count). Mixed online/offline groups become distinct presentation containers, preserving actual variant routing/download IDs. Offline RAM/size summaries use retained variants; a large first entry cannot hide smaller runnable variants. Next uses a generic icon when no dedicated logo exists.
