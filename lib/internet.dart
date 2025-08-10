// internet.dart

import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

/// Singleton service to centralize internet connectivity checks
class InternetService {
  InternetService._internal() {
    _initialize();
  }

  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;

  final InternetConnection _checker = InternetConnection();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _hasInternet = true;

  /// Initialize listener and initial status
  void _initialize() {
    // Listen to status changes
    _checker.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      _hasInternet = connected;
      _controller.add(connected);
    });
    // Check initial status
    hasInternet().then((connected) {
      _hasInternet = connected;
      _controller.add(connected);
    });
  }

  /// Returns current known connectivity status
  bool get currentStatus => _hasInternet;

  /// Returns a broadcast stream of connectivity changes
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Performs an immediate connectivity check
  Future<bool> hasInternet() => _checker.hasInternetAccess;

  /// Dispose the stream controller (call at app teardown)
  void dispose() {
    _controller.close();
  }
}