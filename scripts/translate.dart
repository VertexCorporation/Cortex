// scripts/translate.dart

import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

Future<void> main(List<String> rawArgs) async {
  // 1. Setup Paths
  final scriptPath = Platform.script.toFilePath();
  final projectRoot = p.dirname(p.dirname(scriptPath));
  final arbDir = p.join(projectRoot, 'lib', 'l10n');
  final libDir = p.join(projectRoot, 'lib');
  final backupDir = Directory(p.join(arbDir, '.backup'));

  // --- ARGUMENT SANITIZATION ---
  List<String> args = List.from(rawArgs);
  String? forcedRemoveValue;

  final keyArgIndex = args.indexWhere((arg) => arg.startsWith('--key='));
  if (keyArgIndex != -1) {
    final val = args[keyArgIndex].split('=')[1];

    if (val.startsWith('--remove')) {
      args.removeAt(keyArgIndex);
      args.add('--remove');
      if (val.contains('=')) forcedRemoveValue = val.split('=')[1];
    } else if (val.startsWith('--restore')) {
      args.removeAt(keyArgIndex);
      args.add('--restore');
    } else if (val.startsWith('--rename')) {
      args.removeAt(keyArgIndex);
      args.add(val);
    }
  }

  // --- COMMAND: RESTORE ---
  if (args.contains('--restore')) {
    if (!await backupDir.exists()) {
      stderr.writeln('❌ Error: No backup found to restore.');
      stderr.writeln('   Backups are created automatically only when you run --remove.');
      exit(1);
    }

    stdout.writeln('↺  Restoring ARB files from backup...');
    final backupFiles = backupDir.listSync().whereType<File>();

    int restoredCount = 0;
    for (final backupFile in backupFiles) {
      final fileName = p.basename(backupFile.path);
      final targetPath = p.join(arbDir, fileName);
      await backupFile.copy(targetPath);
      restoredCount++;
    }

    // Clean up backup folder after restore
    await backupDir.delete(recursive: true);

    stdout.writeln('✅ Successfully restored $restoredCount files.');
    return;
  }

  // --- COMMAND: RENAME ---
  final renameArg = args.firstWhere((arg) => arg.startsWith('--rename='), orElse: () => '');
  if (renameArg.isNotEmpty) {
    final pairsString = renameArg.split('=')[1];
    if (pairsString.isEmpty) {
      stderr.writeln('❌ Error: --rename argument have to take a value. Example: --rename=old:new');
      exit(1);
    }

    final Map<String, String> renameMap = {};
    for (final pair in pairsString.split(',')) {
      final parts = pair.split(':');
      if (parts.length != 2 || parts[0].isEmpty || parts[1].isEmpty) {
        stderr.writeln('❌ Error: Invalid Format. Use: --rename=old1:new1,old2:new2');
        exit(1);
      }
      renameMap[parts[0].trim()] = parts[1].trim();
    }

    stdout.writeln('🔄 Key renaming mode is active.');
    stdout.writeln('Keys that will be changed: $renameMap');

    final arbFiles = Directory(arbDir).listSync().where((f) => f.path.endsWith('.arb'));
    int filesChanged = 0;

    for (final fileEntity in arbFiles) {
      final file = File(fileEntity.path);
      String content = await file.readAsString();

      bool fileModified = false;
      renameMap.forEach((oldKey, newKey) {
        final oldKeyPattern = '"$oldKey"';
        final newKeyPattern = '"$newKey"';
        final oldMetaPattern = '"@$oldKey"';
        final newMetaPattern = '"@$newKey"';

        if (content.contains(oldKeyPattern)) {
          content = content.replaceAll(oldKeyPattern, newKeyPattern);
          content = content.replaceAll(oldMetaPattern, newMetaPattern);
          fileModified = true;
        }
      });

      if (fileModified) {
        await file.writeAsString(content);
        stdout.writeln('✅ Updated: ${p.basename(file.path)}');
        filesChanged++;
      }
    }

    stdout.writeln('\n✨ Renaming completed. Total $filesChanged files updated.');
    return;
  }

  // --- COMMAND: REMOVE ---
  final hasRemoveFlag = args.any((arg) => arg.startsWith('--remove'));

  if (hasRemoveFlag) {
    final removeArg = args.firstWhere((arg) => arg.startsWith('--remove'), orElse: () => '');
    List<String> keysToRemove = [];

    String val = '';
    if (forcedRemoveValue != null) {
      val = forcedRemoveValue;
    } else if (removeArg.contains('=')) {
      val = removeArg.split('=')[1];
    }

    if (val.isNotEmpty) {
      // 1. Specific Keys Mode
      keysToRemove = val.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      stdout.writeln('🗑️  Manual removal mode: Removing ${keysToRemove.length} specific keys...');
    } else {
      // 2. Auto-Clean Mode
      stdout.writeln('🧹 Auto-cleanup mode: Scanning project for unused keys...');
      stdout.writeln('   (Excluding "l10n" and "generated" folders to prevent false positives)');

      final templateFile = File(p.join(arbDir, 'app_en.arb'));
      if (!await templateFile.exists()) {
        stderr.writeln('❌ Error: app_en.arb not found, cannot calculate unused keys.');
        exit(1);
      }

      final Map<String, dynamic> jsonMap = jsonDecode(await templateFile.readAsString());
      final Set<String> allKeys = jsonMap.keys.where((k) => !k.startsWith('@')).toSet();

      stdout.writeln('   Scanning lib/ folder for usage references...');

      final Set<String> usedTokens = {};
      final dartFiles = Directory(libDir).listSync(recursive: true).where((f) => f.path.endsWith('.dart'));

      int filesScanned = 0;
      for (final entity in dartFiles) {
        final segments = p.split(entity.path);
        if (segments.contains('l10n') || segments.contains('generated')) {
          continue;
        }

        filesScanned++;
        final file = File(entity.path);
        final content = await file.readAsString();
        final tokens = content.split(RegExp(r'[^a-zA-Z0-9_]'));
        usedTokens.addAll(tokens);
      }

      stdout.writeln('   Scanned $filesScanned Dart files.');

      for (final key in allKeys) {
        if (!usedTokens.contains(key)) {
          keysToRemove.add(key);
        }
      }

      if (keysToRemove.isEmpty) {
        stdout.writeln('✨ No unused keys found. Your ARB files are clean!');
        return;
      }

      stdout.writeln('⚠️  Found ${keysToRemove.length} unused keys.');
    }

    if (keysToRemove.isEmpty) {
      stderr.writeln('❌ Error: No keys to remove found.');
      exit(1);
    }

    // --- AUTOMATIC BACKUP START ---
    stdout.writeln('📦 Creating backup before modification...');
    if (!await backupDir.exists()) await backupDir.create();

    final arbFilesForBackup = Directory(arbDir).listSync().where((f) => f.path.endsWith('.arb'));
    for (final f in arbFilesForBackup) {
      if (f is File) {
        await f.copy(p.join(backupDir.path, p.basename(f.path)));
      }
    }
    stdout.writeln('   Backup saved to: lib/l10n/.backup/');
    // --- AUTOMATIC BACKUP END ---

    // Process Removal
    final arbFiles = Directory(arbDir).listSync().where((f) => f.path.endsWith('.arb'));
    int filesChanged = 0;

    for (final fileEntity in arbFiles) {
      final file = File(fileEntity.path);
      try {
        final contentStr = await file.readAsString();
        if (contentStr.trim().isEmpty) continue;

        final Map<String, dynamic> contentJson = jsonDecode(contentStr);
        bool modified = false;

        for (final key in keysToRemove) {
          if (contentJson.containsKey(key)) {
            contentJson.remove(key);
            modified = true;
          }
          final metaKey = '@$key';
          if (contentJson.containsKey(metaKey)) {
            contentJson.remove(metaKey);
            modified = true;
          }
        }

        if (modified) {
          await file.writeAsString(JsonEncoder.withIndent('  ').convert(contentJson));
          stdout.writeln('   ✂️  Removed keys from: ${p.basename(file.path)}');
          filesChanged++;
        }
      } catch (e) {
        stderr.writeln('   ❌ Error processing ${p.basename(file.path)}: $e');
      }
    }

    stdout.writeln('\n✨ Removal completed. Updated $filesChanged files.');
    stdout.writeln('💡 Mistake? Run "translate --restore" to undo.');
    return;
  }

  // --- COMMAND: TRANSLATE (Default) ---
  final manualOverrides = <String, Map<String, String>>{};

  List<String> keysToUpdate = [];
  final keyArg = args.firstWhere((arg) => arg.startsWith('--key='), orElse: () => '');

  if (keyArg.isNotEmpty) {
    final keysString = keyArg.split('=')[1];
    if (keysString.isEmpty) {
      stderr.writeln('❌ Error: The --key argument must have a value. e.g.: --key=key1,key2');
      exit(1);
    }
    keysToUpdate = keysString.split(',').map((k) => k.trim()).toList();
  }

  final templateArbFileName = 'app_en.arb';
  final sourceLocale = 'en';
  final targetLocales = [
    'tr', 'zh', 'fr', 'hi', 'pt', 'id', 'az', 'de', 'es', 'it', 'ja', 'ko', 'ku', 'ru', 'ar', 'nl'
  ];

  stdout.writeln('--- Cortex Translation using Google API v2 ---');

  if (keysToUpdate.isNotEmpty) {
    stdout.writeln('🟢 Force update mode activated for specific keys: "$keysToUpdate"');
  } else {
    stdout.writeln('-> Running standard synchronization for all keys...');
  }

  final templateArbFile = p.join(arbDir, templateArbFileName);
  final File templateFile = File(templateArbFile);

  if (!await templateFile.exists()) {
    stderr.writeln('❌ Error: Template ARB file not found: $templateArbFile');
    exit(1);
  }

  late final Map<String, dynamic> templateContent;
  try {
    templateContent = jsonDecode(await templateFile.readAsString());
  } on FormatException catch (e) {
    stderr.writeln('❌ FATAL ERROR: Template ARB file is not a valid JSON: $templateArbFile');
    stderr.writeln('   Please check the file for syntax errors like missing commas.');
    stderr.writeln('   Details: $e');
    exit(1);
  }

  final Map<String, dynamic> sourceKeys = {};
  templateContent.forEach((key, value) {
    if (!key.startsWith('@')) {
      sourceKeys[key] = value;
    }
  });

  stdout.writeln('Found ${sourceKeys.length} keys in the template file ($templateArbFileName).');

  if (keysToUpdate.isNotEmpty) {
    for (final key in keysToUpdate) {
      if (!sourceKeys.containsKey(key)) {
        stderr.writeln('❌ Error: The key to be updated "$key" was not found in the template file ($templateArbFileName).');
        exit(1);
      }
    }
  }

  for (final locale in targetLocales) {
    stdout.writeln('\n--- Processing locale: $locale ---');
    final targetArbFileName = 'app_$locale.arb';
    final targetArbFilePath = p.join(arbDir, targetArbFileName);
    final File targetFile = File(targetArbFilePath);

    Map<String, dynamic> targetContent = {};
    if (await targetFile.exists()) {
      try {
        final content = await targetFile.readAsString();
        if (content.trim().isNotEmpty) {
          targetContent = jsonDecode(content);
        }
      } on FormatException catch (e) {
        stderr.writeln('❌ WARNING: Could not parse existing file, it will be treated as empty: $targetArbFileName');
        stderr.writeln('   Details: $e');
      }
    }

    if (targetContent.isEmpty) {
      stdout.writeln('File is empty or new, creating with locale key: $targetArbFileName');
      targetContent['@@locale'] = locale;
    }

    bool wasModified = false;
    final keysToProcess = keysToUpdate.isNotEmpty ? keysToUpdate : sourceKeys.keys.toList();

    for (final key in keysToProcess) {
      final shouldTranslate = !targetContent.containsKey(key) || keysToUpdate.contains(key);

      if (shouldTranslate) {
        wasModified = true;

        if (manualOverrides.containsKey(key) && manualOverrides[key]!.containsKey(locale)) {
          final overriddenText = manualOverrides[key]![locale]!;
          targetContent[key] = overriddenText;
          stdout.writeln('   ✍️ Manual override applied: "$overriddenText"');
          continue;
        }

        const placeholder = 'CORTEXNEWLINE';
        final originalText = sourceKeys[key] as String;
        final textToSend = originalText.replaceAll('\n', placeholder);

        if (keysToUpdate.contains(key)) {
          stdout.writeln('-> Force update: "$key". Translating text: "$textToSend"');
        } else {
          stdout.writeln('-> Found missing key "$key". Translating text: "$textToSend"');
        }

        final result = await Process.run(
          'python',
          [
            p.join(projectRoot, 'scripts', 'translate.py'),
            sourceLocale,
            locale,
            textToSend,
          ],
        );

        if (result.exitCode == 0) {
          String translatedText = result.stdout.toString().trim().replaceAll(placeholder, '\n');
          translatedText = translatedText
              .replaceAll('&#39;', "'")
              .replaceAll('&quot;', '"')
              .replaceAll('&amp;', '&')
              .replaceAll('&lt;', '<')
              .replaceAll('&gt;', '>');
          final instructionRegex = RegExp(r'\[.*?\]\s*');
          translatedText = translatedText.replaceAll(instructionRegex, '');
          targetContent[key] = translatedText;
          stdout.writeln('   ✅ Translation successful: "$translatedText"');
        } else {
          targetContent[key] = originalText;
          stderr.writeln('   ❌ Error translating key "$key". Using source text as fallback.');
          stderr.writeln('   Tool Error: ${result.stderr}');
        }
      }
    }

    if (wasModified) {
      await targetFile.writeAsString(JsonEncoder.withIndent('  ').convert(targetContent));
      stdout.writeln('Saved updated file: $targetArbFileName');
    } else if (keysToUpdate.isEmpty) {
      stdout.writeln('Sync: No new keys to add. File is up to date.');
    } else {
      stdout.writeln('No changes were made. The keys might already be up to date.');
    }
  }

  stdout.writeln('\n--- Translation Process Finished ---');
}