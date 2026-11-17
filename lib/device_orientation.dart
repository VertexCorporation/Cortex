import 'package:flutter/services.dart';

/// Keeps phones portrait while allowing tablets to rotate freely.
List<DeviceOrientation> preferredDeviceOrientations(Size logicalDisplaySize) {
  if (logicalDisplaySize.shortestSide >= 600) {
    return const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ];
  }

  return const [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown];
}
