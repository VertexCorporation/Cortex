// library/backend/download/controller.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import '../data/entity.dart';
import 'download.dart';
import '../data/user.dart';

class ModelDownloadController {
  ModelDownloadController({
    required this.context,
    required this.managers,
    required this.downloadCompleted,
    required this.getFilePathById,
    // THE CORRECT PATTERN: A simple callback to signal a state change.
    required this.onStateChange,
  });

  //---------------------------------------------------------------------
  // External state & helpers
  //---------------------------------------------------------------------
  final BuildContext context;
  final Map<String, DownloadManager> managers;
  final Map<String, bool> downloadCompleted;
  final String Function(String id) getFilePathById;
  /// A callback function that the controller will invoke to signal a UI refresh.
  final VoidCallback onStateChange;

  //---------------------------------------------------------------------
  // Internal fields
  //---------------------------------------------------------------------
  final Map<String, String> _downloadTaskIds = {};
  final Map<String, Mutex> _modelMutexes = {};
  final Map<String, Completer<void>> _activeDownloadCompleters = {};

  //================================================================================
  // Public API
  //================================================================================

  /// Initiates a download for a model.
  Future<void> startDownload({
    required String id,
    required String url,
    required String title,
    required bool showSystemNotification,
  }) async {
    if (url.isEmpty) {
      debugPrint("[DownloadController] Download for '$id' aborted: URL is empty.");
      return;
    }

    final mutex = _modelMutexes.putIfAbsent(id, () => Mutex());
    if (mutex.isLocked) {
      debugPrint("[DownloadController] Download for '$id' is already being initiated. Ignoring duplicate request.");
      return;
    }

    await mutex.acquire();
    try {
      final manager = managers.putIfAbsent(id, () => DownloadManager());
      if (manager.isDownloaded || manager.isDownloading || manager.isPaused) {
        debugPrint("[DownloadController] Pre-flight check failed for '$id'. Aborting.");
        return;
      }

      manager
        ..setCancelled(false)
        ..setDownloading(true)
        ..setPaused(false)
        ..setProgress(0);

      // *** THE FIX ***: Invoke the callback to trigger the UI update.
      onStateChange();

      await _doDownload(
        id: id,
        url: url,
        title: title,
        showSystemNotification: showSystemNotification,
      );
    } catch (e) {
      debugPrint("[DownloadController] CRITICAL ERROR during download initiation for '$id': $e");
      managers[id]?..setDownloading(false)..setPaused(false)..setProgress(0);
      onStateChange(); // Also notify on error
    } finally {
      if (mutex.isLocked) {
        mutex.release();
      }
    }
  }

  /// Cancels an ongoing or paused download.
  Future<void> cancelDownload(String id) async {
    final manager = managers[id];
    if (manager == null) {
      debugPrint("[DownloadController] Cancel request for '$id' ignored: No manager found.");
      return;
    }

    manager
      ..setCancelled(true)
      ..setDownloading(false)
      ..setPaused(false)
      ..setProgress(0);

    // *** THE FIX ***: Invoke the callback to trigger the UI update.
    // This is the key to making the UI update immediately and correctly.
    onStateChange();

    final prefs = await SharedPreferences.getInstance();
    final taskId = _downloadTaskIds[id] ?? prefs.getString('download_task_id_$id');

    if (taskId == null) {
      debugPrint("[DownloadController] Cancel cleanup for '$id': No task ID found, only UI state was reset.");
      return;
    }

    try {
      await FileDownloadHelper().cancelDownload(taskId);
      debugPrint("[DownloadController] Cancellation command sent for task '$taskId'.");

      final filePath = getFilePathById(id);
      final partialFile = File(filePath);
      if (await partialFile.exists()) {
        try {
          await partialFile.delete();
          debugPrint("[DownloadController] Deleted partial download file for '$id'.");
        } catch (e) {
          debugPrint("[DownloadController] Error deleting partial file for '$id': $e");
        }
      }
    } catch (e, s) {
      debugPrint("[DownloadController] An error occurred during cancellation for '$id': $e\n$s");
    } finally {
      _downloadTaskIds.remove(id);
      await prefs.remove('download_task_id_$id');

      if (_activeDownloadCompleters.containsKey(id)) {
        if (!_activeDownloadCompleters[id]!.isCompleted) {
          _activeDownloadCompleters[id]!.complete();
        }
        _activeDownloadCompleters.remove(id);
      }
    }
  }

  /// Resumes a paused download.
  void resumeDownload(String id) async {
    final taskId = _downloadTaskIds[id];
    if (taskId == null) return;
    final newTaskId = await FileDownloadHelper().resumeDownload(taskId);
    if (newTaskId == null) return;

    final prefs = await SharedPreferences.getInstance();
    _downloadTaskIds[id] = newTaskId;
    await prefs.setString('download_task_id_$id', newTaskId);
    final manager = managers[id];
    if (manager != null) {
      manager
        ..setPaused(false)
        ..setDownloading(true);
      onStateChange(); // Notify UI of the change to "resumed" state.
    }
  }

  /// Checks for completed model files on app startup.
  Future<void> checkDownloadStates(List<ModelEntity> models) async {
    for (final model in models) {
      if (model.isServerSide) continue;
      await _checkFileExists(model.id);
    }
  }

  /// Checks for ongoing or paused tasks from the previous session.
  Future<void> checkDownloadingStates({
    required List<ModelEntity> models,
    required Map<String, bool> groundTruthDownloadStates,
  }) async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return;
    final prefs = await SharedPreferences.getInstance();
    bool needsUIRefresh = false;

    for (final model in models) {
      if (model.isServerSide) continue;
      final id = model.id;
      final manager = managers[id];
      if (manager == null) continue;

      final taskId = prefs.getString('download_task_id_$id');
      final task = taskId == null ? null : tasks.firstWhereOrNull((t) => t.taskId == taskId);

      if (task == null) {
        if (manager.isDownloading || manager.isPaused) {
          manager..setDownloading(false)..setPaused(false)..setProgress(0);
          needsUIRefresh = true;
        }
        await prefs.remove('download_task_id_$id');
        continue;
      }

      _downloadTaskIds[id] = task.taskId;
      manager.setCancelled(false);

      switch (task.status) {
        case DownloadTaskStatus.running:
        case DownloadTaskStatus.enqueued:
          manager..setDownloading(true)..setPaused(false)..setProgress(task.progress.toDouble());
          needsUIRefresh = true; // State changed
          break;
        case DownloadTaskStatus.paused:
          manager..setDownloading(false)..setPaused(true)..setProgress(task.progress.toDouble());
          needsUIRefresh = true; // State changed
          break;
        case DownloadTaskStatus.complete:
        // We only trust the 'complete' status if the file ACTUALLY exists on disk.
          final bool fileActuallyExists = groundTruthDownloadStates[id] ?? false;

          if (fileActuallyExists) {
            // The file is there, so the state is genuinely 'downloaded'.
            manager..setDownloading(false)..setPaused(false)..setDownloaded(true)..setProgress(100);
            // We can now safely remove the task ID as it's no longer pending.
            await prefs.remove('download_task_id_$id');
            needsUIRefresh = true;
          } else {
            // CONFLICT DETECTED! The task is 'complete', but the file is gone (uninstalled).
            // The file system wins. We must clean up the stale task.
            debugPrint("[DownloadController] Conflict found for '$id'. Task is 'complete' but file is missing. Cleaning up stale task.");
            await FlutterDownloader.remove(taskId: task.taskId, shouldDeleteContent: false);
            await prefs.remove('download_task_id_$id');
            // The manager's state was already set to 'isDownloaded: false' by the file check,
            // so we don't need to change it here.
          }
          break;
        default: // failed, canceled, undefined
          manager..setDownloading(false)..setPaused(false)..setProgress(0);
          await prefs.remove('download_task_id_$id');
          needsUIRefresh = true; // State changed
          break;
      }
    }
    if (needsUIRefresh) {
      onStateChange();
    }
  }

  //================================================================================
  // Private Helpers
  //================================================================================

  Future<void> _doDownload({
    required String id,
    required String url,
    required String title,
    required bool showSystemNotification,
  }) async {
    final manager = managers[id]!;
    final prefs = await SharedPreferences.getInstance();
    final filePath = getFilePathById(id);

    final completer = Completer<void>();
    _activeDownloadCompleters[id] = completer;

    try {
      final taskId = await FileDownloadHelper().downloadModel(
        id: id,
        url: url,
        filePath: filePath,
        title: title,
        showNotification: showSystemNotification,
        onProgress: (_, progress) {
          if (manager.isCancelled) return;
          manager.setProgress(progress);
        },
        onDownloadCompleted: (_) async {
          if (manager.isCancelled) {
            if (!completer.isCompleted) completer.complete();
            return;
          }
          try {
            await UserModels.addDownloadedModel(id, filePath);
            manager
              ..setDownloading(false)
              ..setDownloaded(true)
              ..setPaused(false)
              ..setProgress(100);
            DownloadedModelsManager().notifyListenersOfChange();
          } catch (e) {
            if (!completer.isCompleted) completer.completeError(e);
          } finally {
            if (!completer.isCompleted) completer.complete();
            onStateChange();
          }
        },
        onDownloadError: (e) async {
          if (manager.isCancelled) return;
          try {
            manager
              ..setDownloading(false)
              ..setPaused(false)
              ..setProgress(0);
            await prefs.remove('download_task_id_$id');
            final partialFile = File(filePath);
            if (await partialFile.exists()) {
              await partialFile.delete();
            }
            await UserModels.removeDownloadedModel(id);
            if (!completer.isCompleted) completer.completeError(e);
          } catch (deleteError) {
            debugPrint("Could not delete partial file during error handling: $deleteError");
          } finally {
            onStateChange();
          }
        },
        onDownloadPaused: () {
          if (manager.isCancelled) return;
          manager..setDownloading(false)..setPaused(true);
          onStateChange();
        },
      );

      if (taskId != null) {
        _downloadTaskIds[id] = taskId;
        await prefs.setString('download_task_id_$id', taskId);
      } else {
        throw Exception('Failed to enqueue download task.');
      }

      await completer.future;
    } catch (e) {
      manager..setDownloading(false)..setPaused(false)..setProgress(0);
      onStateChange();
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    } finally {
      _activeDownloadCompleters.remove(id);
    }
  }

  Future<void> _checkFileExists(String id) async {
    final downloadedPaths = await UserModels.loadDownloadedModelPaths();
    final isPersistentlyDownloaded = downloadedPaths.containsKey(id);
    final manager = managers[id];
    if (manager == null) return;

    bool stateChanged = false;
    final currentCompleted = downloadCompleted[id] ?? false;

    if (!isPersistentlyDownloaded) {
      if (manager.isDownloaded) {
        manager.setDownloaded(false);
        stateChanged = true;
      }
      if (currentCompleted) {
        downloadCompleted[id] = false;
        stateChanged = true;
      }
    } else {
      final filePath = getFilePathById(id);
      final file = File(filePath);
      final exists = await file.exists();

      if (!exists) {
        await UserModels.removeDownloadedModel(id);
        if (manager.isDownloaded) {
          manager.setDownloaded(false);
          stateChanged = true;
        }
        if (currentCompleted) {
          downloadCompleted[id] = false;
          stateChanged = true;
        }
      } else {
        if (!manager.isDownloaded) {
          manager.setDownloaded(true);
          stateChanged = true;
        }
        if (!currentCompleted) {
          downloadCompleted[id] = true;
          stateChanged = true;
        }
      }
    }

    if (stateChanged) {
      onStateChange();
    }
  }
}