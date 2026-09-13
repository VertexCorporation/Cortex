// Real-database tests for the v2 catalog schema migration and the
// per-variant persistence round-trip. Uses sqflite_common_ffi so the actual
// SQLite engine (the same one Android devices run against in production)
// executes the migration and the queries.
import 'dart:convert';

import 'package:cortex/library/backend/data/database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  test('v1 catalog rows are dropped on upgrade to v2, user models survive',
      () async {
    final path = p.join(await getDatabasesPath(), 'cortex_models_v2.db');
    if (await databaseFactory.databaseExists(path)) {
      await databaseFactory.deleteDatabase(path);
    }

    // Seed a legacy v1 database whose catalog row is larger than Android's
    // 2 MB CursorWindow — the state that crashed every catalog read.
    final legacy = await openDatabase(path, version: 1,
        onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE models (
          id TEXT PRIMARY KEY,
          producer TEXT,
          title TEXT,
          is_server_side INTEGER,
          type TEXT,
          raw_json TEXT NOT NULL
        )
      ''');
    });
    final poison = List.filled(2 * 1024 * 1024 + 4096, 'x').join();
    await legacy.insert('models', {
      'id': 'qwen',
      'producer': 'Qwen',
      'title': 'Qwen',
      'is_server_side': 1,
      'type': 'online',
      'raw_json': json.encode({'id': 'qwen', 'blob': poison}),
    });
    await legacy.insert('models', {
      'id': 'self_user_1',
      'producer': '_USER_',
      'title': 'My Model',
      'is_server_side': 0,
      'type': 'roleplay',
      'raw_json': json.encode({
        'id': 'self_user_1',
        'title': 'My Model',
        'type': 'roleplay',
        'category': 'self',
        'producer': '_USER_',
      }),
    });
    await legacy.close();

    // Opening through the helper runs the v2 migration.
    final helper = DatabaseHelper.instance;
    final models = await helper.getAllModels();
    expect(models, hasLength(1));
    expect(models.single['id'], 'self_user_1');
    expect(models.single['title'], 'My Model');

    final db = await helper.database;
    expect(db, isNotNull);
    expect(await db!.getVersion(), 2);
  });

  test('per-variant rows round-trip through the helper', () async {
    final helper = DatabaseHelper.instance;
    // Uses the database opened (and migrated) by the previous test; the
    // helper keeps a single static connection per process.

    for (var i = 0; i < 300; i++) {
      final row = {
        'id': 'catalog_test/variant-$i',
        'title': 'Catalog Test Variant $i',
        'series': 'Qwen Next',
        'producer': 'Qwen Corp',
        'type': 'online',
        'summary': 'Series summary.',
        'description': 'Variant $i description.',
      };
      await helper.insert(
        'models',
        {
          'id': row['id'],
          'producer': row['producer'],
          'title': row['title'],
          'is_server_side': 1,
          'type': row['type'],
          'raw_json': json.encode(row),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    final all = await helper.getAllModels();
    final catalogRows =
        all.where((m) => '${m['id']}'.startsWith('catalog_test/')).toList();
    expect(catalogRows, hasLength(300));
    expect(catalogRows.first['series'], 'Qwen Next');
    expect(catalogRows.first['description'], 'Variant 0 description.');

    final deleted = await helper.delete(
      'models',
      where: "id LIKE 'catalog_test/%'",
    );
    expect(deleted, 300);

    // The user model from the migration phase is untouched.
    final remaining = await helper.getAllModels();
    expect(remaining, hasLength(1));
    expect(remaining.single['id'], 'self_user_1');
  });
}
