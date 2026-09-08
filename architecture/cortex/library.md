# Model Library Architecture

Chain: repository -> typed ModelEntity -> ModelService cache/business rules -> providers -> screens/download/offline runtime. The catalog JSON is published by Synapse (see `../synapse/syncer.md`) and consumed here; custom models are created and verified through Fulcrum `models.js` callables.

## Data layer (library/backend/data/)

- `ModelRepository` (repository.dart) — the only code that knows where model data comes from: `getAllModels`, server sync (`_syncWithServer`, `_fetchAndStorePublicModels`), stale-model pruning (`_cleanupStaleModels`, preserving models that are curated or downloaded), per-language sync state, and image sync (`_syncModelImages`).
- `ModelEntity` (entity.dart) — the typed model record.
- `ModelService` (service.dart) — ChangeNotifier business layer: `getModels(langCode)` with per-language caching (`_ensureCachedLanguage`, `clearAllCache`), base-model validation (`_validateAndAssignDefaultBaseModels`), cache mutations for custom-model changes (`addModelToEntityCache`, `removeModelFromEntityCache`, `updateCachedEntity`), and `updateBaseModel`.
- Support: `DatabaseHelper` (database.dart), `ModelDefaults` (defaults.dart), `ChatFormat`/`ChatTokens` (format.dart), `ModelImageCache` (image.dart), `CryptoHelper` (crypto.dart), `UserModels` (user.dart).

## Downloads and offline runtime

`ModelDownloadController` (download/controller.dart) and `DownloadManager`/`DownloadedModelsManager`/`DownloadedModel`/`FileDownloadHelper` (download/download.dart) manage GGUF downloads. `ModelRemoveService` (backend/remove.dart) removes models. `SystemInfoProvider`/`SystemInfoData` (system.dart) expose device capabilities. `ModelsBackendUtils`/`CompatibilityStatus` (utils.dart) hold compatibility rules; `ModelDataUtils` (library/utils.dart) formats model data.

## Providers (library/providers/)

`ModelCatalogProvider` (catalog.dart), `ModelDetailProvider` (details.dart), `ModelLocalStateProvider` (local.dart — download/local state) and `ModelCreationProvider` (new.dart — custom model creation).

## Screens (library/screen/)

- `LibraryScreen` (models/controller.dart) + catalog widgets (appbar, tiles, categories, search, system-info chart, animated borders, premium sheet).
- `ModelDetailPage`/`ModelDetailView` (model/controller.dart) + detail widgets (header, sections, banner overlays, bottom action buttons, variant overlay).
- `ModelCreationHost` + `AddForm`/`CreateForm` (new/) with `GgufFilePicker`, `BaseModelSelector`, `CreationProfileHeader`, `CreationFormSection`, `CreationSaveButton` — the custom GGUF model flow.

The complete widget list is in `file-map.md`.
