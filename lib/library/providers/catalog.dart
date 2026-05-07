// lib/library/providers/catalog.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../darkener.dart';
import '../../../../internet.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../language.dart';
import '../../navigation.dart';
import '../../notifications/introvert.dart';
import '../../theme.dart';
import '../backend/data/entity.dart';
import '../backend/data/service.dart';
import '../backend/remove.dart';
import '../screen/model/controller.dart';
import '../screen/new/controller.dart';
import '../../chat/providers/session.dart';
import '../../chat/services/offline.dart';
import 'local.dart';

/// Manages the state of the model catalog for the entire library feature.
///
/// This provider is the single source of truth for the list of all available models.
/// It is architected to be independent of `BuildContext` for its core data loading
/// logic, instead listening reactively to its data source dependencies (`ModelService`
/// and `LocaleProvider`) to trigger reloads automatically.
class ModelCatalogProvider extends ChangeNotifier {
  //================================================================================
  // Dependencies (Injected via initialize)
  //================================================================================

  late ModelService _modelService;
  late LocaleProvider _localeProvider;
  bool _isInitialized = false;

  //================================================================================
  // Private State Properties
  //================================================================================

  bool _isLoading = true;
  bool _loadError = false;
  List<ModelEntity> _allModels = [];

  //================================================================================
  // Public Getters for UI Consumption
  //================================================================================

  bool get isLoading => _isLoading;

  bool get loadError => _loadError;

  List<ModelEntity> get allModels => List.unmodifiable(_allModels);

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================

  ModelCatalogProvider();

  /// Initializes the provider by reading its dependencies and starting the initial data load.
  /// This must be called once before the provider is used.
  void initialize({required BuildContext context}) {
    if (_isInitialized) return;

    // Read dependencies ONCE.
    _modelService = context.read<ModelService>();
    _localeProvider = context.read<LocaleProvider>();

    _isInitialized = true;

    debugPrint(
        "[ModelCatalogProvider] Initialized. Triggering initial data load.");

    // Trigger the initial data load manually.
    _loadCatalogData();
  }

  @override
  void dispose() {
    // No listeners to remove.
    super.dispose();
  }

  //================================================================================
  // Public Actions (Called from the UI)
  //================================================================================

  // --- PUBLIC ACTIONS ---

  /// Forces a full refresh of the model catalog.
  /// This should be called on language change or when the user manually requests a refresh.
  void refreshCatalog() {
    if (_isLoading) {
      debugPrint(
          "[ModelCatalogProvider.refreshCatalog] A load is already in progress. Ignoring.");
      return;
    }
    debugPrint("[ModelCatalogProvider.refreshCatalog] Full refresh requested.");
    _isLoading = true;
    _loadError = false;
    notifyListeners(); // Let the UI know we are starting a refresh.

    _modelService.clearAllCache();

    // Now, trigger the data loading process.
    _loadCatalogData();
  }

  /// Retries loading the model catalog in case of a previous error.
  void retryLoad() {
    _isLoading = true;
    _loadError = false;
    notifyListeners();
    _loadCatalogData();
  }

  Future<bool> removeModel(BuildContext context, ModelEntity model) async {
    final localizations = AppLocalizations.of(context)!;
    final notificationService = context.read<IntrovertNotificationService>();
    final localStateProvider = context.read<ModelLocalStateProvider>();

    // FIX: Ensure we unload the model from memory if it's currently loaded.
    // This releases the file handle, allowing the OS to reclaim storage immediately.
    try {
      final chatSession = context.read<ChatSessionProvider>();
      if (chatSession.modelId == model.id) {
        debugPrint(
            "[ModelCatalogProvider] Deleting currently active model ('${model.id}'). checking load state...");
        // Even if not "loaded" flag is true, we should try to release to be safe if it's the selected one.
        final offlineService = context.read<OfflineService>();
        await offlineService.releaseModel();
        debugPrint("[ModelCatalogProvider] Model released from memory.");
      }
    } catch (e) {
      debugPrint(
          "[ModelCatalogProvider] Warning: Could not release model from memory: $e");
    }

    if (!context.mounted) return false;

    final confirmed = await showRemoveConfirmationDialog(
        context, model.displayTitle, localizations);
    if (confirmed != true) return false;

    bool success = false;
    try {
      if (model.category == 'self') {
        if (!InternetService().currentStatus) {
          notificationService.showNotification(
              message: localizations.noInternetConnection,
              type: NotificationType.error);
          return false;
        }
        success = await ModelRemoveService.deleteCustomModel(
          id: model.id,
          title: model.displayTitle,
          notificationService: notificationService,
          localizations: localizations,
          modelService: _modelService,
        );
      } else {
        final String? uninstalledModelTitle =
            await localStateProvider.uninstallDownloadedModel(model.id);
        success = uninstalledModelTitle != null;

        if (success) {
          notificationService.showNotification(
            message: localizations.modelRemovedSuccess(uninstalledModelTitle),
            type: NotificationType.success,
          );
        } else {
          notificationService.showNotification(
            message: localizations.anErrorOccurred,
            type: NotificationType.error,
          );
        }
      }

      if (success) {
        debugPrint(
          "[ModelCatalogProvider] Model removed (${model.id}). Syncing catalog with ModelService cache.",
        );
        _onDataSourceChanged();
      }

      return success;
    } catch (e) {
      debugPrint("[ModelCatalogProvider] Error during model removal: $e");
      notificationService.showNotification(
        message: localizations.anErrorOccurred,
        type: NotificationType.error,
      );
      return false;
    }
  }

  /// Navigates to the model creation screen.
  Future<void> openCreateScreen(BuildContext context) async {
    await navigateToScreen(
      ModelCreationHost(availableBaseModels: _allModels),
      direction: const Offset(1.0, 0.0),
    );

    _onDataSourceChanged();
  }

  /// Navigates to the model detail page for a given model ID.
  Future<void> openModelDetail(BuildContext context, String id) async {
    if (_isLoading) return;

    final langCode = _localeProvider.locale.languageCode;
    final localStateProvider = context.read<ModelLocalStateProvider>();

    final modelEntity = _allModels.firstWhere(
      (m) => m.id == id,
      orElse: () => _modelService.getPreciseModelData(id, langCode: langCode),
    );

    final dynamic result = await navigateToScreen(
      ChangeNotifierProvider.value(
        value: localStateProvider,
        child: ModelDetailPage(id: modelEntity.id),
      ),
      direction: const Offset(1.0, 0.0),
    );

    if (result == null || !context.mounted) return;

    bool needsRefresh = false;

    if (result == 'model_updated') {
      needsRefresh = true;
    } else if (result is Map<String, dynamic>) {
      if (result['action'] == 'start_chat') {
        final String modelId = result['modelId'];
        await startChatWithModel(modelId);
      }
      if (result['model_updated'] == true) {
        needsRefresh = true;
      }
    }

    if (needsRefresh) {
      debugPrint(
          "[ModelCatalogProvider] Received 'model_updated' signal. Refreshing data.");
      // Trigger a refresh through the central listener system.
      _onDataSourceChanged();
    }
  }

  /// Initiates a chat session with the selected model.
  Future<void> startChatWithModel(String id) async {
    try {
      ModelEntity? model;

      // 1. Try direct match in top-level models.
      try {
        model = _allModels.firstWhere((m) => m.id == id);
      } catch (_) {
        // Not a top-level model — may be a variant ID from an offline series.
      }

      // 2. If not found, search inside variants of offline series.
      if (model == null) {
        for (final seriesModel in _allModels) {
          if (seriesModel.variants?.containsKey(id) == true) {
            // Use the parent series entity but override the ID to the variant.
            model = seriesModel.copyWith(id: id);
            break;
          }
        }
      }

      if (model == null) {
        debugPrint(
            "[ModelCatalogProvider.startChat] Error: Model with ID '$id' not found.");
        return;
      }

      mainScreenKey.currentState?.startChatWithModel(model);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_model_id', id);
    } catch (e) {
      debugPrint(
          "[ModelCatalogProvider.startChat] Error: Model with ID '$id' not found. $e");
    }
  }

  //================================================================================
  // Private Core Logic
  //================================================================================

  /// The central callback that is triggered when any of the underlying
  /// data sources (like `ModelService` or `LocaleProvider`) change.
  void _onDataSourceChanged() {
    if (_isLoading) {
      debugPrint(
          "[ModelCatalogProvider] A data source changed, but a reload is already in progress. Ignoring.");
      return;
    }

    // --- SIMPLE REFRESH from ModelService's cache ---
    // If ModelService updated its internal cache (e.g., after a baseModelId repair),
    // we don't need to trigger a full network reload. We can just sync our state.
    final modelsFromServiceCache = _modelService.getCachedModelsSync();

    // If the cached list from the service is not empty and is different from our current list,
    // we update our list. This avoids a full, expensive reload cycle.
    if (modelsFromServiceCache.isNotEmpty &&
        !listEquals(_allModels, modelsFromServiceCache)) {
      debugPrint(
          "[ModelCatalogProvider] Detected change in ModelService cache. Performing a lightweight refresh.");
      _allModels = modelsFromServiceCache;
      notifyListeners(); // This is safe now because it doesn't trigger a reload loop.
    } else {
      debugPrint(
          "[ModelCatalogProvider] Data source changed, but no new data in service cache. Likely a language change. Triggering full reload.");
      // This will now only be called for language changes or retries, breaking the loop.
      retryLoad();
    }
  }

  /// The core data fetching method. This is now the ONLY way data is loaded.
  Future<void> _loadCatalogData() async {
    final langCode = _localeProvider.locale.languageCode;

    // We fetch the models from the service.
    final modelsFromData = await _modelService.getModels(langCode: langCode);

    if (modelsFromData == null) {
      _loadError = true;
    } else {
      _allModels = modelsFromData;
      _loadError = false;
    }

    _isLoading = false;

    // Notify listeners that the loading process is complete (either with data or an error).
    notifyListeners();
  }

  /// Displays a modern, centralized dialog to confirm model deletion.
  Future<bool> showRemoveConfirmationDialog(BuildContext context, String title,
      AppLocalizations localizations) async {
    final restoreNavBar = Darkener.darken();
    // Get screen dimensions once for responsive sizing.
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'RemoveModelConfirmation',
      transitionDuration: const Duration(milliseconds: 150),
      pageBuilder: (ctx, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: screenWidth * 0.8,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenWidth * 0.05),
                      // Dynamic padding
                      child: Column(
                        children: [
                          Text(
                            localizations.removeModel,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              // Dynamic font size
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          // Dynamic spacing
                          Text(
                            localizations.confirmRemoveModel(title),
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.6),
                              fontSize:
                                  screenWidth * 0.035, // Dynamic font size
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    Divider(color: AppColors.border, thickness: 0.5, height: 1),
                    IntrinsicHeight(
                      child: Row(
                        children: [
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(ctx).pop(false),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  // Dynamic padding
                                  child: Text(localizations.cancel,
                                      style: TextStyle(
                                        color: AppColors.senaryColor,
                                        fontSize: screenWidth *
                                            0.04, // Dynamic font size
                                      )),
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: AppColors.border),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(ctx).pop(true),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  // Dynamic padding
                                  child: Text(localizations.remove,
                                      style: TextStyle(
                                        color: AppColors.septenaryColor,
                                        fontSize: screenWidth *
                                            0.04, // Dynamic font size
                                      )),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      restoreNavBar();
    });

    return result ?? false;
  }
}
