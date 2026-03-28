// lib/library/backend/remove.dart

import 'dart:developer' as dev;
import 'dart:io';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cortex/library/backend/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../l10n/app_localizations.dart';
// import '../../chat/services/storage.dart';
import '../../notifications/introvert.dart';
import 'data/database.dart';
import 'data/image.dart';
import 'data/service.dart';
import 'data/user.dart';

/// A static service class for handling the removal and uninstallation of models.
/// It orchestrates all necessary cleanup operations across different data sources.
class ModelRemoveService {
  // Private constructor to prevent instantiation.
  const ModelRemoveService._();

  /// Deletes a user-created model ('self_' or 'local_') from all data sources.
  /// This is a permanent, destructive action that includes server-side deletion.
  static Future<bool> deleteCustomModel({
    required String id,
    required String title,
    required IntrovertNotificationService notificationService,
    required AppLocalizations localizations,
    required ModelService modelService,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      dev.log('Cannot delete custom model: User not logged in.',
          name: 'ModelRemove');
      return false;
    }

    dev.log('--- [ModelRemoveService.deleteCustom] START for ID: $id ---',
        name: 'ModelRemove');
    try {
      // Step 1: De-register the model from the backend server.
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1')
          .httpsCallable('deleteCustomModel');
      await callable
          .call({'modelType': id.startsWith('self_') ? 'roleplay' : 'offline'});
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 1: De-registered from server.',
          name: 'ModelRemove');

      // Step 2: Remove the model's raw data from the local SQLite database.
      final db = await DatabaseHelper.instance.database;
      await db?.delete('models', where: 'id = ?', whereArgs: [id]);
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 2: Removed from local DB.',
          name: 'ModelRemove');

      // Step 3 & 4: Clean up application-level data (conversations and recents).
      // await ChatStorageService.deleteConversationsForModel(id);
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 3: Skipped deletion of associated conversations (Preserved per user request).',
          name: 'ModelRemove');

      // Step 5: If it was an offline model, clean up its GGUF file and download task.
      await _cleanupDownloadTaskAndFile(id);
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 4: Cleaned up GGUF file and download task (if any).',
          name: 'ModelRemove');

      // Step 6: Remove any cached cover images.
      await ModelImageCache.remove([id]);
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 5: Cleaned up image cache.',
          name: 'ModelRemove');

      // FINAL STEP: Remove the model from the central in-memory cache.
      // This will trigger a reactive UI update across the app.
      modelService.removeModelFromEntityCache(id);
      dev.log(
          '[ModelRemoveService.deleteCustom] Step 6: Removed model from live entity cache.',
          name: 'ModelRemove');

      notificationService.showNotification(
        message: localizations.modelRemovedSuccess(title),
        type: NotificationType.success,
      );

      dev.log('--- [ModelRemoveService.deleteCustom] SUCCESS for ID: $id ---',
          name: 'ModelRemove');
      return true;
    } catch (e, st) {
      dev.log(
          '--- [ModelRemoveService.deleteCustom] FAILED for ID: $id. Error: $e ---',
          name: 'ModelRemove',
          stackTrace: st);
      notificationService.showNotification(
        message: localizations.errorDeletingModel,
        type: NotificationType.error,
      );
      return false;
    }
  }

  /// Uninstalls a public, downloaded model from the local device.
  /// This is a local-only action and does not affect server data.
  /// FIX: Removed notificationService and localizations. The caller is now
  /// responsible for showing UI feedback. Returns true on success.
  static Future<bool> uninstallDownloadedModel({
    required String id,
    required String title,
  }) async {
    final logName = 'ModelUninstall';
    dev.log(
        '--- [ModelRemoveService.uninstall] START Uninstall Process for ID: $id ---',
        name: logName);

    try {
      // Step 1: Clean up the download task and the physical GGUF file.
      dev.log(
          '[ModelRemoveService.uninstall] Step 1: Cleaning up download task and physical file.',
          name: logName);
      await _cleanupDownloadTaskAndFile(id, title: title);

      // Step 2: Remove the persistent record of the download from UserModels.
      dev.log(
          '[ModelRemoveService.uninstall] Step 2: Removing in-app record from UserModels.',
          name: logName);
      await UserModels.removeDownloadedModel(id);

      // Step 3 & 4: Clean up application-level data (conversations and recents).
      dev.log(
          '[ModelRemoveService.uninstall] Step 3: Skipped deletion of associated conversations.',
          name: logName);
      // await ChatStorageService.deleteConversationsForModel(id);
      dev.log('--- [ModelRemoveService.uninstall] SUCCESS for ID: $id ---',
          name: logName);
      return true;
    } catch (e, st) {
      dev.log(
          '--- [ModelRemoveService.uninstall] FAILED for ID: $id. Error: $e ---',
          name: logName,
          stackTrace: st);
      // ERROR NOTIFICATION LOGIC REMOVED FROM HERE
      return false;
    }
  }

  /// A private helper to robustly clean up all artifacts of a download.
  /// It finds the task ID from SharedPreferences, removes the task from the
  /// downloader's database, and then manually deletes the file as a guarantee.
  ///
  /// This method now includes:
  /// 1. Primary deletion using the canonical ID-based path
  /// 2. Fallback deletion using legacy title-based path
  /// 3. Verification logging to confirm deletion success
  static Future<void> _cleanupDownloadTaskAndFile(String modelId,
      {String? title}) async {
    final logName = 'DownloadCleanup';
    dev.log('[Cleanup] Starting cleanup for model ID: $modelId, title: $title',
        name: logName);

    try {
      final prefs = await SharedPreferences.getInstance();
      final taskId = prefs.getString('download_task_id_$modelId');

      if (taskId != null) {
        dev.log(
            '[Cleanup] Found associated task ID: $taskId. Removing from FlutterDownloader.',
            name: logName);
        try {
          if (taskId.startsWith('dio_')) {
            // Already handled by File delete below, just ignore FlutterDownloader
          } else {
            await FlutterDownloader.remove(
                taskId: taskId, shouldDeleteContent: true);
          }
        } catch (e) {
          dev.log(
              '[Cleanup] FlutterDownloader.remove failed (may be already removed): $e',
              name: logName);
        }
        await prefs.remove('download_task_id_$modelId');
      } else {
        dev.log(
            '[Cleanup] No active task ID found in prefs. Proceeding with manual file deletion.',
            name: logName);
      }

      // 0. Get the canonical path from UserModels (The Source of Truth)
      // This is crucial because if we rely only on the ID, we might miss the file
      // if it was saved with a custom name or in a different location (though unlikely now).
      final userModels = await UserModels.loadDownloadedModelPaths();
      final recordedPath = userModels[modelId];

      if (recordedPath != null && await File(recordedPath).exists()) {
        final file = File(recordedPath);
        final size = await file.length();
        await file.delete();
        dev.log(
            '[Cleanup] Deleted file from UserModels record: $recordedPath (freed ${(size / 1024 / 1024).toStringAsFixed(2)} MB)',
            name: logName);
      }

      final filesDir = await ModelsBackendUtils.initializeDirectory();

      // PRIMARY PATH: Use the canonical ID-based path (current standard)
      final canonicalPath = ModelsBackendUtils.getFilePathById(
          filesDir: filesDir, modelId: modelId, modelTitle: title ?? modelId);
      final canonicalFile = File(canonicalPath);

      bool deletedCanonical = false;
      if (await canonicalFile.exists()) {
        final fileSize = await canonicalFile.length();
        await canonicalFile.delete();
        deletedCanonical = true;
        dev.log(
            '[Cleanup] Deleted canonical file at: $canonicalPath (freed ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
            name: logName);
      } else {
        dev.log('[Cleanup] Canonical file at $canonicalPath does not exist.',
            name: logName);
      }

      // FALLBACK PATH: Try legacy title-based path (for older downloads)
      if (!deletedCanonical && title != null && title != modelId) {
        final sanitizedTitle = title.replaceAll(RegExp(r'[/\\]'), '_');
        final legacyPath = '$filesDir/$sanitizedTitle.gguf';
        final legacyFile = File(legacyPath);

        if (await legacyFile.exists()) {
          final fileSize = await legacyFile.length();
          await legacyFile.delete();
          dev.log(
              '[Cleanup] Deleted LEGACY file at: $legacyPath (freed ${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
              name: logName);
        } else {
          dev.log('[Cleanup] Legacy file at $legacyPath also does not exist.',
              name: logName);
        }
      }

      // FINAL VERIFICATION: Ensure both paths no longer exist
      final canonicalStillExists = await canonicalFile.exists();
      if (canonicalStillExists) {
        dev.log(
            '[Cleanup] WARNING: Canonical file still exists after deletion attempt!',
            name: logName);
      } else {
        dev.log('[Cleanup] Verified: Canonical path is clear.', name: logName);
      }
    } catch (e) {
      dev.log(
          '[Cleanup] An error occurred during cleanup for $modelId, but uninstall will continue. Error: $e',
          name: logName);
    }
  }
}
