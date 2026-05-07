part of 'service.dart';

extension FundsUserData on FundsBackend {
  void _listenToUserChanges() {
    _userSubscription?.cancel();
    _userSubscription = null;

    final user = _auth.currentUser;

    if (user == null) {
      _currentUserSubscriptionLevel = 0;
      _activeSubscriptionOption = null;
      _activeSubscriptionProductId = null;
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
      } else {
        final data = snapshot.data();
        _currentUserSubscriptionLevel = data?['hasCortexSubscription'] ?? 0;
        _activeSubscriptionOption = data?['activeSubscriptionOption'];
        _activeSubscriptionProductId = data?['activeSubscriptionProductId'];
      }
      _notify();
    }, onError: (error) {
      if (error.toString().contains("permission-denied")) {
        _userSubscription?.cancel();
      }
    });
  }
}
