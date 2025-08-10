/*  cache.dart (FINAL, COMPLETE, AND CORRECTED)
 *───────────────────────────────────────────────────────────────────────────
 *  Lightweight in-memory cache helper.
 *  - Keeps frequently-used data structures alive between screen switches
 *    to avoid expensive database / disk reads.
 *  - Automatically expires each cache after a configurable timeout.
 *  - Five independent sections:
 *      ① Model Selection screen      (SelectionScreen)
 *      ② Conversation list / Inbox   (MenuScreen)
 *      ③ User Settings screen        (SettingsScreen)
 *      ④ Premium Products screen     (PremiumScreen)
 *      ⑤ Models Discovery screen     (ModelsScreen)
 *───────────────────────────────────────────────────────────────────────────*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../conversations/manager.dart';
import '../models/backend/data.dart';

/// A singleton class to track the state of app-wide data.
/// It provides a simple flag to signal when critical data, like user
/// subscriptions, has changed and a refresh is required.
class AppDataState {
  static final AppDataState _instance = AppDataState._internal();
  factory AppDataState() => _instance;
  AppDataState._internal();

  bool _hasUserDataChanged = false;

  /// Call this method after any action that changes user data on the server,
  /// such as a purchase, profile update, or deletion.
  void markUserDataAsChanged() {
    debugPrint("[AppDataState] User data has been marked as changed. A refresh will be forced on next relevant screen load.");
    _hasUserDataChanged = true;
  }

  /// Screens should check this property before loading data.
  /// If it returns true, they must bypass the cache and fetch fresh data.
  /// The flag is automatically reset after being checked.
  bool get needsRefresh {
    if (_hasUserDataChanged) {
      debugPrint("[AppDataState] Change flag was checked and is TRUE. Resetting flag and reporting need for refresh.");
      _hasUserDataChanged = false; // Reset after checking
      return true;
    }
    return false;
  }
}


class CacheService {
  /*───────────────────────────────
   * SECTION ① – Model Selection
   *──────────────────────────────*/
  static List<ModelInfo>? cachedAllModels;
  static List<ModelInfo>? cachedFilteredModels;

  /*───────────────────────────────
   * SECTION ② – Conversation Inbox
   *──────────────────────────────*/
  static Map<String, ConversationManager>? cachedConversationManagers;
  static List<String>?                     cachedConversationOrder;
  static List<String>?                     cachedStarredIds;
  static List<Map<String, dynamic>>?       cachedUserModels;

  /*───────────────────────────────
   * SECTION ③ – User Settings
   *──────────────────────────────*/
  static Map<String, dynamic>? cachedSettingsUserData;

  /*───────────────────────────────────
   * SECTION ④ – Premium Products (IAP)
   *───────────────────────────────────*/
  static List<ProductDetails>? cachedPremiumProducts;

  /*───────────────────────────────────
   * SECTION ⑤ – Models Discovery Screen
   *───────────────────────────────────*/
  static List<Map<String, dynamic>>? cachedModelsScreenData;


  /*───────────────────────────────
   * Internal timers – one per section
   *──────────────────────────────*/
  static Timer? _modelCacheTimer; // RESTORED ORIGINAL NAME
  static Timer? _conversationCacheTimer;
  static Timer? _settingsCacheTimer;
  static Timer? _premiumCacheTimer;
  static Timer? _modelsScreenCacheTimer; // NEW for ModelsScreen

  // ──────────────────────────────────────────────────────────
  // MODEL CACHING – public helpers (RESTORED)
  // ──────────────────────────────────────────────────────────
  static void touchModelCache() => _modelCacheTimer?.cancel();

  static void startModelCacheTimer({
    Duration?   timeout,
    VoidCallback? onClear,
  }) {
    _modelCacheTimer?.cancel();
    _modelCacheTimer = Timer(timeout ?? const Duration(minutes: 2), () {
      cachedAllModels      = null;
      cachedFilteredModels = null;
      debugPrint('CacheService ▸ Model cache cleared.');
      onClear?.call();
    });
  }

  // ──────────────────────────────────────────────────────────
  // CONVERSATION CACHING – public helpers
  // ──────────────────────────────────────────────────────────
  static void touchConversationCache() => _conversationCacheTimer?.cancel();

  static void startConversationCacheTimer({ Duration? timeout, VoidCallback? onClear }) {
    _conversationCacheTimer?.cancel();
    _conversationCacheTimer = Timer(timeout ?? const Duration(minutes: 2), () {
      invalidateConversationCache();
      debugPrint('CacheService ▸ Conversation cache cleared.');
      onClear?.call();
    });
  }

  static void invalidateConversationCache() {
    cachedConversationManagers = null;
    cachedConversationOrder    = null;
    cachedStarredIds           = null;
    cachedUserModels           = null;
  }

  // ──────────────────────────────────────────────────────────
  // SETTINGS CACHING – public helpers
  // ──────────────────────────────────────────────────────────
  static void touchSettingsCache() => _settingsCacheTimer?.cancel();

  static void startSettingsCacheTimer({ Duration? timeout, VoidCallback? onClear }) {
    _settingsCacheTimer?.cancel();
    _settingsCacheTimer = Timer(timeout ?? const Duration(minutes: 3), () {
      invalidateSettingsCache();
      debugPrint('CacheService ▸ Settings cache cleared.');
      onClear?.call();
    });
  }

  static void invalidateSettingsCache() {
    cachedSettingsUserData = null;
  }

  static void updateSettingsCache(Map<String, dynamic> data) {
    cachedSettingsUserData = data;
    debugPrint('CacheService ▸ Settings cache was updated with new data.');
  }

  // ──────────────────────────────────────────────────────────
  // PREMIUM PRODUCTS CACHING – public helpers
  // ──────────────────────────────────────────────────────────
  static void touchPremiumCache() => _premiumCacheTimer?.cancel();

  static void startPremiumCacheTimer({ Duration? timeout, VoidCallback? onClear }) {
    _premiumCacheTimer?.cancel();
    _premiumCacheTimer = Timer(timeout ?? const Duration(minutes: 10), () {
      invalidatePremiumCache();
      debugPrint('CacheService ▸ Premium products cache cleared.');
      onClear?.call();
    });
  }

  static void invalidatePremiumCache() {
    cachedPremiumProducts = null;
    debugPrint('CacheService ▸ Premium products cache invalidated.');
  }

  // ──────────────────────────────────────────────────────────
  // MODELS SCREEN CACHING – public helpers (NEW)
  // ──────────────────────────────────────────────────────────
  static void touchModelsScreenCache() => _modelsScreenCacheTimer?.cancel();

  static void startModelsScreenCacheTimer({
    Duration?   timeout,
    VoidCallback? onClear,
  }) {
    _modelsScreenCacheTimer?.cancel();
    _modelsScreenCacheTimer = Timer(timeout ?? const Duration(minutes: 5), () {
      invalidateModelsScreenCache();
      debugPrint('CacheService ▸ ModelsScreen cache cleared due to timeout.');
      onClear?.call();
    });
  }

  static void invalidateModelsScreenCache() {
    cachedModelsScreenData = null;
    debugPrint('CacheService ▸ ModelsScreen cache invalidated.');
  }

  // ──────────────────────────────────────────────────────────
  // MISC – wipe everything (used on logout etc.)
  // ──────────────────────────────────────────────────────────
  static void clearAll() {
    // Section 1
    cachedAllModels            = null;
    cachedFilteredModels       = null;
    // Section 2
    cachedConversationManagers = null;
    cachedConversationOrder    = null;
    cachedStarredIds           = null;
    cachedUserModels           = null;
    // Section 3
    cachedSettingsUserData     = null;
    // Section 4
    cachedPremiumProducts      = null;
    // Section 5
    cachedModelsScreenData     = null;

    // Timers
    _modelCacheTimer?.cancel(); // RESTORED
    _conversationCacheTimer?.cancel();
    _settingsCacheTimer?.cancel();
    _premiumCacheTimer?.cancel();
    _modelsScreenCacheTimer?.cancel();

    _modelCacheTimer        = null; // RESTORED
    _conversationCacheTimer = null;
    _settingsCacheTimer     = null;
    _premiumCacheTimer      = null;
    _modelsScreenCacheTimer = null;
  }
}