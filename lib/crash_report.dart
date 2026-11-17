// lib/crash_report.dart
//
// Crashlytics bridge that is safe to call from the global error handlers.
//
// Crashlytics has no web implementation: without one, the plugin falls back
// to its method-channel platform, whose calls throw MissingPluginException on
// web. Because these calls run inside FlutterError.onError /
// PlatformDispatcher.onError, that failure would recursively re-enter the
// same handlers and wedge the app. On web we log locally instead of
// reporting; on io platforms behavior is identical to direct Crashlytics
// calls.

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Non-fatal error report (mirrors `FirebaseCrashlytics.recordError`).
Future<void> reportError(
  Object error,
  StackTrace? stack, {
  String? reason,
}) async {
  if (kIsWeb) {
    debugPrint('[CrashReport] ${reason ?? 'error'}: $error');
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordError(error, stack, reason: reason);
  } catch (e) {
    debugPrint('[CrashReport] recordError failed: $e');
  }
}

/// Crashlytics breadcrumb log (mirrors `FirebaseCrashlytics.log`).
void reportLog(String message) {
  if (kIsWeb) {
    debugPrint('[CrashReport] log: $message');
    return;
  }
  try {
    FirebaseCrashlytics.instance.log(message);
  } catch (e) {
    debugPrint('[CrashReport] log failed: $e');
  }
}

/// Flutter framework error report (mirrors
/// `FirebaseCrashlytics.recordFlutterError`).
Future<void> reportFlutterError(FlutterErrorDetails details) async {
  if (kIsWeb) {
    // Web has no Crashlytics backend; print the full details (including the
    // stack) so web debugging has the same information Android gets.
    debugPrint('[CrashReport] Flutter error: ${details.exceptionAsString()}');
    debugPrint('${details.stack}');
    return;
  }
  try {
    await FirebaseCrashlytics.instance.recordFlutterError(details);
  } catch (e) {
    debugPrint('[CrashReport] recordFlutterError failed: $e');
  }
}
