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
import '../../cache.dart';
import '../../notifications/introvert.dart';
import '../backend/data/entity.dart';
import '../backend/download/controller.dart';
import '../backend/download/download.dart';
import '../backend/remove.dart';
import '../backend/system.dart';
import '../backend/utils.dart';

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

  final newPathStates = await ModelsBackendUtils.collectFileStates(offlineModels, filesDirectoryPath);

  Map<String, bool> oldPathStates = {};
  if (filesDirectoryPath != oldFilesDirectoryPath) {
    oldPathStates = await ModelsBackendUtils.collectFileStates(offlineModels, oldFilesDirectoryPath);
  }

  final Map<String, bool> combinedStates = {};
  for (var model in offlineModels) {
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
class ModelLocalStateProvider extends ChangeNotifier with WidgetsBindingObserver {
  //================================================================================
  // Private State Properties
  //================================================================================

  SystemInfoData? _systemInfo;
  Map<String, bool> _downloadCompleted = {};
  String _filesDirectoryPath = '';
  String _oldFilesDirectoryPath = '';
  final Map<String, DownloadManager> _downloadManagers = {};
  final DownloadedModelsManager _downloadedModelsManager = DownloadedModelsManager();
  late final ModelDownloadController _dl;
  late final VoidCallback _downloadedModelsManagerListener;
  List<ModelEntity> _currentModels = [];
  bool isInitialized = false;
  bool _isRequestingPermission = false;

  //================================================================================
  // Public Getters for UI consumption
  //================================================================================

  SystemInfoData? get systemInfo => _systemInfo;
  Map<String, bool> get downloadCompleted => Map.unmodifiable(_downloadCompleted);
  Map<String, DownloadManager> get downloadManagers => Map.unmodifiable(_downloadManagers);

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

    debugPrint("[ModelLocalStateProvider] Received updated model list from catalog. Checking file states.");
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
      debugPrint("[ModelLocalStateProvider] App resumed from background. Forcing download state sync.");

      _dl.checkDownloadingStates(
        models: _currentModels,
        groundTruthDownloadStates: _downloadCompleted,
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
      debugPrint("[ModelLocalStateProvider] isModelOnDisk check failed: Path is null or empty.");
      return false;
    }
    final file = File(path);
    final exists = file.existsSync();
    debugPrint("[ModelLocalStateProvider] Checking isModelOnDisk for path: '$path'. Exists: $exists");
    return exists;
  }

  /// Handles the entire flow for starting a model download, including permission requests.
  /// Handles the entire flow for starting a model download, including permission requests.
  Future<bool> requestPermissionAndStartDownload({
    required BuildContext context,
    required String id,
    required String? url,
  }) async {
    if (_isRequestingPermission) {
      debugPrint("[ModelLocalStateProvider] Permission request already in progress. Ignoring tap.");
      return false;
    }

    final manager = _downloadManagers[id];
    final isAlreadyCompleted = _downloadCompleted[id] ?? false;
    final modelTitle = _getTitleById(id) ?? id;

    if (url == null || (manager != null && (manager.isDownloading || manager.isPaused || isAlreadyCompleted))) {
      return false;
    }

    _isRequestingPermission = true;

    try {
      final notificationService = Provider.of<IntrovertNotificationService>(context, listen: false);
      final localizations = AppLocalizations.of(context)!;

      final notificationStatus = await Permission.notification.request();

      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;

        if (androidInfo.version.sdkInt <= 32) {
          final storageStatus = await Permission.storage.request();
          if (!storageStatus.isGranted) {
            notificationService.showNotification(
                message: localizations.storagePermissionRequired, type: NotificationType.error);
            return false;
          }
        }

        final manufacturer = androidInfo.manufacturer.toLowerCase();
        final problematicVendors = ['xiaomi', 'redmi', 'poco', 'huawei', 'honor', 'oppo', 'vivo', 'meizu', 'oneplus'];

        if (problematicVendors.any((vendor) => manufacturer.contains(vendor))) {
          final batteryStatus = await Permission.ignoreBatteryOptimizations.status;

          if (!batteryStatus.isGranted) {
            debugPrint("[ModelLocalStateProvider] $manufacturer device found, requesting the battery optimization permission.");

            await Permission.ignoreBatteryOptimizations.request();
          }
        }
      }

      final canShowSystemNotifications = notificationStatus.isGranted;

      _dl.startDownload(
          id: id,
          url: url,
          title: modelTitle,
          showSystemNotification: canShowSystemNotifications);

      if (!canShowSystemNotifications) {
        notificationService.showNotification(
            message: localizations.downloadStarted, type: NotificationType.success, oneLine: true);
      }
      return true;

    } catch (e) {
      debugPrint("[ModelLocalStateProvider] Error during permission/download sequence: $e");
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
          filesDir: _oldFilesDirectoryPath,
          modelId: id,
          modelTitle: title
      );
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

    final modelsList = _currentModels.map((e) => e.toMap()).toList();

    final newDownloadStates = await ModelsBackendUtils.collectFileStates(modelsList, _filesDirectoryPath);

    Map<String, bool> oldDownloadStates = {};
    if (_filesDirectoryPath != _oldFilesDirectoryPath) {
      oldDownloadStates = await ModelsBackendUtils.collectFileStates(modelsList, _oldFilesDirectoryPath);
    }

    final Map<String, bool> combinedStates = {};
    for (var model in _currentModels) {
      combinedStates[model.id] = (newDownloadStates[model.id] ?? false) ||
          (oldDownloadStates[model.id] ?? false);
    }

    bool hasChanged = !mapEquals(_downloadCompleted, combinedStates);
    if (hasChanged) {
      _downloadCompleted = combinedStates;
    }

    for (final model in _currentModels) {
      final newState = combinedStates[model.id] ?? false;
      final oldState = _downloadManagers[model.id]?.isDownloaded ?? !newState;
      if (newState != oldState) {
        _downloadManagers[model.id]?.setDownloaded(newState);
        hasChanged = true;
      }
    }

    if (hasChanged) {
      CacheService.invalidate(CacheKey.filteredModels);
      debugPrint("[ModelLocalStateProvider] Download state changed. Invalidated filtered models cache.");
      notifyListeners();
    }
  }

  Future<void> _updateFileStatesInBackground(List<ModelEntity> models) async {
    if (_filesDirectoryPath.isEmpty) {
      debugPrint("[ModelLocalStateProvider] Files directory path not initialized. Aborting state update.");
      return;
    }

    final token = RootIsolateToken.instance!;
    final processedData = await compute(_processModelStatesInBackground, {
      'models': models.map((e) => e.toMap()).toList(),
      'filesDirectoryPath': _filesDirectoryPath,
      'oldFilesDirectoryPath': _oldFilesDirectoryPath,
      'token': token,
    });

    _downloadCompleted = processedData.downloadCompleted;

    _downloadManagers.removeWhere((id, _) => !models.any((m) => m.id == id));
    for (final model in models) {
      _downloadManagers
          .putIfAbsent(model.id, () => DownloadManager())
          .setDownloaded(_downloadCompleted[model.id] ?? false);
    }

    await _dl.checkDownloadingStates(
      models: models,
      groundTruthDownloadStates: _downloadCompleted,
    );

    notifyListeners();
  }

  void _onDownloadedModelsChanged() {
    debugPrint("[ModelLocalStateProvider] Downloaded models changed. Refreshing state.");
    _refreshStateAfterFileChange();
  }

  //================================================================================
  // Private Helpers
  //================================================================================

  String? _getTitleById(String id) {
    try {
      return _currentModels.firstWhere((m) => m.id == id).displayTitle;
    } catch (e) {
      return null;
    }
  }
}