part of 'service.dart';

extension FundsPurchase on FundsBackend {
  Future<void> purchase(ProductDetails product) async {
    if (_isPurchasePending) {
      log('Purchase attempt ignored: Another purchase is already pending.',
          name: FundsBackend._logName);
      return;
    }

    _setPurchasePending(true);

    final user = _auth.currentUser;
    if (user == null) {
      log('Purchase blocked: User is not authenticated.',
          name: FundsBackend._logName);
      _setPurchasePending(false);
      return;
    }

    ProductDetails freshProductDetails;
    try {
      if (!await _inAppPurchase.isAvailable()) {
        throw Exception(
            "Billing service is not available at the moment of purchase.");
      }

      final response = await _inAppPurchase.queryProductDetails({product.id});
      if (response.error != null) {
        throw Exception(
            'Store error while refreshing product: ${response.error!.message}');
      }
      if (response.productDetails.isEmpty) {
        throw Exception(
            'Product with ID ${product.id} not found on the store. It might have been removed.');
      }

      freshProductDetails = response.productDetails.first;
      log('Successfully refreshed product details for ${product.id}',
          name: FundsBackend._logName);
    } catch (e) {
      log('Could not refresh product details before purchase: $e',
          name: FundsBackend._logName, error: e);
      _notificationService?.showNotification(
        message: _localizations?.productNotFound ?? 'productNotFound',
        type: NotificationType.error,
        oneLine: false,
      );
      _setPurchasePending(false);
      return;
    }

    await _crashlytics.setUserIdentifier(user.uid);
    await _crashlytics.setCustomKey('iap_product_id', freshProductDetails.id);

    PurchaseParam purchaseParam;

    if (defaultTargetPlatform == TargetPlatform.android) {
      if (freshProductDetails is! GooglePlayProductDetails) {
        log('Product details are not GooglePlayProductDetails.',
            name: FundsBackend._logName);
        _notificationService?.showNotification(
          message: _localizations?.anErrorOccurred ?? 'anErrorOccurred',
          type: NotificationType.error,
          oneLine: false,
        );
        _setPurchasePending(false);
        return;
      }
      final googlePlayProductDetails = freshProductDetails;
      final offerToken = googlePlayProductDetails.offerToken;

      final bool isSubscription =
          FundsBackend._subscriptionIds.contains(googlePlayProductDetails.id);

      if (isSubscription) {
        if (offerToken == null || offerToken.isEmpty) {
          log('Subscription ${googlePlayProductDetails.id} is missing a valid offerToken.',
              name: FundsBackend._logName);
          _notificationService?.showNotification(
              message:
                  _localizations?.cacheIsNotUpToDate ?? 'cacheIsNotUpToDate',
              type: NotificationType.error,
              oneLine: false);
          _setPurchasePending(false);
          return;
        }

        ChangeSubscriptionParam? changeParam;

        if (_activeSubscriptionProductId != null &&
            _activeSubscriptionProductId!.isNotEmpty) {
          log('Detected active subscription: $_activeSubscriptionProductId. Attempting upgrade flow.',
              name: FundsBackend._logName);

          GooglePlayPurchaseDetails? oldPurchase;

          try {
            final androidAddition = _inAppPurchase
                .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            final QueryPurchaseDetailsResponse pastPurchasesResponse =
                await androidAddition.queryPastPurchases();

            if (pastPurchasesResponse.error == null) {
              try {
                oldPurchase = pastPurchasesResponse.pastPurchases
                    .map((e) => e)
                    .firstWhere((p) =>
                        p.productID == _activeSubscriptionProductId &&
                        p.status == PurchaseStatus.purchased);
              } catch (_) {}
            }
          } catch (e) {
            log('Failed to query past purchases for upgrade flow: $e',
                name: FundsBackend._logName);
          }

          if (oldPurchase != null) {
            log('Found old purchase token. Configuring replacement mode (Upgrade).',
                name: FundsBackend._logName);
            changeParam = ChangeSubscriptionParam(
              oldPurchaseDetails: oldPurchase,
              replacementMode: ReplacementMode.withTimeProration,
            );
          } else {
            log('CRITICAL: Sync mismatch. DB says active sub, but local store has no token. Blocking to prevent double billing.',
                name: FundsBackend._logName);

            _notificationService?.showNotification(
              message:
                  "Please tap 'Restore Purchases' first to sync your account.",
              type: NotificationType.error,
              oneLine: false,
            );
            _setPurchasePending(false);
            return;
          }
        }

        purchaseParam = GooglePlayPurchaseParam(
          productDetails: googlePlayProductDetails,
          applicationUserName: user.uid,
          offerToken: offerToken,
          changeSubscriptionParam: changeParam,
        );
      } else {
        purchaseParam = PurchaseParam(
          productDetails: freshProductDetails,
          applicationUserName: user.uid,
        );
      }
    } else {
      purchaseParam = PurchaseParam(
        productDetails: freshProductDetails,
        applicationUserName: user.uid,
      );
    }

    try {
      if (FundsBackend._subscriptionIds.contains(product.id)) {
        await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      } else {
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      }
    } catch (e, stack) {
      log('Error initiating purchase flow: $e',
          name: FundsBackend._logName, error: e);

      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user canceled') ||
          errorString.contains('canceled') ||
          errorString.contains('storekiterror')) {
      } else {
        _notificationService?.showNotification(
            message: _localizations?.anErrorOccurred ?? 'anErrorOccurred',
            type: NotificationType.error);
        await _crashlytics.recordError(e, stack,
            reason: 'Error on buy call', fatal: false);
      }
      _setPurchasePending(false);
    }
  }

  Future<void> manageSubscription() async {
    final user = _auth.currentUser;
    if (user == null) return;

    Uri url;
    if (Platform.isIOS) {
      url = Uri.parse('https://apps.apple.com/account/subscriptions');
    } else {
      url = Uri.parse(
          'https://play.google.com/store/account/subscriptions?package=${FundsBackend.appPackageName}');
    }

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      log('Could not launch subscription management URL.',
          name: FundsBackend._logName);
    }
  }

  Future<void> restorePurchases() async {
    if (_isPurchasePending) return;
    _setPurchasePending(true);

    try {
      log('Restoring purchases...', name: FundsBackend._logName);
      await _inAppPurchase.restorePurchases();

      Future.delayed(const Duration(seconds: 4), () {
        if (_isPurchasePending) {
          log('Restore timeout. Resetting UI.', name: FundsBackend._logName);
          _setPurchasePending(false);
        }
      });
    } catch (e) {
      log('Restore failed: $e', name: FundsBackend._logName, error: e);
      _notificationService?.showNotification(
        message: _localizations?.anErrorOccurred ?? 'anErrorOccurred',
        type: NotificationType.error,
      );
      _setPurchasePending(false);
    }
  }

  void _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          _setPurchasePending(true);
          break;
        case PurchaseStatus.error:
          _handleFailedPurchase(purchaseDetails);
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyAndCompletePurchase(purchaseDetails);
          break;
        case PurchaseStatus.canceled:
          _handleCanceledPurchase(purchaseDetails);
          break;
      }
    }
  }

  void _handleFailedPurchase(PurchaseDetails purchaseDetails) {
    final errorCode = purchaseDetails.error?.code ?? '';
    final errorMessage = purchaseDetails.error?.message ??
        _localizations?.purchaseStreamError ??
        'purchaseStreamError';
    final errorString = purchaseDetails.error?.toString().toLowerCase() ?? '';

    final isUserCancelled =
        errorCode == 'canceled' || errorString.contains('user canceled');
    final isInsufficientFunds = errorCode == 'purchase_error' &&
        (errorMessage.contains('insufficient funds') ||
            errorMessage.contains('Payment declined') ||
            errorString.contains('billingunavailable'));
    final isAlreadyOwned = errorCode == 'item_already_owned';

    if (!isUserCancelled && !isInsufficientFunds && !isAlreadyOwned) {
      log('Purchase error: $errorMessage',
          name: FundsBackend._logName, error: purchaseDetails.error);
    }

    _notificationService?.showNotification(
      message: isUserCancelled ? "Cancelled" : errorMessage,
      type: isUserCancelled ? NotificationType.neutral : NotificationType.error,
      oneLine: false,
    );

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }

    _setPurchasePending(false);
  }

  void _onPurchaseStreamError(dynamic error, StackTrace? stack) {
    log('Purchase Stream Error: $error',
        name: FundsBackend._logName, error: error);
    _notificationService?.showNotification(
      message: _localizations?.purchaseStreamError ?? 'purchaseStreamError',
      type: NotificationType.error,
      oneLine: false,
    );
    _setPurchasePending(false);
  }

  void _handleCanceledPurchase(PurchaseDetails d) {
    if (d.pendingCompletePurchase) _inAppPurchase.completePurchase(d);
    _setPurchasePending(false);
  }
}
