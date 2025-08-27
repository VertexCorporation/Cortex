// scripts/translate.dart
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart' as p;

Future<void> main() async {
  final scriptPath = Platform.script.toFilePath();
  final projectRoot = p.dirname(p.dirname(scriptPath));

  final arbDir = p.join(projectRoot, 'lib', 'l10n');
  final templateArbFileName = 'app_en.arb';
  final sourceLocale = 'en';
  final targetLocales = [
    'tr', 'zh', 'fr', 'hi', 'pt', 'id', 'az', 'de', 'es', 'it', 'ja', 'ko', 'ku', 'ru', 'ar', 'nl'
  ];

  print('Starting ARB synchronization and translation process...');

  final templateArbFile = p.join(arbDir, templateArbFileName);
  final File templateFile = File(templateArbFile);

  if (!await templateFile.exists()) {
    stderr.writeln('❌ Error: Template ARB file not found at: $templateArbFile');
    exit(1);
  }

  final Map<String, dynamic> templateContent = jsonDecode(await templateFile.readAsString());
  final Map<String, dynamic> sourceKeys = {};
  templateContent.forEach((key, value) {
    if (!key.startsWith('@')) {
      sourceKeys[key] = value;
    }
  });

  print('Found ${sourceKeys.length} keys in the template file ($templateArbFileName).');

  for (final locale in targetLocales) {
    print('\n--- Processing locale: $locale ---');
    final targetArbFileName = 'app_$locale.arb';
    final targetArbFilePath = p.join(arbDir, targetArbFileName);
    final File targetFile = File(targetArbFilePath);

    Map<String, dynamic> targetContent = {};
    if (await targetFile.exists()) {
      targetContent = jsonDecode(await targetFile.readAsString());
    } else {
      print('File not found, creating a new one: $targetArbFileName');
      targetContent['@@locale'] = locale;
    }

    bool wasModified = false;
    for (final key in sourceKeys.keys) {
      if (!targetContent.containsKey(key)) {
        wasModified = true;
        final sourceText = sourceKeys[key];
        print('-> Found missing key "$key". Translating text: "$sourceText"');

        // --- THE NEW GOOGLE TRANSLATE v2 ENGINE ---
        final result = await Process.run(
          'python', // Just needs a python from the activated venv
          [
            p.join(projectRoot, 'scripts', 'translate.py'),
            sourceLocale,
            locale,
            sourceText,
          ],
        );

        if (result.exitCode == 0) {
          String translatedText = result.stdout.toString().trim();
          targetContent[key] = translatedText;
          print('   ✅ Translation successful: "$translatedText"');
        } else {
          targetContent[key] = sourceText;
          stderr.writeln('   ❌ Error translating key "$key". Using source text as fallback.');
          stderr.writeln('   Tool Error: ${result.stderr}');
        }
      }
    }

    if (wasModified) {
      await targetFile.writeAsString(JsonEncoder.withIndent('  ').convert(targetContent));
      print('Saved updated file: $targetArbFileName');
    } else {
      print('Sync: No new keys to add. File is up to date.');
    }
  }

  print('\n🎉 All ARB files have been synchronized and translated successfully!');
}