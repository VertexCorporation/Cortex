// internet.dart

import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'dart:async';

/// A dedicated ChangeNotifier to manage and provide internet connectivity state.
class InternetProvider with ChangeNotifier {
  late final StreamSubscription<bool> _subscription;
  bool _isConnected = true; // Assume connected initially (Optimistic UI).

  bool get isConnected => _isConnected;

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

  final InternetConnection _checker = InternetConnection();
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
          debugPrint("[Connectivity] Status changed to: ${connected ? 'ONLINE' : 'OFFLINE'}");
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