import 'dart:developer' as dev;

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AnonymousDeviceEntitlement {
  AnonymousDeviceEntitlement._();

  static final AnonymousDeviceEntitlement instance =
      AnonymousDeviceEntitlement._();

  static const String _installIdKey = 'cortex_anonymous_install_id_v1';
  static const MethodChannel _deviceChannel =
      MethodChannel('com.vertex.cortex/device');
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  final FirebaseFunctions _functions =
      FirebaseFunctions.instanceFor(region: 'europe-west1');

  Future<String?> _getNativeDeviceScopedId() async {
    try {
      final androidId =
          await _deviceChannel.invokeMethod<String>('getScopedAndroidId');
      final normalized = androidId?.trim();
      if (normalized == null || normalized.length < 8) {
        return null;
      }
      return 'android-secure:$normalized';
    } on MissingPluginException {
      return null;
    } catch (e) {
      dev.log(
        '[AnonymousDeviceEntitlement] Native device id unavailable: $e',
        name: 'Auth.Anonymous',
      );
      return null;
    }
  }

  Future<String> _getOrCreateInstallId() async {
    final prefs = await SharedPreferences.getInstance();
    final nativeDeviceId = await _getNativeDeviceScopedId();
    if (nativeDeviceId != null) {
      await prefs.setString(_installIdKey, nativeDeviceId);
      await _secureStorage
          .write(key: _installIdKey, value: nativeDeviceId)
          .catchError((_) {});
      return nativeDeviceId;
    }

    final localExisting = prefs.getString(_installIdKey);
    if (localExisting != null && localExisting.isNotEmpty) {
      await _secureStorage
          .write(key: _installIdKey, value: localExisting)
          .catchError((_) {});
      return localExisting;
    }

    final secureExisting = await _secureStorage.read(key: _installIdKey);
    if (secureExisting != null && secureExisting.isNotEmpty) {
      await prefs.setString(_installIdKey, secureExisting);
      return secureExisting;
    }

    final installId = const Uuid().v4();
    await prefs.setString(_installIdKey, installId);
    await _secureStorage
        .write(key: _installIdKey, value: installId)
        .catchError((_) {});
    return installId;
  }

  Future<void> registerIfAnonymous(User? user) async {
    if (user == null || !user.isAnonymous) return;

    final installId = await _getOrCreateInstallId();
    final callable = _functions.httpsCallable('registerAnonymousDevice');

    for (var attempt = 1; attempt <= 5; attempt++) {
      try {
        await callable.call(<String, dynamic>{'installId': installId});
        dev.log(
          '[AnonymousDeviceEntitlement] Registered anonymous entitlement for UID: ${user.uid}',
          name: 'Auth.Anonymous',
        );
        return;
      } on FirebaseFunctionsException catch (e) {
        if (e.code != 'not-found' || attempt == 5) rethrow;
        await Future.delayed(Duration(milliseconds: 250 * attempt));
      }
    }
  }
}
