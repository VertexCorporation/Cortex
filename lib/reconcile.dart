// lib/reconcile.dart

import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'library/backend/data/database.dart';
import 'purchase_sync_queue.dart';

Future<void>? _purchaseSync;

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
    if (db == null) return;
    // Count in SQLite instead of transferring every encrypted JSON payload
    // across the platform channel. GLOB treats the underscore literally.
    final counts = await db.rawQuery('''
      SELECT COUNT(CASE WHEN id GLOB 'self_*' THEN 1 END) AS roleplay,
             COUNT(CASE WHEN id GLOB 'local_*' THEN 1 END) AS offline
      FROM models
    ''');
    final localRoleplayCount = (counts.single['roleplay'] as num).toInt();
    final localOfflineCount = (counts.single['offline'] as num).toInt();
    if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;

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

      if (FirebaseAuth.instance.currentUser?.uid != user.uid) return;
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
Future<void> reconcileAndSyncPurchases() {
  // Startup/resume callers share one listener and restore operation.
  return _purchaseSync ??= _runPurchaseSync().whenComplete(() {
    _purchaseSync = null;
  });
}

Future<void> _runPurchaseSync() async {
  debugPrint(
    'Purchase Sync: Starting full purchase reconciliation.',
  );

  final InAppPurchase iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? streamSubscription;
  StreamSubscription<User?>? authSubscription;
  final auth = FirebaseAuth.instance;
  final userId = auth.currentUser?.uid;
  if (userId == null) return;
  bool sessionActive = true;
  final ended = Completer<void>();
  void endSession() {
    sessionActive = false;
    if (!ended.isCompleted) ended.complete();
  }
  final queue = PurchaseSyncQueue(
    isSessionCurrent: () => sessionActive && auth.currentUser?.uid == userId,
  );
  authSubscription = auth.authStateChanges().listen((user) {
    if (user?.uid != userId) endSession();
  }, onError: (Object _) => endSession());

  try {
    final bool isAvailable = await iap.isAvailable();
    if (!isAvailable) {
      debugPrint(
        'Purchase Sync: Billing service is not available. Skipping reconciliation.',
      );
      return;
    }

    if (!sessionActive || auth.currentUser?.uid != userId) {
      debugPrint('Purchase Sync: No user logged in. Skipping.');
      return;
    }

    final functions = FirebaseFunctions.instanceFor(region: 'europe-west1');

    streamSubscription = iap.purchaseStream.listen(
      (purchaseDetailsList) {
        for (final purchase in purchaseDetailsList) {
          final status = purchase.status;
          if (status == PurchaseStatus.purchased ||
              status == PurchaseStatus.restored) {
            final receipt = purchase.verificationData.serverVerificationData;
            if (receipt.isEmpty) continue;
            // Never retain or log a raw receipt as the duplicate key.
            final key = sha256.convert(utf8.encode(jsonEncode([
              purchase.productID,
              purchase.purchaseID,
              receipt,
            ]))).toString();
            unawaited(queue.submit(
              key: key,
              verify: () async {
                final callable = functions.httpsCallable('verifyPurchase');
                await callable.call<dynamic>({
                  'receiptData': receipt,
                  'productId': purchase.productID,
                  'platform': defaultTargetPlatform.name.toLowerCase(),
                });
              },
              complete: () async {
                if (purchase.pendingCompletePurchase) {
                  await iap.completePurchase(purchase);
                }
              },
            ).catchError((Object _) {
              // Exceptions can contain receipt data. Do not log their payload.
              if (kDebugMode) debugPrint('Purchase Sync: Verification deferred.');
            }));
          }
        }
      },
      onDone: () {
        if (!ended.isCompleted) ended.complete();
      },
      onError: (Object _) => endSession(),
    );

    await iap.restorePurchases();
    await Future.any(
      [
        ended.future,
        Future.delayed(const Duration(seconds: 15)),
      ],
    );
  } catch (_) {
    if (kDebugMode) debugPrint('Purchase Sync: Reconciliation deferred.');
  } finally {
    await streamSubscription?.cancel();
    // Finish accepted batches before removing the account guard. The first
    // batch (including an empty batch) is not a store restore-complete signal.
    await queue.drained;
    sessionActive = false;
    await authSubscription?.cancel();
    debugPrint("Purchase Sync: Reconciliation listener cancelled.");
  }
}
