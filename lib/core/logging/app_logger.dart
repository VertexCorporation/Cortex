// lib/core/logging/app_logger.dart

import 'dart:developer' as dev;
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Centralized, corporate-grade logging for Cortex.
///
/// Severity-named helpers:
///   * [v] / [d] (verbose / debug) are gated behind [kDebugMode] and never emit
///     in release builds — so verbose/trace noise never ships.
///   * [i] / [w] / [e] (info / warning / error) always emit via `dart:developer`
///     (visible in DevTools) and forward to Crashlytics in release builds.
///
/// This replaces ad-hoc [debugPrint], [print], and scattered
/// `FirebaseCrashlytics.instance.recordError` usages across the codebase.
class AppLogger {
  AppLogger._();

  /// The default logging category/name when none is supplied.
  static const String defaultName = 'Cortex';

  /// Network / expected noise that should NOT be reported to Crashlytics.
  static const List<String> _networkNoise = <String>[
    'SocketException',
    'ClientException',
    'DioException',
    'HandshakeException',
    'TLSException',
    'TimeoutException',
    'CertificateException',
    'WebSocketException',
    'Connection closed',
    'Connection reset',
    'Failed host lookup',
    'Network is unreachable',
    'Connection timed out',
    'ENOTFOUND',
  ];

  /// Returns true when the error is worth reporting to Crashlytics.
  static bool shouldReport(Object? error) {
    if (error == null) return false;
    final String text = error.toString();
    for (final String noise in _networkNoise) {
      if (text.contains(noise)) return false;
    }
    return true;
  }

  static void v(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    dev.log(
      message.toString(),
      name: name ?? defaultName,
      error: error,
      stackTrace: stackTrace,
      level: 300, // FINEST
    );
  }

  static void d(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!kDebugMode) return;
    dev.log(
      message.toString(),
      name: name ?? defaultName,
      error: error,
      stackTrace: stackTrace,
      level: 500, // FINE
    );
  }

  static void i(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message.toString(),
      name: name ?? defaultName,
      error: error,
      stackTrace: stackTrace,
      level: 700, // INFO
    );
  }

  static void w(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message.toString(),
      name: name ?? defaultName,
      error: error,
      stackTrace: stackTrace,
      level: 800, // WARNING
    );
    if (!kDebugMode && error != null && shouldReport(error)) {
      CrashlyticsService.recordError(error, stackTrace, reason: message.toString());
    }
  }

  static void e(
    Object? message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
    bool fatal = false,
  }) {
    dev.log(
      message.toString(),
      name: name ?? defaultName,
      error: error,
      stackTrace: stackTrace,
      level: 900, // SEVERE
    );
    if (error != null && shouldReport(error)) {
      CrashlyticsService.recordError(
        error,
        stackTrace,
        reason: message.toString(),
        fatal: fatal,
      );
    }
  }
}

/// Single source of truth for Crashlytics usage across the app.
class CrashlyticsService {
  CrashlyticsService._();

  static FirebaseCrashlytics get instance => FirebaseCrashlytics.instance;

  static void recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    bool fatal = false,
    Map<String, dynamic>? customKeys,
  }) {
    if (!AppLogger.shouldReport(error)) return;
    if (customKeys != null) {
      for (final MapEntry<String, dynamic> entry in customKeys.entries) {
        instance.setCustomKey(entry.key, entry.value);
      }
    }
    instance.recordError(error, stackTrace, reason: reason, fatal: fatal);
  }

  static void setUserIdentifier(String? id) =>
      instance.setUserIdentifier(id ?? '');

  static void setCustomKey(String key, Object value) =>
      instance.setCustomKey(key, value);

  static void log(String message) => instance.log(message);
}
