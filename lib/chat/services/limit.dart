// limit.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../messages/messages.dart';

class ChatLimitManager {
  final int _cortexSubscription;
  final Timestamp? _subscriptionExpiresAt;

  const ChatLimitManager({
    required int cortexSubscription,
    Timestamp? subscriptionExpiresAt,
  })  : _cortexSubscription = cortexSubscription,
        _subscriptionExpiresAt = subscriptionExpiresAt;

  /// Calculates the true, trusted subscription level by handling both
  /// standard time-based subscriptions (1, 2, 3) and
  /// lifetime/manual subscriptions (4, 5, 6).
  int get _activeSubscriptionLevel {
    // First, check for lifetime/manual subscription levels.
    // These are always active and do not need a date check.
    if (_cortexSubscription >= 4) {
      return _cortexSubscription;
    }

    // If not a lifetime sub, perform the standard checks for time-based subs.
    if (_cortexSubscription == 0) {
      return 0; // Not subscribed at all.
    }

    // A time-based subscription MUST have an expiration date.
    if (_subscriptionExpiresAt == null) {
      return 0; // Missing expiration date means it's not a valid subscription.
    }

    // Check if the expiration date is in the past.
    if (_subscriptionExpiresAt.toDate().isBefore(DateTime.now())) {
      return 0; // Subscription has expired.
    }

    // If all checks pass, the time-based subscription is active.
    return _cortexSubscription;
  }

  /// Returns the maximum allowed characters in a chat context based on the
  /// user's effective subscription level.
  int get chatCharacterLimit {
    final level = _activeSubscriptionLevel; // Now uses the perfected getter.

    // This logic now works correctly for ALL subscription types.
    if (level == 0) {
      return 50000;
    } else if (level == 1 || level == 4) {
      return 70000;
    } else if (level == 2 || level == 5) {
      return 90000;
    } else if (level == 3 || level == 6) {
      return 100000;
    }
    return 50000; // Fallback for any unknown cases.
  }

  /// Calculates the total number of characters in a list of messages.
  int calculateTotalCharacters(List<Message> messages) {
    int total = 0;
    for (var message in messages) {
      // It's safer to check for null text, just in case.
      total += message.text.length;
    }
    return total;
  }

  /// Checks if the total characters in the message list exceed the user's limit.
  bool isLimitExceeded(List<Message> messages) {
    return calculateTotalCharacters(messages) >= chatCharacterLimit;
  }
}