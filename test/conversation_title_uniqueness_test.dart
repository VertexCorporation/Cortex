import 'dart:io';

import 'package:cortex/chat/services/database.dart';
import 'package:cortex/chat/services/storage.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  late Directory root;

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    root = await Directory.systemTemp.createTemp('cortex_unique_chat_titles');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, (_) async => root.path);
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(pathProviderChannel, null);
  });

  test('new and renamed chats get distinct titles ignoring case', () async {
    final first = await ChatStorageService.saveConversation(
      'title-test-1',
      'Project notes',
      const [],
    );
    final second = await ChatStorageService.saveConversation(
      'title-test-2',
      'project notes',
      const [],
    );
    final renamed = await ChatStorageService.renameConversation(
      'title-test-2',
      'PROJECT NOTES',
      source: 'test',
    );

    expect(first, 'Project notes');
    expect(second, 'project notes (2)');
    expect(renamed, 'PROJECT NOTES (2)');

    final rows = await (await DbHelper().db).query(
      'conversations',
      columns: ['title'],
      where: 'id IN (?, ?)',
      whereArgs: const ['title-test-1', 'title-test-2'],
      orderBy: 'id',
    );
    expect(rows.map((row) => row['title']), [
      'Project notes',
      'PROJECT NOTES (2)',
    ]);
  });
}
