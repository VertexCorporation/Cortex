// lib/library/backend/data/image_file.dart
//
// Cross-platform removal helper for locally cached model image files.
//
// io platforms delete the real file; web returns false because browser builds
// never store locally downloaded image files (the previous
// `dart:io if (dart.library.html) dart:typed_data` conditional import made
// `File` unresolvable on web and broke web compilation).

export 'image_file_io.dart' if (dart.library.html) 'image_file_web.dart';
