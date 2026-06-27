// errors.dart

import 'package:flutter/foundation.dart';

class ChatErrorState extends ChangeNotifier {
  bool _internetError = false;
  bool _conversationLimitExceeded = false;

  bool get internetError => _internetError;
  bool get conversationLimitExceeded => _conversationLimitExceeded;

  /// Internet error
  void setInternetError(bool value) {
    if (_internetError != value) {
      _internetError = value;
      notifyListeners();
    }
  }

  /// Conversation limit error
  void setConversationLimitExceeded(bool value) {
    if (_conversationLimitExceeded != value) {
      _conversationLimitExceeded = value;
      notifyListeners();
    }
  }

  /// Reset error states
  void reset() {
    _internetError = false;
    _conversationLimitExceeded = false;
    notifyListeners();
  }
}
