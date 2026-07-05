part of 'service.dart';

extension FundsReceipt on FundsBackend {
  bool _isPlaceholderReceipt(String s) {
    final t = s.trim();
    return t.isEmpty || t == "{}" || t == "[]";
  }

  bool _looksLikeJson(String s) {
    final t = s.trimLeft();
    return t.startsWith("{") || t.startsWith("[");
  }

  bool _looksLikeBase64(String s) {
    final t = s.replaceAll(RegExp(r"\s+"), ""); // remove whitespace/newlines
    if (t.length < 50) return false;
    if (_looksLikeJson(t)) return false;
    return RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(t);
  }

  Future<String?> _resolveIosReceiptBase64(
      PurchaseDetails purchaseDetails) async {
    final v = purchaseDetails.verificationData;

    final fromLocal = (v.localVerificationData).trim();
    if (!_isPlaceholderReceipt(fromLocal) && _looksLikeBase64(fromLocal)) {
      return fromLocal;
    }

    final fromServer = (v.serverVerificationData).trim();
    if (!_isPlaceholderReceipt(fromServer) && _looksLikeBase64(fromServer)) {
      return fromServer;
    }

    try {
      final storekit = _inAppPurchase
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();

      try {
        await storekit.sync();
      } catch (_) {}

      final refreshed = await storekit.refreshPurchaseVerificationData();
      final refreshedReceipt = (refreshed?.serverVerificationData ??
          refreshed?.localVerificationData ??
          '')
          .trim();

      if (!_isPlaceholderReceipt(refreshedReceipt) &&
          _looksLikeBase64(refreshedReceipt)) {
        return refreshedReceipt;
      }
    } catch (e, stack) {
      await _crashlytics.recordError(
        e,
        stack,
        reason: 'Failed to refresh iOS receipt data (StoreKit).',
        fatal: false,
      );
    }

    return null;
  }
}
