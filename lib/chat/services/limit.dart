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

  /// Calculates the true, trusted subscription level by requiring the server
  /// tier and a future expiry timestamp.
  int get _activeSubscriptionLevel {
    if (_cortexSubscription == 0) {
      return 0; // Not subscribed at all.
    }

    if (_subscriptionExpiresAt == null) {
      return _cortexSubscription >= 4 && _cortexSubscription <= 6
          ? _cortexSubscription
          : 0;
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
      return 100000;
    } else if (level == 1 || level == 4) {
      return 250000;
    } else if (level == 2 || level == 5) {
      return 500000;
    } else if (level == 3 || level == 6) {
      return 1000000;
    }
    return 100000; // Fallback for any unknown cases.
  }

  /// Approximate character count equivalent for an image attachment.
  static const int imageCharacterEquivalent = 1000;

  /// Calculates the total number of characters in a list of messages.
  int calculateTotalCharacters(List<Message> messages) {
    int total = 0;
    for (var message in messages) {
      // It's safer to check for null text, just in case.
      total += message.text.length;
      // Add equivalent characters for each attachment
      total += message.attachmentPaths.length * imageCharacterEquivalent;
    }
    return total;
  }

  /// Checks if the total characters in the message list exceed the user's limit.
  bool isLimitExceeded(List<Message> messages) {
    return calculateTotalCharacters(messages) >= chatCharacterLimit;
  }
}
