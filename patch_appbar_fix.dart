import 'dart:io';

void main() {
  final file = File('lib/chat/screen/appbar/appbar.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll('mainScreenKey.currentState?.pushScreen(MainScreenPage.settings);', 'navigateToScreen(const SettingsScreen());');
  if(!content.contains('SettingsScreen')) {
    content = "import 'package:cortex/settings/controller.dart';\n" + content;
  }
  file.writeAsStringSync(content);
}
