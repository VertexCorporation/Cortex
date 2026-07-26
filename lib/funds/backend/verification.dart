part of 'service.dart';

extension FundsVerification on FundsBackend {
  Future<void> _verifyAndCompletePurchase(
      PurchaseDetails purchaseDetails) async {
    String? verificationData;

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
      final callable = _functions.httpsCallable('verifyPurchase');
      await callable.call<dynamic>({
        'receiptData': verificationData,
        'productId': purchaseDetails.productID,
        'platform': defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'packageName': FundsBackend.appPackageName,
        'transactionId': purchaseDetails.purchaseID,
      });

      if (purchaseDetails.pendingCompletePurchase) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }

      AppDataState().markUserDataAsChanged();

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

      if (e.code == 'invalid-argument' ||
          e.code == 'not-found' ||
          e.code == 'already-exists') {
        log('Fatal error. Clearing from queue.', name: FundsBackend._logName);
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
        _notificationService?.showNotification(
          message: _localizations?.purchaseError ?? 'purchaseError',
          type: NotificationType.error,
          oneLine: false,
        );
      } else {
        _notificationService?.showNotification(
          message: _localizations?.verificationDelayed ?? 'verificationDelayed',
          type: NotificationType.error,
          oneLine: false,
        );
      }

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
