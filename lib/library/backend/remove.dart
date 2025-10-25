// remove.dart

import 'dart:io';
import 'dart:developer' as dev;
import 'package:flutter/material.dart'; // For BuildContext
import 'package:provider/provider.dart'; // For Provider
import 'package:cortex/l10n/app_localizations.dart'; // For localizations
import 'package:cortex/models/backend/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../../chat/services/storage.dart';
import '../../notifications.dart'; // For NotificationService
import 'data/data.dart';
import 'data/database.dart';
import 'data/user.dart';
import 'download.dart';

class ModelRemoveService {
  const ModelRemoveService._();

  /// Deletes a user-created model ('self_' or 'local_').
  /// It requires a BuildContext to send notifications via Provider.
  static Future<bool> deleteCustomModel({
    required String id,
    required String title,
    required BuildContext context,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      dev.log('Cannot delete custom model: User not logged in.', name: 'ModelRemove');
      return false;
    }

    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    dev.log('--- [ModelRemoveService.deleteCustom] START for ID: $id ---', name: 'ModelRemove');
    try {
      final callable = FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable('deleteCustomModel');
      await callable.call({'modelType': id.startsWith('self_') ? 'roleplay' : 'offline'});
      dev.log('[ModelRemoveService.deleteCustom] Step 1/4: De-registered from server.', name: 'ModelRemove');

      final db = await DatabaseHelper.instance.database;
      await db.delete('models', where: 'id = ?', whereArgs: [id]);
      dev.log('[ModelRemoveService.deleteCustom] Step 2/4: Removed from local DB.', name: 'ModelRemove');

      await ChatStorageService.deleteConversationsForModel(id);
      dev.log('[ModelRemoveService.deleteCustom] Step 3/4: Deleted associated conversations.', name: 'ModelRemove');

      final downloadedModelPaths = await UserModels.loadDownloadedModelPaths();
      final ggufFilePath = downloadedModelPaths[id];
      if (ggufFilePath != null && ggufFilePath.isNotEmpty) {
        final file = File(ggufFilePath);
        if (await file.exists()) await file.delete();
      }
      await UserModels.removeDownloadedModel(id);
      await ModelData.removeCachedImages([id]);
      dev.log('[ModelRemoveService.deleteCustom] Step 4/4: Cleaned up local files.', name: 'ModelRemove');

      ModelData.removeModelFromCache(id);
      dev.log('[ModelRemoveService.deleteCustom] Step 5/5: Removed model from live cache and notified listeners.', name: 'ModelRemove');


      notificationService.showNotification(
        message: localizations.modelRemovedSuccess(title),
        isSuccess: true,
      );

      dev.log('--- [ModelRemoveService.deleteCustom] SUCCESS for ID: $id ---', name: 'ModelRemove');
      return true;

    } catch (e, st) {
      dev.log('--- [ModelRemoveService.deleteCustom] FAILED for ID: $id. Error: $e ---', name: 'ModelRemove', stackTrace: st);

      notificationService.showNotification(
        message: localizations.errorDeletingModel,
        isSuccess: false,
      );
      return false;
    }
  }

  /// Uninstalls a public, downloaded model from the local device.
  /// This operation is now atomic: the in-app record is only removed if the
  /// physical file is successfully deleted or already absent.
  static Future<bool> uninstallDownloadedModel({
    required String id,
    required String title,
    required BuildContext context,
  }) async {
    // Get service references before any async gaps to avoid context issues.
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    final downloadedModelsManager = Provider.of<DownloadedModelsManager>(context, listen: false);
    final localizations = AppLocalizations.of(context)!;

    final logName = 'ModelUninstall';
    dev.log('--- [ModelRemoveService.uninstall] START Uninstall Process for ID: $id ---', name: logName);

    try {
      // Step 1: Get the canonical file path. (Unchanged)
      dev.log('[ModelRemoveService.uninstall] Step 1/4: Constructing canonical file path.', name: logName);
      final filesDir = await Utils.initializeDirectory();
      final String ggufFilePath = Utils.getFilePathById(filesDir: filesDir, modelId: id, modelTitle: title);
      final file = File(ggufFilePath);

      // Step 2: Attempt to delete the physical file first. (Unchanged)
      dev.log('[ModelRemoveService.uninstall] Step 2/4: Attempting to delete physical file.', name: logName);
      if (await file.exists()) {
        try {
          await file.delete();
          dev.log('[ModelRemoveService.uninstall]   - SUCCESS: Deleted file at $ggufFilePath', name: logName);
        } catch (e) {
          dev.log('[ModelRemoveService.uninstall]   - FAILED: Could not delete file. Aborting uninstall. Error: $e', name: logName);
          throw Exception('Failed to delete model file on disk.');
        }
      } else {
        dev.log('[ModelRemoveService.uninstall]   - INFO: File did not exist at $ggufFilePath. No deletion needed.', name: logName);
      }

      // Step 3: Remove the in-app record from SharedPreferences. (Unchanged)
      dev.log('[ModelRemoveService.uninstall] Step 3/4: Physical file confirmed gone. Removing in-app record.', name: logName);
      await UserModels.removeDownloadedModel(id);

      // Step 4: Delete associated conversations. (Unchanged)
      dev.log('[ModelRemoveService.uninstall] Step 4/4: Deleting all associated conversations.', name: logName);
      await ChatStorageService.deleteConversationsForModel(id);

      // Step 5: NOW, after all file/record operations are complete, notify the UI.
      // This is the correct moment to trigger a refresh.
      dev.log('[ModelRemoveService.uninstall] Step 5/5: Notifying listeners of the state change.', name: logName);
      downloadedModelsManager.notifyListenersOfChange();

      // Show the success message to the user.
      notificationService.showNotification(
        message: localizations.modelRemovedSuccess(title),
        isSuccess: true,
      );

      dev.log('--- [ModelRemoveService.uninstall] SUCCESS for ID: $id ---', name: logName);
      return true;

    } catch (e, st) {
      // Error handling remains unchanged.
      dev.log('--- [ModelRemoveService.uninstall] FAILED for ID: $id. Error: $e ---', name: logName, stackTrace: st);
      notificationService.showNotification(
        message: localizations.errorDeletingModel,
        isSuccess: false,
      );
      return false;
    }
  }
}