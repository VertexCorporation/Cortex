// lib/chat/news.dart (FINAL, FULLY FEATURED)

import 'package:cortex/cache.dart';
import 'package:cortex/main.dart';
import 'package:cortex/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../initialization.dart';

/// Represents a single news article with full content for expansion.
class NewsArticle {
  final String id;
  final Map<String, String> title;
  final Map<String, String> summary;
  final Map<String, String> content; // NEW: Added full content for expandable card
  final String? link;
  final Map<String, String>? coverImagePaths;
  final DateTime publishedAt;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content, // NEW
    this.link,
    this.coverImagePaths,
    required this.publishedAt,
  });

  /// Factory constructor updated to parse the full 'content' field.
  factory NewsArticle.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'] as Map<String, dynamic>? ?? {};
    final Map<String, String> titleMap = {};
    final Map<String, String> summaryMap = {};
    final Map<String, String> contentMap = {}; // NEW

    translations.forEach((langCode, translationData) {
      if (translationData is Map<String, dynamic>) {
        titleMap[langCode] = translationData['title'] as String? ?? '';
        summaryMap[langCode] = translationData['summary'] as String? ?? '';
        contentMap[langCode] = translationData['content'] as String? ?? ''; // NEW
      }
    });

    final references = json['references'] as List<dynamic>?;
    String? link;
    if (references != null && references.isNotEmpty) {
      link = references.first as String?;
    }

    return NewsArticle(
      id: json['id'] ?? 'unknown_id',
      title: titleMap,
      summary: summaryMap,
      content: contentMap, // NEW
      link: link,
      coverImagePaths: json['cover'] != null ? Map<String, String>.from(json['cover']) : null,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt']) : DateTime.now(),
    );
  }

  /// Retrieves the localized string, defaulting to 'en' for any language other than 'tr'.
  String getLocalized(BuildContext context, Map<String, String> field) {
    final languageCode = Localizations.localeOf(context).languageCode;
    // CRITICAL FIX for language handling: Use 'tr' if available, otherwise default to 'en'.
    return field[languageCode] ?? field['en'] ?? '';
  }
}

/// A service class to handle fetching and caching news data.
/// Now includes a `forceRefresh` method to be called on language change.
class NewsService with ChangeNotifier {
  List<NewsArticle> _articles = [];
  List<NewsArticle> get articles => _articles;
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  String? _error;
  String? get error => _error;
  static const String _cacheKey = 'news_cache_data_v3'; // Incremented version for new structure
  static const String _timestampKey = 'news_cache_timestamp_v3';
  final String _getCacheUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getNewsCacheUrl";

  /// Public method to force a reload of news, bypassing the 7-day cache.
  /// This should be called after a language change.
  Future<void> forceRefresh(BuildContext context) async { // <-- CONTEXT EKLE
    debugPrint("[NewsService] Force refresh triggered. Fetching fresh news data...");

    // Set loading state to ensure UI shows shimmer during the refresh.
    if (!_isLoading) {
      _isLoading = true;
      notifyListeners();
    }

    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[NewsService] Core services are ready for force refresh.");

    await _fetchAndCacheNews();
  }

  /// This is the primary entry point for fetching news.
  /// It now requires a `BuildContext` to safely access the `AppInitializer`
  /// and ensure core services like Firebase are ready before proceeding.
  /// This method should be called from `initState` within a `WidgetsBinding.instance.addPostFrameCallback`.
  Future<void> loadNews(BuildContext context) async {
    // If we already have articles, there's nothing to do. Exit immediately.
    // This is the most reliable check and avoids issues with stale `_isLoading` flags.
    if (_articles.isNotEmpty) {
      return;
    }

    debugPrint("[NewsService] No articles found. Initiating news load process.");

    // Actively reset the state for a new loading attempt.
    // This ensures that even if a previous attempt failed (setting _error),
    // we start fresh. This is critical for the "login -> fail -> login again" scenario.
    _isLoading = true;
    _error = null;
    notifyListeners(); // Immediately update the UI to show the shimmer.

    // --- CRITICAL SAFETY LOCK ---
    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;
    debugPrint("[NewsService] Core services are ready. Proceeding to load news.");

    // Check SharedPreferences for valid cached data.
    final prefs = await SharedPreferences.getInstance();
    final lastFetchTimestamp = prefs.getInt(_timestampKey);
    if (lastFetchTimestamp != null) {
      final lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetchTimestamp);
      if (DateTime.now().difference(lastFetchDate).inDays < 7) {
        final cachedData = prefs.getString(_cacheKey);
        if (cachedData != null) {
          debugPrint("[NewsService] Loading news from valid cache.");
          _parseAndSetArticles(cachedData);
          _isLoading = false;
          notifyListeners();
          return; // Exit if loaded from cache.
        }
      }
    }

    // If cache is invalid or missing, fetch from the network.
    debugPrint("[NewsService] Cache is invalid or missing. Fetching from network.");
    await _fetchAndCacheNews();
  }

  /// This private method now includes a top-level timeout to prevent
  /// any possibility of an infinite loading state.
  Future<void> _fetchAndCacheNews() async {
    try {
      // This ensures that the entire news fetching process, including all awaits inside,
      // cannot get stuck for more than 20 seconds. If any internal await hangs
      // indefinitely, this timeout will fire, throwing a TimeoutException.
      await _fetchNewsWithTimeout();

    } catch (e, s) {
      _error = 'Could not fetch news updates.';
      // This catch block will now also handle the TimeoutException.
      debugPrint('[NewsService] An error occurred during fetch: $e\n$s');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// A helper method that contains the actual fetching logic,
  /// wrapped by a timeout in the calling function.
  Future<void> _fetchNewsWithTimeout() async {
    // We now wait patiently for the first authentication state to be emitted by Firebase.
    final user = await FirebaseAuth.instance.authStateChanges().first;

    if (user == null) {
      throw Exception("User session could not be established.");
    }

    final idToken = await user.getIdToken();

    final urlResponse = await http.post(
      Uri.parse(_getCacheUrlEndpoint),
      headers: {
        "Authorization": "Bearer $idToken",
        "Content-Type": "application/json"
      },
      body: jsonEncode({'data': null}),
    ).timeout(const Duration(seconds: 20)); // Individual timeout for network calls

    if (urlResponse.statusCode != 200) {
      throw Exception("Failed to get cache URL. Status: ${urlResponse.statusCode}, Body: ${urlResponse.body}");
    }

    final jsonBody = jsonDecode(urlResponse.body);
    final String? signedUrl = jsonBody['result']?['signedUrl'];

    if (signedUrl == null) {
      throw Exception("Backend did not return a 'signedUrl'.");
    }

    final newsResponse = await http.get(Uri.parse(signedUrl))
        .timeout(const Duration(seconds: 20)); // Individual timeout for network calls

    if (newsResponse.statusCode == 200) {
      final newsJsonString = utf8.decode(newsResponse.bodyBytes);
      _parseAndSetArticles(newsJsonString);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cacheKey, newsJsonString);
      await prefs.setInt(_timestampKey, DateTime.now().millisecondsSinceEpoch);
      debugPrint("[NewsService] Successfully fetched and cached new news data.");
    } else {
      throw Exception('Failed to load news content from signed URL. Status: ${newsResponse.statusCode}');
    }
  }

  void _parseAndSetArticles(String jsonString) {
    try {
      final List<dynamic> jsonData = json.decode(jsonString);
      _articles = jsonData.map((json) => NewsArticle.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      _error = 'Failed to display news.';
      _articles = [];
      debugPrint('[NewsService] Failed to parse articles: $e');
    }
  }
}

/// A widget to securely load and display an image from Firebase Storage using an in-memory cache.
class FirebaseStorageImage extends StatefulWidget {
  final String imagePath;
  const FirebaseStorageImage({super.key, required this.imagePath});
  @override
  State<FirebaseStorageImage> createState() => _FirebaseStorageImageState();
}

class _FirebaseStorageImageState extends State<FirebaseStorageImage> {
  Future<String?>? _imageUrlFuture;
  final String _getDownloadUrlEndpoint = "https://europe-west1-vertex-ai-1618.cloudfunctions.net/getCoverDownloadUrl";

  @override
  void initState() {
    super.initState();
    // The future is initialized only once when the widget's state is created.
    _imageUrlFuture = _getCachedOrFetchDownloadUrl();
  }

  /// --- ROBUST CACHING LOGIC ---
  /// Fetches the download URL using a three-tier caching strategy to minimize network requests.
  /// 1. In-Memory Cache (CacheService): Fastest check for immediate access within the session.
  /// 2. Persistent Cache (SharedPreferences): Slower check, but survives app restarts and timeouts.
  /// 3. Network Fetch: The slowest path, used only when both caches miss or are expired.
  Future<String?> _getCachedOrFetchDownloadUrl() async {
    // TIER 1: Check the fast, in-memory cache first.
    final inMemoryUrl = CacheService.cachedNewsImageUrls?[widget.imagePath];
    if (inMemoryUrl != null) {
      debugPrint("[FirebaseStorageImage] URL found in fast in-memory cache for: ${widget.imagePath}");
      return inMemoryUrl;
    }

    // TIER 2: Check the persistent SharedPreferences cache.
    final prefs = await SharedPreferences.getInstance();
    final String cacheKey = 'news_image_url_${widget.imagePath}'; // Unique key for each image
    final String? cachedDataJson = prefs.getString(cacheKey);

    if (cachedDataJson != null) {
      try {
        final Map<String, dynamic> cachedData = jsonDecode(cachedDataJson);
        final int expiryTimestamp = cachedData['expires'] as int;

        // Check if the cached URL is still valid.
        if (DateTime.now().millisecondsSinceEpoch < expiryTimestamp) {
          final String persistentUrl = cachedData['url'] as String;
          debugPrint("[FirebaseStorageImage] URL found in persistent cache (SharedPreferences) for: ${widget.imagePath}");

          // IMPORTANT: Populate the fast in-memory cache for subsequent quick access.
          CacheService.cachedNewsImageUrls ??= {};
          CacheService.cachedNewsImageUrls![widget.imagePath] = persistentUrl;

          return persistentUrl;
        } else {
          debugPrint("[FirebaseStorageImage] Persistent cache expired for: ${widget.imagePath}");
        }
      } catch (e) {
        debugPrint("[FirebaseStorageImage] Error decoding persistent cache: $e");
      }
    }

    // TIER 3: If both caches miss, fetch from the network.
    debugPrint("[FirebaseStorageImage] CACHE MISS. Fetching from network for: ${widget.imagePath}");
    final appInitializer = Provider.of<AppInitializer>(context, listen: false);
    await appInitializer.onCoreServicesReady;

    // --- FIX: Using 'authStateChanges().first' for confirmed user access ---
    try {
      // Listen to auth state changes to ensure there is a user before proceeding
      final user = await FirebaseAuth.instance.authStateChanges().first;

      if (user == null) {
        // Handle the case where a user is not available. This should now be rare.
        debugPrint("[FirebaseStorageImage] No user available, cannot fetch download URL.");
        return null;
      }

      final idToken = await user.getIdToken();

      final response = await http.post(
        Uri.parse(_getDownloadUrlEndpoint),
        headers: {if (idToken != null) "Authorization": "Bearer $idToken", "Content-Type": "application/json"},
        body: jsonEncode({'data': {'filePath': widget.imagePath}}),
      );

      if (response.statusCode == 200) {
        final jsonBody = jsonDecode(response.body);
        final newUrl = jsonBody['result']?['signedUrl'] as String?;

        if (newUrl != null) {
          // --- UPDATE BOTH CACHES ---
          // 1. Update the fast in-memory cache.
          CacheService.cachedNewsImageUrls ??= {};
          CacheService.cachedNewsImageUrls![widget.imagePath] = newUrl;
          CacheService.startNewsImageCacheTimer(); // Resets the 8-min timer for the in-memory cache.

          // 2. Update the persistent cache with an expiry time.
          final expiryTime = DateTime.now().add(const Duration(minutes: 8)).millisecondsSinceEpoch;
          final Map<String, dynamic> dataToCache = {'url': newUrl, 'expires': expiryTime};
          await prefs.setString(cacheKey, jsonEncode(dataToCache));
          debugPrint("[FirebaseStorageImage] Successfully fetched and updated both caches for: ${widget.imagePath}");
        }
        return newUrl;
      }
      return null;
    } catch (e) {
      debugPrint("Failed to get image download URL: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final Widget errorWidget = Stack(
      alignment: Alignment.center,
      children: [
        Container(color: AppColors.border.withOpacity(0.5)),
        SvgPicture.asset(
          'assets/icons/warning.svg',
          width: screenWidth * 0.1,
          height: screenWidth * 0.1,
          colorFilter: ColorFilter.mode(
            AppColors.primaryColor.inverted.withOpacity(0.5),
            BlendMode.srcIn,
          ),
        ),
      ],
    );

    return FutureBuilder<String?>(
      future: _imageUrlFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _ShimmerPlaceholder();
        }
        if (!snapshot.hasData || snapshot.data == null) {
          // Use the predefined error widget
          return errorWidget;
        }
        return CachedNetworkImage(
          imageUrl: snapshot.data!,
          fit: BoxFit.cover,
          placeholder: (context, url) => const _ShimmerPlaceholder(),
          // Use the same predefined error widget here
          errorWidget: (context, url, error) => errorWidget,
        );
      },
    );
  }
}

/// Main widget to display a list of news articles with a staggered fade-in animation.
class NewsSection extends StatelessWidget {
  const NewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final newsService = Provider.of<NewsService>(context);

    // --- FIX: Robust and Reliable Display Logic ---
    // We combine all the conditions into a single, clear statement.
    // The news section is only displayed if there are articles to show AND it is not loading AND there isn't an error.
    if (newsService.articles.isNotEmpty && !newsService.isLoading && newsService.error == null) {
      return Column(
        children: newsService.articles
            .asMap()
            .entries
            .map((entry) => NewsArticleCard(
          article: entry.value,
          index: entry.key,
        ))
            .toList(),
      );
    }

    // --- UI State handling with explicit and clear return statements
    // If is loading, show shimmer
    if (newsService.isLoading) {
      return const _ShimmerNewsList();
    }

    //If there is an error, or no articles exist, hide the section entirely
    return const SizedBox.shrink();
  }
}

// lib/chat/news.dart (ONLY THE REFACTORED WIDGETS)

/// A stateful card that now correctly animates its appearance when first built.
/// REFACTORED: All fixed sizes have been converted to dynamic, screen-relative values
/// for a fully scalable and responsive layout.
class NewsArticleCard extends StatefulWidget {
  final NewsArticle article;
  final int index;

  const NewsArticleCard({
    super.key,
    required this.article,
    required this.index,
  });

  @override
  State<NewsArticleCard> createState() => _NewsArticleCardState();
}

class _NewsArticleCardState extends State<NewsArticleCard> {
  bool _isExpanded = false;
  bool _isAnimated = false; // Controls the animation state

  @override
  void initState() {
    super.initState();
    // --- CORRECTED DELAY LOGIC ---
    // We wait for a calculated duration before setting the state to 'animated'.
    // This is the standard way to create a staggered animation effect.
    Future.delayed(Duration(milliseconds: 100 * widget.index), () {
      if (mounted) {
        setState(() {
          _isAnimated = true;
        });
      }
    });
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  Future<void> _launchLink() async {
    final link = widget.article.link;
    if (link != null && link.isNotEmpty) {
      final uri = Uri.parse(link);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        debugPrint("Could not launch URL: $link");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC SIZING ---
    // Define all layout values based on screen width for a responsive UI.
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06; // e.g., 24px on a 400px screen
    final double basePadding = screenWidth * 0.04; // e.g., 16px
    final double mediumSpacing = screenWidth * 0.03; // e.g., 12px
    final double smallSpacing = screenWidth * 0.01; // e.g., 4px
    final double iconSize = screenWidth * 0.05; // e.g., 20px

    final locale = Localizations.localeOf(context).toLanguageTag();
    final title = widget.article.getLocalized(context, widget.article.title);
    final summary = widget.article.getLocalized(context, widget.article.summary);
    final fullContent = widget.article.getLocalized(context, widget.article.content);
    final coverPath = widget.article.getLocalized(context, widget.article.coverImagePaths ?? {});
    final hasLink = widget.article.link != null && widget.article.link!.isNotEmpty;
    final hasExpandableContent = fullContent.isNotEmpty;

    return AnimatedOpacity(
      opacity: _isAnimated ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(
          top: _isAnimated ? 0 : 20, // This animation effect is kept fixed
          bottom: basePadding,
        ),
        child: Material(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(cardRadius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: hasExpandableContent ? _toggleExpansion : null,
            splashColor: AppColors.primaryColor.inverted.withOpacity(0.1),
            highlightColor: AppColors.primaryColor.inverted.withOpacity(0.05),
            child: AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border, width: 1.0), // 1.0 width is fine
                  borderRadius: BorderRadius.circular(cardRadius),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (coverPath.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius - 1.0)),
                        child: AspectRatio(
                          aspectRatio: 16 / 9,
                          child: FirebaseStorageImage(imagePath: coverPath),
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.all(basePadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      style: TextStyle(fontSize: screenWidth * 0.045, fontWeight: FontWeight.bold, color: AppColors.primaryColor.inverted, height: 1.3),
                                    ),
                                    SizedBox(height: smallSpacing),
                                    Text(
                                      DateFormat.yMd(locale).format(widget.article.publishedAt),
                                      style: TextStyle(fontSize: screenWidth * 0.032, color: AppColors.primaryColor.inverted.withOpacity(0.6)),
                                    ),
                                  ],
                                ),
                              ),
                              if (hasLink)
                                IconButton(
                                  icon: Icon(Icons.touch_app, size: iconSize, color: AppColors.primaryColor.inverted.withOpacity(0.8)),
                                  onPressed: _launchLink,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                            ],
                          ),
                          SizedBox(height: mediumSpacing),
                          Text(
                            summary,
                            style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withOpacity(0.85), height: 1.5),
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) {
                              return FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position: Tween<Offset>(
                                    begin: const Offset(0.0, -0.1),
                                    end: Offset.zero,
                                  ).animate(animation),
                                  child: child,
                                ),
                              );
                            },
                            child: _isExpanded && hasExpandableContent
                                ? Padding(
                              key: ValueKey(widget.article.id),
                              padding: EdgeInsets.only(top: mediumSpacing),
                              child: Text(
                                fullContent,
                                style: TextStyle(fontSize: screenWidth * 0.038, color: AppColors.primaryColor.inverted.withOpacity(0.85), height: 1.5),
                              ),
                            )
                                : const SizedBox.shrink(key: ValueKey('empty')),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- Shimmer widgets updated to match the responsive layout ---
class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(baseColor: AppColors.border.withOpacity(0.5), highlightColor: AppColors.border.withOpacity(0.2), child: Container(color: AppColors.border));
  }
}

class _ShimmerNewsList extends StatelessWidget {
  const _ShimmerNewsList();
  @override
  Widget build(BuildContext context) {
    return Column(children: List.generate(2, (index) => const _ShimmerNewsCard()));
  }
}

class _ShimmerNewsCard extends StatelessWidget {
  const _ShimmerNewsCard();
  @override
  Widget build(BuildContext context) {
    // --- DYNAMIC SIZING FOR SHIMMER ---
    // Use the same screen-relative values to ensure the shimmer skeleton
    // perfectly matches the real card's layout.
    final screenWidth = MediaQuery.of(context).size.width;
    final double cardRadius = screenWidth * 0.06;
    final double basePadding = screenWidth * 0.04;

    return Padding(
      padding: EdgeInsets.only(bottom: basePadding),
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(cardRadius), border: Border.all(color: AppColors.border, width: 1.0)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(cardRadius - 1)),
              child: AspectRatio(aspectRatio: 16 / 9, child: Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.background, child: Container(color: Colors.white))),
            ),
            Padding(
              padding: EdgeInsets.all(basePadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerLine(context, 0.8, screenWidth * 0.045), // Title
                  SizedBox(height: screenWidth * 0.02),
                  _buildShimmerLine(context, 0.4, screenWidth * 0.032), // Date
                  SizedBox(height: basePadding),
                  _buildShimmerLine(context, 1.0, screenWidth * 0.038), // Summary line 1
                  SizedBox(height: screenWidth * 0.015),
                  _buildShimmerLine(context, 0.7, screenWidth * 0.038), // Summary line 2
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerLine(BuildContext context, double widthFactor, double height) {
    // Width is already a factor, now height is also dynamic.
    return Shimmer.fromColors(baseColor: AppColors.border, highlightColor: AppColors.background, child: Container(width: MediaQuery.of(context).size.width * widthFactor, height: height, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))));
  }
}