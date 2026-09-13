// limit.dart

import '../../server/subscription.dart';
import '../messages/messages.dart';

class ChatLimitManager {
  final SubscriptionEntitlement _subscription;

  const ChatLimitManager({required this._subscription});

  /// Returns the maximum allowed characters in a chat context based on the
  /// user's effective subscription tier.
  int get chatCharacterLimit => _subscription.chatCharacterLimit;

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
