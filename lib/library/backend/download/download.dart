// download.dart

import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DownloadManager extends ChangeNotifier {
  bool isDownloading = false;
  bool isPaused = false;
  bool isDownloaded = false;
  double progress = 0.0; // 0..100
  bool isCancelled = false;

  void setDownloading(bool val) {
    if (isDownloading == val) return;
    isDownloading = val;
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
    debugPrint("[DownloadedModelsManager] A downloaded model's state has changed. Notifying all listeners to perform a data refresh.");
    notifyListeners();
  }

  void updateSingleDownloadedModel(String modelTitle, String imagePath) {
    int index = downloadedModels.indexWhere((model) => model.name == modelTitle);
    if (index >= 0) {
      downloadedModels[index] = DownloadedModel(name: modelTitle, image: imagePath);
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

  void refresh() {
    notifyListeners();
  }

  /// Listens for download progress from the background isolate and updates the app state.
  void _bindBackgroundIsolate() {
    if (IsolateNameServer.lookupPortByName('downloader_send_port') != null) {
      IsolateNameServer.removePortNameMapping('downloader_send_port');
    }
    IsolateNameServer.registerPortWithName(_port.sendPort, 'downloader_send_port');

    _port.listen((dynamic data) async {
      try {
        final String taskId = data[0];
        final int statusInt = data[1];
        final int progress = data[2];
        final DownloadTaskStatus status = DownloadTaskStatus.values[statusInt];

        final taskInfo = _tasks[taskId];
        if (taskInfo != null) {
          final prefs = await SharedPreferences.getInstance();
          final String spKeyDownloading = 'is_downloading_${taskInfo.modelId}';

          if (status == DownloadTaskStatus.running) {
            taskInfo.onProgress(taskId, progress.toDouble());
            await prefs.setBool(spKeyDownloading, true);
          } else if (status == DownloadTaskStatus.enqueued) {
            await prefs.setBool(spKeyDownloading, true);
          } else if (status == DownloadTaskStatus.complete) {
            await prefs.setBool(spKeyDownloading, false);
            taskInfo.onDownloadCompleted(taskId);
            _tasks.remove(taskId);

            debugPrint("[FileDownloadHelper] Download complete for task '$taskId'. Broadcasting a global state change notification.");
            DownloadedModelsManager().notifyListenersOfChange();

          } else if (status == DownloadTaskStatus.paused) {
            await prefs.setBool(spKeyDownloading, false);
            taskInfo.onDownloadPaused();
          } else if (status == DownloadTaskStatus.failed || status == DownloadTaskStatus.canceled) {
            await prefs.setBool(spKeyDownloading, false);
            // Don't call onDownloadError here for cancellations, as the controller handles it.
            // Only call it for genuine failures.
            if (status == DownloadTaskStatus.failed) {
              taskInfo.onDownloadError('Download failed');
            }
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

      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: savedDir,
        fileName: fileName,
        showNotification: showNotification,
        openFileFromNotification: showNotification,
      );

      if (taskId != null) {
        _tasks[taskId] = _DownloadTaskInfo(
          modelId: id,
          taskId: taskId,
          title: title,
          filePath: filePath,
          onProgress: onProgress,
          onDownloadCompleted: onDownloadCompleted,
          onDownloadError: onDownloadError,
          onDownloadPaused: onDownloadPaused,
        );
      } else {
        onDownloadError('Download could not be started.');
      }
      return taskId;
    } catch (e) {
      _status = 'Download Failed';
      refresh();
      onDownloadError('An error occurred: $e');
      return null;
    }
  }

  /// --- THE PERFECT FIX ---
  /// This method is now robust and stateless. Its only job is to tell the
  /// flutter_downloader plugin to cancel a task. It does not rely on the
  /// in-memory `_tasks` map, so it works perfectly even after an app restart.
  Future<void> cancelDownload(String taskId) async {
    debugPrint('[FileDownloadHelper] Received request to cancel taskId: $taskId');
    try {
      // Unconditionally call the plugin to cancel the task. This is the fix.
      await FlutterDownloader.cancel(taskId: taskId);
      debugPrint('[FileDownloadHelper] Command to cancel taskId: $taskId sent to the OS successfully.');

      // Also remove the task from our in-memory map if it happens to exist
      // (for the non-restart scenario).
      _tasks.remove(taskId);
    } catch (e) {
      // This might happen if the task ID is invalid or already completed. It's safe to ignore.
      debugPrint("[FileDownloadHelper] Error while cancelling download task '$taskId': $e");
    }
  }


  Future<void> removeDownload(String taskId) async {
    try {
      await FlutterDownloader.remove(taskId: taskId, shouldDeleteContent: false);
    } catch (e) {
      debugPrint("Error removing task: $e");
    }
  }

  Future<String?> resumeDownload(String taskId) async {
    final newTaskId = await FlutterDownloader.resume(taskId: taskId);
    if (newTaskId != null) {
      final oldInfo = _tasks.remove(taskId);
      if (oldInfo != null) {
        _tasks[newTaskId] = _DownloadTaskInfo(
          modelId: oldInfo.modelId,
          taskId: newTaskId,
          title: oldInfo.title,
          filePath: oldInfo.filePath,
          onProgress: oldInfo.onProgress,
          onDownloadCompleted: oldInfo.onDownloadCompleted,
          onDownloadError: oldInfo.onDownloadError,
          onDownloadPaused: oldInfo.onDownloadPaused,
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

      final prefs       = await SharedPreferences.getInstance();
      final keysToWipe  = prefs.getKeys().where((k) =>
      k.startsWith('is_downloading_') || k.startsWith('download_task_id_'));
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
    required this.onProgress,
    required this.onDownloadCompleted,
    required this.onDownloadError,
    required this.onDownloadPaused,
  });
}