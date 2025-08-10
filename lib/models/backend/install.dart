// install.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import 'dart:developer' as dev;
import '../backend/download.dart';
import 'data.dart';

class ModelDownloadController {
  ModelDownloadController({
    required this.context,
    required this.managers,
    required this.downloadCompleted,
    required this.getFilePathById,
  });

  //---------------------------------------------------------------------
  // External state & helpers
  //---------------------------------------------------------------------
  final BuildContext context;
  final Map<String, DownloadManager> managers;
  final Map<String, bool> downloadCompleted;
  final String Function(String id) getFilePathById;

  //---------------------------------------------------------------------
  // Internal fields
  //---------------------------------------------------------------------
  final Map<String, String> _downloadTaskIds = {};
  final Map<String, Mutex> _modelMutexes = {};

  /// --- THE FIX: A map to track the completer for each download process. ---
  /// This allows the `cancelDownload` function to signal the `_doDownload`
  /// function to stop waiting, which is essential for releasing the mutex.
  final Map<String, Completer<void>> _activeDownloadCompleters = {};

  //---------------------------------------------------------------------
  // Public API
  //---------------------------------------------------------------------

  /// Initiates the download process for a model, guarded by a mutex.
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

    // This mutex prevents rapid double-taps from initiating two downloads.
    final mutex = _modelMutexes.putIfAbsent(id, () => Mutex());
    if (mutex.isLocked) {
      debugPrint("[DownloadController] Download for '$id' is already being initiated. Ignoring duplicate request.");
      return;
    }

    await mutex.acquire();

    try {
      final manager = managers.putIfAbsent(id, () => DownloadManager());
      if (manager.isDownloaded || manager.isDownloading || manager.isPaused) {
        debugPrint("[DownloadController] Pre-flight check failed. Download for '$id' is already running, paused, or complete. Aborting.");
        return;
      }

      debugPrint("[DownloadController] Starting download process for model '$id' with URL: $url");
      manager
        ..setCancelled(false) // Reset cancellation flag for the new download
        ..setDownloading(true)
        ..setPaused(false)
        ..setProgress(0);

      // This call now waits for a future that can be completed by success, error, OR cancellation.
      await _doDownload(
        id: id,
        url: url,
        title: title,
        showSystemNotification: showSystemNotification,
      );

    } catch (e) {
      debugPrint("[DownloadController] CRITICAL ERROR during download initiation for '$id': $e");
      managers[id]?..setDownloading(false)..setPaused(false)..setProgress(0);
    } finally {
      // This is now guaranteed to be called even after cancellation, unblocking the UI.
      if (mutex.isLocked) {
        debugPrint("[DownloadController] Mutex for '$id' has been released.");
        mutex.release();
      }
    }
  }

  /// Cancels an in-progress or paused download. This is now fully robust.
  Future<void> cancelDownload(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final manager = managers[id];

    if (manager == null || (!manager.isDownloading && !manager.isPaused)) {
      debugPrint("[DownloadController] Cancel ignored: no active or paused download for '$id'.");
      return;
    }

    try {
      // Set UI state immediately for responsiveness.
      // This also signals any in-flight callbacks to stop processing.
      manager
        ..setCancelled(true)
        ..setDownloading(false)
        ..setPaused(false)
        ..setProgress(0);

      // Reliably find the taskId, even after an app restart.
      final taskId = _downloadTaskIds[id] ?? await prefs.getString('download_task_id_$id');

      if (taskId != null) {
        debugPrint("[DownloadController] Found taskId '$taskId' for model '$id'. Proceeding with cancellation.");

        await FileDownloadHelper().cancelDownload(taskId);

        final filePath = getFilePathById(id);
        final partialFile = File(filePath);
        if (await partialFile.exists()) {
          try {
            await partialFile.delete();
            debugPrint("[DownloadController] Successfully deleted partial file for '$id' at: $filePath");
          } catch (e) {
            debugPrint("[DownloadController] Error deleting partial file for '$id': $e");
          }
        }

        // Clean up all persistent and in-memory state.
        _downloadTaskIds.remove(id);
        await prefs.remove('download_task_id_$id');
        await prefs.remove('is_downloading_$id');
        debugPrint("[DownloadController] Cancellation for model '$id' complete. State cleaned up.");

      } else {
        debugPrint("[DownloadController] Could not find taskId for model '$id' to cancel. Cleaning up local state as a precaution.");
        await prefs.remove('is_downloading_$id');
      }

    } catch(e) {
      debugPrint("[DownloadController] Error during cancellation for '$id': $e");
    } finally {
      /// --- THE PERFECT FIX ---
      /// Forcefully complete the hanging Future from _doDownload.
      /// This unblocks the `await` in `startDownload`, allowing its `finally`
      /// block to run and release the mutex.
      if (_activeDownloadCompleters.containsKey(id)) {
        if (!_activeDownloadCompleters[id]!.isCompleted) {
          _activeDownloadCompleters[id]!.complete();
          dev.log("[DownloadController] Manually completed the hanging future for '$id' to release the mutex.", name: 'Install');
        }
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
    managers[id]?.setPaused(false);
    managers[id]?.setDownloading(true);
  }

  /// Checks and corrects the state of downloaded models on app startup.
  Future<void> checkDownloadStates(List<Map<String, dynamic>> models) async {
    for (final m in models) {
      if (m['type'] != 'offline') continue;
      final id = m['id'] as String;

      final isDownloading = managers[id]?.isDownloading ?? false;
      if (!isDownloading) {
        await _checkFileExists(id);
      }
    }
  }

  /// Specifically checks for transient download tasks (running, paused) upon app startup.
  Future<void> checkDownloadingStates(List<Map<String, dynamic>> models) async {
    final tasks = await FlutterDownloader.loadTasks();
    if (tasks == null) return;
    final prefs = await SharedPreferences.getInstance();

    for (final m in models) {
      if (m['type'] != 'offline') continue;
      final id = m['id'] as String;
      final manager = managers[id];
      if (manager == null) continue;

      final taskId = prefs.getString('download_task_id_$id');
      final task = taskId == null ? null : tasks.firstWhereOrNull((t) => t.taskId == taskId);

      if (task == null) {
        if (manager.isDownloading || manager.isPaused) {
          manager..setDownloading(false)..setPaused(false);
        }
        continue;
      }

      _downloadTaskIds[id] = task.taskId;
      switch (task.status) {
        case DownloadTaskStatus.running:
        case DownloadTaskStatus.enqueued:
          manager..setDownloading(true)..setPaused(false)..setProgress(task.progress.toDouble());
          break;
        case DownloadTaskStatus.paused:
          manager..setDownloading(false)..setPaused(true)..setProgress(task.progress.toDouble());
          break;
        case DownloadTaskStatus.complete:
          manager..setDownloading(false)..setPaused(false)..setDownloaded(true)..setProgress(100);
          await UserModels.addDownloadedModel(id, getFilePathById(id));
          await prefs.remove('download_task_id_$id');
          break;
        default: // Failed, Canceled, Undefined
          manager..setDownloading(false)..setPaused(false)..setProgress(0);
          await prefs.remove('download_task_id_$id');
          break;
      }
    }
  }

  //---------------------------------------------------------------------
  // Private helpers
  //---------------------------------------------------------------------

  /// Main download worker. It registers and cleans up a completer to ensure
  /// the lock in `startDownload` is always eventually released.
  Future<void> _doDownload({
    required String id,
    required String url,
    required String title,
    required bool showSystemNotification,
  }) async {
    final manager = managers[id]!;
    final prefs = await SharedPreferences.getInstance();
    final filePath = getFilePathById(id);

    // --- THE FIX: Create and register the completer ---
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
            dev.log("[DownloadController] Download task for '$id' COMPLETED. Persisting state...", name: 'Install');
            await UserModels.addDownloadedModel(id, filePath);

            manager
              ..setDownloading(false)
              ..setDownloaded(true)
              ..setPaused(false)
              ..setProgress(100);

            DownloadedModelsManager().notifyListenersOfChange();

          } catch (e) {
            dev.log("[DownloadController] CRITICAL: Failed to save download record for '$id': $e", name: 'Install', error: e);
            if (!completer.isCompleted) completer.completeError(e);
          } finally {
            if (!completer.isCompleted) completer.complete();
          }
        },
        onDownloadError: (e) async {
          dev.log("[DownloadController] Download FAILED for '$id'. Cleaning up... Error: $e", name: 'Install', error: e);
          final partialFile = File(filePath);
          if (await partialFile.exists()) {
            await partialFile.delete();
          }
          await UserModels.removeDownloadedModel(id);

          manager
            ..setDownloading(false)
            ..setPaused(false)
            ..setProgress(0);

          await prefs.remove('is_downloading_$id');
          await prefs.remove('download_task_id_$id');

          if (!completer.isCompleted) completer.completeError(e);
        },
        onDownloadPaused: () {
          if (manager.isCancelled) return;
          manager..setDownloading(false)..setPaused(true);
        },
      );

      if (taskId != null) {
        _downloadTaskIds[id] = taskId;
        await prefs.setString('is_downloading_$id', 'true');
        await prefs.setString('download_task_id_$id', taskId);
      } else {
        throw Exception('Failed to enqueue download task.');
      }

      // Wait for success, error, or manual cancellation signal.
      await completer.future;

    } catch (e) {
      manager
        ..setDownloading(false)
        ..setPaused(false)
        ..setProgress(0);
      if (!completer.isCompleted) completer.completeError(e);
      rethrow;
    } finally {
      // --- THE FIX: Always clean up the completer from the map ---
      _activeDownloadCompleters.remove(id);
      dev.log("[DownloadController] Completer for '$id' has been removed.", name: 'Install');
    }
  }

  /// Verifies if a model's file exists on disk and corrects the state if there's a mismatch.
  Future<void> _checkFileExists(String id) async {
    final downloadedPaths = await UserModels.loadDownloadedModelPaths();
    final bool isPersistentlyDownloaded = downloadedPaths.containsKey(id);

    final manager = managers[id];
    if (manager == null) return;

    if (!isPersistentlyDownloaded) {
      if (manager.isDownloaded) {
        debugPrint("[DownloadController] State Mismatch for '$id': Record says NOT downloaded, but manager was. Correcting manager state.");
        manager.setDownloaded(false);
      }
      downloadCompleted[id] = false;
      return;
    }

    final filePath = getFilePathById(id);
    final file = File(filePath);
    final exists = await file.exists();

    if (!exists) {
      debugPrint("[DownloadController] State Mismatch for '$id': Record says downloaded, but file is MISSING. Correcting state and removing faulty record.");
      await UserModels.removeDownloadedModel(id);
      downloadCompleted[id] = false;
      manager.setDownloaded(false);
    } else {
      downloadCompleted[id] = true;
      if (!manager.isDownloaded) {
        manager.setDownloaded(true);
      }
    }
  }
}