import 'package:cortex/device_orientation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('preferredDeviceOrientations', () {
    test('keeps phone-sized windows in portrait', () {
      expect(preferredDeviceOrientations(const Size(390, 844)), const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
    });

    test('allows all orientations on tablet-sized windows', () {
      expect(preferredDeviceOrientations(const Size(768, 1024)), const [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });

    test('uses the 600 dp shortest-side tablet breakpoint', () {
      expect(
        preferredDeviceOrientations(const Size(600, 900)),
        contains(DeviceOrientation.landscapeLeft),
      );
      expect(
        preferredDeviceOrientations(const Size(599, 900)),
        isNot(contains(DeviceOrientation.landscapeLeft)),
      );
    });
  });
}
