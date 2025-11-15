// internet.dart

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

/// A dedicated ChangeNotifier to manage and provide internet connectivity state
/// throughout the application. This centralizes the logic and makes it easy for any
/// widget to react to connectivity changes.
class InternetProvider with ChangeNotifier {
  late final StreamSubscription<bool> _subscription;
  bool _isConnected = true; // Assume connected initially to avoid UI flicker.

  bool get isConnected => _isConnected;

  InternetProvider() {
    // Immediately check initial status and then start listening for changes.
    _initialize();
  }

  void _initialize() async {
    // Set initial state faster
    _isConnected = await InternetService().hasInternet();
    notifyListeners();

    // Listen for subsequent changes. The 'status' parameter here is now correctly inferred as a bool.
    _subscription = InternetService().onConnectivityChanged.listen((status) {
      final newStatus = status;
      if (_isConnected != newStatus) {
        _isConnected = newStatus;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}


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
  late final StreamSubscription<InternetStatus> _subscription;

  /// Initialize listener and initial status
  void _initialize() {
    _subscription = _checker.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (_hasInternet != connected) {
        _hasInternet = connected;
        _controller.add(connected);

        final logMessage = "[Connectivity] Status changed to: ${connected ? 'ONLINE' : 'OFFLINE'}";
        debugPrint(logMessage);

        FirebaseCrashlytics.instance.log(logMessage);
      }
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
    _subscription.cancel();
    _controller.close();
  }
}