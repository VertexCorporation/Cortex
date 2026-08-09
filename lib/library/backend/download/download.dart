// download.dart

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';

class DownloadManager extends ChangeNotifier {
  bool isDownloading = false;
  bool isPaused = false;
  bool isDownloaded = false;
  double progress = 0.0; // 0..100
  bool isCancelled = false;
  DateTime lastProgressUpdateTime = DateTime.now();

  void setDownloading(bool val) {
    if (isDownloading == val) return;
    isDownloading = val;
    if (val) lastProgressUpdateTime = DateTime.now();
    notifyListeners();
  }

  void setPaused(bool val) {
    if (isPaused == val) return;
    isPaused = val;
    notifyListeners();
  }

  void setDownloaded(bool val) {
    if (isDownloaded == val) return;
    isDownloaded = val;
    notifyListeners();
  }

  void setProgress(double val) {
    if (progress == val) return;
    progress = val;
    lastProgressUpdateTime = DateTime.now();
    notifyListeners();
  }

  void setCancelled(bool val) {
    if (isCancelled == val) return;
    isCancelled = val;
    notifyListeners();
  }
}

class DownloadedModelsManager extends ChangeNotifier {
  static final DownloadedModelsManager _instance =
      DownloadedModelsManager._internal();

  factory DownloadedModelsManager() => _instance;

  DownloadedModelsManager._internal();

  List<DownloadedModel> downloadedModels = [];

  void updateDownloadedModels(List<DownloadedModel> newList) {
    downloadedModels = newList;
    notifyListeners();
  }

  /// Call this whenever a model is downloaded OR uninstalled.
  /// It simply notifies all listeners (like ModelsScreen and ChatScreen)
  /// that they need to reload their data to get the latest download states.
  void notifyListenersOfChange() {
    debugPrint(
        "[DownloadedModelsManager] A downloaded model's state has changed. Notifying all listeners to perform a data refresh.");
    notifyListeners();
  }

  void updateSingleDownloadedModel(String modelTitle, String imagePath) {
    int index =
        downloadedModels.indexWhere((model) => model.name == modelTitle);
    if (index >= 0) {
      downloadedModels[index] =
          DownloadedModel(name: modelTitle, image: imagePath);
    } else {
      downloadedModels.add(DownloadedModel(name: modelTitle, image: imagePath));
    }
    notifyListeners();
  }
}

class DownloadedModel {
  final String name;
  final String image;

  DownloadedModel({required this.name, required this.image});
}

class FileDownloadHelper extends ChangeNotifier {
  static final FileDownloadHelper _instance = FileDownloadHelper._internal();

  factory FileDownloadHelper() => _instance;

  FileDownloadHelper._internal() {
    _bindBackgroundIsolate();
  }

  String _status = "Couldn't Downloaded";

  String get status => _status;

  final ReceivePort _port = ReceivePort();
  final Map<String, _DownloadTaskInfo> _tasks = {};

  // Dio Failover Additions
  final Dio _dio = Dio();
  final Map<String, CancelToken> _dioCancelTokens = {};
  final Map<String, int> _dioProgressUpdateMs = {};

  void refresh() {
    notifyListeners();
  }

  /// Listens for download progress from the background isolate and updates the app state.
  void _bindBackgroundIsolate() {
    if (IsolateNameServer.lookupPortByName('downloader_send_port') != null) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      try {
        final String taskId = data[0];
        final int statusInt = data[1];
        final int progress = data[2];
        final DownloadTaskStatus dstatus = DownloadTaskStatus.values[statusInt];

        final taskInfo = _tasks[taskId];
        if (taskInfo != null && !taskInfo.isDioFallback) {
          if (dstatus == DownloadTaskStatus.running) {
            taskInfo.onProgress(taskId, progress.toDouble());
          } else if (dstatus == DownloadTaskStatus.enqueued) {
            // Do nothing
          } else if (dstatus == DownloadTaskStatus.complete) {
            taskInfo.onDownloadCompleted(taskId);
            _tasks.remove(taskId);
            debugPrint(
                "[FileDownloadHelper] Download complete for task '$taskId'. Broadcasting global state change.");
            DownloadedModelsManager().notifyListenersOfChange();
          } else if (dstatus == DownloadTaskStatus.paused) {
            taskInfo.onDownloadPaused();
          } else if (dstatus == DownloadTaskStatus.failed) {
            debugPrint(
                '[FileDownloadHelper] FlutterDownloader failed for task \'$taskId\'. Initiating Dio fallback...');
            _startDioFallbackFromFailedTask(taskId);
          } else if (dstatus == DownloadTaskStatus.canceled) {
            debugPrint(
                "[FileDownloadHelper] Task '$taskId' was confirmed as canceled by the backend.");
            taskInfo.onDownloadError('Download canceled');
            _tasks.remove(taskId);
          }
        }
      } catch (e) {
        debugPrint('[FileDownloadHelper] FATAL ERROR in download callback: $e');
      }
    });
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  Future<void> _startDioFallbackFromFailedTask(String failedTaskId) async {
    final taskInfo = _tasks.remove(failedTaskId);
    if (taskInfo == null) return;

    final newTaskId = 'dio_${taskInfo.modelId}';
    final cancelToken = CancelToken();
    _dioCancelTokens[newTaskId] = cancelToken;
    _dioProgressUpdateMs[newTaskId] = 0;

    _tasks[newTaskId] = _DownloadTaskInfo(
      modelId: taskInfo.modelId,
      taskId: newTaskId,
      title: taskInfo.title,
      filePath: taskInfo.filePath,
      url: taskInfo.url,
      onProgress: taskInfo.onProgress,
      onDownloadCompleted: taskInfo.onDownloadCompleted,
      onDownloadError: taskInfo.onDownloadError,
      onDownloadPaused: taskInfo.onDownloadPaused,
      isDioFallback: true,
      cancelToken: cancelToken,
    );

    _startDioDownload(newTaskId);
  }

  Future<String?> downloadModel({
    required String id,
    required String url,
    required String filePath,
    required String title,
    required Function(String, double) onProgress,
    required Function(String) onDownloadCompleted,
    required Function(String) onDownloadError,
    required Function() onDownloadPaused,
    required bool showNotification,
  }) async {
    try {
      _status = 'Downloading';
      refresh();

      final file = File(filePath);
      final savedDir = file.parent.path;
      final fileName = file.uri.pathSegments.last;

      final savedDirPath = Directory(savedDir);
      if (!savedDirPath.existsSync()) {
        savedDirPath.createSync(recursive: true);
      }

      String? taskId;
      bool useDioFallback = false;

      if (Platform.isIOS) {
        final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
        final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        if (!iosInfo.isPhysicalDevice) {
          useDioFallback = true;
          debugPrint('[FileDownloadHelper] Forcing Dio fallback on iOS Simulator');
        }
      }

      if (!useDioFallback) {
        try {
          taskId = await FlutterDownloader.enqueue(
            url: url,
            savedDir: savedDir,
            fileName: fileName,
            showNotification: showNotification,
            openFileFromNotification: false,
          );
        } catch (e) {
          debugPrint(
              '[FileDownloadHelper] FlutterDownloader enqueue failed: $e, falling back to Dio');
        }
      }

      if (taskId == null) {
        useDioFallback = true;
        taskId = 'dio_$id';
      }

      if (useDioFallback) {
        final cancelToken = CancelToken();
        _dioCancelTokens[taskId] = cancelToken;
        _dioProgressUpdateMs[taskId] = 0;

        _tasks[taskId] = _DownloadTaskInfo(
          modelId: id,
          taskId: taskId,
          title: title,
          filePath: filePath,
          url: url,
          cancelToken: cancelToken,
          isDioFallback: true,
          onProgress: onProgress,
          onDownloadCompleted: onDownloadCompleted,
          onDownloadError: onDownloadError,
          onDownloadPaused: onDownloadPaused,
        );

        _startDioDownload(taskId);
      } else {
        _tasks[taskId] = _DownloadTaskInfo(
          modelId: id,
          taskId: taskId,
          title: title,
          filePath: filePath,
          url: url,
          onProgress: onProgress,
          onDownloadCompleted: onDownloadCompleted,
          onDownloadError: onDownloadError,
          onDownloadPaused: onDownloadPaused,
        );
      }
      return taskId;
    } catch (e) {
      _status = 'Download Failed';
      refresh();
      onDownloadError('An error occurred: $e');
      return null;
    }
  }

  Future<void> _startDioDownload(String taskId) async {
    final taskInfo = _tasks[taskId];
    if (taskInfo == null) return;

    try {
      String tempFilePath = "${taskInfo.filePath}.tmp";

      if (File(tempFilePath).existsSync()) {
        File(tempFilePath).deleteSync();
      }

      await _dio.download(
        taskInfo.url,
        tempFilePath,
        cancelToken: taskInfo.cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total) * 100;

            int currentMs = DateTime.now().millisecondsSinceEpoch;
            int lastUpdate = _dioProgressUpdateMs[taskId] ?? 0;
            if (currentMs - lastUpdate > 250 || progress == 100) {
              _dioProgressUpdateMs[taskId] = currentMs;
              taskInfo.onProgress(taskInfo.modelId,
                  progress); // use model id or task id? ui might prefer taskid, but let's stick to taskid since that's what we returned
            }
          }
        },
      );

      final tempFile = File(tempFilePath);
      if (await tempFile.exists()) {
        await tempFile.rename(taskInfo.filePath);
      }

      taskInfo.onProgress(taskId, 100);
      taskInfo.onDownloadCompleted(taskId);
      _tasks.remove(taskId);
      _dioCancelTokens.remove(taskId);
      _dioProgressUpdateMs.remove(taskId);

      debugPrint(
          "[FileDownloadHelper] Dio Download complete for task '$taskId'.");
      DownloadedModelsManager().notifyListenersOfChange();
    } catch (e) {
      if (e is DioException && CancelToken.isCancel(e)) {
        debugPrint("[FileDownloadHelper] Dio Download cancelled: $taskId");
      } else {
        debugPrint("[FileDownloadHelper] Dio Download error: $e");
        taskInfo.onDownloadError('Error: $e');
      }
      _tasks.remove(taskId);
      _dioCancelTokens.remove(taskId);
      _dioProgressUpdateMs.remove(taskId);
    }
  }

  Future<void> cancelDownload(String taskId) async {
    debugPrint(
        '[FileDownloadHelper] Received request to cancel taskId: $taskId');
    try {
      if (taskId.startsWith('dio_')) {
        final cancelToken = _dioCancelTokens[taskId];
        cancelToken?.cancel("User requested cancellation");
        final taskInfo = _tasks.remove(taskId);
        if (taskInfo != null) {
          taskInfo.isCancelledByUser = true;
          final tempFile = File("${taskInfo.filePath}.tmp");
          if (await tempFile.exists()) await tempFile.delete();
        }
        _dioCancelTokens.remove(taskId);
        _dioProgressUpdateMs.remove(taskId);
        debugPrint('[FileDownloadHelper] Dio task $taskId cancelled.');
        return;
      }

      await FlutterDownloader.cancel(taskId: taskId);
      debugPrint(
          '[FileDownloadHelper] Command to cancel taskId: $taskId sent to the OS successfully.');
      _tasks.remove(taskId);
    } catch (e) {
      debugPrint(
          "[FileDownloadHelper] Error while cancelling download task '$taskId': $e");
    }
  }

  Future<void> removeDownload(String taskId) async {
    try {
      if (taskId.startsWith('dio_')) {
        await cancelDownload(taskId);
        return;
      }
      await FlutterDownloader.remove(
          taskId: taskId, shouldDeleteContent: false);
    } catch (e) {
      debugPrint("Error removing task: $e");
    }
  }

  Future<String?> resumeDownload(String taskId) async {
    if (taskId.startsWith('dio_')) {
      return null; // Force controller to start new fallback download
    }

    final newTaskId = await FlutterDownloader.resume(taskId: taskId);
    if (newTaskId != null) {
      final oldInfo = _tasks.remove(taskId);
      if (oldInfo != null) {
        _tasks[newTaskId] = _DownloadTaskInfo(
          modelId: oldInfo.modelId,
          taskId: newTaskId,
          title: oldInfo.title,
          filePath: oldInfo.filePath,
          url: oldInfo.url,
          onProgress: oldInfo.onProgress,
          onDownloadCompleted: oldInfo.onDownloadCompleted,
          onDownloadError: oldInfo.onDownloadError,
          onDownloadPaused: oldInfo.onDownloadPaused,
          cancelToken: oldInfo.cancelToken,
          isDioFallback: oldInfo.isDioFallback,
        );
      }
      return newTaskId;
    }
    return null;
  }

  Future<void> cancelAllPendingDownloads() async {
    try {
      final trackedIds = _tasks.keys.toList();
      for (final id in trackedIds) {
        await cancelDownload(id);
      }

      try {
        final allTasks = await FlutterDownloader.loadTasks();
        if (allTasks != null) {
          for (final t in allTasks) {
            final s = t.status;
            if (s == DownloadTaskStatus.running ||
                s == DownloadTaskStatus.enqueued ||
                s == DownloadTaskStatus.paused) {
              await FlutterDownloader.cancel(taskId: t.taskId);
            }
          }
        }
      } catch (_) {}

      final prefs = await SharedPreferences.getInstance();
      final keysToWipe =
          prefs.getKeys().where((k) => k.startsWith('download_task_id_'));
      for (final k in keysToWipe) {
        await prefs.remove(k);
      }

      debugPrint('[DL] All pending downloads were cancelled on logout.');
    } catch (e) {
      debugPrint('[DL] Error while cancelling downloads on logout → $e');
    }
  }
}

class _DownloadTaskInfo {
  final String modelId;
  final String taskId;
  final String title;
  final String filePath;
  final String url;
  final CancelToken? cancelToken;
  final bool isDioFallback;
  final Function(String, double) onProgress;
  final Function(String) onDownloadCompleted;
  final Function(String) onDownloadError;
  final Function() onDownloadPaused;
  bool isCancelledByUser = false;

  _DownloadTaskInfo({
    required this.modelId,
    required this.taskId,
    required this.title,
    required this.filePath,
    required this.url,
    this.cancelToken,
    this.isDioFallback = false,
    required this.onProgress,
    required this.onDownloadCompleted,
    required this.onDownloadError,
    required this.onDownloadPaused,
  });
}
