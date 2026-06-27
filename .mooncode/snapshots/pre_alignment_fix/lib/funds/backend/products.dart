part of 'service.dart';

class TrialInfo {
  final String days;
  final String truePrice;
  final double trueRawPrice;

  TrialInfo(this.days, this.truePrice, this.trueRawPrice);
}

TrialInfo? getTrialInfo(ProductDetails? product) {
  if (product == null) return null;
  try {
    if (defaultTargetPlatform == TargetPlatform.android &&
        product is GooglePlayProductDetails) {
      final offers = product.productDetails.subscriptionOfferDetails;
      if (offers != null && offers.isNotEmpty) {
        for (final offer in offers) {
          final phases = offer.pricingPhases;
          if (phases.length > 1) {
            final firstPhase = phases.first;
            final lastPhase = phases.last;
            if (firstPhase.priceAmountMicros == 0) {
              int days = 0;
              final period = firstPhase.billingPeriod;
              if (period.endsWith('D')) {
                days =
                    int.tryParse(period.substring(1, period.length - 1)) ?? 0;
              } else if (period.endsWith('W')) {
                days = (int.tryParse(period.substring(1, period.length - 1)) ??
                    0) * 7;
              } else if (period.endsWith('M')) {
                days = (int.tryParse(period.substring(1, period.length - 1)) ??
                    0) * 30;
              }
              if (days > 0) {
                return TrialInfo(days.toString(), lastPhase.formattedPrice, lastPhase.priceAmountMicros / 1000000);
              }
            }
          }
        }
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS &&
        product is AppStoreProductDetails) {
      final introPrice = product.skProduct.introductoryPrice;
      if (introPrice != null &&
          introPrice.paymentMode == SKProductDiscountPaymentMode.freeTrail) {
        final period = introPrice.subscriptionPeriod;
        int days = 0;
        if (period.unit == SKSubscriptionPeriodUnit.day) {
          days = period.numberOfUnits;
        } else if (period.unit == SKSubscriptionPeriodUnit.week) {
          days = period.numberOfUnits * 7;
        } else if (period.unit == SKSubscriptionPeriodUnit.month) {
          days = period.numberOfUnits * 30;
        }
        if (days > 0) {
          return TrialInfo(days.toString(), product.price, product.rawPrice);
        }
      }
    }
  } catch (e) {
    debugPrint("Trial info parse error: \$e");
  }
  return null;
}

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
      _setError(_localizations?.noInternetConnection ?? 'noInternetConnection');
      return;
    }

    if (!await _inAppPurchase.isAvailable()) {
      _setError(_localizations?.anErrorOccurred ?? 'anErrorOccurred');
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
        _setError(_localizations?.noProductsFound ?? 'noProductsFound');
      } else {
        await _crashlytics.recordError(
          e,
          stack,
          reason: 'Failed in _fetchProductDetails catch block.',
          fatal: true,
        );
        _setError(_localizations?.anErrorOccurred ?? 'anErrorOccurred');
      }
    } finally {
      _setLoading(false);
    }
  }
}
