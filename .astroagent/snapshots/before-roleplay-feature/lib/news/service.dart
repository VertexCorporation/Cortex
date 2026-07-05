// lib/news/service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../initialization.dart';
import '../../../../../internet.dart';
import 'data.dart';

enum NewsState {
  initial,
  loading,
  success,
}

class NewsService with ChangeNotifier {
  late Dio _dio;
  late AppInitializer _appInitializer;
  late InternetProvider _internetProvider;

  final Set<String> _languagesWithFetchErrors = {};
  bool _isLoadingOperation = false;
  final Map<String, List<NewsArticle>> _cachedArticlesByLang = {};
  String _currentLanguageCode = 'en';

  NewsService({
    required Dio dio,
    required AppInitializer appInitializer,
    required InternetProvider internetProvider,
  }) {
    _dio = dio;
    _appInitializer = appInitializer;
    _internetProvider = internetProvider;
    _internetProvider.addListener(_onConnectivityChanged);
    debugPrint("[NewsService] 🟢 Instance created.");
  }

  @override
  void dispose() {
    _internetProvider.removeListener(_onConnectivityChanged);
    super.dispose();
  }

  void updateDependencies({
    required AppInitializer appInitializer,
    required Dio dio,
    required InternetProvider internetProvider,
  }) {
    _appInitializer = appInitializer;
    _dio = dio;
    if (_internetProvider != internetProvider) {
      _internetProvider.removeListener(_onConnectivityChanged);
      _internetProvider = internetProvider;
      _internetProvider.addListener(_onConnectivityChanged);
    }
  }

  void _onConnectivityChanged() {
    if (_internetProvider.isConnected && _languagesWithFetchErrors.isNotEmpty) {
      debugPrint(
          "[NewsService] 📶 Internet reconnected. Retrying failed languages...");
      final bool shouldRetry = _languagesWithFetchErrors.contains(
          _currentLanguageCode);
      _languagesWithFetchErrors.clear();
      if (shouldRetry) {
        loadNewsForLanguage(_currentLanguageCode);
      }
    }
  }

  // --- State Management ---
  NewsState _state = NewsState.initial;

  NewsState get state => _state;

  List<NewsArticle> get articles =>
      _cachedArticlesByLang[_currentLanguageCode] ?? [];

  static const String _cacheKey = 'news_cache_data_v3';
  static const String _timestampKey = 'news_cache_timestamp_v3';
  static const String _getCacheUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl";

  // --- Public Methods ---

  Future<void> loadNewsForLanguage(String languageCode) async {
    _currentLanguageCode = languageCode;

    // Memory Cache Check
    if (_cachedArticlesByLang.containsKey(languageCode) &&
        (_cachedArticlesByLang[languageCode]?.isNotEmpty ?? false)) {
      _setState(NewsState.success, "memory_cache");
      return;
    }

    if (_isLoadingOperation) return;

    _isLoadingOperation = true;
    _setState(NewsState.loading, "start_fetch");

    try {
      await _appInitializer.onCoreServicesReady;

      bool loadedFromDisk = await _loadFromCache();
      if (!loadedFromDisk) {
        await _fetchFromNetworkAndCache();
      }
    } catch (e, s) {
      _handleError('Fetch failed', e, s);
    } finally {
      debugPrint(
          "[NewsService] 🏁 Operation finished (Success or Error). Resetting flag.");
      _isLoadingOperation = false;
    }
  }

  Future<void> forceRefreshCurrentLanguage() async {
    if (_isLoadingOperation) return;
    _isLoadingOperation = true;
    _setState(NewsState.loading, "force_refresh");
    try {
      await _appInitializer.onCoreServicesReady.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            debugPrint(
                "[NewsService] ⚠️ AppInit timed out. Proceeding anyway.");
          }
      );
      await _fetchFromNetworkAndCache();
    } catch (e, s) {
      _handleError('Refresh failed', e, s);
    } finally {
      _isLoadingOperation = false;
    }
  }

  // --- Private Helper Methods ---

  Future<bool> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastFetchTimestamp = prefs.getInt(_timestampKey);

      if (lastFetchTimestamp != null) {
        final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(
            lastFetchTimestamp);
        if (DateTime
            .now()
            .difference(lastFetchDate)
            .inDays < 7) {
          final cachedData = prefs.getString(_cacheKey);
          if (cachedData != null) {
            final parsedArticles = _parseAndValidateArticles(cachedData);
            if (parsedArticles.isNotEmpty) {
              _cachedArticlesByLang[_currentLanguageCode] = parsedArticles;
              _setState(NewsState.success, "disk_cache");
              return true;
            }
          }
        }
      }
    } catch (e) {
      debugPrint("[NewsService] ⚠️ Cache read error: $e");
    }
    return false;
  }

  Future<void> _fetchFromNetworkAndCache() async {
    int attempts = 0;
    const int maxAttempts = 3;

    while (attempts < maxAttempts) {
      try {
        attempts++;
        debugPrint(
            "[NewsService] 📡 Network Attempt $attempts/$maxAttempts started.");

        User? user = FirebaseAuth.instance.currentUser;
        if (user == null) {
          debugPrint("[NewsService] 👤 User is null immediately. Will retry.");
          throw Exception("User session missing.");
        }

        debugPrint("[NewsService] 🔑 Getting ID Token...");
        final idToken = await user.getIdToken(attempts == 1).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException("Token fetch timed out")
        );

        debugPrint("[NewsService] 🌍 Calling Cloud Function...");
        final urlResponse = await _dio.post(
          _getCacheUrlEndpoint,
          data: jsonEncode({'data': null}),
          options: Options(
            headers: {
              "Authorization": "Bearer $idToken",
              "Content-Type": "application/json"
            },
            sendTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        );

        if (urlResponse.statusCode != 200 || urlResponse.data == null) {
          throw Exception("Cloud Function failed: ${urlResponse.statusCode}");
        }

        final String? signedUrl = urlResponse.data['result']?['signedUrl'];
        if (signedUrl == null) {
          throw Exception(
              "Cloud Function returned NULL signedUrl.");
        }

        debugPrint("[NewsService] 🔗 Downloading content...");
        final newsResponse = await _dio.get(
          signedUrl,
          options: Options(
              responseType: ResponseType.bytes,
              receiveTimeout: const Duration(seconds: 10)
          ),
        );

        if (newsResponse.statusCode == 200 && newsResponse.data != null) {
          final newsJsonString = utf8.decode(newsResponse.data as List<int>);
          final parsedArticles = _parseAndValidateArticles(newsJsonString);

          _cachedArticlesByLang[_currentLanguageCode] = parsedArticles;

          SharedPreferences.getInstance().then((prefs) {
            prefs.setString(_cacheKey, newsJsonString);
            prefs.setInt(_timestampKey, DateTime
                .now()
                .millisecondsSinceEpoch);
          });

          debugPrint("[NewsService] ✅ Success!");
          _setState(NewsState.success, "network_fetch");
          return;
        } else {
          throw Exception('Download failed status: ${newsResponse.statusCode}');
        }
      } catch (e) {
        debugPrint("[NewsService] ❌ Attempt $attempts failed: $e");

        if (attempts >= maxAttempts) rethrow;

        await Future.delayed(Duration(seconds: attempts));
      }
    }
  }

  List<NewsArticle> _parseAndValidateArticles(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      final allArticles = jsonData.map((json) =>
          NewsArticle.fromJson(json as Map<String, dynamic>)).toList();
      return allArticles.where((article) => article.isValid).toList();
    } catch (e) {
      throw Exception('Failed to parse news articles: $e');
    }
  }

  void _handleError(String message, Object e, StackTrace s) {
    debugPrint(
        '[NewsService] 💥 FINAL ERROR for "$_currentLanguageCode": $message -> $e');
    _languagesWithFetchErrors.add(_currentLanguageCode);

    if (!_cachedArticlesByLang.containsKey(_currentLanguageCode)) {
      _cachedArticlesByLang[_currentLanguageCode] = [];
    }
    _setState(NewsState.success, "error_fallback");
  }

  void _setState(NewsState newState, String source) {
    if (_state == newState) return;
    debugPrint("[NewsService] 🔔 State: $newState ($source). Count: ${articles
        .length}");
    _state = newState;
    notifyListeners();
  }
}