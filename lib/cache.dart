/*  cache.dart (FINAL, UPDATED FOR NEWS IMAGES)
 *───────────────────────────────────────────────────────────────────────────
 *  Lightweight in-memory cache helper.
 *  - Added Section ⑥ for caching temporary news image URLs to prevent shimmer.
 *───────────────────────────────────────────────────────────────────────────*/

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../conversations/manager.dart';
import '../models/backend/data.dart';

/// A singleton class to track the state of app-wide data.
class AppDataState {
  static final AppDataState _instance = AppDataState._internal();
  factory AppDataState() => _instance;
  AppDataState._internal();

  bool _hasUserDataChanged = false;

  void markUserDataAsChanged() {
    debugPrint("[AppDataState] User data has been marked as changed. A refresh will be forced on next relevant screen load.");
    _hasUserDataChanged = true;
  }

  bool get needsRefresh {
    if (_hasUserDataChanged) {
      debugPrint("[AppDataState] Change flag was checked and is TRUE. Resetting flag and reporting need for refresh.");
      _hasUserDataChanged = false;
      return true;
    }
    return false;
  }
}


class CacheService {
  /* SECTION ① – Model Selection */
  static List<ModelInfo>? cachedAllModels;
  static List<ModelInfo>? cachedFilteredModels;

  /* SECTION ② – Conversation Inbox */
  static Map<String, ConversationManager>? cachedConversationManagers;
  static List<String>?                     cachedConversationOrder;
  static List<String>?                     cachedStarredIds;
  static List<Map<String, dynamic>>?       cachedUserModels;

  /* SECTION ③ – User Settings */
  static Map<String, dynamic>? cachedSettingsUserData;

  /* SECTION ④ – Premium Products (IAP) */
  static List<ProductDetails>? cachedPremiumProducts;

  /* SECTION ⑤ – Models Discovery Screen */
  static List<Map<String, dynamic>>? cachedModelsScreenData;

  /*───────────────────────────────
   * SECTION ⑥ – News Image URLs (NEW!)
   * Caches the signed URLs for news cover images to prevent re-fetching
   * and eliminate the shimmer effect on screen transitions.
   *──────────────────────────────*/
  static Map<String, String>? cachedNewsImageUrls;


  /* Internal timers – one per section */
  static Timer? _modelCacheTimer;
  static Timer? _conversationCacheTimer;
  static Timer? _settingsCacheTimer;
  static Timer? _premiumCacheTimer;
  static Timer? _modelsScreenCacheTimer;
  static Timer? _newsImageCacheTimer; // NEW for News Image URLs

  // MODEL CACHING
  static void touchModelCache() => _modelCacheTimer?.cancel();
  static void startModelCacheTimer({ Duration? timeout, VoidCallback? onClear }) {
    _modelCacheTimer?.cancel();
    _modelCacheTimer = Timer(timeout ?? const Duration(minutes: 2), () {
      cachedAllModels      = null;
      cachedFilteredModels = null;
      debugPrint('CacheService ▸ Model cache cleared.');
      onClear?.call();
    });
  }

  // CONVERSATION CACHING
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

  // SETTINGS CACHING
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

  // PREMIUM PRODUCTS CACHING
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

  // MODELS SCREEN CACHING
  static void touchModelsScreenCache() => _modelsScreenCacheTimer?.cancel();
  static void startModelsScreenCacheTimer({ Duration? timeout, VoidCallback? onClear }) {
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
  // NEWS IMAGE URL CACHING – public helpers (NEW!)
  // ──────────────────────────────────────────────────────────
  static void touchNewsImageCache() => _newsImageCacheTimer?.cancel();

  static void startNewsImageCacheTimer({
    Duration?   timeout,
    VoidCallback? onClear,
  }) {
    _newsImageCacheTimer?.cancel();
    // URLs expire in 10 mins, so we clear our cache in 8 to be safe.
    _newsImageCacheTimer = Timer(timeout ?? const Duration(minutes: 8), () {
      invalidateNewsImageCache();
      debugPrint('CacheService ▸ News image URL cache cleared due to timeout.');
      onClear?.call();
    });
  }

  static void invalidateNewsImageCache() {
    cachedNewsImageUrls = null;
    debugPrint('CacheService ▸ News image URL cache invalidated.');
  }


  // MISC – wipe everything (used on logout etc.)
  static void clearAll() {
    cachedAllModels = null;
    cachedFilteredModels = null;
    cachedConversationManagers = null;
    cachedConversationOrder = null;
    cachedStarredIds = null;
    cachedUserModels = null;
    cachedSettingsUserData = null;
    cachedPremiumProducts = null;
    cachedModelsScreenData = null;
    cachedNewsImageUrls = null; // NEW

    _modelCacheTimer?.cancel();
    _conversationCacheTimer?.cancel();
    _settingsCacheTimer?.cancel();
    _premiumCacheTimer?.cancel();
    _modelsScreenCacheTimer?.cancel();
    _newsImageCacheTimer?.cancel(); // NEW

    _modelCacheTimer = null;
    _conversationCacheTimer = null;
    _settingsCacheTimer = null;
    _premiumCacheTimer = null;
    _modelsScreenCacheTimer = null;
    _newsImageCacheTimer = null; // NEW
  }
}