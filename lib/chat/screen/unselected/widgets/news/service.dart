// lib/screen/unselected/news/service.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../../initialization.dart';
import 'news.dart';

/// Defines the possible states for the news loading process.
enum NewsState {
  /// The initial state before any loading has begun.
  initial,
  /// The state when news articles are being fetched from the network or cache.
  loading,
  /// The state when news articles have been successfully loaded.
  success,
  /// The state when an error occurred during the loading process.
  error,
}

/// A service class responsible for fetching, caching, and managing the state of news articles.
///
/// This class follows the ChangeNotifier pattern to notify UI widgets of state changes.
/// It is decoupled from the UI layer by receiving its dependencies (Dio, AppInitializer)
/// via its constructor, making it highly testable.
class NewsService with ChangeNotifier {
  final Dio _dio;
  final AppInitializer _appInitializer;

  /// Private constructor for dependency injection.
  NewsService({
    required Dio dio,
    required AppInitializer appInitializer,
  })  : _dio = dio,
        _appInitializer = appInitializer;

  // --- State Management ---

  NewsState _state = NewsState.initial;
  /// The current state of the news loading process.
  NewsState get state => _state;

  List<NewsArticle> _articles = [];
  /// The list of loaded news articles. This list is empty until the state is `success`.
  List<NewsArticle> get articles => _articles;

  String _errorMessage = '';
  /// The error message, only relevant when the state is `error`.
  String get errorMessage => _errorMessage;

  // --- Constants ---

  static const String _cacheKey = 'news_cache_data_v3';
  static const String _timestampKey = 'news_cache_timestamp_v3';
  static const String _getCacheUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl";

  // --- Public Methods ---

  /// Loads news articles, utilizing a 7-day cache to avoid unnecessary network requests.
  ///
  /// This is the primary method to be called by the UI to fetch news.
  /// It first checks for valid cached data before fetching from the network.
  Future<void> loadNews() async {
    // If articles are already loaded and the state is success, do nothing.
    if (_state == NewsState.success && _articles.isNotEmpty) {
      return;
    }

    _setState(NewsState.loading);

    try {
      // Ensure core services like Firebase are ready before any operation.
      await _appInitializer.onCoreServicesReady;

      // Attempt to load from cache first.
      final bool loadedFromCache = await _loadFromCache();
      if (loadedFromCache) {
        _setState(NewsState.success);
        return;
      }

      // If cache is invalid or missing, fetch from the network.
      debugPrint("[NewsService] Cache invalid or empty. Fetching from network.");
      await _fetchFromNetworkAndCache();
      _setState(NewsState.success);

    } catch (e, s) {
      _handleError('Could not fetch news updates.', e, s);
    }
  }

  /// Forces a refresh of the news articles, bypassing the cache.
  ///
  /// This is useful for "pull-to-refresh" actions or after a significant app
  /// event like a language change.
  Future<void> forceRefresh() async {
    debugPrint("[NewsService] Force refresh triggered.");
    _setState(NewsState.loading);

    try {
      await _appInitializer.onCoreServicesReady;
      await _fetchFromNetworkAndCache();
      _setState(NewsState.success);
    } catch (e, s) {
      _handleError('Could not refresh news updates.', e, s);
    }
  }

  // --- Private Helper Methods ---

  /// Attempts to load and parse news articles from SharedPreferences.
  /// Returns `true` if loading from cache was successful, `false` otherwise.
  Future<bool> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt(_timestampKey);

    if (lastFetchTimestamp != null) {
      final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetchTimestamp);
      if (DateTime.now().difference(lastFetchDate).inDays < 7) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          debugPrint("[NewsService] Loading news from valid cache.");
          _parseAndSetArticles(cachedData);
          return true;
        }
      }
    }
    return false;
  }

  /// Fetches news data from the network, parses it, and saves it to the cache.
  /// Throws an exception if any step of the process fails.
  Future<void> _fetchFromNetworkAndCache() async {
    final user = await FirebaseAuth.instance.authStateChanges().first;
    if (user == null) {
      throw Exception("User session could not be established for news fetch.");
    }
    final idToken = await user.getIdToken();

    // 1. Get the signed URL for the news JSON file.
    final urlResponse = await _dio.post(
      _getCacheUrlEndpoint,
      data: jsonEncode({'data': null}),
      options: Options(headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json",
      }),
    );

    if (urlResponse.statusCode != 200 || urlResponse.data == null) {
      throw Exception("Failed to get cache URL. Status: ${urlResponse.statusCode}");
    }
    final String? signedUrl = urlResponse.data['result']?['signedUrl'];
    if (signedUrl == null) {
      throw Exception("Backend did not return a 'signedUrl'.");
    }

    // 2. Fetch the actual news content using the signed URL.
    final newsResponse = await _dio.get(
      signedUrl,
      options: Options(responseType: ResponseType.bytes),
    );

    if (newsResponse.statusCode == 200 && newsResponse.data != null) {
      final newsJsonString = utf8.decode(newsResponse.data as List<int>);
      _parseAndSetArticles(newsJsonString);

      // 3. Cache the new data successfully.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, newsJsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint("[NewsService] Successfully fetched and cached new news data.");
    } else {
      throw Exception('Failed to load news content. Status: ${newsResponse.statusCode}');
    }
  }

  /// Parses the JSON string into a list of [NewsArticle] objects.
  /// Throws an exception if parsing fails.
  void _parseAndSetArticles(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      _articles = jsonData
          .map((json) => NewsArticle.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Re-throw a more specific error to be caught by the calling method.
      throw Exception('Failed to parse news articles: $e');
    }
  }

  /// A centralized method for handling errors.
  void _handleError(String message, Object e, StackTrace s) {
    debugPrint('[NewsService] An error occurred: $e\n$s');
    _errorMessage = message;
    _articles = [];
    _setState(NewsState.error);
  }

  /// A centralized method for updating the state and notifying listeners.
  void _setState(NewsState newState) {
    _state = newState;
    notifyListeners();
  }
}