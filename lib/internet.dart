// internet.dart

import 'dart:async';

import 'package:cortex/performance/async_coalescer.dart';
import 'package:cortex/performance/perf_trace.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class InternetProvider with ChangeNotifier {
  StreamSubscription<bool>? _subscription;
  bool _forceOffline = false;
  bool _isConnected = true;
  bool _disposed = false;

  bool get isConnected => _forceOffline ? false : _isConnected;

  void setForceOffline(bool value) {
    if (_forceOffline == value) return;
    final before = isConnected;
    _forceOffline = value;
    if (!_disposed && before != isConnected) notifyListeners();
  }

  InternetProvider() {
    unawaited(_initialize());
  }

  Future<void> _initialize() async {
    final service = InternetService();
    final initial = await service.hasInternet();
    if (_disposed) return;

    final before = isConnected;
    _isConnected = initial;
    if (before != isConnected) notifyListeners();

    _subscription = service.onConnectivityChanged.listen((status) {
      if (_disposed || _isConnected == status) return;
      final visibleBefore = isConnected;
      _isConnected = status;
      if (visibleBefore != isConnected) notifyListeners();
    });
  }

  Future<void> checkInternetConnection() async {
    final currentStatus = await InternetService().hasInternet();
    if (_disposed || _isConnected == currentStatus) return;
    final before = isConnected;
    _isConnected = currentStatus;
    if (before != isConnected) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    super.dispose();
  }
}

/// Singleton connectivity service. Simultaneous explicit probes share one
/// platform/network operation, while stream updates remain the continuous
/// source of connectivity changes.
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
  final AsyncCoalescer<bool> _probeCoalescer = AsyncCoalescer<bool>();

  bool _hasInternet = true;
  StreamSubscription<InternetStatus>? _subscription;
  bool _disposed = false;

  void _initialize() {
    _subscription = _checker.onStatusChange.listen((status) {
      if (_disposed) return;
      _publish(status == InternetStatus.connected);
    });
  }

  void _publish(bool connected) {
    if (_hasInternet == connected) return;
    _hasInternet = connected;
    if (!_controller.isClosed) _controller.add(connected);
    if (kDebugMode) {
      debugPrint(
        '[Connectivity] Status changed to: ${connected ? 'ONLINE' : 'OFFLINE'}',
      );
    }
  }

  bool get currentStatus => _hasInternet;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  Future<bool> hasInternet() {
    if (_disposed) return Future<bool>.value(_hasInternet);
    return _probeCoalescer.run(() {
      return PerfTrace.measureAsync('network.connectivity_probe', () async {
        final connected = await _checker.hasInternetAccess;
        if (!_disposed) _publish(connected);
        return connected;
      });
    });
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _subscription?.cancel();
    _subscription = null;
    _probeCoalescer.forget();
    _controller.close();
  }
}
