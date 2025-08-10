// errors.dart
import 'package:flutter/foundation.dart';

class ChatErrorState extends ChangeNotifier {
  bool _internetError = false;
  bool _conversationLimitExceeded = false;

  bool get internetError => _internetError;
  bool get conversationLimitExceeded => _conversationLimitExceeded;

  /// İnternet hatası var mı?
  void setInternetError(bool value) {
    if (_internetError != value) {
      _internetError = value;
      notifyListeners();
    }
  }

  /// Sohbet limiti aşıldı hatası var mı?
  void setConversationLimitExceeded(bool value) {
    if (_conversationLimitExceeded != value) {
      _conversationLimitExceeded = value;
      notifyListeners();
    }
  }

  /// Hata durumlarını sıfırlamak için
  void reset() {
    _internetError = false;
    _conversationLimitExceeded = false;
    notifyListeners();
  }
}
