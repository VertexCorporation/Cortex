// lib/library/backend/data/image_file_web.dart
//
// Web implementation: browser builds never hold locally downloaded image
// files, so removal is a no-op.

/// Web stub: there are no locally cached image files to delete.
Future<bool> deleteLocalImageFile(String path) async => false;
