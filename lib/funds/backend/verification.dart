part of 'service.dart';

extension FundsVerification on FundsBackend {
  Future<void> _verifyAndCompletePurchase(
      PurchaseDetails purchaseDetails) async {
    final expectedUid = _auth.currentUser?.uid;
    if (expectedUid == null) return;

    // A store may replay the same purchase while verification is still pending.
    // Scope the guard to the account that started verification so an auth switch
    // cannot make a callback look like it belongs to the newly signed-in user.
    final receipt = purchaseDetails.verificationData.serverVerificationData;
    final key = '$expectedUid:${purchaseDetails.productID}:'
        '${purchaseDetails.purchaseID ?? receipt}';
    try {
      await _verificationGuard.run(key, () async {
        if (_disposed || _auth.currentUser?.uid != expectedUid) return;
        _notify();
        await _processPurchase(purchaseDetails, expectedUid);
      });
    } catch (e, stack) {
      await _crashlytics.recordError(e, stack,
          reason: 'Purchase processing failed', fatal: false);
    } finally {
      if (!_disposed) _notify();
    }
  }

  Future<void> _processPurchase(
      PurchaseDetails purchaseDetails, String expectedUid) async {
    String? verificationData;

    if (_auth.currentUser?.uid != expectedUid) {
      log('Purchase verification skipped because the signed-in account changed.',
          name: FundsBackend._logName);
      _setPurchasePending(false);
      return;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      verificationData = await _resolveIosReceiptBase64(purchaseDetails);

      if (verificationData == null) {
        log('iOS receipt is NULL. Cannot verify.', name: FundsBackend._logName);
        _notificationService?.showNotification(
          message:
              "Receipt missing. Please restart app or try Restore Purchases.",
          type: NotificationType.error,
          oneLine: false,
        );
        _setPurchasePending(false);
        return;
      }
    } else {
      final server =
          purchaseDetails.verificationData.serverVerificationData.trim();
      final local =
          purchaseDetails.verificationData.localVerificationData.trim();

      verificationData = !_isPlaceholderReceipt(server)
          ? server
          : (!_isPlaceholderReceipt(local) ? local : null);
    }

    if (verificationData == null ||
        verificationData.trim().isEmpty ||
        verificationData.trim() == "{}" ||
        verificationData.trim() == "[]") {
      log('Invalid verification data for ${purchaseDetails.productID}',
          name: FundsBackend._logName);
      _notificationService?.showNotification(
        message: "Validation failed. Please Restore Purchases.",
        type: NotificationType.error,
        oneLine: false,
      );
      _setPurchasePending(false);
      return;
    }

    void safeAddEvent() {
      if (!_disposed && !_purchaseCompletedController.isClosed) {
        _purchaseCompletedController.add(purchaseDetails.productID);
      }
    }

    try {
      // Re-check immediately before the callable so a queued purchase callback
      // cannot be verified against a different Firebase account.
      if (_auth.currentUser?.uid != expectedUid) {
        log('Purchase verification aborted after an account switch.',
            name: FundsBackend._logName);
        return;
      }

      final callable = _functions.httpsCallable('verifyPurchase');
      final result = await callable.call<dynamic>({
        'receiptData': verificationData,
        'productId': purchaseDetails.productID,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'packageName': FundsBackend.appPackageName,
        'transactionId': purchaseDetails.purchaseID,
      });

      // A resolved callable is not automatically a successful purchase. Require
      // the backend's explicit success contract before store finalization or UI.
      final data = result.data;
      if (data is! Map || data['success'] != true) {
        throw StateError('verifyPurchase returned no explicit success result');
      }

      final isAndroidConsumable =
          defaultTargetPlatform == TargetPlatform.android &&
              !FundsBackend._subscriptionIds.contains(purchaseDetails.productID);

      if (!isAndroidConsumable && purchaseDetails.pendingCompletePurchase) {
        // Android consumables are consumed by Fulcrum after verification. Do not
        // race the secure backend with a second client-side consume/ack request.
        // Subscriptions and Apple purchases still need normal store completion.
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      AppDataState().markUserDataAsChanged();

      // If the account changed while the server call was in flight, the server
      // still delivered to the account whose auth token made the request. Store
      // finalization above is therefore valid, but success UI must not leak into
      // the newly signed-in account.
      if (_auth.currentUser?.uid != expectedUid) {
        log('Purchase verified for the previous account; suppressing success UI.',
            name: FundsBackend._logName);
        return;
      }

      // Only fire the purchase-completed event for genuinely fresh
      // transactions (within the last 5 minutes).  Google Play's
      // purchaseStream replays existing subscriptions on every app
      // launch with PurchaseStatus.purchased / restored, so we must
      // NOT show any success UI for those stale replays.
      bool isRecentPurchase = true;
      if (purchaseDetails.transactionDate != null) {
        try {
          final rawDate = purchaseDetails.transactionDate!;
          DateTime? transactionTime;
          final dtInt = int.tryParse(rawDate);
          if (dtInt != null && dtInt > 0) {
            transactionTime = DateTime.fromMillisecondsSinceEpoch(dtInt);
          } else {
            transactionTime = DateTime.tryParse(rawDate);
          }

          if (transactionTime != null) {
            final diff = DateTime.now().difference(transactionTime);
            if (diff.inMinutes.abs() > 5) {
              isRecentPurchase = false;
            }
          }
        } catch (_) {}
      }

      if (isRecentPurchase) {
        safeAddEvent();
      }
    } on FirebaseFunctionsException catch (e, stack) {
      log('Verification failed: ${e.message} (Code: ${e.code})',
          name: FundsBackend._logName);

      // A generic error code does not prove that entitlement was delivered.
      // Keep the transaction recoverable until the server confirms success.
      _notificationService?.showNotification(
        message: _localizations?.verificationDelayed ?? 'verificationDelayed',
        type: NotificationType.error,
        oneLine: false,
      );

      await _crashlytics.recordError(e, stack,
          reason: 'Server returned HttpsError for ${purchaseDetails.productID}',
          fatal: false);
    } catch (e, stack) {
      log('Unexpected client verification error: $e',
          name: FundsBackend._logName);
      _notificationService?.showNotification(
        message: _localizations?.anErrorOccurred ?? 'anErrorOccurred',
        type: NotificationType.error,
        oneLine: false,
      );
      await _crashlytics.recordError(e, stack,
          reason: 'Unexpected client-side error during verifyPurchase',
          fatal: false);
    } finally {
      _setPurchasePending(false);
    }
  }
}
