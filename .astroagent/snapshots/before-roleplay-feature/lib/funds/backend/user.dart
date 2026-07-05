part of 'service.dart';

extension FundsUserData on FundsBackend {
  int _parseSubscriptionLevel(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  DateTime? _parseSubscriptionExpiry(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  int _effectiveSubscriptionLevel({
    required User user,
    required Map<String, dynamic>? data,
  }) {
    if (data == null) return 0;
    if (user.isAnonymous || data['accountType'] == 'anonymous') return 0;

    final level = _parseSubscriptionLevel(data['hasCortexSubscription']);
    if (level <= 0) return 0;

    final expiry = _parseSubscriptionExpiry(data['subscriptionExpiresAt']);
    if (expiry == null) return level >= 4 && level <= 6 ? level : 0;
    return expiry.isAfter(DateTime.now()) ? level : 0;
  }

  String? _inferSubscriptionOption({
    required int level,
    required String? option,
    required String? productId,
  }) {
    if (option == 'monthly' || option == 'annual') return option;

    final normalizedProductId = productId?.toLowerCase() ?? '';
    if (normalizedProductId.contains('annual')) return 'annual';
    if (normalizedProductId.contains('monthly')) return 'monthly';

    // If the server says the account is subscribed but the store metadata is
    // unavailable on this device, still show the active plan instead of making
    // the Funds screen look unsubscribed.
    return level > 0 ? 'monthly' : null;
  }

  void _syncSpecialOfferStateFromUserData({
    required User user,
    required Map<String, dynamic>? data,
  }) {
    final shouldSuppressOffer =
        data == null || user.isAnonymous || _currentUserSubscriptionLevel > 0;
    if (shouldSuppressOffer) {
      _isSpecialOfferActive = false;
      _isSpecialOfferEligible = false;
      _specialOfferExpiresAt = null;
      CacheService.invalidate(CacheKey.premiumScreenState);
      return;
    }

    final now = DateTime.now();
    final offerExpiry = _parseSubscriptionExpiry(data['specialOfferExpiresAt']);

    if (offerExpiry == null) {
      _isSpecialOfferActive = false;
      _isSpecialOfferEligible = true;
      _specialOfferExpiresAt = null;
      return;
    }

    if (offerExpiry.isAfter(now)) {
      _isSpecialOfferActive = true;
      _isSpecialOfferEligible = false;
      _specialOfferExpiresAt = offerExpiry.millisecondsSinceEpoch;
      return;
    }

    _isSpecialOfferActive = false;
    _specialOfferExpiresAt = null;
    _isSpecialOfferEligible =
        now.isAfter(offerExpiry.add(const Duration(days: 21)));
  }

  void _listenToUserChanges() {
    _userSubscription?.cancel();
    _userSubscription = null;

    final user = _auth.currentUser;

    if (user == null) {
      _currentUserSubscriptionLevel = 0;
      _activeSubscriptionOption = null;
      _activeSubscriptionProductId = null;
      _isSpecialOfferActive = false;
      _isSpecialOfferEligible = false;
      _specialOfferExpiresAt = null;
      _notify();
      return;
    }

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) {
        _currentUserSubscriptionLevel = 0;
        _activeSubscriptionOption = null;
        _activeSubscriptionProductId = null;
        _syncSpecialOfferStateFromUserData(user: user, data: null);
      } else {
        final data = snapshot.data();
        _currentUserSubscriptionLevel = _effectiveSubscriptionLevel(
          user: user,
          data: data,
        );
        _syncSpecialOfferStateFromUserData(user: user, data: data);

        if (_currentUserSubscriptionLevel > 0) {
          _activeSubscriptionProductId =
              data?['activeSubscriptionProductId']?.toString();
          _activeSubscriptionOption = _inferSubscriptionOption(
            level: _currentUserSubscriptionLevel,
            option: data?['activeSubscriptionOption']?.toString(),
            productId: _activeSubscriptionProductId,
          );
        } else {
          _activeSubscriptionProductId = null;
          _activeSubscriptionOption = null;
        }
      }
      _notify();
    }, onError: (error) {
      if (error.toString().contains("permission-denied")) {
        _userSubscription?.cancel();
      }
    });
  }
}
