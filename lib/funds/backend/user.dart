part of 'service.dart';

extension FundsUserData on FundsBackend {
  DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  void _syncSpecialOfferStateFromUserData({
    required User user,
    required Map<String, dynamic>? data,
  }) {
    final shouldSuppressOffer =
        data == null || user.isAnonymous || _subscription.isPaid;
    if (shouldSuppressOffer) {
      _isSpecialOfferActive = false;
      _isSpecialOfferEligible = false;
      _specialOfferExpiresAt = null;
      CacheService.invalidate(CacheKey.premiumScreenState);
      return;
    }

    final now = DateTime.now();
    final offerExpiry = _parseTimestamp(data['specialOfferExpiresAt']);

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

  void _resetSubscriptionState() {
    _subscription = SubscriptionEntitlement.none;
    _isSpecialOfferActive = false;
    _isSpecialOfferEligible = false;
    _specialOfferExpiresAt = null;
  }

  /// Attaches to the shared UserProvider instead of opening a second
  /// `users/{uid}` snapshot. The provider owns the single Firestore listener;
  /// the backend reacts to its change notifications.
  void _attachUserProvider() {
    final provider = _userProvider;
    if (provider == null) {
      _resetSubscriptionState();
      _notify();
      return;
    }

    provider.removeListener(_onUserDataChanged);
    provider.addListener(_onUserDataChanged);
    _onUserDataChanged();
  }

  /// Reacts to UserProvider updates (live snapshots, cache loads, sign-out).
  void _onUserDataChanged() {
    final user = _auth.currentUser;
    final provider = _userProvider;

    if (user == null || provider == null || provider.userData == null) {
      _resetSubscriptionState();
      _notify();
      return;
    }

    final data = provider.userData;
    _subscription = SubscriptionEntitlement.fromUserData(
      data,
      isAnonymous: user.isAnonymous || data?['accountType'] == 'anonymous',
    );
    _syncSpecialOfferStateFromUserData(user: user, data: data);
    _notify();
  }
}
