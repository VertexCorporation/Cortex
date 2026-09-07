part of 'service.dart';

extension FundsVerification on FundsBackend {
  Future<void> _verifyAndCompletePurchase(
      PurchaseDetails purchaseDetails) async {
    // A store may replay the same purchase while verification is still pending.
    final receipt = purchaseDetails.verificationData.serverVerificationData;
    final key = '${purchaseDetails.productID}:'
        '${purchaseDetails.purchaseID ?? receipt}';
    try {
      await _verificationGuard.run(key, () async {
        if (_disposed || _auth.currentUser == null) return;
        _notify();
        await _processPurchase(purchaseDetails);
      });
    } catch (e, stack) {
      await _crashlytics.recordError(e, stack,
          reason: 'Purchase processing failed', fatal: false);
    } finally {
      if (!_disposed) _notify();
    }
  }

  Future<void> _processPurchase(PurchaseDetails purchaseDetails) async {
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

      // Do not consume Android credits until server verification has succeeded.
      if (defaultTargetPlatform == TargetPlatform.android &&
          !FundsBackend._subscriptionIds.contains(purchaseDetails.productID)) {
        final android = _inAppPurchase
            .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
        final result = await android.consumePurchase(purchaseDetails);
        if (result.responseCode != BillingResponse.ok) {
          throw StateError('Could not consume verified purchase: '
              '${result.responseCode}');
        }
      } else if (purchaseDetails.pendingCompletePurchase) {
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
