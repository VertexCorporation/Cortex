// models.dart

import 'dart:async';
import 'dart:io';
import 'package:cortex/models/screen/skeleton.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../../cache.dart';
import '../../chat/chat.dart';
import '../../darkener.dart';
import '../../errorview.dart';
import '../../internet.dart';
import '../../notifications.dart';
import '../backend/install.dart';
import '../backend/remove.dart';
import '../backend/search.dart';
import '../backend/utils.dart';
import '../widgets/cards.dart';
import 'chart.dart';
import '../new/create.dart';
import 'model.dart';
import '../../theme.dart';
import '../backend/data.dart';
import '../backend/download.dart';
import '../../main.dart';
import '../backend/system_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cortex/l10n/app_localizations.dart';

/// A data class to hold the results from the background isolate.
class _ProcessedStateData {
  final Map<String, bool> downloadCompleted;
  final List<Map<String, dynamic>> allModels;

  _ProcessedStateData({
    required this.downloadCompleted,
    required this.allModels,
  });
}


/// TOP-LEVEL FUNCTION: This runs in a separate isolate to avoid freezing the UI.
/// It performs all the heavy file I/O and data processing.
Future<_ProcessedStateData> _processModelStatesInBackground(Map<String, dynamic> args) async {
  final token = args['token'] as RootIsolateToken;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);

  final List<Map<String, dynamic>> models = args['models'];
  final String filesDirectoryPath = args['filesDirectoryPath'];

  debugPrint("[Background Isolate] Starting SMART work for ${models.length} models.");

  final List<Map<String, dynamic>> offlineModels = [];
  final Map<String, bool> nonOfflineModelStates = {};

  for (final model in models) {
    if (model['type'] == 'offline') {
      offlineModels.add(model);
    } else {
      nonOfflineModelStates[model['id'] as String] = false;
    }
  }

  debugPrint("[Background Isolate] Heavy I/O needed for only ${offlineModels.length} offline models.");

  final offlineModelStates = await Utils.collectFileStates(offlineModels, filesDirectoryPath);

  final Map<String, bool> allDownloadStates = {
    ...nonOfflineModelStates,
    ...offlineModelStates,
  };

  debugPrint("[Background Isolate] Smart work complete. Returning processed data.");
  return _ProcessedStateData(
    downloadCompleted: allDownloadStates,
    allModels: models,
  );
}

class ModelsScreen extends StatefulWidget {
  const ModelsScreen({Key? key}) : super(key: key);

  @override
  _ModelsScreenState createState() => _ModelsScreenState();
}

class _ModelsScreenState extends State<ModelsScreen>
    with
        TickerProviderStateMixin,
        WidgetsBindingObserver,
        AutomaticKeepAliveClientMixin<ModelsScreen> {

  static bool _hasWarningBeenShownThisSession = false;
  bool _showLocalizationWarning = false;

  final DownloadedModelsManager _downloadedModelsManager = DownloadedModelsManager();
  final Map<String, DownloadManager> _downloadManagers = {};
  late Map<String, bool> _downloadCompleted;
  Map<String, List<GlobalKey>> columnKeysMap = {};
  Map<String, double> pageViewHeights = {};
  bool heightsMeasured = false;
  SystemInfoData? _systemInfo;
  List<Map<String, dynamic>> _allModels = [];
  late String _filesDirectoryPath;
  bool _isLoading = true;
  bool _loadError = false;
  ModelsSearchController? _searchCtrl;

  late final VoidCallback _modelDataListener;

  @override
  bool get wantKeepAlive => true;

  late final ModelDownloadController _dl;

  // --- THE FIX (Step 1): Define a listener variable. ---
  /// A listener that will be attached to the DownloadedModelsManager.
  late final VoidCallback _downloadedModelsManagerListener;

  /// Refreshes both system information and file download states in the correct order.
  /// This is the single source of truth for updating the UI after any file operation
  /// (download completion or uninstallation).
  Future<void> _refreshStateAfterFileChange() async {
    if (!mounted) return;

    // --- DYNAMIC & ROBUST FIX: Poll for storage update ---
    // Instead of a fixed delay, we will check the free storage until it updates
    // or we time out. This is much more reliable across different devices.

    // 1. Get the current free storage *before* the refresh logic.
    final initialSystemInfo = await SystemInfoProvider.fetchSystemInfo();
    final initialFreeStorage = initialSystemInfo.freeStorage;

    const int maxRetries = 15; // Try for a maximum of 1.5 seconds (15 * 100ms)
    int retryCount = 0;
    bool storageUpdated = false;

    debugPrint("[ModelsScreen] Refresh triggered. Initial free storage: $initialFreeStorage MB. Polling for OS update...");

    while (retryCount < maxRetries && !storageUpdated) {
      // Wait for a short interval to give the OS time to process the file deletion.
      await Future.delayed(const Duration(milliseconds: 100));

      final currentSystemInfo = await SystemInfoProvider.fetchSystemInfo();
      final currentFreeStorage = currentSystemInfo.freeStorage;

      // If the storage has increased, it means the OS has registered the file deletion.
      // We use `>` to be safe.
      if (currentFreeStorage > initialFreeStorage) {
        storageUpdated = true;
        if (mounted) {
          // Use the latest, confirmed info for the UI update.
          setState(() { _systemInfo = currentSystemInfo; });
        }
        debugPrint("[ModelsScreen] Storage updated after ${retryCount + 1} retries. New free storage: $currentFreeStorage MB.");
      } else {
        retryCount++;
      }
    }

    if (!storageUpdated) {
      debugPrint("[ModelsScreen] Warning: Storage did not update after timeout. Proceeding with potentially stale data.");
      // If it never updates (unlikely but possible), just load the latest info we have and proceed.
      if (mounted) {
        await _loadSystemInfo();
      }
    }

    // Now that storage info is as fresh as possible, continue with the rest of the refresh.
    if (!mounted) return;

    // Re-check which model files exist on disk.
    final newDownloadStates = await Utils.collectFileStates(_allModels, _filesDirectoryPath);

    // Trigger a single, unified UI update with all the fresh data.
    if (mounted) {
      setState(() {
        _downloadCompleted = newDownloadStates;
        // Also update the individual managers to ensure consistency.
        for (final model in _allModels) {
          final id = model['id'] as String;
          _downloadManagers[id]?.setDownloaded(newDownloadStates[id] ?? false);
        }
      });
    }

    debugPrint("[ModelsScreen] State refreshed successfully after file change.");
  }

  /// This listener handles non-destructive updates, like a model being
  /// downloaded or uninstalled. It now simply triggers the central refresh logic.
  void _onDownloadedModelsChanged() {
    if (!mounted) {
      print("[ModelsScreen.Listener] Aborting, not mounted.");
      return;
    }
    print("[ModelsScreen.Listener] Received download state change. Triggering central refresh.");
    // --- THE FIX: Defer to the centralized refresh function ---
    _refreshStateAfterFileChange();
  }

  /// --- THIS LISTENER'S ROLE IS NOW MORE SPECIFIC ---
  /// This listener is now ONLY for destructive changes (model created/deleted).
  /// It forces a full data reload because the list of models itself has changed.
  void _onModelsChanged() {
    if (!mounted) {
      debugPrint("[ModelsScreen.Listener] Received a model data notification, but screen is not mounted. Aborting.");
      return;
    }
    debugPrint("[ModelsScreen.Listener] Received a global notification from ModelData. Forcing a full UI reload.");

    // Invalidate the screen's cache because the underlying data source (ModelData) has changed.
    CacheService.invalidateModelsScreenCache();
    // This triggers a full reload, which will fetch the fresh list from ModelData's cache.
    _loadDataAndInitialize();
  }

  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    debugPrint("[ModelsScreen.initState] Initializing state...");

    WidgetsBinding.instance.addObserver(this);
    _downloadCompleted = {};

    // This listener handles DESTRUCTIVE changes (model created/deleted).
    _modelDataListener = _onModelsChanged;
    ModelData.addListener(_modelDataListener);

    // This listener handles NON-DESTRUCTIVE state changes (model downloaded/uninstalled).
    _downloadedModelsManagerListener = _onDownloadedModelsChanged;
    _downloadedModelsManager.addListener(_downloadedModelsManagerListener);

    _dl = ModelDownloadController(
      context: context,
      managers: _downloadManagers,
      downloadCompleted: _downloadCompleted,
      getFilePathById: _getFilePathById,
    );

    // ... (rest of initState is unchanged and correct) ...
    _searchCtrl = ModelsSearchController(
      context: context,
      allModels: [],
      downloadManagers: _downloadManagers,
      getCompatibilityStatus: _compatCheckWrapper,
      openModelDetail: ({
        required id,
        required description,
        required imagePath,
        required int? size,
        required int? ram,
        required producer,
        required isServerSide,
        required isDownloaded,
        required isDownloading,
        required compatibilityStatus,
        required url,
        required bool isCustomModel,
        required String? modelPath,
        required bool isFullyLocalized,
      }) =>
          _openModelDetail(
            id,
            description,
            imagePath,
            size,
            ram,
            producer,
            isServerSide,
            isDownloaded,
            isDownloading,
            compatibilityStatus,
            url,
            isFullyLocalized,
            isCustomModel: isCustomModel,
            modelPath: modelPath,
          ),
      removeModel: (id) async {
        final title = _getTitleById(id);
        await _handleRemoveFromList(id, title);
      },
      startChat: (id, isServerSide, {isCustomModel = false, modelPath}) =>
          _startChatWithModel(id, isServerSide,
              isCustomModel: isCustomModel, modelPath: modelPath),
      startDownload: ({required id, required url, required title}) =>
          _requestPermissionAndStartDownload(id: id, url: url, title: title),
      cancelDownload: (id) => _dl.cancelDownload(id),
      resumeDownload: (id) => _dl.resumeDownload(id),
      downloadedFileStates: _downloadCompleted,
    );

    if (!_hasWarningBeenShownThisSession) {
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) {
          setState(() => _showLocalizationWarning = true);
          _hasWarningBeenShownThisSession = true;
          debugPrint("Localization warning shown for the first time this session.");
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final newLocale = Localizations.localeOf(context);

    // This logic now correctly handles both the initial build and any subsequent
    // rebuilds caused by a language change.
    // If the locale is new, we always reload. The cache invalidation in settings.dart
    // guarantees that this reload will fetch fresh data.
    if (_currentLocale != newLocale) {
      debugPrint("[ModelsScreen] Locale change detected (or initial load). New locale: '${newLocale.languageCode}'. Forcing data reload.");
      _currentLocale = newLocale;

      // We still set isLoading to true to show the skeleton screen during the reload,
      // which is visually much smoother.
      setState(() {
        _isLoading = true;
      });

      // This will now always work as intended.
      _loadDataAndInitialize();
    }
  }

  @override
  void dispose() {
    // Unsubscribe from both listeners to prevent memory leaks.
    ModelData.removeListener(_modelDataListener);
    _downloadedModelsManager.removeListener(_downloadedModelsManagerListener);

    WidgetsBinding.instance.removeObserver(this);
    _searchCtrl?.dispose();
    super.dispose();
  }

  void _dismissWarningPanel() {
    if (mounted && _showLocalizationWarning) {
      setState(() {
        _showLocalizationWarning = false;
      });
      debugPrint("Localization warning dismissed by user action.");
    }
  }

  String _getTitleById(String id) {
    try {
      final model = _allModels.firstWhere((m) => m['id'] == id);
      return ModelData.getLocalizedText(model, 'title', Localizations.localeOf(context).languageCode);
    } catch (e) {
      return id;
    }
  }

  String _getFilePathById(String id) {
    return Utils.getFilePathById(
      filesDir: _filesDirectoryPath,
      modelId: id,
      modelTitle: _getTitleById(id),
    );
  }

  Future<void> _precacheModelImages() async {
    if (!mounted || _allModels.isEmpty) return;
    for (final model in _allModels) {
      try {
        final imagePath = ModelData.getModelImagePath(model);
        if (!mounted) return;
        final ImageProvider imageProvider;
        if (imagePath.startsWith('assets/')) {
          imageProvider = AssetImage(imagePath);
        } else {
          final file = File(imagePath);
          if (file.existsSync()) {
            imageProvider = FileImage(file);
          } else {
            imageProvider = const AssetImage('assets/icons/self.svg');
          }
        }
        await precacheImage(imageProvider, context, onError: (e, stack) {
          debugPrint('Failed to precache image for ${model['id']}: $imagePath. Error: $e');
        });
      } catch (e) {
        debugPrint('General error precaching for ${model['id']}: $e');
      }
    }
  }

  CompatibilityStatus _compatCheckWrapper(int? modelSizeInMB) {
    return Utils.getCompatibilityStatus(sys: _systemInfo, modelSizeInMB: modelSizeInMB);
  }

  double _calculateCategoryHeight(List<Map<String, dynamic>> m, double w) => Utils.calculateCategoryHeight(m, w);

  Future<bool> _requestPermissionAndStartDownload({
    required String id,
    required String? url,
    required String title,
  }) async {
    final manager = _downloadManagers[id];
    final isAlreadyCompleted = _downloadCompleted[id] ?? false;
    if (manager != null && (manager.isDownloading || manager.isPaused || isAlreadyCompleted)) {
      debugPrint("[ModelsScreen.requestDownload] Download for '$id' blocked by pre-flight check.");
      return false;
    }
    if (url == null) {
      debugPrint("Download failed for model '$id': URL is null.");
      return false;
    }
    if (!mounted) return false;

    final notificationStatus = await Permission.notification.request();
    if (!mounted) return false;

    if (Platform.isAndroid) {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      if (deviceInfo.version.sdkInt <= 32) {
        debugPrint("[ModelsScreen.requestDownload] Old Android version detected (SDK ${deviceInfo.version.sdkInt}). Requesting storage permission.");
        final storageStatus = await Permission.storage.request();
        if (!storageStatus.isGranted) {
          debugPrint("[ModelsScreen.requestDownload] Storage permission denied. Aborting download.");
          if(mounted) {
            Provider.of<NotificationService>(context, listen: false).showNotification(
                message: AppLocalizations.of(context)!.storagePermissionRequired,
                isSuccess: false
            );
          }
          return false;
        }
      }
    }

    final bool canShowSystemNotifications = notificationStatus.isGranted;
    _dl.startDownload(
      id: id,
      url: url,
      title: title,
      showSystemNotification: canShowSystemNotifications,
    );

    if (!canShowSystemNotifications) {
      final notificationService = Provider.of<NotificationService>(context, listen: false);
      notificationService.showNotification(
        message: AppLocalizations.of(context)!.downloadStarted,
        isSuccess: true,
        oneLine: true,
      );
    }
    return true;
  }

  Future<void> _updateStateWithNewModels(List<Map<String, dynamic>> models) async {
    debugPrint("[ModelsScreen] Starting UI update process for ${models.length} models.");

    // <-- DÜZELTME (Adım 2): Arka plan isolate'i için iletişim jetonunu al.
    final token = RootIsolateToken.instance!;

    // The data is now available.
    // Instead of processing it here and freezing the app,
    // we send it to the background isolate using `compute`.
    final processedData = await compute(_processModelStatesInBackground, {
      'models': models,
      'filesDirectoryPath': _filesDirectoryPath,
      'token': token, // <-- DÜZELTME: Jetonu argüman olarak ekle.
    });

    // By the time we get here, the UI has remained responsive.
    // Now we can safely update the state with the pre-processed data.

    if (!mounted) return; // Always check if the widget is still in the tree.

    _downloadCompleted = processedData.downloadCompleted;
    _searchCtrl?.updateModels(processedData.allModels);
    if (_searchCtrl != null) {
      _searchCtrl!.downloadedFileStates = _downloadCompleted;
    }

    final newModelIds = processedData.allModels.map((m) => m['id'] as String).toSet();
    _downloadManagers.removeWhere((id, manager) => !newModelIds.contains(id));

    for (final m in processedData.allModels) {
      final id = m['id'] as String;
      final manager = _downloadManagers.putIfAbsent(id, () => DownloadManager());
      manager.setDownloaded(_downloadCompleted[id] ?? false);
    }

    // This setState is now very fast because all the heavy work is already done.
    setState(() {
      _allModels = processedData.allModels;
      _isLoading = false;
      _loadError = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _precacheModelImages();
        _dl.checkDownloadingStates(_allModels);
      }
    });
  }

  Future<void> _loadDataAndInitialize() async {
    // Step 1: Initialize prerequisites. This is always needed.
    await Future.wait([
      _initializeDirectory(),
      _loadSystemInfo(),
    ]);

    if (!mounted) return;

    // Step 2: Check the screen-level cache.
    final cachedModels = CacheService.cachedModelsScreenData;

    if (cachedModels != null) {
      // --- CACHE HIT PATH (The new, fast path) ---
      debugPrint("[ModelsScreen] Cache HIT. Performing fast initial render.");
      CacheService.touchModelsScreenCache();

      // IMPORTANT: Immediately update the UI with the cached data.
      // This makes the screen appear instantly without a loading skeleton.
      setState(() {
        _allModels = cachedModels;
        _isLoading = false; // Ensure we are not in a loading state
        _loadError = false;
        _searchCtrl?.updateModels(cachedModels);
      });

      // Now, run the heavy file check in the background WITHOUT blocking the UI.
      // We don't `await` this call. It runs silently.
      _updateFileStatesInBackground(cachedModels);

      // The function ends here for the cache hit scenario.
      return;
    }

    // --- CACHE MISS PATH (The original, slower path for first load) ---
    debugPrint("[ModelsScreen] Cache MISS. Fetching data from source with loading screen.");

    // This is the only place where we now explicitly set isLoading to true.
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }

    final langCode = Localizations.localeOf(context).languageCode;
    final modelsFromData = await ModelData.getModels(langCode: langCode);

    if (!mounted) return;

    if (modelsFromData == null) {
      if (mounted) setState(() { _isLoading = false; _loadError = true; });
    } else {
      // Cache the new data
      CacheService.cachedModelsScreenData = modelsFromData;
      CacheService.startModelsScreenCacheTimer();

      // Use the full update path which includes background processing
      await _updateStateWithNewModels(modelsFromData);
    }
  }

  /// This is called only on a cache hit to refresh download statuses without a loading screen.
  Future<void> _updateFileStatesInBackground(List<Map<String, dynamic>> models) async {
    debugPrint("[ModelsScreen] Starting silent background refresh of file states.");

    // <-- DÜZELTME (Adım 3): Arka plan isolate'i için iletişim jetonunu al.
    final token = RootIsolateToken.instance!;

    final processedData = await compute(_processModelStatesInBackground, {
      'models': models,
      'filesDirectoryPath': _filesDirectoryPath,
      'token': token, // <-- DÜZELTME: Jetonu argüman olarak ekle.
    });

    if (!mounted) return;

    // Now, apply the fresh download states to the already-rendered UI.
    // This `setState` is very cheap and won't cause a noticeable flicker.
    setState(() {
      _downloadCompleted = processedData.downloadCompleted;
      if (_searchCtrl != null) {
        _searchCtrl!.downloadedFileStates = _downloadCompleted;
      }
      for (final m in processedData.allModels) {
        final id = m['id'] as String;
        _downloadManagers[id]?.setDownloaded(_downloadCompleted[id] ?? false);
      }
    });

    // Also perform post-frame checks, just like in the full update path.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _precacheModelImages();
        _dl.checkDownloadingStates(_allModels);
      }
    });

    debugPrint("[ModelsScreen] Silent background refresh complete.");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _dl.checkDownloadingStates(_allModels);
    }
  }

  Future<void> _initializeDirectory() async {
    Directory appSupportDir = await getApplicationSupportDirectory();
    _filesDirectoryPath = appSupportDir.path;
    debugPrint("Model files will be saved in/loaded from: $_filesDirectoryPath");
  }

  Future<void> _loadSystemInfo() async {
    try {
      final systemInfo = await SystemInfoProvider.fetchSystemInfo();
      if (mounted) {
        setState(() {
          _systemInfo = systemInfo;
        });
      }
    } catch (e) {
      debugPrint('Error fetching system information: $e');
    }
  }

  Future<void> _startChatWithModel(String id, bool isServerSide, {bool isCustomModel = false, String? modelPath}) async {
    final prefs = await SharedPreferences.getInstance();
    final modelData = _allModels.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (modelData.isEmpty) {
      debugPrint("Error: Could not start chat. Model with ID '$id' not found.");
      return;
    }

    mainScreenKey.currentState?.onItemTapped(0);
    mainScreenKey.currentState?.updateBottomAppBarVisibility(true);
    debugPrint("[ModelsScreen] Callback sent to MainScreen to hide BottomAppBar.");

    ChatScreenState? chatState;
    while (chatState == null) {
      await Future.delayed(const Duration(milliseconds: 16));
      chatState = mainScreenKey.currentState?.chatScreenKey.currentState;
    }

    await chatState.resetConversation(resetModel: true);
    final modelInfo = ModelInfo(
        id: id,
        title: _getTitleById(id),
        imagePath: ModelData.getModelImagePath(modelData),
        producer: modelData['producer'] ?? 'Unknown',
        path: modelData['type'] == 'offline' ? _getFilePathById(id) : null,
        category: modelData['category'] as String?,
        modalities: modelData['modalities'] as Map<String, dynamic>? ?? const {},
        role: modelData['role'] as String?
    );

    await chatState.selectionService.selectModel(modelInfo, resetMessages: true);

    await prefs.setString('selected_model_id', id);
    if (modelData['type'] == 'offline') {
      await prefs.setString('selected_model_path', modelInfo.path ?? '');
    } else {
      await prefs.remove('selected_model_path');
    }
  }

  Future<void> _openCreateScreen(BuildContext context) async {
    // --- THE FIX: The result of the push is no longer needed. ---
    // The new listener architecture handles the UI refresh automatically.
    await Navigator.push(
      context,
      SlideRightRoute(page: CreateScreen(availableBaseModels: _allModels)),
    );

    // The 'if (created == true)' block has been removed.
  }


  // Handles the complete user flow for removing/uninstalling a model.
  Future<void> _handleRemoveFromList(String id, String title) async {
    // 1. Get necessary dependencies from the context before any async gaps.
    final localizations = AppLocalizations.of(context)!;
    final internetService = Provider.of<InternetService>(context, listen: false);

    // 2. Determine if the model is a custom creation or a public, downloadable one.
    final bool isCustomModel = id.startsWith('self_') || id.startsWith('local_');

    // 3. Prepare localized text for the confirmation dialog.
    final String dialogTitle = localizations.removeModel;
    final String dialogMessage = localizations.confirmRemoveModel(title);
    final String confirmButtonText = localizations.remove;

    // 4. Perform a pre-flight check: custom models require an internet connection to be deleted.
    if (isCustomModel && !internetService.currentStatus) {
      Provider.of<NotificationService>(context, listen: false).showNotification(message: localizations.noInternetConnection, isSuccess: false);
      return; // Abort if offline.
    }

    // 5. Show a confirmation dialog to the user. (This part is unchanged and correct)
    final restoreNavBar = Darkener.darken();
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierLabel: 'RemoveModel',
      barrierDismissible: true,
      pageBuilder: (dialogCtx, _, __) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 340),
              child: Container(
                decoration: BoxDecoration(color: AppColors.secondaryColor, borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 16), child: Column(children: [
                      Text(dialogTitle, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted), textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      Text(dialogMessage, style: TextStyle(color: AppColors.primaryColor.inverted.withOpacity(0.8)), textAlign: TextAlign.center),
                    ])),
                    Divider(color: AppColors.border, thickness: 0.5, height: 0.5),
                    IntrinsicHeight(child: Row(children: [
                      Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.of(dialogCtx).pop(false), child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 16), child: Text(localizations.cancel, style: TextStyle(color: AppColors.senaryColor, fontSize: 16)))))),
                      VerticalDivider(color: AppColors.border, thickness: 0.5),
                      Expanded(child: Material(color: Colors.transparent, child: InkWell(onTap: () => Navigator.of(dialogCtx).pop(true), child: Container(alignment: Alignment.center, padding: const EdgeInsets.symmetric(vertical: 16), child: Text(confirmButtonText, style: TextStyle(color: AppColors.septenaryColor, fontSize: 16)))))),
                    ])),
                  ]),
                ),
              ),
            ),
          ),
        );
      },
    );
    restoreNavBar();

    // If the user cancelled the dialog, abort the process.
    if (confirmed != true) return;

    // 6. Execute the appropriate removal logic based on the model type.
    bool success;
    if (isCustomModel) {
      // PERMANENT DELETION: The listener `_onModelsChanged` will handle the full refresh.
      success = await ModelRemoveService.deleteCustomModel(id: id, title: title, context: context);
    } else {
      // --- THIS IS THE KEY CHANGE ---
      // UNINSTALLATION: A non-destructive change.
      // We simply call the service to perform the uninstallation.
      // We NO LONGER call `_refreshStateAfterFileChange` from here.
      // The `ModelRemoveService` will notify the `DownloadedModelsManager`,
      // which in turn triggers our `_onDownloadedModelsChanged` listener.
      // That listener is now the SINGLE, RELIABLE trigger for the UI refresh.
      // This eliminates the race condition entirely.
      success = await ModelRemoveService.uninstallDownloadedModel(id: id, title: title, context: context);
    }

    // 7. Handle any failures during the removal process.
    if (!success && mounted) {
      print("[ModelsScreen.handleRemove] Removal failed. Forcing a full data reload as a safety measure.");
      CacheService.invalidateModelsScreenCache();
      setState(() => _isLoading = true);
      await _refreshStateAfterFileChange();
      await _loadDataAndInitialize();
    }
  }

  List<Widget> _buildModelColumns(List<Map<String, dynamic>> models, String section, double screenWidth) {
    List<Widget> columns = [];
    const int modelsPerColumn = 3;
    int totalModels = models.length;
    int totalColumns = (totalModels / modelsPerColumn).ceil();
    double cardWidth = screenWidth - 2 * (screenWidth * 0.04);
    List<GlobalKey> columnKeys = [];

    final langCode = Localizations.localeOf(context).languageCode;

    for (int i = 0; i < totalColumns; i++) {
      int startIndex = i * modelsPerColumn;
      int endIndex = (startIndex + modelsPerColumn > totalModels) ? totalModels : startIndex + modelsPerColumn;
      List<Map<String, dynamic>> columnModels = models.sublist(startIndex, endIndex);
      GlobalKey key = GlobalKey();
      columnKeys.add(key);

      columns.add(
        Container(
          key: key,
          width: cardWidth,
          child: Column(
            children: columnModels.map((model) {
              final String id = model['id'] as String;
              final String producer = model['producer'] as String;
              final String imagePath = ModelData.getModelImagePath(model);
              final bool isServerSide = model['type'] != 'offline';
              final String? modelPath = model['path'] as String?;
              final String? url = model['url'] as String?;
              final int? size = model['size'] as int?;
              final int? ram = model['ram'] as int?;
              final bool isFullyLocalized = model['isFullyLocalized'] as bool? ?? false;
              final manager = _downloadManagers.putIfAbsent(id, () => DownloadManager());
              final bool isCustomModel = id.startsWith('self_') || id.startsWith('local_');

              final String title = ModelData.getLocalizedText(model, 'title', langCode);
              final String summary = ModelData.getLocalizedText(model, 'summary', langCode);
              final String fullDescription = ModelData.getLocalizedText(model, 'description', langCode);

              final bool isDownloaded = _downloadCompleted[id] ?? false;

              final CompatibilityStatus compatibilityStatus;
              if (isDownloaded) {
                compatibilityStatus = CompatibilityStatus.compatible;
              } else {
                compatibilityStatus = _compatCheckWrapper(size);
              }

              return ModelTile(
                  id: id,
                  title: title,
                  description: summary,
                  imagePath: imagePath,
                  producer: producer,
                  url: url,
                  size: size?.toString(),
                  requirements: ram?.toString(),
                  modelPath: modelPath,
                  isServerSide: isServerSide,
                  isCustomModel: isCustomModel,
                  isLastInColumn: model == columnModels.last,
                  isSeeAll: false,
                  manager: manager,
                  isDownloaded: isDownloaded,
                  compatibilityStatus: compatibilityStatus,
                  onTileTap: () {
                    _openModelDetail(
                        id,
                        fullDescription,
                        imagePath,
                        size,
                        ram,
                        producer,
                        isServerSide,
                        isDownloaded,
                        manager.isDownloading,
                        compatibilityStatus,
                        url,
                        isFullyLocalized,
                        isCustomModel: isCustomModel,
                        modelPath: modelPath);
                  },
                  onRemoveRequested: () async {
                    HapticFeedback.mediumImpact();
                    await _handleRemoveFromList(id, title);
                  },
                  onChatPressed: () => _startChatWithModel(id, isServerSide, isCustomModel: isCustomModel, modelPath: modelPath),
                  onDownloadPressed: () => _requestPermissionAndStartDownload(id: id, url: url, title: title),
                  onCancelDownload: () => _dl.cancelDownload(id),
                  onResumeDownload: () => _dl.resumeDownload(id)
              );
            }).toList(),
          ),
        ),
      );
    }
    columnKeysMap[section] = columnKeys;
    return columns;
  }

// Handles navigation to the Model Detail page and processes the result.
  Future<void> _openModelDetail(
      String id,
      String description,
      String imagePath,
      int? size,
      int? ram,
      String producer,
      bool isServerSide,
      bool isDownloaded,
      bool isDownloading,
      CompatibilityStatus compatibilityStatus,
      String? url,
      bool isFullyLocalized,
      {bool isCustomModel = false, String? modelPath}) async {
    // Prevent navigation while the main screen is in a loading state.
    if (_isLoading) {
      debugPrint("[ModelsScreen] Navigation to detail page blocked because the screen is still loading.");
      return;
    }

    // Fetch the most precise model data and the current language code before navigating.
    final modelData = ModelData.getPreciseModelData(id);
    if (!mounted) return;
    final langCode = Localizations.localeOf(context).languageCode;

    // Navigate to the detail page and wait for a result.
    final dynamic result = await Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => ModelDetailPage(
            id: id,
            title: ModelData.getLocalizedText(modelData, 'title', langCode),
            description: ModelData.getLocalizedText(modelData, 'description', langCode),
            summary: ModelData.getLocalizedText(modelData, 'summary', langCode),
            imagePath: ModelData.getModelImagePath(modelData),
            size: size,
            ram: ram,
            producer: producer,
            isDownloaded: isDownloaded,
            isDownloading: isDownloading,
            compatibilityStatus: compatibilityStatus,
            isServerSide: isServerSide,
            isFullyLocalized: isFullyLocalized,
            onDownloadPressed: url != null ? () => _requestPermissionAndStartDownload(id: id, url: url, title: ModelData.getLocalizedText(modelData, 'title', langCode)) : null,
            onRemovePressed: null,
            onChatPressed: () => _startChatWithModel(id, isServerSide, isCustomModel: isCustomModel, modelPath: modelPath),
            onCancelPressed: () => _dl.cancelDownload(id),
            downloadManager: _downloadManagers[id],
            category: modelData['category'] as String? ?? '',
            modalities: modelData['modalities'] as Map<String, dynamic>? ?? const {},
            context: modelData['context']?.toString() ?? '',
            extensions: (modelData['extensions'] as Map?)?.cast<String, Map<String, dynamic>>(),
            baseModelId: modelData['baseModelId'] as String?),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.ease;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );

    if (!mounted) return;

    // If the detail page returned 'model_updated', it means a change occurred
    // (e.g., a custom model was edited), and our current data is stale.
    if (result == 'model_updated') {
      debugPrint("[ModelsScreen] Received 'model_updated' signal. Invalidating caches and refreshing data.");

      // --- CACHE INTEGRATION ---
      // Invalidate both caches to ensure we fetch fresh data.
      // 1. Invalidate the high-level screen cache.
      CacheService.invalidateModelsScreenCache();
      // 2. Invalidate the low-level data provider cache.
      ModelData.clearCache();

      // Show the skeleton screen for a smooth visual transition.
      setState(() {
        _isLoading = true;
      });

      // Trigger a full data reload.
      await _loadDataAndInitialize();

      debugPrint("[ModelsScreen] Silent data refresh complete.");
    }
  }

  Future<void> deleteChatsForSelfModel(String modelId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> conversations = prefs.getStringList('conversations') ?? [];
    conversations = conversations.where((entry) {
      final parts = entry.split('|');
      if (parts.length >= 3) {
        return parts[2] != modelId;
      }
      return true;
    }).toList();
    await prefs.setStringList('conversations', conversations);
  }

  Widget _buildDefaultStuff(double screenWidth, double screenHeight) {
    final loc = AppLocalizations.of(context)!;

    // First, get all models that belong to the user. This is the highest priority category.
    // It correctly includes models created from both the CreateScreen and AddScreen.
    final self = _allModels.where((m) => m['category'] == 'self').toList();

    // Now, for the public categories, filter them as before, but ADD a condition
    // to EXCLUDE any model that is already in the 'self' category. This prevents duplication.
    final serverSide = _allModels.where((m) => m['type'] == 'online' && m['category'] != 'self').toList();
    final local = _allModels.where((m) => m['type'] == 'offline' && m['category'] != 'self').toList();
    final role = _allModels.where((m) => m['type'] == 'roleplay' && m['category'] != 'self').toList();

    return Padding(
      key: const ValueKey('defaultView'),
      padding: EdgeInsets.only(
          left: screenWidth * 0.04,
          right: screenWidth * 0.04,
          bottom: screenWidth * 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenHeight * 0.01),
          // The rest of the build logic remains the same.
          // It now operates on correctly filtered, non-overlapping lists.
          if (local.isNotEmpty) ...[
            _buildSectionHeader(loc.localModels, 'localModels', local, screenWidth),
            SizedBox(
                height: _calculateCategoryHeight(local, screenWidth),
                child: PageView(
                    children: _buildModelColumns(local, 'localModels', screenWidth))),
          ],
          if (serverSide.isNotEmpty) ...[
            _buildSectionHeader(
                loc.serverSideModels, 'serverSide', serverSide, screenWidth),
            SizedBox(
                height: _calculateCategoryHeight(serverSide, screenWidth),
                child: PageView(
                    children:
                    _buildModelColumns(serverSide, 'serverSide', screenWidth))),
          ],
          if (role.isNotEmpty) ...[
            _buildSectionHeader(loc.roleModels, 'roleModels', role, screenWidth),
            SizedBox(
                height: _calculateCategoryHeight(role, screenWidth),
                child: PageView(
                    children: _buildModelColumns(role, 'roleModels', screenWidth))),
          ],
          if (self.isNotEmpty) ...[
            _buildSectionHeader(loc.myModels, 'self', self, screenWidth),
            SizedBox(
                height: _calculateCategoryHeight(self, screenWidth),
                child: PageView(
                    children: _buildModelColumns(self, 'self', screenWidth))),
          ],
          if (_systemInfo != null) ...[
            Padding(
              padding: EdgeInsets.symmetric(vertical: screenWidth * 0.015),
              child: Text(loc.systemInfo,
                  style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold)),
            ),
            SystemInfoChart(
                totalStorage: _systemInfo!.totalStorage,
                usedStorage: _systemInfo!.totalStorage - _systemInfo!.freeStorage,
                totalMemory: _systemInfo!.deviceMemory,
                usedMemory: _systemInfo!.usedMemory),
          ],
        ],
      ),
    );
  }

  Widget _buildRealContent(double w, double h, {required ValueKey<String> key}) {
    if (_searchCtrl == null) {
      return const SizedBox.shrink();
    }
    final bool isSearchActive = _searchCtrl!.textController.text.trim().isNotEmpty;
    final Widget bodyContent = isSearchActive ? _searchCtrl!.buildSearchBody(w) : _buildDefaultStuff(w, h);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _searchCtrl!.buildSearchBar(w)),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) => currentChild ?? const SizedBox.shrink(),
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            child: KeyedSubtree(
              key: ValueKey(isSearchActive ? 'search' : 'default'),
              child: bodyContent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, String section, List<Map<String, dynamic>> models, double screenWidth) {
    return Padding(
      padding: EdgeInsets.only(top: screenWidth * 0.02, bottom: screenWidth * 0.01),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(color: AppColors.primaryColor.inverted, fontSize: screenWidth * 0.05, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalizationWarningPanel(AppLocalizations localizations) {
    final double bottomPosition = _showLocalizationWarning ? 16.0 : -150.0;
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      bottom: bottomPosition,
      left: screenWidth * 0.04,
      right: screenWidth * 0.04,
      child: GestureDetector(
        onTap: _dismissWarningPanel,
        child: Material(
          type: MaterialType.transparency,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border.withOpacity(0.5)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/icons/warning.svg',
                  colorFilter: ColorFilter.mode(
                      AppColors.primaryColor.inverted, BlendMode.srcIn),
                  width: 24,
                  height: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    localizations
                        .aiTranslationWarning,
                    style: TextStyle(
                      color: AppColors.primaryColor.inverted,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the main content view, which includes the search bar and the list of models.
  /// This widget is displayed only when the screen state is successful (not loading and no errors).
  /// A [ValueKey] is assigned to help the parent `AnimatedSwitcher` identify this widget.
  Widget _buildContent(double screenWidth, double screenHeight) {
    // Determine if the search is active to switch between the default view and search results.
    final bool isSearchActive = _searchCtrl?.textController.text.trim().isNotEmpty ?? false;

    // The CustomScrollView allows the search bar to scroll away with the content,
    // providing a more integrated user experience.
    return CustomScrollView(
      key: const ValueKey('content'), // A stable key for the AnimatedSwitcher.
      slivers: [
        // The search bar is always the first item.
        SliverToBoxAdapter(child: _searchCtrl!.buildSearchBar(screenWidth)),

        // The body of the list, which switches between the default view and search results.
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            // A fade transition provides a smooth change between the two list states.
            transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
            // The KeyedSubtree ensures the state of the search results or default view is preserved correctly.
            child: KeyedSubtree(
              key: ValueKey(isSearchActive ? 'search' : 'default'),
              child: isSearchActive
                  ? _searchCtrl!.buildSearchBody(screenWidth)
                  : _buildDefaultStuff(screenWidth, screenHeight),
            ),
          ),
        ),
      ],
    );
  }

  /// The main build method, acting as the master controller for the screen's UI.
  ///
  /// It uses an `AnimatedSwitcher` to elegantly transition between three primary states:
  /// 1. `_isLoading`: Displays a `SkeletonScreen` placeholder.
  /// 2. `_loadError`: Displays an `ErrorView` with a retry option.
  /// 3. `Success`: Displays the main content via the `_buildContent` method.
  ///
  /// This architecture ensures a clean separation of concerns and a polished user experience.
  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final localizations = AppLocalizations.of(context)!;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          localizations.modelsTitle,
          style: TextStyle(
            fontFamily: 'Roboto',
            color: AppColors.primaryColor.inverted,
            fontSize: screenWidth * 0.07,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        actions: [
          SizedBox(
            width: screenWidth * 0.37,
            height: screenHeight * 0.1,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topLeft,
              children: [
                Positioned(
                  top: screenHeight * 0.0129,
                  left: screenWidth * 0.082,
                  child: Container(
                    width: screenWidth * 0.26,
                    height: screenHeight * 0.045,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.016,
                      vertical: screenHeight * 0.005,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.senaryColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Container(
                            padding: EdgeInsets.all(screenWidth * 0.01),
                          ),
                        ),
                        Positioned(
                          top: screenWidth * 0.012,
                          right: screenWidth * 0.094,
                          child: Text(
                            localizations.create,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.036,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: screenHeight * 0.0129,
                  left: screenWidth * 0.25,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openCreateScreen(context),
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: screenWidth * 0.1,
                        height: screenHeight * 0.045,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.senaryColor,
                        ),
                        padding: EdgeInsets.all(screenWidth * 0.026),
                        child: SvgPicture.asset(
                          'assets/icons/plus.svg',
                          colorFilter:
                          const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                          width: screenWidth * 0.02,
                          height: screenWidth * 0.02,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  left: screenWidth * 0.07,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _openCreateScreen(context),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // The main content area, which reacts to the current state.
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => FocusScope.of(context).unfocus(), // Dismiss keyboard on tap.
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (Widget child, Animation<double> animation) {
                // Use a fade transition for smooth state changes.
                return FadeTransition(opacity: animation, child: child);
              },
              // The core logic that determines which widget to display based on state flags.
              child: _isLoading
                  ? const SkeletonScreen(key: ValueKey('skeleton'))
                  : _loadError
                  ? ErrorView(
                key: const ValueKey('error'),
                title: localizations.errorLoadingTitle,
                message: localizations.errorLoadingMessage,
                buttonText: localizations.retry,
                onRetry: _loadDataAndInitialize,
              )
                  : _buildContent(screenWidth, screenHeight),
            ),
          ),

          // The localization warning panel is a separate layer on top of the main content.
          _buildLocalizationWarningPanel(localizations),
        ],
      ),
    );
  }
}

class SlideRightRoute extends PageRouteBuilder<bool> {
  final Widget page;
  SlideRightRoute({required this.page})
      : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      var begin = const Offset(1.0, 0.0);
      var end = Offset.zero;
      var curve = Curves.ease;
      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
  );
}