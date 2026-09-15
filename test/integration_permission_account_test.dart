import 'package:cortex/integrations/permission_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('account switch does not inherit permanent grants', () async {
    SharedPreferences.setMockInitialValues({});
    String? uid = 'alice';
    final store = IntegrationPermissionStore(currentUserId: () => uid);
    await store.setMode('gmail', IntegrationPermissionMode.allowAll);
    expect(await store.isAlwaysAllowed('gmail', 'GMAIL_SEND_EMAIL'), isTrue);
    uid = 'bob';
    expect(await store.isAlwaysAllowed('gmail', 'GMAIL_SEND_EMAIL'), isFalse);
    await store.setAlwaysAllowed('gmail', 'GMAIL_LIST_MESSAGES', allowed: true);
    uid = 'alice';
    await store.resetToolkit('gmail');
    expect(await store.alwaysAllowedTools('gmail'), isEmpty);
    uid = 'bob';
    expect(
      await store.alwaysAllowedTools('gmail'),
      contains('GMAIL_LIST_MESSAGES'),
    );
    uid = null;
    expect(
      await store.isAlwaysAllowed('gmail', 'GMAIL_LIST_MESSAGES'),
      isFalse,
    );
  });

  test('legacy ownerless permissions do not grant access', () async {
    SharedPreferences.setMockInitialValues({
      'integration.mode.gmail': 'allowAll',
      'integration.always.gmail': ['GMAIL_SEND_EMAIL'],
    });
    final store = IntegrationPermissionStore(currentUserId: () => 'alice');
    expect(
      await store.modeForToolkit('gmail'),
      IntegrationPermissionMode.askEveryTime,
    );
    expect(await store.isAlwaysAllowed('gmail', 'GMAIL_SEND_EMAIL'), isFalse);
  });
}
