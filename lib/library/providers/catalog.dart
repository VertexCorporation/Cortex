// lib/library/providers/catalog.dart

import 'dart:async';
import 'package:cortex/app.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
import 'local.dart';

class ModelCatalogProvider extends ChangeNotifier {
  //================================================================================
  // Dependencies
  //================================================================================

  // DÜZELTME: 'late final' kaldırdık. Artık tekrar atanabilirler.
  ModelService? _modelService;
  LocaleProvider? _localeProvider;

  bool _isInitialized = false;
  String? _trackedUserId;

  //================================================================================
  // Private State Properties
  //================================================================================

  bool _isLoading = true;
  bool _loadError = false;
  List<ModelEntity> _allModels = [];

  //================================================================================
  // Public Getters
  //================================================================================

  bool get isLoading => _isLoading;
  bool get loadError => _loadError;
  List<ModelEntity> get allModels => List.unmodifiable(_allModels);

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================

  ModelCatalogProvider();

  void updateUser(User? user) {
    if (user == null) {
      if (_isInitialized || _allModels.isNotEmpty) {
        debugPrint("[ModelCatalogProvider] User logged out. Resetting initialization state.");
        _isInitialized = false;
        _allModels = [];
        _trackedUserId = null;
        _isLoading = true;
      }
    }
    else if (_trackedUserId != user.uid) {
      debugPrint("[ModelCatalogProvider] User changed (Old: $_trackedUserId, New: ${user.uid}). Resetting state.");
      _isInitialized = false;
      _trackedUserId = user.uid;
      _isLoading = true;
    }
  }

  void initialize({required BuildContext context}) {
    // DÜZELTME: Her çağrıldığında servisleri güncelliyoruz, hata vermiyor artık.
    _modelService = context.read<ModelService>();
    _localeProvider = context.read<LocaleProvider>();

    if (_isInitialized) return;

    _isInitialized = true;

    debugPrint("[ModelCatalogProvider] Initialized. Triggering initial data load.");
    _loadCatalogData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //================================================================================
  // Public Actions
  //================================================================================

  void refreshCatalog() {
    if (_isLoading) return;
    _isLoading = true;
    _loadError = false;
    notifyListeners();

    _modelService?.clearAllCache();
    _loadCatalogData();
  }

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

    final confirmed = await showRemoveConfirmationDialog(context, model.displayTitle, localizations);
    if (confirmed != true) return false;

    bool success = false;
    try {
      if (model.category == 'self') {
        if (!InternetService().currentStatus) {
          notificationService.showNotification(message: localizations.noInternetConnection, type: NotificationType.error);
          return false;
        }
        success = await ModelRemoveService.deleteCustomModel(
          id: model.id,
          title: model.displayTitle,
          notificationService: notificationService,
          localizations: localizations,
          modelService: _modelService!,
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
        debugPrint("[ModelCatalogProvider] Model removed. Syncing catalog.");
        _onDataSourceChanged();
      }

      return success;
    } catch (e) {
      debugPrint("[ModelCatalogProvider] Error during removal: $e");
      notificationService.showNotification(
        message: localizations.anErrorOccurred,
        type: NotificationType.error,
      );
      return false;
    }
  }

  Future<void> openCreateScreen(BuildContext context) async {
    await navigateToScreen(
      ModelCreationHost(availableBaseModels: _allModels),
      direction: const Offset(1.0, 0.0),
    );
    _onDataSourceChanged();
  }

  Future<void> openModelDetail(BuildContext context, String id) async {
    if (_isLoading) return;

    final langCode = _localeProvider!.locale.languageCode;
    final localStateProvider = context.read<ModelLocalStateProvider>();

    final modelEntity = _allModels.firstWhere(
          (m) => m.id == id,
      orElse: () => _modelService!.getPreciseModelData(id, langCode: langCode),
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
      _onDataSourceChanged();
    }
  }

  Future<void> startChatWithModel(String id) async {
    try {
      final model = _allModels.firstWhere((m) => m.id == id);
      mainScreenKey.currentState?.startChatWithModel(model);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_model_id', id);
    } catch (e) {
      debugPrint("[ModelCatalogProvider.startChat] Error: Model with ID '$id' not found. $e");
    }
  }

  //================================================================================
  // Private Core Logic
  //================================================================================

  void _onDataSourceChanged() {
    if (_isLoading || _modelService == null) return;

    final modelsFromServiceCache = _modelService!.getCachedModelsSync();

    if (modelsFromServiceCache.isNotEmpty && !listEquals(_allModels, modelsFromServiceCache)) {
      debugPrint("[ModelCatalogProvider] Detected change in cache. Lightweight refresh.");
      _allModels = modelsFromServiceCache;
      notifyListeners();
    } else {
      retryLoad();
    }
  }

  Future<void> _loadCatalogData() async {
    if (_modelService == null || _localeProvider == null) {
      debugPrint("[ModelCatalogProvider] Dependencies not ready.");
      return;
    }

    final langCode = _localeProvider!.locale.languageCode;
    final modelsFromData = await _modelService!.getModels(langCode: langCode);

    if (modelsFromData == null) {
      _loadError = true;
    } else {
      _allModels = modelsFromData;
      _loadError = false;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> showRemoveConfirmationDialog(
      BuildContext context, String title, AppLocalizations localizations) async {
    final restoreNavBar = Darkener.darken();
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
                      child: Column(
                        children: [
                          Text(
                            localizations.removeModel,
                            style: TextStyle(
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.02),
                          Text(
                            localizations.confirmRemoveModel(title),
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted.withValues(alpha:0.6),
                              fontSize: screenWidth * 0.035,
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
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                  child: Text(localizations.cancel,
                                      style: TextStyle(
                                        color: AppColors.senaryColor,
                                        fontSize: screenWidth * 0.04,
                                      )),
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(width: 1, thickness: 0.5, color: AppColors.border),
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => Navigator.of(ctx).pop(true),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02),
                                  child: Text(localizations.remove,
                                      style: TextStyle(
                                        color: AppColors.septenaryColor,
                                        fontSize: screenWidth * 0.04,
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