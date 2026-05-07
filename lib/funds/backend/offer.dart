part of 'service.dart';

extension FundsSpecialOffer on FundsBackend {
  /// Loads cached state into this instance (call after checking isPreloaded).
  void loadFromCache() {
    final logName = '${FundsBackend._logName}.loadFromCache';
    final cachedProducts = CacheService.get<List<ProductDetails>>(CacheKey.premiumProducts);
    final cachedState = CacheService.get<Map<String, dynamic>>(CacheKey.premiumScreenState);

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      _products = cachedProducts;
      _errorMessage = null;
      log('Loaded ${cachedProducts.length} products from cache', name: logName);
    }

    if (cachedState != null) {
      _isSpecialOfferActive = cachedState['specialOfferActive'] ?? false;
      _specialOfferExpiresAt = cachedState['specialOfferExpiresAt'] as int?;
      log('Loaded special offer state: active=$_isSpecialOfferActive', name: logName);
    }

    _setLoading(false);
    _notify();
  }

  Future<void> checkOrStartSpecialOffer() async {
    final user = _auth.currentUser;
    if (user == null) {
      log('Cannot check special offer: User not authenticated.',
          name: FundsBackend._logName);
      return;
    }

    try {
      final callable = _functions.httpsCallable('checkOrStartSpecialOffer');
      final result = await callable.call<Map<String, dynamic>>({});

      final data = result.data;
      final status = data['status'] as String?;
      final expiresAt = data['expiresAt'] as int?;

      if (status == 'active' && expiresAt != null) {
        _isSpecialOfferActive = true;
        _specialOfferExpiresAt = expiresAt;
        log('Special offer ACTIVE. Expires at: ${DateTime
            .fromMillisecondsSinceEpoch(expiresAt)}',
            name: FundsBackend._logName);
      } else {
        _isSpecialOfferActive = false;
        _specialOfferExpiresAt = null;
        log('Special offer in COOLDOWN or unavailable.', name: FundsBackend._logName);
      }

      _notify();
    } on FirebaseFunctionsException catch (e) {
      log('Special offer check failed: ${e.message}', name: FundsBackend._logName, error: e);
      _isSpecialOfferActive = false;
      _specialOfferExpiresAt = null;
    } catch (e, stack) {
      log('Unexpected error checking special offer: $e',
          name: FundsBackend._logName, error: e);
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Failed to check or start special offer.',
        fatal: false,
      );
      _isSpecialOfferActive = false;
      _specialOfferExpiresAt = null;
    }
  }
}
