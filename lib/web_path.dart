import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Web-safe path provider that falls back to in-memory path on web.
class AppPaths {
  static Future<String> get documentsDirectory async {
    if (kIsWeb) {
      return '/cortex_data';
    }
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static Future<String> get temporaryDirectory async {
    if (kIsWeb) {
      return '/cortex_temp';
    }
    final dir = await getTemporaryDirectory();
    return dir.path;
  }

  static String join(String part1, String part2) {
    return p.join(part1, part2);
  }
}
