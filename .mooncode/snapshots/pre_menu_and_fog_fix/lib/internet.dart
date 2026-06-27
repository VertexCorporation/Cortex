// internet.dart

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

/// A dedicated ChangeNotifier to manage and provide internet connectivity state.
class InternetProvider with ChangeNotifier {
  late final StreamSubscription<bool> _subscription;
  bool _forceOffline = false;
  bool _isConnected = true; // Assume connected initially (Optimistic UI).

  bool get isConnected => _forceOffline ? false : _isConnected;

  /// Forces the app to behave as if it's offline.
  /// Used for maintenance mode bypass.
  void setForceOffline(bool value) {
    if (_forceOffline != value) {
      _forceOffline = value;
      notifyListeners();
    }
  }

  InternetProvider() {
    _initialize();
  }

  void _initialize() async {
    // 1. Initial fast check
    _isConnected = await InternetService().hasInternet();
    notifyListeners();

    // 2. Listen for live changes
    _subscription = InternetService().onConnectivityChanged.listen((status) {
      if (_isConnected != status) {
        _isConnected = status;
        // Only notify if we are NOT in forced offline mode.
        // If forced offline, isConnected remains false regardless of real status.
        // But we should still notify if the *real* status changes?
        // Actually, if we are forced offline, isConnected is always false.
        // So a change in _isConnected implementation detail shouldn't fire a notification
        // if the public getter result doesn't change?
        // But ChangeNotifier usually just notifies. Consumers check the value.
        // If _forceOffline is true, isConnected returns false.
        // If _isConnected flips true->false, isConnected is still false.
        // So technically no change.
        notifyListeners();
      }
    });
  }

  /// --- NEW METHOD ---
  /// Called by AppInitializer during startup to get the definitive
  /// current status before running background tasks.
  Future<void> checkInternetConnection() async {
    final bool currentStatus = await InternetService().hasInternet();
    if (_isConnected != currentStatus) {
      _isConnected = currentStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// Singleton service to centralize internet connectivity checks (No changes needed here, but kept for context)
class InternetService {
  InternetService._internal() {
    _initialize();
  }

  static final InternetService _instance = InternetService._internal();
  factory InternetService() => _instance;

  final InternetConnection _checker = InternetConnection.createInstance(
    checkInterval: const Duration(seconds: 2),
  );
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  bool _hasInternet = true;
  late final StreamSubscription<InternetStatus> _subscription;

  void _initialize() {
    _subscription = _checker.onStatusChange.listen((status) {
      final connected = status == InternetStatus.connected;
      if (_hasInternet != connected) {
        _hasInternet = connected;
        _controller.add(connected);

        // Only log significant changes to keep logs clean
        if (kDebugMode) {
          debugPrint(
              "[Connectivity] Status changed to: ${connected ? 'ONLINE' : 'OFFLINE'}");
        }
      }
    });
  }

  bool get currentStatus => _hasInternet;

  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<bool> hasInternet() => _checker.hasInternetAccess;

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
