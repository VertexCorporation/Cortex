// library/backend/download/controller.dart

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cortex/notifications/introvert.dart';
import 'package:cortex/l10n/app_localizations.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';
import 'package:mutex/mutex.dart';
import '../data/entity.dart';
import 'download.dart';
import '../data/user.dart';
import '../system.dart';

class ModelDownloadController {
  ModelDownloadController({
    required this.context,
    required this.managers,
    required this.downloadCompleted,
    required this.getFilePathById,
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
    double? sizeInMB,
  }) async {
    if (url.isEmpty) {
      debugPrint(
          "[DownloadController] Download for '$id' aborted: URL is empty.");
      return;
    }

    if (kIsWeb) {
      debugPrint("[DownloadController] Downloads are not supported on Web.");
      return;
    }

    // Storage Check
    if (sizeInMB != null) {
      final sysInfo = await SystemInfoProvider.fetchSystemInfo();
      final freeStorage = sysInfo.freeStorage; // MB
      // 10% safety buffer or 500MB, whichever is smaller, but at least 100MB
      final buffer = (sizeInMB * 0.1).clamp(100.0, 500.0);

      if (freeStorage < (sizeInMB + buffer)) {
        debugPrint(
            "[DownloadController] Not enough storage. Free: ${freeStorage}MB, Required: ${sizeInMB +
                buffer}MB");
        if (context.mounted) {
          final l10n = AppLocalizations.of(context);
          final errorMessage = l10n?.errorInsufficientStorage ??
              "Insufficient storage space to download this model.";
          Provider
              .of<IntrovertNotificationService>(context, listen: false)
              .showNotification(
            message: errorMessage,
            type: NotificationType.error,
          );
        }
        return;
      }
    }

    final mutex = _modelMutexes.putIfAbsent(id, () => Mutex());
    if (mutex.isLocked) {
      debugPrint(
          "[DownloadController] Download for '$id' is already being initiated. Ignoring duplicate request.");
      return;
    }

    await mutex.acquire();
    try {
      final manager = managers.putIfAbsent(id, () => DownloadManager());
      if (manager.isDownloaded || manager.isDownloading || manager.isPaused) {
        debugPrint(
            "[DownloadController] Pre-flight check failed for '$id'. Aborting.");
        return;
      }

      manager
        ..setCancelled(false)
        ..setDownloading(true)
        ..setPaused(false)
        ..setProgress(0);

      onStateChange();

      await _doDownload(
        id: id,
        url: url,
        title: title,
        showSystemNotification: showSystemNotification,
      );
    } catch (e) {
      debugPrint(
          "[DownloadController] CRITICAL ERROR during download initiation for '$id': $e");
      managers[id]
        ?..setDownloading(false)
        ..setPaused(false)
        ..setProgress(0);
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
      debugPrint(
          "[DownloadController] Cancel request for '$id' ignored: No manager found.");
      return;
    }

    manager
      ..setCancelled(true)
      ..setDownloading(false)
      ..setPaused(false)
      ..setProgress(0);

    // This is the key to making the UI update immediately and correctly.
    onStateChange();

    final prefs = await SharedPreferences.getInstance();
    final taskId =
        _downloadTaskIds[id] ?? prefs.getString('download_task_id_$id');

    if (taskId == null) {
      debugPrint(
          "[DownloadController] Cancel cleanup for '$id': No task ID found, only UI state was reset.");
      return;
    }

    try {
      await FileDownloadHelper().cancelDownload(taskId);
      debugPrint(
          "[DownloadController] Cancellation command sent for task '$taskId'.");

      final filePath = getFilePathById(id);
      final partialFile = File(filePath);
      if (await partialFile.exists()) {
        try {
          await partialFile.delete();
          debugPrint(
              "[DownloadController] Deleted partial download file for '$id'.");
        } catch (e) {
          debugPrint(
              "[DownloadController] Error deleting partial file for '$id': $e");
        }
      }
    } catch (e, s) {
      debugPrint(
          "[DownloadController] An error occurred during cancellation for '$id': $e\n$s");
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
    bool isFreshStart = false,
  }) async {
    if (kIsWeb) return;

    final tasks = await FlutterDownloader.loadTasks();
    final safeTasks = tasks ?? [];

    final prefs = await SharedPreferences.getInstance();
    bool needsUIRefresh = false;

    for (final model in models) {
      if (model.isServerSide) continue;
      final id = model.id;
      final manager = managers[id];
      final effectiveManager =
          manager ?? managers.putIfAbsent(id, () => DownloadManager());

      final taskId = prefs.getString('download_task_id_$id');
      final task = taskId == null
          ? null
          : safeTasks.firstWhereOrNull((t) => t.taskId == taskId);

      bool isTaskRunning = task != null &&
          (task.status == DownloadTaskStatus.running ||
              task.status == DownloadTaskStatus.enqueued);

      if (!isTaskRunning && _activeDownloadCompleters.containsKey(id)) {
        debugPrint(
            "[DownloadController] ZOMBIE LOCK DETECTED for '$id'. Forcing completer termination.");
        final completer = _activeDownloadCompleters[id];
        if (completer != null && !completer.isCompleted) {
          completer.completeError("System process kill detected on resume");
        }
        _activeDownloadCompleters.remove(id);
      }

      if (task == null) {
        if (effectiveManager.isDownloading || effectiveManager.isPaused) {
          debugPrint(
              "[DownloadController] Sync: Task for '$id' disappeared. Resetting UI.");
          effectiveManager
            ..setDownloading(false)
            ..setPaused(false)
            ..setProgress(0);
          needsUIRefresh = true;
        }

        if (taskId != null) {
          await prefs.remove('download_task_id_$id');
          _downloadTaskIds.remove(id);
        }

        // Fix: Orphaned File Cleanup
        // If the task is gone from the DB, and we don't think it's downloaded,
        // and we are starting fresh... the file is likely a zombie partial.
        if (isFreshStart) {
          final isDownloaded = groundTruthDownloadStates[id] ?? false;
          if (!isDownloaded) {
            final path = getFilePathById(id);
            final file = File(path);
            if (await file.exists()) {
              debugPrint(
                  "[DownloadController] Fresh Start Cleanup: Deleting ORPHANED file for '$id' (No task found).");
              try {
                await file.delete();
              } catch (e) {
                debugPrint("Error deleting orphan: $e");
              }
            }
          }
        }

        continue;
      }

      _downloadTaskIds[id] = task.taskId;
      effectiveManager.setCancelled(false);

      debugPrint(
          "[DownloadController] Syncing '$id': Status ${task
              .status}, Progress ${task.progress}");

      switch (task.status) {
        case DownloadTaskStatus.running:
          effectiveManager
            ..setDownloading(true)
            ..setPaused(false)
            ..setProgress(task.progress.toDouble());
          needsUIRefresh = true;
          break;

        case DownloadTaskStatus.enqueued:
          effectiveManager
            ..setDownloading(true)
            ..setPaused(false)
            ..setProgress(task.progress.toDouble());
          needsUIRefresh = true;
          break;

        case DownloadTaskStatus.paused:
          effectiveManager
            ..setDownloading(false)
            ..setPaused(true)
            ..setProgress(task.progress.toDouble());
          needsUIRefresh = true;
          break;

        case DownloadTaskStatus.complete:
          final bool fileActuallyExists =
              groundTruthDownloadStates[id] ?? false;

          if (fileActuallyExists) {
            effectiveManager
              ..setDownloading(false)
              ..setPaused(false)
              ..setDownloaded(true)
              ..setProgress(100);
            await prefs.remove('download_task_id_$id');
            needsUIRefresh = true;
          } else {
            debugPrint(
                "[DownloadController] Conflict found for '$id'. Task complete but file missing. Cleaning up.");
            // FIX: Ensure we clean up the zombie task from the downloader DB
            await FlutterDownloader.remove(
                taskId: task.taskId, shouldDeleteContent: false);
            await prefs.remove('download_task_id_$id');

            // FIX: Ensure we remove the 'downloaded' mark from user models if file is gone
            await UserModels.removeDownloadedModel(id);

            effectiveManager
              ..setDownloading(false)
              ..setDownloaded(false)
              ..setProgress(0);
            needsUIRefresh = true;
          }
          break;

        case DownloadTaskStatus.failed:
          debugPrint(
              "[DownloadController] Sync: Task '$id' failed while backgrounded.");
          effectiveManager
            ..setDownloading(false)
            ..setPaused(false)
            ..setProgress(0);

          if (isFreshStart) {
            debugPrint(
                "[DownloadController] Fresh Start Cleanup: Deleting stale failed task '$id'.");
            await FlutterDownloader.remove(
                taskId: task.taskId, shouldDeleteContent: true);
            await prefs.remove('download_task_id_$id');
            await UserModels.removeDownloadedModel(id);
          } else {
            // Keep for resume if simple lifecycle resume
            needsUIRefresh = true;
          }
          break;

        case DownloadTaskStatus.canceled:
          effectiveManager
            ..setDownloading(false)
            ..setPaused(false)
            ..setProgress(0);

          if (isFreshStart) {
            debugPrint(
                "[DownloadController] Fresh Start Cleanup: Deleting stale canceled task '$id'.");
            await FlutterDownloader.remove(
                taskId: task.taskId, shouldDeleteContent: true);
            await prefs.remove('download_task_id_$id');
            await UserModels.removeDownloadedModel(id);
          } else {
            await prefs.remove('download_task_id_$id');
          }
          needsUIRefresh = true;
          break;

        default: // undefined
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
            // Fix: Do NOT delete partial file or model record. Allow resume.
            // final partialFile = File(filePath);
            // if (await partialFile.exists()) { await partialFile.delete(); }
            // await UserModels.removeDownloadedModel(id);
            if (!completer.isCompleted) completer.completeError(e);
          } catch (deleteError) {
            debugPrint(
                "Could not delete partial file during error handling: $deleteError");
          } finally {
            onStateChange();
          }
        },
        onDownloadPaused: () {
          if (manager.isCancelled) return;
          manager
            ..setDownloading(false)
            ..setPaused(true);
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
      manager
        ..setDownloading(false)
        ..setPaused(false)
        ..setProgress(0);
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
