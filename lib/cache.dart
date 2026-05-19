// cache.dart (FINAL, OPTIMIZED)
//───────────────────────────────────────────────────────────────────────────
//  Lightweight, scalable in-memory cache helper.
//  - Refactored to use a centralized Map and Enum for O(1) access and easy extensibility.
//  - Eliminates boilerplate code for adding new cache types.
//───────────────────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:flutter/material.dart';

/// Defines the unique keys for each type of data that can be cached.
/// This provides type-safety and improves code readability.
enum CacheKey {
  // Model Selection
  allModels,
  filteredModels,
  recentModels,

  // Conversation Inbox
  conversationManagers,
  conversationOrder,
  starredIds,
  userModels,

  // User Settings
  settingsUserData,

  // Premium Products (IAP)
  premiumProducts,

  // Premium Screen State (products + special offer - for preloading)
  premiumScreenState,

  // Models Discovery Screen
  modelsScreenData,

  // News Image URLs
  newsImageUrls,
}

/// A singleton class to track the state of app-wide data.
class AppDataState {
  static final AppDataState _instance = AppDataState._internal();

  factory AppDataState() => _instance;

  AppDataState._internal();

  bool _hasUserDataChanged = false;

  void markUserDataAsChanged() {
    debugPrint("[AppDataState] User data marked as changed.");
    _hasUserDataChanged = true;
  }

  bool get needsRefresh {
    if (_hasUserDataChanged) {
      _hasUserDataChanged = false; // Reset the flag after checking.
      debugPrint(
          "[AppDataState] Change flag was TRUE. Reporting need for refresh.");
      return true;
    }
    return false;
  }
}


/// A highly optimized, centralized in-memory cache service.
class CacheService {
  /// The central data store. Access is O(1) thanks to the Map structure.
  static final Map<CacheKey, dynamic> _cache = {};

  /// The central store for cache expiration timers.
  static final Map<CacheKey, Timer> _timers = {};

  /// The default expiration times for different cache types.
  static const Map<CacheKey, Duration> _defaultTimeouts = {
    CacheKey.allModels: Duration(minutes: 2),
    CacheKey.filteredModels: Duration(minutes: 2),
    CacheKey.recentModels: Duration(minutes: 10),
    CacheKey.conversationManagers: Duration(minutes: 2),
    CacheKey.conversationOrder: Duration(minutes: 2),
    CacheKey.starredIds: Duration(minutes: 2),
    CacheKey.userModels: Duration(minutes: 2),
    CacheKey.settingsUserData: Duration(minutes: 3),
    CacheKey.premiumProducts: Duration(minutes: 15),
    CacheKey.premiumScreenState: Duration(minutes: 15),
    CacheKey.modelsScreenData: Duration(minutes: 5),
    CacheKey.newsImageUrls: Duration(minutes: 8),
    // URLs expire in 10, so 8 is safer.
  };

  /// Retrieves a value from the cache.
  /// Returns the cached data, or `null` if it doesn't exist.
  /// The type parameter `T` allows for strong typing on return.
  ///
  /// Example: `final List<ModelInfo>? models = CacheService.get<List<ModelInfo>>(CacheKey.allModels);`
  static T? get<T>(CacheKey key) {
    // Before returning the data, we "touch" the cache to reset its expiration timer.
    touch(key);
    if (_cache.containsKey(key)) {
      return _cache[key] as T?;
    }
    return null;
  }

  /// Stores or updates a value in the cache and starts its expiration timer.
  ///
  /// Example: `CacheService.set(CacheKey.allModels, myListOfModels);`
  static void set(CacheKey key, dynamic value) {
    _cache[key] = value;
    debugPrint('CacheService ▸ Set/Updated data for [${key.name}]');
    startTimer(key);
  }

  /// Removes a specific entry from the cache and cancels its timer.
  ///
  /// Example: `CacheService.invalidate(CacheKey.allModels);`
  static void invalidate(CacheKey key) {
    if (_cache.remove(key) != null) {
      debugPrint('CacheService ▸ Invalidated cache for [${key.name}]');
    }
    _timers[key]?.cancel();
    _timers.remove(key);
  }

  /// Resets the expiration timer for a specific cache entry without changing its data.
  /// This is useful when data is accessed but not modified.
  static void touch(CacheKey key) {
    if (_cache.containsKey(key)) {
      startTimer(key); // Restarting the timer effectively "touches" it.
    }
  }

  /// Starts or restarts the expiration timer for a cache entry.
  static void startTimer(CacheKey key, {VoidCallback? onClear}) {
    // Cancel any existing timer for this key.
    _timers[key]?.cancel();

    final timeout = _defaultTimeouts[key] ??
        const Duration(minutes: 5); // Fallback timeout

    _timers[key] = Timer(timeout, () {
      invalidate(key);
      debugPrint(
          'CacheService ▸ Cache for [${key.name}] cleared due to timeout.');
      onClear?.call();
    });
  }

  /// Clears the entire cache and cancels all timers.
  /// Typically used on user logout.
  static void clearAll() {
    for (var timer in _timers.values) {
      timer.cancel();
    }
    _timers.clear();
    _cache.clear();
    debugPrint('CacheService ▸ All caches cleared.');
  }

  // --- COMPOSITE INVALIDATION HELPERS ---
  // For convenience, we can keep helpers that invalidate multiple keys at once.

  /// Invalidates all cache entries related to the conversation inbox.
  static void invalidateConversationCache() {
    invalidate(CacheKey.conversationManagers);
    invalidate(CacheKey.conversationOrder);
    invalidate(CacheKey.starredIds);
    invalidate(CacheKey.userModels);
    debugPrint('CacheService ▸ All conversation-related caches invalidated.');
  }
}