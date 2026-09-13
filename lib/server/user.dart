// lib/server/user.dart

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cortex/cache.dart';
import 'package:cortex/performance/stable_fingerprint.dart';
import 'package:cortex/performance/write_behind.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'subscription.dart';

class _UserCacheWrite {
  const _UserCacheWrite({required this.uid, required this.json});
  final String uid;
  final String json;
}

/// Single source of truth for authenticated user data.
///
/// Firestore can replay semantically identical snapshots (cache -> server,
/// metadata changes, listener reattachment). A stable fingerprint suppresses
/// redundant provider rebuilds and persistence. Cache writes are replaceable,
/// so a short write-behind queue folds bursts into one SharedPreferences write.
class UserProvider with ChangeNotifier {
  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  UserProvider({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    Map<String, dynamic>? initialData,
  })  : _authOverride = auth,
        _firestoreOverride = firestore,
        _userData = initialData {
    if (initialData != null) _dataFingerprint.changed(initialData);
  }

  Map<String, dynamic>? _userData;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  String? _activeUid;
  int _listenerGeneration = 0;
  bool _disposed = false;

  final FingerprintGuard _dataFingerprint = FingerprintGuard();

  late final LatestWriteQueue<_UserCacheWrite> _cacheWrites =
      LatestWriteQueue<_UserCacheWrite>(
    delay: const Duration(milliseconds: 250),
    writer: (write) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKeyForUid(write.uid), write.json);
    },
    onError: (error, stack) {
      debugPrint('[UserProvider] deferred cache write failed: $error');
    },
  );

  String _cacheKeyForUid(String uid) => 'cached_user_data_$uid';

  User? get _safeCurrentUser {
    try {
      return _auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool _dataBelongsToUser(Map<String, dynamic> data, User user) {
    final cachedUid = data['uid']?.toString();
    if (cachedUid != null && cachedUid.isNotEmpty) {
      return cachedUid == user.uid;
    }

    final cachedEmail = data['email']?.toString().toLowerCase();
    final userEmail = user.email?.toLowerCase();
    if (cachedEmail != null &&
        cachedEmail.isNotEmpty &&
        userEmail != null &&
        userEmail.isNotEmpty) {
      return cachedEmail == userEmail;
    }

    return false;
  }

  bool _isCurrentUser(User user, int generation) {
    return generation == _listenerGeneration &&
        _activeUid == user.uid &&
        _safeCurrentUser?.uid == user.uid;
  }

  Map<String, dynamic>? get userData => _userData;

  @visibleForTesting
  set userData(Map<String, dynamic>? data) {
    if (!_dataFingerprint.changed(data)) return;
    _userData = data;
    if (!_disposed) notifyListeners();
  }

  bool get isLoggedIn => _safeCurrentUser != null && _userData != null;

  bool get isUserStateReady {
    final user = _safeCurrentUser;
    final data = _userData;
    if (user == null || data == null) return false;
    if (_dataBelongsToUser(data, user)) return true;
    return _activeUid == user.uid;
  }

  String get username => _userData?['username'] as String? ?? 'Guest';
  bool get isVertex => _userData?['isVertex'] == true;

  bool get isAnonymous {
    final user = _safeCurrentUser;
    if (user != null && user.isAnonymous) return true;
    if (_userData == null) return false;
    return _userData!['accountType'] == 'anonymous';
  }

  SubscriptionEntitlement get subscription =>
      SubscriptionEntitlement.fromUserData(
        _userData,
        isAnonymous: isAnonymous,
      );

  /// Credit limits for the user's effective tier, published by the server on
  /// the user document (`creditLimits` map) and cached here with the normal
  /// user data — no extra reads. UI code reads these instead of hardcoding
  /// tier limits; the server re-derives them from `TIER_LIMITS` on every
  /// request, so a limit change on the backend propagates with the next
  /// user-data snapshot.
  CreditLimits get creditLimits =>
      CreditLimits.fromData(_userData?['creditLimits']);

  /// The user's daily realtime Voice/Flow pool (see [VoiceUsage]). Mirrored
  /// from the server's reservation/settlement writes — the server stays
  /// authoritative at every speech-token mint.
  VoiceUsage get voiceUsage => VoiceUsage.fromData(_userData?['voiceUsage']);

  /// The first initial of the user's name for use in avatars. Defaults to '?'.
  String get profileInitial {
    final name = username;
    if (name.trim().isEmpty || name == 'Guest') return '?';
    return name.trim()[0].toUpperCase();
  }

  void listenToUserData(User user) {
    _listenerGeneration++;
    final generation = _listenerGeneration;
    final accountChanged = _activeUid != user.uid;
    _activeUid = user.uid;
    _userSubscription?.cancel();

    if (accountChanged) _dataFingerprint.reset();

    if (_userData != null && !_dataBelongsToUser(_userData!, user)) {
      _userData = null;
      _dataFingerprint.changed(null);
      if (!_disposed) notifyListeners();
    }

    _userSubscription = _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen((snapshot) {
      if (!_isCurrentUser(user, generation) || _disposed) {
        debugPrint(
          '[UserProvider] Ignored stale user snapshot for: ${user.uid}',
        );
        return;
      }

      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      // Skip identical cache/server replays before JSON encoding, disk writes
      // and ChangeNotifier fan-out.
      if (!_dataFingerprint.changed(data)) return;

      _userData = data;
      unawaited(_cacheUserData(data, uid: user.uid));
      notifyListeners();
      debugPrint('[UserProvider] User data updated for: ${user.uid}');
    }, onError: (error) {
      if (!_isCurrentUser(user, generation) || _disposed) {
        debugPrint('[UserProvider] Ignored stale user error for: ${user.uid}');
        return;
      }

      debugPrint('[UserProvider] Error listening to user data: $error');
      if (error is FirebaseException && error.code == 'permission-denied') {
        unawaited(clearDataOnSignOut());
      }
    });
  }

  Future<void> fetchInitialData(User user) async {
    final accountChanged = _activeUid != user.uid;
    _activeUid = user.uid;
    if (accountChanged) _dataFingerprint.reset();
    final generation = _listenerGeneration;

    try {
      if (_userData != null && !_dataBelongsToUser(_userData!, user)) {
        _userData = null;
        _dataFingerprint.changed(null);
        if (!_disposed) notifyListeners();
      }

      await loadFromCache(user: user);
      if (!_isCurrentUser(user, generation) || _disposed) {
        debugPrint('[UserProvider] Ignored stale cached fetch for: ${user.uid}');
        return;
      }

      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!_isCurrentUser(user, generation) || _disposed) {
        debugPrint('[UserProvider] Ignored stale server fetch for: ${user.uid}');
        return;
      }

      if (doc.exists) {
        final data = doc.data();
        if (data != null && _dataFingerprint.changed(data)) {
          _userData = data;
          await _cacheUserData(data, uid: user.uid);
          if (!_disposed) notifyListeners();
          debugPrint(
            '[UserProvider] Initial user data fetched for: ${user.uid}',
          );
        }
      }
    } catch (e) {
      debugPrint('[UserProvider] Error fetching initial data: $e');
    }
  }

  Future<void> clearDataOnSignOut() async {
    _listenerGeneration++;
    _activeUid = null;
    await _userSubscription?.cancel();
    _userSubscription = null;

    // Ensure a deferred write from the previous account cannot race after the
    // cache deletion and recreate signed-out state on disk.
    await _cacheWrites.flush();

    _userData = null;
    _dataFingerprint.reset();
    await _clearCachedUserData();
    CacheService.clearAll();
    if (!_disposed) notifyListeners();
    debugPrint('[UserProvider] All user data and listeners cleared.');
  }

  Future<void> _cacheUserData(
    Map<String, dynamic> data, {
    required String uid,
  }) async {
    try {
      if (uid.isEmpty) return;
      final jsonString = jsonEncode(
        data,
        toEncodable: (object) =>
            object is Timestamp ? object.toDate().toIso8601String() : object,
      );
      _cacheWrites.add(_UserCacheWrite(uid: uid, json: jsonString));
    } catch (e) {
      debugPrint('[UserProvider] Cache encode error: $e');
    }
  }

  Future<void> loadFromCache({User? user}) async {
    final currentUser = user ?? _safeCurrentUser;
    if (currentUser == null || _disposed) return;

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = _cacheKeyForUid(currentUser.uid);
    var jsonString = prefs.getString(cacheKey);
    final isLegacyCache = jsonString == null;
    jsonString ??= prefs.getString('cached_user_data');

    if (jsonString == null) return;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic> ||
          !_dataBelongsToUser(decoded, currentUser)) {
        if (isLegacyCache) await prefs.remove('cached_user_data');
        if (_userData != null &&
            !_dataBelongsToUser(_userData!, currentUser)) {
          _userData = null;
          _dataFingerprint.changed(null);
        }
        debugPrint(
          '[UserProvider] Cached data ignored because it belongs to another user.',
        );
        return;
      }

      final changed = _dataFingerprint.changed(decoded);
      _userData = decoded;
      if (isLegacyCache) {
        await prefs.setString(cacheKey, jsonString);
        await prefs.remove('cached_user_data');
      }
      debugPrint('[UserProvider] Cached data loaded successfully.');
      if (changed && !_disposed) notifyListeners();
    } catch (e) {
      debugPrint('[UserProvider] Failed to parse cached user data: $e');
    }
  }

  Future<void> _clearCachedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('cached_user_data_'))
        .toList(growable: false);
    for (final key in keys) {
      await prefs.remove(key);
    }
    await prefs.remove('cached_user_data');
  }

  @override
  void dispose() {
    _disposed = true;
    _listenerGeneration++;
    _userSubscription?.cancel();
    unawaited(_cacheWrites.flush());
    super.dispose();
  }
}
