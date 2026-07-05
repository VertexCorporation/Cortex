// lib/screens/models/providers/local.dart

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../l10n/app_localizations.dart';
import '../../app.dart';
import '../../cache.dart';
import '../../notifications/introvert.dart';
import '../backend/data/entity.dart';
import '../backend/download/controller.dart';
import '../backend/download/download.dart';
import '../backend/remove.dart';
import '../backend/system.dart';
import '../backend/utils.dart';
import '../../../../darkener.dart';
import '../../../../theme.dart';

/// Data class for results from the background isolate.
class _ProcessedStateData {
  final Map<String, bool> downloadCompleted;
  _ProcessedStateData({required this.downloadCompleted});
}

/// Top-level function to run in a separate isolate for checking file states.
Future<_ProcessedStateData> _processModelStatesInBackground(
    Map<String, dynamic> args) async {
  final token = args['token'] as RootIsolateToken;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final List<Map<String, dynamic>> modelMaps = args['models'];
  final String filesDirectoryPath = args['filesDirectoryPath'];
  final String oldFilesDirectoryPath = args['oldFilesDirectoryPath'];

  final offlineModels = modelMaps.where((m) => m['type'] == 'offline').toList();

  final nonOfflineModelStates = {
    for (var model in modelMaps.where((m) => m['type'] != 'offline'))
      model['id'] as String: false
  };

  // Collect variant maps from offline series models for individual tracking.
  final List<Map<String, dynamic>> variantMaps = [];
  for (var model in offlineModels) {
    final variants = model['variants'] as Map<String, dynamic>?;
    if (variants != null && variants.isNotEmpty) {
      for (final entry in variants.entries) {
        if (entry.value is Map<String, dynamic>) {
          variantMaps.add({
            'id': entry.key,
            'type': 'offline',
            ...entry.value as Map<String, dynamic>,
          });
        }
      }
    }
  }

  // Check states for both top-level offline models and their variants.
  final allOfflineToCheck = [...offlineModels, ...variantMaps];

  final newPathStates = await ModelsBackendUtils.collectFileStates(
      allOfflineToCheck, filesDirectoryPath);

  Map<String, bool> oldPathStates = {};
  if (filesDirectoryPath != oldFilesDirectoryPath) {
    oldPathStates = await ModelsBackendUtils.collectFileStates(
        allOfflineToCheck, oldFilesDirectoryPath);
  }

  final Map<String, bool> combinedStates = {};
  for (var model in allOfflineToCheck) {
    final id = model['id'] as String;
    final existsInNew = newPathStates[id] ?? false;
    final existsInOld = oldPathStates[id] ?? false;
    combinedStates[id] = existsInNew || existsInOld;
  }

  return _ProcessedStateData(
    downloadCompleted: {...nonOfflineModelStates, ...combinedStates},
  );
}

/// Manages the local state of models on the device, such as download status and system compatibility.
class ModelLocalStateProvider extends ChangeNotifier
    with WidgetsBindingObserver {
  //================================================================================
  // Private State Properties
  //================================================================================

  SystemInfoData? _systemInfo;
  final Map<String, bool> _downloadCompleted = {};
  String _filesDirectoryPath = '';
  String _oldFilesDirectoryPath = '';
  final Map<String, DownloadManager> _downloadManagers = {};
  final DownloadedModelsManager _downloadedModelsManager =
      DownloadedModelsManager();
  late final ModelDownloadController _dl;
  late final VoidCallback _downloadedModelsManagerListener;
  List<ModelEntity> _currentModels = [];
  bool isInitialized = false;
  bool _isRequestingPermission = false;

  //================================================================================
  // Public Getters for UI consumption
  //================================================================================

  SystemInfoData? get systemInfo => _systemInfo;
  Map<String, bool> get downloadCompleted =>
      Map.unmodifiable(_downloadCompleted);
  Map<String, DownloadManager> get downloadManagers =>
      Map.unmodifiable(_downloadManagers);
  bool get hasResolvedFilesDirectory => _filesDirectoryPath.isNotEmpty;

  //================================================================================
  // Initialization & Lifecycle
  //================================================================================
  ModelLocalStateProvider();

  /// Initializes the provider by reading dependencies and setting up internal controllers.
  /// The method signature now uses a named `context` parameter for consistency.
  void initialize({required BuildContext context}) {
    if (isInitialized) return;

    WidgetsBinding.instance.addObserver(this);

    isInitialized = true;
    debugPrint("[ModelLocalStateProvider] Initializing...");

    _dl = ModelDownloadController(
      context: context,
      managers: _downloadManagers,
      downloadCompleted: _downloadCompleted,
      getFilePathById: getFilePathById,
      onStateChange: notifyListeners,
    );

    _downloadedModelsManagerListener = _onDownloadedModelsChanged;
    _downloadedModelsManager.addListener(_downloadedModelsManagerListener);

    _initializeDependencies();
  }

  /// Called by a `ProxyProvider` to update the list of models this provider should manage.
  void update(List<ModelEntity> modelsFromCatalog) {
    if (listEquals(_currentModels, modelsFromCatalog)) return;

    debugPrint(
        "[ModelLocalStateProvider] Received updated model list from catalog. Checking file states.");
    _currentModels = modelsFromCatalog;

    if (_filesDirectoryPath.isEmpty) {
      _initializeDependencies().then((_) {
        _updateFileStatesInBackground(_currentModels);
      });
    } else {
      _updateFileStatesInBackground(_currentModels);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint(
          "[ModelLocalStateProvider] App resumed from background. Forcing download state sync.");

      _dl.checkDownloadingStates(
        models: _currentModels,
        groundTruthDownloadStates: _downloadCompleted,
        isFreshStart:
            false, // On resume, we want to KEEP failed tasks so user can retry
      );

      if (_filesDirectoryPath.isNotEmpty && _currentModels.isNotEmpty) {
        _updateFileStatesInBackground(_currentModels);
      }
    }
  }

  @override
  void dispose() {
    debugPrint("[ModelLocalStateProvider] Disposing...");
    WidgetsBinding.instance.removeObserver(this);
    _downloadedModelsManager.removeListener(_downloadedModelsManagerListener);
    super.dispose();
  }

  //================================================================================
  // Public Actions (Called by the UI)
  //================================================================================

  /// Checks if a model's file exists on disk using its path.
  bool isModelOnDisk(String? path) {
    if (path == null || path.isEmpty) {
      debugPrint(
          "[ModelLocalStateProvider] isModelOnDisk check failed: Path is null or empty.");
      return false;
    }
    final file = File(path);
    final exists = file.existsSync();
    debugPrint(
        "[ModelLocalStateProvider] Checking isModelOnDisk for path: '$path'. Exists: $exists");
    return exists;
  }

  /// Handles the entire flow for starting a model download, including permission requests.
  Future<bool> requestPermissionAndStartDownload({
    required BuildContext context,
    required String id,
    required String? url,
  }) async {
    if (_isRequestingPermission) {
      debugPrint(
          "[ModelLocalStateProvider] Permission request already in progress. Ignoring tap.");
      return false;
    }
    final notificationService =
        Provider.of<IntrovertNotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    final manager = _downloadManagers[id];
    final isAlreadyCompleted = _downloadCompleted[id] ?? false;
    final modelTitle = _getTitleById(id) ?? id;

    if (url == null ||
        (manager != null &&
            (manager.isDownloading ||
                manager.isPaused ||
                isAlreadyCompleted))) {
      return false;
    }

    _isRequestingPermission = true;

    try {
      if (Platform.isIOS) {
        final double sizeInGB;
        // For variant downloads, find the size from the variant data.
        final directModel = _currentModels.where((m) => m.id == id).toList();
        if (directModel.isNotEmpty) {
          sizeInGB = (directModel.first.size ?? 0) / 1024.0;
        } else {
          sizeInGB = (_findSizeById(id) ?? 0) / 1024.0;
        }

        final bool confirmed = await _showDownloadConfirmationDialog(
            context, modelTitle, sizeInGB);

        if (!confirmed) {
          _isRequestingPermission = false;
          return false;
        }
      }

      final notificationStatus = await Permission.notification.request();

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt <= 32) {
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            notificationService.showNotification(
                message: localizations.storagePermissionRequired,
                type: NotificationType.error);
            return false;
          }
        }

        final manufacturer = androidInfo.manufacturer.toLowerCase();
        final problematicVendors = [
          'xiaomi',
          'redmi',
          'poco',
          'huawei',
          'honor',
          'oppo',
          'vivo',
          'meizu',
          'oneplus'
        ];

        if (problematicVendors.any((vendor) => manufacturer.contains(vendor))) {
          final batteryStatus =
              await Permission.ignoreBatteryOptimizations.status;

          if (!batteryStatus.isGranted) {
            debugPrint(
                "[ModelLocalStateProvider] $manufacturer device found, requesting the battery optimization permission.");
            await Permission.ignoreBatteryOptimizations.request();
          }
        }
      }

      if (!context.mounted) {
        debugPrint(
            "[ModelLocalStateProvider] Context no longer mounted after permission request. Aborting download.");
        return false;
      }

      final canShowSystemNotifications = notificationStatus.isGranted;

      // Resolve size: for variant downloads, find size from variant data.
      final double? sizeVal = _findSizeById(id);

      _dl.startDownload(
          id: id,
          url: url,
          title: modelTitle,
          showSystemNotification: canShowSystemNotifications,
          sizeInMB: sizeVal);

      if (!canShowSystemNotifications) {
        notificationService.showNotification(
            message: localizations.downloadStarted,
            type: NotificationType.success,
            oneLine: true);
      }
      return true;
    } catch (e) {
      debugPrint(
          "[ModelLocalStateProvider] Error during permission/download sequence: $e");
      return false;
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// Initiates the uninstallation of a downloaded model.
  /// Returns the display title on success, null on failure.
  /// The caller is responsible for showing notifications.
  Future<String?> uninstallDownloadedModel(String id) async {
    final title = _getTitleById(id) ?? id;

    final bool success = await ModelRemoveService.uninstallDownloadedModel(
      id: id,
      title: title,
    );

    if (success) {
      await _refreshStateAfterFileChange();
      return title;
    }
    return null;
  }

  void cancelDownload(String id) => _dl.cancelDownload(id);

  void resumeDownload(String id) => _dl.resumeDownload(id);

  //================================================================================
  // Public Helpers
  //================================================================================

  CompatibilityStatus getCompatibilityStatus(int? modelSizeInMB) {
    return ModelsBackendUtils.getCompatibilityStatus(
        sys: _systemInfo, modelSizeInMB: modelSizeInMB);
  }

  String getFilePathById(String id) {
    final title = _getTitleById(id) ?? id;

    if (_oldFilesDirectoryPath.isNotEmpty) {
      final oldPath = ModelsBackendUtils.getFilePathById(
          filesDir: _oldFilesDirectoryPath, modelId: id, modelTitle: title);
      if (File(oldPath).existsSync()) {
        return oldPath;
      }
    }

    return ModelsBackendUtils.getFilePathById(
      filesDir: _filesDirectoryPath,
      modelId: id,
      modelTitle: title,
    );
  }

  //================================================================================
  // Private Logic & State Management
  //================================================================================

  Future<void> _initializeDependencies() async {
    if (_filesDirectoryPath.isEmpty) {
      if (Platform.isAndroid) {
        final dir = await getExternalStorageDirectory();
        final supportDir = await getApplicationSupportDirectory();

        _filesDirectoryPath = dir?.path ?? supportDir.path;

        _oldFilesDirectoryPath = supportDir.path;
      } else {
        _filesDirectoryPath = (await getApplicationSupportDirectory()).path;
        _oldFilesDirectoryPath = _filesDirectoryPath;
      }
    }

    if (_systemInfo == null) {
      _systemInfo = await SystemInfoProvider.fetchSystemInfo();
      notifyListeners();
    }
  }

  Future<void> _refreshStateAfterFileChange() async {
    if (_filesDirectoryPath.isEmpty) await _initializeDependencies();

    // Build the list: include both top-level models AND their variants.
    final List<Map<String, dynamic>> allToCheck = [];
    for (final model in _currentModels) {
      allToCheck.add(model.toMap());
      // For offline series, also check each variant's download state.
      if (!model.isServerSide && (model.variants?.isNotEmpty ?? false)) {
        for (final entry in model.variants!.entries) {
          if (entry.value is Map<String, dynamic>) {
            allToCheck.add({
              'id': entry.key,
              'type': 'offline',
              ...entry.value as Map<String, dynamic>,
            });
          }
        }
      }
    }

    final newDownloadStates = await ModelsBackendUtils.collectFileStates(
        allToCheck, _filesDirectoryPath);

    Map<String, bool> oldDownloadStates = {};
    if (_filesDirectoryPath != _oldFilesDirectoryPath) {
      oldDownloadStates = await ModelsBackendUtils.collectFileStates(
          allToCheck, _oldFilesDirectoryPath);
    }

    final Map<String, bool> combinedStates = {};
    for (var item in allToCheck) {
      final id = item['id'] as String;
      combinedStates[id] =
          (newDownloadStates[id] ?? false) || (oldDownloadStates[id] ?? false);
    }

    bool hasChanged = !mapEquals(_downloadCompleted, combinedStates);
    if (hasChanged) {
      // CRITICAL FIX: Do NOT replace the map reference. The
      // ModelDownloadController holds a direct reference to this same map
      // object. If we reassign _downloadCompleted to a new map, the
      // controller's reference becomes a stale orphan and any writes it
      // makes (e.g. downloadCompleted[id] = true) are silently lost.
      _downloadCompleted.clear();
      _downloadCompleted.addAll(combinedStates);
    }

    // Update download managers for all tracked IDs.
    for (var item in allToCheck) {
      final id = item['id'] as String;
      final newState = combinedStates[id] ?? false;
      final oldState = _downloadManagers[id]?.isDownloaded ?? !newState;
      if (newState != oldState) {
        _downloadManagers
            .putIfAbsent(id, () => DownloadManager())
            .setDownloaded(newState);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      CacheService.invalidate(CacheKey.filteredModels);
      debugPrint(
          "[ModelLocalStateProvider] Download state changed. Invalidated filtered models cache.");
      notifyListeners();
    }
  }

  Future<void> _updateFileStatesInBackground(List<ModelEntity> models) async {
    if (_filesDirectoryPath.isEmpty) {
      debugPrint(
          "[ModelLocalStateProvider] Files directory path not initialized. Aborting state update.");
      return;
    }

    final token = RootIsolateToken.instance!;
    final processedData = await compute(_processModelStatesInBackground, {
      'models': models.map((e) => e.toMap()).toList(),
      'filesDirectoryPath': _filesDirectoryPath,
      'oldFilesDirectoryPath': _oldFilesDirectoryPath,
      'token': token,
    });

    // CRITICAL FIX: Preserve the map reference for ModelDownloadController.
    // See _refreshStateAfterFileChange for the full explanation.
    _downloadCompleted.clear();
    _downloadCompleted.addAll(processedData.downloadCompleted);

    // Collect all IDs we need managers for: model IDs + their variant IDs.
    final Set<String> allManagedIds = {};
    for (final model in models) {
      allManagedIds.add(model.id);
      // For offline series, also create managers for each variant.
      if (!model.isServerSide && (model.variants?.isNotEmpty ?? false)) {
        for (final variantId in model.variants!.keys) {
          allManagedIds.add(variantId);
        }
      }
    }

    _downloadManagers.removeWhere((id, _) => !allManagedIds.contains(id));
    for (final id in allManagedIds) {
      _downloadManagers
          .putIfAbsent(id, () => DownloadManager())
          .setDownloaded(_downloadCompleted[id] ?? false);
    }

    await _dl.checkDownloadingStates(
      models: models,
      groundTruthDownloadStates: _downloadCompleted,
      isFreshStart:
          true, // We assume a full re-init implies a fresh perspective or app start
    );

    notifyListeners();
  }

  void _onDownloadedModelsChanged() {
    debugPrint(
        "[ModelLocalStateProvider] Downloaded models changed. Refreshing state.");
    _refreshStateAfterFileChange();
  }

  //================================================================================
  // Private Helpers & Dialogs
  //================================================================================

  String? _getTitleById(String id) {
    try {
      return _currentModels.firstWhere((m) => m.id == id).displayTitle;
    } catch (e) {
      // If not a top-level model, search inside variants of offline series.
      for (final model in _currentModels) {
        if (model.variants?.containsKey(id) == true) {
          final variantData = model.variants![id];
          if (variantData is Map<String, dynamic>) {
            return variantData['title'] as String? ?? id;
          }
        }
      }
      return null;
    }
  }

  /// Finds a model's size by its ID: first checks top-level models, then variants.
  double? _findSizeById(String id) {
    // 1. Direct match in top-level models
    try {
      final model = _currentModels.firstWhere((m) => m.id == id);
      return model.size?.toDouble();
    } catch (_) {
      // Not a top-level model
    }
    // 2. Search inside variants
    for (final model in _currentModels) {
      if (model.variants?.containsKey(id) == true) {
        final variantData = model.variants![id];
        if (variantData is Map<String, dynamic>) {
          final sizeVal = int.tryParse(variantData['size']?.toString() ?? '');
          return sizeVal?.toDouble();
        }
      }
    }
    return null;
  }

  /// Shows a confirmation dialog required by Apple for large downloads.
  /// Matches the app's visual style, handles MB/GB formatting, and uses updated colors.
  Future<bool> _showDownloadConfirmationDialog(
      BuildContext context, String modelTitle, double sizeInGB) async {
    final localizations = AppLocalizations.of(context)!;
    final restoreNavBar = Darkener.darken();

    // Get screen dimensions once for responsive sizing.
    final screenWidth = MediaQuery.sizeOf(context).width;
    final screenHeight = MediaQuery.sizeOf(context).height;

    // 1. Smart Size Formatting (MB vs GB)
    String sizeString;
    if (sizeInGB < 1.0) {
      // If less than 1 GB, show in MB (e.g. 0.3 GB -> 307 MB)
      final int sizeInMB = (sizeInGB * 1024).round();
      sizeString = "$sizeInMB MB";
    } else {
      // Otherwise keep GB (e.g. 2.4 GB)
      sizeString = "${sizeInGB.toStringAsFixed(1)} GB";
    }

    final result = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'DownloadConfirmation',
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
                      padding:
                          EdgeInsets.all(screenWidth * 0.05), // Dynamic padding
                      child: Column(
                        children: [
                          // 1. Title: Are you sure?
                          Text(
                            localizations.confirmDownloadTitle,
                            style: TextStyle(
                              fontSize:
                                  screenWidth * 0.045, // Dynamic font size
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor.inverted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(
                              height: screenHeight * 0.015), // Dynamic spacing

                          // REMOVED: Huge Model Title (as requested)

                          // 2. Size Disclosure (Apple Requirement)
                          Text(
                            localizations.downloadSizeDisclosure(sizeString),
                            style: TextStyle(
                              color: AppColors.primaryColor.inverted
                                  .withValues(alpha: 0.6),
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
                          // Cancel Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                // Ripple Effect: Senary color with low opacity
                                splashColor: AppColors.senaryColor
                                    .withValues(alpha: 0.1),
                                highlightColor: AppColors.senaryColor
                                    .withValues(alpha: 0.05),
                                onTap: () => Navigator.of(ctx).pop(false),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  child: Text(localizations.cancel,
                                      style: TextStyle(
                                        color: AppColors
                                            .senaryColor, // Senary Color
                                        fontSize: screenWidth * 0.04,
                                      )),
                                ),
                              ),
                            ),
                          ),
                          VerticalDivider(
                              width: 1,
                              thickness: 0.5,
                              color: AppColors.border),
                          // Download Button
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                // Ripple Effect: Senary color with low opacity
                                splashColor: AppColors.senaryColor
                                    .withValues(alpha: 0.1),
                                highlightColor: AppColors.senaryColor
                                    .withValues(alpha: 0.05),
                                onTap: () => Navigator.of(ctx).pop(true),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(
                                      vertical: screenHeight * 0.02),
                                  child: Text(localizations.download,
                                      style: TextStyle(
                                        color: AppColors
                                            .senaryColor, // Senary Color
                                        fontSize: screenWidth * 0.04,
                                        fontWeight: FontWeight.bold,
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
