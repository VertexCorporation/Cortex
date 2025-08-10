//system_info

import 'package:flutter/services.dart';

class SystemInfoProvider {
  static Future<SystemInfoData> fetchSystemInfo() async {
    final int deviceMemory = await _getDeviceMemory();
    final int freeStorage = await _getFreeStorage();
    final int totalStorage = await _getTotalStorage();
    final int usedMemory = await _getUsedMemory();

    return SystemInfoData(
      deviceMemory: deviceMemory,
      freeStorage: freeStorage,
      totalStorage: totalStorage,
      usedMemory: usedMemory,
    );
  }

  static Future<int> _getDeviceMemory() async {
    try {
      final int result = await _memoryChannel.invokeMethod(
          'getDeviceMemory');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get device memory: '${e.message}'");
      return -1;
    }
  }

  static Future<int> _getUsedMemory() async {
    try {
      final int result = await _memoryChannel.invokeMethod('getUsedMemory');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get used memory: '${e.message}'");
      return -1;
    }
  }

  static Future<int> _getFreeStorage() async {
    try {
      final int result = await _storageChannel.invokeMethod('getFreeStorage');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get free storage: '${e.message}'");
      return -1;
    }
  }

  static Future<int> _getTotalStorage() async {
    try {
      final int result = await _storageChannel.invokeMethod('getTotalStorage');
      return result;
    } on PlatformException catch (e) {
      print("Failed to get total storage: '${e.message}'");
      return -1;
    }
  }

  static const MethodChannel _storageChannel = MethodChannel(
      'com.vertex.cortex/storage');
  static const MethodChannel _memoryChannel = MethodChannel(
      'com.vertex.cortex/memory');
}

class SystemInfoData {
  final int deviceMemory; // in MB
  final int freeStorage;  // in MB
  final int totalStorage; // in MB
  final int usedMemory;   // in MB

  SystemInfoData({
    required this.deviceMemory,
    required this.freeStorage,
    required this.totalStorage,
    required this.usedMemory,
  });
}
