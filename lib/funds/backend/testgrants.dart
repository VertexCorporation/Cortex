part of 'service.dart';

/// Simulated (test) purchase flow — the client half of the debug-only test
/// checkout. Mirrors how RevenueCat sandbox / StoreKit test transactions let
/// you exercise the real purchase lifecycle without billing.
///
/// Security model: the debug-only availability getter below shapes UX only.
/// Every call is re-checked server-side (Fulcrum `testgrants.js` requires
/// `isVertex === true` and refuses to touch non-test entitlements), so a
/// tampered client gains nothing.
extension FundsTestGrants on FundsBackend {
  /// Whether the simulated purchase flow is offered in this build: debug
  /// builds signed into an `isVertex` test account. Release builds and
  /// regular accounts always keep the real store flow.
  bool get isTestPurchaseAvailable =>
      kDebugMode && (_userProvider?.isVertex ?? false);

  /// Runs the simulated checkout for [productId] by calling the Fulcrum
  /// `grantTestSubscription` callable. On success the server has written a
  /// short-lived `internal_test` entitlement to `users/{uid}.subscription`;
  /// the normal UserProvider → backend chain refreshes all gates/credits,
  /// and [onTestGrantCompleted] fires for the purchase-complete UX.
  ///
  /// Returns whether the grant succeeded.
  Future<bool> purchaseTestSubscription(
    String productId, {
    int durationMinutes = FundsBackend.testGrantDurationMinutes,
  }) async {
    if (_isPurchasePending) {
      log('Test purchase attempt ignored: another purchase is pending.',
          name: FundsBackend._logName);
      return false;
    }

    final user = _auth.currentUser;
    if (user == null) {
      log('Test purchase blocked: user is not authenticated.',
          name: FundsBackend._logName);
      return false;
    }

    _setPurchasePending(true);

    try {
      await _crashlytics.setUserIdentifier(user.uid);
      await _crashlytics.setCustomKey('iap_test_product_id', productId);

      final callable = _functions.httpsCallable('grantTestSubscription');
      final result = await callable.call<dynamic>({
        'productId': productId,
        'durationMinutes': durationMinutes,
      });
      final data = result.data;
      final expiresAtMillis = data is Map ? data['expiresAtMillis'] : null;
      log(
        'Test subscription granted for $productId '
        '(expires at: $expiresAtMillis).',
        name: FundsBackend._logName,
      );

      // The server write is authoritative; nudge the shared user-data
      // listener chain the same way a verified store purchase does.
      AppDataState().markUserDataAsChanged();

      if (!_disposed && !_testGrantCompletedController.isClosed) {
        _testGrantCompletedController.add(productId);
      }

      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.testPurchaseSuccess,
          type: NotificationType.success,
          oneLine: false,
        );
      }

      return true;
    } on FirebaseFunctionsException catch (e, stack) {
      log('Test purchase failed: ${e.message} (Code: ${e.code})',
          name: FundsBackend._logName);
      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.testPurchaseError(e.message ?? e.code),
          type: NotificationType.error,
          oneLine: false,
        );
      }
      await _crashlytics.recordError(e, stack,
          reason: 'grantTestSubscription failed for $productId', fatal: false);
      return false;
    } catch (e, stack) {
      log('Unexpected test purchase error: $e',
          name: FundsBackend._logName, error: e);
      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.anErrorOccurred,
          type: NotificationType.error,
          oneLine: false,
        );
      }
      await _crashlytics.recordError(e, stack,
          reason: 'Unexpected error during test purchase', fatal: false);
      return false;
    } finally {
      _setPurchasePending(false);
    }
  }

  /// Cancels the active test subscription immediately via the Fulcrum
  /// `revokeTestSubscription` callable. Only test entitlements can ever be
  /// revoked this way — the server rejects anything else.
  ///
  /// Returns whether the revoke succeeded.
  Future<bool> revokeTestSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    try {
      final callable = _functions.httpsCallable('revokeTestSubscription');
      await callable.call<dynamic>({});

      AppDataState().markUserDataAsChanged();

      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.testPurchaseRevoked,
          type: NotificationType.neutral,
          oneLine: false,
        );
      }

      log('Test subscription revoked.', name: FundsBackend._logName);
      return true;
    } on FirebaseFunctionsException catch (e, stack) {
      log('Test revoke failed: ${e.message} (Code: ${e.code})',
          name: FundsBackend._logName);
      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.testPurchaseError(e.message ?? e.code),
          type: NotificationType.error,
          oneLine: false,
        );
      }
      await _crashlytics.recordError(e, stack,
          reason: 'revokeTestSubscription failed', fatal: false);
      return false;
    } catch (e, stack) {
      log('Unexpected test revoke error: $e',
          name: FundsBackend._logName, error: e);
      if (_localizations != null) {
        _notificationService?.showNotification(
          message: _localizations!.anErrorOccurred,
          type: NotificationType.error,
          oneLine: false,
        );
      }
      await _crashlytics.recordError(e, stack,
          reason: 'Unexpected error during test revoke', fatal: false);
      return false;
    }
  }
}
