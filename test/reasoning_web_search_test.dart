import 'package:cortex/chat/providers/input.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputProvider input;
  setUp(() => input = InputProvider());
  tearDown(() => input.dispose());

  test('enabling search preserves reasoning', () {
    input.setFeatureMode(ChatInputMode.featureReasoning);
    input.toggleWebSearch();
    expect(input.featureMode, ChatInputMode.featureReasoning);
    expect(input.enableWebSearch, isTrue);
  });

  test('enabling reasoning preserves search in either selection order', () {
    input.toggleWebSearch();
    input.setFeatureMode(ChatInputMode.featureReasoning);
    expect(input.enableWebSearch, isTrue);
    input.clearAfterSend();
    expect(input.featureMode, ChatInputMode.featureReasoning);
    expect(input.enableWebSearch, isTrue);
  });

  test('each option can be disabled independently', () {
    input.setFeatureMode(ChatInputMode.featureReasoning);
    input.toggleWebSearch();
    input.toggleWebSearch();
    expect(input.featureMode, ChatInputMode.featureReasoning);
    input.toggleWebSearch();
    input.clearFeatureMode();
    expect(input.enableWebSearch, isTrue);
  });

  test('offline mode preserves optional search and logout clears both', () {
    input.toggleWebSearch();
    input.setFeatureMode(ChatInputMode.offline);
    expect(input.enableWebSearch, isTrue);
    input.setFeatureMode(ChatInputMode.featureReasoning);
    input.resetForLogout();
    expect(input.featureMode, ChatInputMode.none);
    expect(input.enableWebSearch, isFalse);
  });
}
