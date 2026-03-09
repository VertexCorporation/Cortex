// lib/reconcile.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'library/backend/data/database.dart';

/// Reconciles local model counts (roleplay + offline) with remote counts
/// stored on the server, updating the backend if local counts are higher.
Future<void> reconcileLocalAndRemoteModelCounts() async {
  debugPrint(
    'Reconciliation: Starting model count consistency check...',
  );

  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  try {
    final db = await DatabaseHelper.instance.database;
    final localRoleplayModels =
        await db?.query('models', where: "id LIKE 'self_%'") ?? [];
    final localOfflineModels =
        await db?.query('models', where: "id LIKE 'local_%'") ?? [];

    final int localRoleplayCount = localRoleplayModels.length;
    final int localOfflineCount = localOfflineModels.length;

    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    if (!userDoc.exists) return;

    final remoteData = userDoc.data()!;
    final int remoteRoleplayCount = remoteData['roleplayModelCount'] ?? 0;
    final int remoteOfflineCount = remoteData['offlineModelCount'] ?? 0;

    if (localRoleplayCount > remoteRoleplayCount ||
        localOfflineCount > remoteOfflineCount) {
      debugPrint(
        'Reconciliation: Local count is higher. Syncing up with server.',
      );
      final callable = FirebaseFunctions.instanceFor(
        region: 'europe-west1',
      ).httpsCallable('reconcileModelCounts');

      await callable.call({
        'localRoleplayCount': localRoleplayCount,
        'localOfflineCount': localOfflineCount,
      });

      debugPrint('Reconciliation: Server counts updated.');
    } else {
      debugPrint(
        'Reconciliation: Counts are in sync or server is ahead. No action needed.',
      );
    }
  } catch (e) {
    debugPrint(
      "Reconciliation: Error during model count sync: $e",
    );
  }
}

/// Performs a one-shot reconciliation and verification of in-app purchases
/// with the backend, restoring purchases and verifying them on the server.
Future<void> reconcileAndSyncPurchases() async {
  debugPrint(
    'Purchase Sync: Starting full purchase reconciliation.',
  );

  final InAppPurchase iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? streamSubscription;

  try {
    final bool isAvailable = await iap.isAvailable();
    if (!isAvailable) {
      debugPrint(
        'Purchase Sync: Billing service is not available. Skipping reconciliation.',
      );
      return;
    }

    if (FirebaseAuth.instance.currentUser == null) {
      debugPrint('Purchase Sync: No user logged in. Skipping.');
      return;
    }

    final completer = Completer<void>();
    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    streamSubscription = iap.purchaseStream.listen(
      (purchaseDetailsList) async {
        if (purchaseDetailsList.isEmpty && !completer.isCompleted) {
          completer.complete();
          return;
        }

        for (final purchase in purchaseDetailsList) {
          final status = purchase.status;
          if (status == PurchaseStatus.purchased ||
              status == PurchaseStatus.restored) {
            try {
              final callable = functions.httpsCallable('verifyPurchase');
              await callable.call<dynamic>({
                'receiptData': purchase.verificationData.serverVerificationData,
                'productId': purchase.productID,
                'platform': defaultTargetPlatform.name.toLowerCase(),
              });

              if (purchase.pendingCompletePurchase) {
                await iap.completePurchase(purchase);
              }
            } catch (e) {
              debugPrint(
                'Purchase Sync: Server verification failed for '
                '${purchase.productID}. Error: $e',
              );
            }
          }
        }

        if (!completer.isCompleted) {
          completer.complete();
        }
      },
      onDone: () {
        if (!completer.isCompleted) completer.complete();
      },
      onError: (e) {
        if (!completer.isCompleted) completer.completeError(e);
      },
    );

    await iap.restorePurchases();
    await Future.any(
      [
        completer.future,
        Future.delayed(const Duration(seconds: 15)),
      ],
    );
  } catch (e) {
    debugPrint(
      "Purchase Sync: A critical error occurred: $e",
    );
  } finally {
    await streamSubscription?.cancel();
    debugPrint("Purchase Sync: Reconciliation listener cancelled.");
  }
}
