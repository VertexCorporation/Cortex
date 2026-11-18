// lib/library/backend/data/image_file_io.dart
//
// io implementation: deletes a locally cached image file.

import 'dart:io';

/// Deletes a locally cached image file. Returns true when a file existed and
/// was removed, false when it did not exist. Storage errors propagate to the
/// caller, which logs them.
Future<bool> deleteLocalImageFile(String path) async {
  final file = File(path);
  if (await file.exists()) {
    await file.delete();
    return true;
  }
  return false;
}
