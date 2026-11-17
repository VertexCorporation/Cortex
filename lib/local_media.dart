// lib/local_media.dart
//
// Cross-platform helpers for rendering locally downloaded media files.
//
// io platforms (Android/iOS/desktop) render through real `dart:io` Files.
// The browser cannot read local files, so the web implementation returns
// null and callers keep their asset/placeholder fallbacks — this also avoids
// flutter_svg's web-only `File` type mismatch that broke web compilation.
//
// Usage:
//   final widget = localSvgFile(path, ...) ?? fallbackWidget;
//   final provider = localFileImage(path) ?? const AssetImage(...);

export 'local_media_io.dart' if (dart.library.html) 'local_media_web.dart';
