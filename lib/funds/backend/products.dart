part of 'service.dart';

extension FundsProducts on FundsBackend {
  Future<void> _fetchProductDetails() async {
    if (AppDataState().needsRefresh) {
      CacheService.invalidate(CacheKey.premiumProducts);
    }

    final cachedProducts =
    CacheService.get<List<ProductDetails>>(CacheKey.premiumProducts);

    if (cachedProducts != null && cachedProducts.isNotEmpty) {
      log('Cache hit! Initializing with cached product data.', name: FundsBackend._logName);
      _products = cachedProducts;
      _errorMessage = null;
      _setLoading(false);
    } else {
      _setLoading(true);
    }

    if (!kReleaseMode) {
      log('Running in Test Mode. Using mock product data.', name: FundsBackend._logName);
      await Future.delayed(const Duration(milliseconds: 800));
      _products = FundsBackend._mockProducts;
      CacheService.set(CacheKey.premiumProducts, FundsBackend._mockProducts);
      _errorMessage = null;
      _setLoading(false);
      return;
    }

    if (!await InternetService().hasInternet()) {
      _setError(_localizations.noInternetConnection);
      return;
    }

    if (!await _inAppPurchase.isAvailable()) {
      _setError(_localizations.anErrorOccurred);
      return;
    }

    try {
      final allProductIds = {...FundsBackend._subscriptionIds};
      final response = await _inAppPurchase.queryProductDetails(allProductIds);

      if (response.error != null) {
        throw Exception('Store error: ${response.error!.message}');
      }

      if (response.productDetails.isEmpty) {
        log('Store returned zero products.', name: FundsBackend._logName);
        throw Exception(
            "Store returned no products. This implies a Store connection issue.");
      }

      _products = response.productDetails;
      CacheService.set(CacheKey.premiumProducts, _products);
      _errorMessage = null;
    } catch (e, stack) {
      log('Error fetching product details: $e', name: FundsBackend._logName, error: e);

      if (e.toString().contains("Store returned no products")) {
        _setError(_localizations.noProductsFound);
      } else {
        await _crashlytics.recordError(
          e,
          stack,
          reason: 'Failed in _fetchProductDetails catch block.',
          fatal: true,
        );
        _setError(_localizations.anErrorOccurred);
      }
    } finally {
      _setLoading(false);
    }
  }
}
