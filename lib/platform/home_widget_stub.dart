import 'dart:async';

class HomeWidget {
  static Stream<Uri?> get widgetClicked => const Stream<Uri?>.empty();
  static Future<Uri?> initiallyLaunchedFromHomeWidget() async => null;
}

class CortexQuickChatSchemaHomeWidget {
  static Future<void> saveData({String? messageHint}) async {}
  static Future<bool?> updateWidget() async => false;
}
