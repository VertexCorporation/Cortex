// lib/chat/screen/unselected/widgets/news/service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../initialization.dart';
import '../../../../../internet.dart';
import 'data.dart';

/// Defines the possible states for the news loading process.
enum NewsState {
  /// The initial state before any loading has begun.
  initial,
  /// The state when news articles are being fetched from the network or cache.
  loading,
  /// The state when news articles have been successfully loaded.
  success,
}

/// A service class responsible for fetching, caching, and managing the state of news articles.
///
/// This class follows the ChangeNotifier pattern to notify UI widgets of state changes.
/// It is decoupled from the UI layer by receiving its dependencies (Dio, AppInitializer)
/// via its constructor, making it highly testable.
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

    debugPrint("[NewsService] Instance created. Awaiting first load command from UI.");
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
      debugPrint("[NewsService] Internet reconnected. Clearing language error cache and checking for retry.");

      final bool shouldRetryCurrentLanguage = _languagesWithFetchErrors.contains(_currentLanguageCode);

      _languagesWithFetchErrors.clear();

      if (shouldRetryCurrentLanguage) {
        debugPrint("[NewsService] Retrying to fetch news for the current language '$_currentLanguageCode' automatically.");
        loadNewsForLanguage(_currentLanguageCode);
      }
    }
  }

  // --- State Management ---

  NewsState _state = NewsState.initial;
  /// The current state of the news loading process.
  NewsState get state => _state;

  /// The list of loaded news articles for the CURRENTLY selected language.
  /// It safely returns an empty list if no data is available for that language.
  List<NewsArticle> get articles => _cachedArticlesByLang[_currentLanguageCode] ?? [];

  // --- Constants ---

  static const String _cacheKey = 'news_cache_data_v3';
  static const String _timestampKey = 'news_cache_timestamp_v3';
  static const String _getCacheUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl";

  // --- Public Methods ---

  /// The new primary method to load news for a specific language.
  /// It first checks the multi-language cache before fetching from the network.
  Future<void> loadNewsForLanguage(String languageCode) async {
    _currentLanguageCode = languageCode;

    if (_cachedArticlesByLang.containsKey(languageCode) && !_languagesWithFetchErrors.contains(languageCode)) {
      debugPrint("[NewsService] Found valid cached articles for '$languageCode'. Showing immediately.");
      _setState(NewsState.success, "loadNewsForLanguage - from lang cache");
      return;
    }

    if (_isLoadingOperation) {
      debugPrint("[NewsService] loadNewsForLanguage SKIPPED: An operation is already in progress.");
      return;
    }
    _isLoadingOperation = true;
    _setState(NewsState.loading, "loadNewsForLanguage - starting fetch for '$languageCode'");

    try {
      await _appInitializer.onCoreServicesReady;

      if (await _loadFromCache()) {
      } else {
        debugPrint("[NewsService] Device cache invalid for '$languageCode'. Fetching from network.");
        await _fetchFromNetworkAndCache();
      }
    } catch (e, s) {
      _handleError('Could not fetch news updates.', e, s);
    } finally {
      _isLoadingOperation = false;
    }
  }

  /// Forces a refresh for the CURRENT language, bypassing all caches.
  Future<void> forceRefreshCurrentLanguage() async {
    if (_isLoadingOperation) {
      debugPrint("[NewsService] forceRefresh SKIPPED: An operation is already in progress.");
      return;
    }
    _isLoadingOperation = true;
    _setState(NewsState.loading, "forceRefreshCurrentLanguage - starting fetch for '$_currentLanguageCode'");

    try {
      await _appInitializer.onCoreServicesReady;
      await _fetchFromNetworkAndCache();
    } catch (e, s) {
      _handleError('Could not refresh news updates.', e, s);
    } finally {
      _isLoadingOperation = false;
    }
  }

  // --- Private Helper Methods ---

  /// Attempts to load and parse news articles from SharedPreferences.
  Future<bool> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt(_timestampKey);

    if (lastFetchTimestamp != null) {
      final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetchTimestamp);
      if (DateTime.now().difference(lastFetchDate).inDays < 7) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          debugPrint("[NewsService] Loading news from valid device cache.");
          final parsedArticles = _parseAndValidateArticles(cachedData);
          _cachedArticlesByLang[_currentLanguageCode] = parsedArticles;
          _setState(NewsState.success, "loadFromCache");
          return true;
        }
      }
    }
    return false;
  }

  /// Fetches news data from the network, parses it, and saves it to caches.
  Future<void> _fetchFromNetworkAndCache() async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user == null) throw Exception("User session could not be established.");

    final idToken = await user.getIdToken();

    final urlResponse = await _dio.post(_getCacheUrlEndpoint,
      data: jsonEncode({'data': null}),
      options: Options(headers: {"Authorization": "Bearer $idToken", "Content-Type": "application/json"}),
    );

    if (urlResponse.statusCode != 200 || urlResponse.data == null) throw Exception("Failed to get cache URL.");
    final String? signedUrl = urlResponse.data['result']?['signedUrl'];
    if (signedUrl == null) throw Exception("Backend did not return a 'signedUrl'.");

    final newsResponse = await _dio.get(signedUrl, options: Options(responseType: ResponseType.bytes));

    if (newsResponse.statusCode == 200 && newsResponse.data != null) {
      final newsJsonString = utf8.decode(newsResponse.data as List<int>);
      final parsedArticles = _parseAndValidateArticles(newsJsonString);

      _cachedArticlesByLang[_currentLanguageCode] = parsedArticles;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, newsJsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint("[NewsService] Successfully fetched and cached new news data.");
      _setState(NewsState.success, "fetchFromNetwork");
    } else {
      throw Exception('Failed to load news content. Status: ${newsResponse.statusCode}');
    }
  }

  /// Parses the JSON string and filters out any invalid articles.
  List<NewsArticle> _parseAndValidateArticles(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      final allArticles = jsonData.map((json) => NewsArticle.fromJson(json as Map<String, dynamic>)).toList();

      final validArticles = allArticles.where((article) => article.isValid).toList();

      if (allArticles.length != validArticles.length) {
        debugPrint("[NewsService] Filtered out ${allArticles.length - validArticles.length} invalid articles.");
      }
      return validArticles;
    } catch (e) {
      throw Exception('Failed to parse news articles: $e');
    }
  }

  /// Handles errors by setting state to success with an empty list for the current language,
  /// preserving data for other languages.
  void _handleError(String message, Object e, StackTrace s) {
    debugPrint('[NewsService] ERROR for language "$_currentLanguageCode": $message. Exception: $e');

    _languagesWithFetchErrors.add(_currentLanguageCode);

    _cachedArticlesByLang[_currentLanguageCode] = [];

    _setState(NewsState.success, "handleError - failing silently for '$_currentLanguageCode'");
  }

  /// A centralized method for updating the state and notifying listeners with logging.
  /// It now prevents unnecessary notifications if the state hasn't actually changed.
  void _setState(NewsState newState, String source) {
    // If the new state is the same as the current state,
    // there is no reason to notify listeners and trigger a UI rebuild.
    // This is a core optimization that prevents unnecessary redraw cycles.
    if (_state == newState) {
      debugPrint("[NewsService] State is already $newState. No notification needed. (Source: $source)");
      return;
    }

    debugPrint("[NewsService] State changed from $_state to: $newState. Triggered by: $source");
    _state = newState;
    notifyListeners();
  }
}